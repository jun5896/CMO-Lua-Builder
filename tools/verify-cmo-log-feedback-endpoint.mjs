#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createAdapterTransport } from '../src/lib/adapterTransport.js';
import { once } from 'node:events';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';

const ADAPTER_PORT = 8768;
const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-log-feedback-endpoint-'));

const adapterFetch = createAdapterTransport(`http://127.0.0.1:${ADAPTER_PORT}`);

function startAdapter() {
  const proc = spawn(process.execPath, ['server/ai-provider-adapter.mjs'], {
    cwd: path.resolve('.'),
    env: {
      ...process.env,
      PORT: String(ADAPTER_PORT),
      CMO_LOGS_ROOT: tmp,
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let logs = '';
  proc.stdout.on('data', (chunk) => { logs += chunk.toString(); });
  proc.stderr.on('data', (chunk) => { logs += chunk.toString(); });
  return { proc, getLogs: () => logs };
}

async function waitForAdapter() {
  const started = Date.now();
  while (Date.now() - started < 5000) {
    try {
      const response = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/health`);
      if (response.ok) return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
  }
  throw new Error('adapter did not start');
}

async function getLogFeedback(query = '') {
  const response = await adapterFetch(`http://127.0.0.1:${ADAPTER_PORT}/api/cmo/log-feedback${query}`);
  const json = await response.json();
  return { status: response.status, json };
}

let adapter;
try {
  const adapterSource = await readFile('server/ai-provider-adapter.mjs', 'utf8');
  assert.match(adapterSource, /handleCmoLogFeedback/);
  assert.match(adapterSource, /\/api\/cmo\/log-feedback/);
  assert.doesNotMatch(adapterSource, /searchParams\.get\(['"]logsRoot['"]\)/);
  assert.doesNotMatch(adapterSource, /sendCmoAiPrompt|callProvider\([^)]*logFeedback/i);

  await writeFile(
    path.join(tmp, 'ExceptionLog_2026_05_11.txt'),
    [
      String.raw`2026-05-11T03:00:00.000Z old line C:\Users\dlwls\old.lua`,
      String.raw`2026-05-11T04:00:00.000Z Lua error at C:\Users\dlwls\AiAssist\bad.lua Authorization: Bearer secretvalue`,
      '',
    ].join('\r\n'),
    'utf8',
  );
  await writeFile(
    path.join(tmp, 'LuaHistory_2026_05_11_040000.txt'),
    [
      'ScenEdit_RunScript("/AiAssist/AiAssist_20260511_test.lua")',
      'print("endpoint history")',
      '',
    ].join('\r\n'),
    'utf8',
  );

  adapter = startAdapter();
  await waitForAdapter();

  const all = await getLogFeedback('?kind=all&since=2026-05-11T03:30:00.000Z&limit=10&maxBytes=12000&logsRoot=C:\\malicious');
  assert.equal(all.status, 200);
  assert.equal(all.json.ok, true);
  assert.equal(all.json.logsRootConfigured, true);
  assert.equal(all.json.kind, 'all');
  assert.equal(all.json.files.some((file) => file.kind === 'exception'), true);
  assert.equal(all.json.files.some((file) => file.kind === 'lua-history'), true);
  assert.match(JSON.stringify(all.json), /Lua error/);
  assert.doesNotMatch(JSON.stringify(all.json), /old line/);
  assert.doesNotMatch(JSON.stringify(all.json), /dlwls/i);
  assert.doesNotMatch(JSON.stringify(all.json), /Bearer secretvalue/i);
  assert.doesNotMatch(JSON.stringify(all.json), /C:\\malicious/i);
  assert.match(all.json.followUpDraft, /Do not invent/i);

  const luaOnly = await getLogFeedback('?kind=lua-history&limit=5');
  assert.equal(luaOnly.status, 200);
  assert.equal(luaOnly.json.files.every((file) => file.kind === 'lua-history'), true);

  const badKind = await getLogFeedback('?kind=invalid&limit=999&maxBytes=999999');
  assert.equal(badKind.status, 200);
  assert.equal(badKind.json.kind, 'all');
  assert.equal(badKind.json.summary.entriesReturned <= 50, true);

  const logs = adapter.getLogs();
  assert.match(logs, /cmo log feedback all ->/);
  assert.doesNotMatch(logs, /secretvalue|Bearer\s+|sk-/i);

  console.log('PASS - CMO log feedback endpoint contract holds.');
} finally {
  if (adapter?.proc && !adapter.proc.killed) {
    adapter.proc.kill('SIGTERM');
    await Promise.race([once(adapter.proc, 'exit'), new Promise((resolve) => setTimeout(resolve, 1000))]).catch(() => {});
  }
  await rm(tmp, { recursive: true, force: true });
}
