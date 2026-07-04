#!/usr/bin/env node
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {
  DEFAULT_CMO_LOGS_ROOT,
  buildCmoLogFeedback,
  redactCmoLogText,
  resolveCmoLogsRoot,
} from '../server/cmo-log-feedback-reader.mjs';

const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-log-feedback-'));

try {
  const helperSource = await readFile('server/cmo-log-feedback-reader.mjs', 'utf8');
  assert.doesNotMatch(helperSource, /\breadFile\b/, 'helper must not full-read CMO log files');
  assert.doesNotMatch(helperSource, /\b(?:spawn|exec|execFile|fork)\b/, 'helper must not execute processes');
  assert.doesNotMatch(
    helperSource,
    /\b(?:writeFile|appendFile|truncate|unlink|rename)\b/,
    'helper must not modify files',
  );

  const redactionFixture = [
    String.raw`C:\Users\dlwls\secret\bad.lua`,
    'C:/Users/dlwls/secret/bad.lua',
    String.raw`c:\temp\lowercase-drive.lua`,
    String.raw`\\server\share\private\log.txt`,
    String.raw`C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Logs\ExceptionLog_2026_05_10.txt`,
    'Authorization: Bearer abcdefghijklmnop',
    'sk-testsecretvalue',
  ].join(' ');

  const redacted = redactCmoLogText(redactionFixture);
  assert.doesNotMatch(redacted.text, /dlwls/i);
  assert.doesNotMatch(redacted.text, /server\\share/i);
  assert.doesNotMatch(redacted.text, /Command - Modern Operations/i);
  assert.doesNotMatch(redacted.text, /Bearer abcdefgh/i);
  assert.doesNotMatch(redacted.text, /sk-testsecretvalue/i);
  assert.equal(redacted.redactionsApplied >= 5, true);

  const resolved = resolveCmoLogsRoot({ logsRoot: tmp });
  assert.equal(resolved, path.resolve(tmp));
  assert.equal(typeof DEFAULT_CMO_LOGS_ROOT, 'string');

  await mkdir(tmp, { recursive: true });
  await writeFile(
    path.join(tmp, 'ExceptionLog_2026_05_10.txt'),
    [
      String.raw`2026-05-10T04:00:00.000Z old line C:\Users\dlwls\old.lua`,
      String.raw`2026-05-10T05:20:00.000Z Lua execution failed at C:\Users\dlwls\AiAssist\bad.lua`,
      '',
    ].join('\r\n'),
    'utf8',
  );
  await writeFile(
    path.join(tmp, 'LuaHistory_2026_05_10_052000.txt'),
    [
      'ScenEdit_RunScript("/AiAssist/AiAssist_20260510_test.lua")',
      'print("history marker")',
      '',
    ].join('\r\n'),
    'utf8',
  );

  const sinceResult = await buildCmoLogFeedback({
    logsRoot: tmp,
    kind: 'all',
    since: '2026-05-10T05:00:00.000Z',
    limit: 10,
    maxBytes: 12000,
  });

  assert.equal(sinceResult.ok, true);
  assert.equal(sinceResult.logsRootConfigured, true);
  assert.equal(sinceResult.kind, 'all');
  assert.equal(sinceResult.files.some((file) => file.kind === 'exception'), true);
  assert.equal(sinceResult.files.some((file) => file.kind === 'lua-history'), true);
  assert.match(JSON.stringify(sinceResult), /Lua execution failed/);
  assert.doesNotMatch(JSON.stringify(sinceResult), /old line/);
  assert.doesNotMatch(JSON.stringify(sinceResult), /dlwls/i);
  assert.match(sinceResult.followUpDraft, /Do not invent/i);
  assert.equal(sinceResult.summary.entriesReturned <= 10, true);

  const luaOnly = await buildCmoLogFeedback({
    logsRoot: tmp,
    kind: 'lua-history',
    limit: 5,
    maxBytes: 12000,
  });
  assert.equal(luaOnly.files.every((file) => file.kind === 'lua-history'), true);

  const giantPrefix = 'x'.repeat(9000);
  await writeFile(
    path.join(tmp, 'ExceptionLog_2026_05_11.txt'),
    `${giantPrefix}\r\n2026-05-11T01:00:00.000Z last-line: see this\r\n`,
    'utf8',
  );

  const tailed = await buildCmoLogFeedback({
    logsRoot: tmp,
    kind: 'exception',
    limit: 5,
    maxBytes: 4096,
  });
  assert.equal(tailed.files[0].entries.some((entry) => entry.text.includes('last-line: see this')), true);
  assert.equal(
    tailed.files[0].entries.some((entry) => entry.text.includes(giantPrefix.slice(0, 1000))),
    false,
    'must not return the giant prefix',
  );

  const missing = await buildCmoLogFeedback({
    logsRoot: path.join(tmp, 'missing'),
    kind: 'all',
  });
  assert.equal(missing.ok, true);
  assert.equal(missing.logsRootConfigured, false);
  assert.deepEqual(missing.files, []);
  assert.equal(missing.summary.entriesReturned, 0);

  console.log('PASS - CMO log feedback helper contract holds.');
} finally {
  await rm(tmp, { recursive: true, force: true });
}
