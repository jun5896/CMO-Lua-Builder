#!/usr/bin/env node
import assert from 'node:assert/strict';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';

import {
  INBOX_FILE_NAME,
  INBOX_RUNSCRIPT_PATH,
  buildInboxLua,
  buildInboxStamp,
  buildNoopInboxLua,
  buildPollerInstallerLua,
  publishInbox,
  writeTrustedAiAssistFile,
} from './cmo-ai-bridge.mjs';

async function run() {
  const tmp = await mkdtemp(path.join(tmpdir(), 'cmo-ai-bridge-'));

  try {
    // Inbox stamp is deterministic for identical payload + time.
    const now = new Date('2026-07-04T12:00:00');
    const stampA = buildInboxStamp('print(1)', now);
    const stampB = buildInboxStamp('print(1)', now);
    assert.equal(stampA, stampB);
    assert.match(stampA, /^\d{8}_\d{6}_[0-9a-f]{8}$/);

    // Inbox wrapper carries the guard and the payload.
    const inboxLua = buildInboxLua("print('hello')", stampA);
    assert.match(inboxLua, /aiassist_inbox_stamp/);
    assert.match(inboxLua, /pcall\(function\(\)/);
    assert.match(inboxLua, /print\('hello'\)/);
    assert.match(inboxLua, /aiassist_inbox_result/);

    // Unsafe payloads are rejected by the shared gate.
    assert.throws(() => buildInboxLua("io.open('x')", stampA), /Unsafe Lua/);
    assert.throws(() => buildInboxLua("ScenEdit_RunScript('/x.lua')", stampA), /Unsafe Lua/);
    assert.throws(() => buildInboxLua('', stampA), /required/);
    assert.throws(() => buildInboxLua('print(1)', 'bad stamp!'), /stamp/);

    // Poller installer is the only surface allowed to carry RunScript.
    const installer = buildPollerInstallerLua({ interval: 0 });
    assert.match(installer, /type='RegularTime'/);
    assert.match(installer, /interval=0/);
    assert.ok(installer.includes(`ScenEdit_RunScript('${INBOX_RUNSCRIPT_PATH}')`));
    assert.match(installer, /IsRepeatable=true/);
    assert.throws(() => buildPollerInstallerLua({ interval: 99 }), /interval/);
    assert.throws(() => buildPollerInstallerLua({ interval: 1.5 }), /interval/);

    const uninstaller = buildPollerInstallerLua({ uninstall: true });
    assert.match(uninstaller, /UNINSTALLER/);
    assert.doesNotMatch(uninstaller, /RegularTime/);

    // No-op inbox is safe filler.
    assert.match(buildNoopInboxLua(), /no payload published yet/);

    // publishInbox dry-run writes nothing.
    const dryRun = await publishInbox({ payload: 'print(1)', cmoLuaRoot: tmp });
    assert.equal(dryRun.mode, 'dry-run');
    assert.equal(dryRun.wroteFile, false);
    assert.equal(dryRun.runScriptPath, INBOX_RUNSCRIPT_PATH);
    await assert.rejects(readFile(dryRun.targetFile, 'utf8'));

    // publishInbox write + overwrite both succeed (inbox is a mailbox, not append-only).
    const first = await publishInbox({ payload: 'print(1)', cmoLuaRoot: tmp, write: true });
    assert.equal(first.wroteFile, true);
    assert.ok(first.targetFile.endsWith(INBOX_FILE_NAME));
    const second = await publishInbox({ payload: 'print(2)', cmoLuaRoot: tmp, write: true });
    assert.equal(second.wroteFile, true);
    const finalContent = await readFile(second.targetFile, 'utf8');
    assert.match(finalContent, /print\(2\)/);
    assert.doesNotMatch(finalContent, /print\(1\)/);
    assert.notEqual(first.stamp, second.stamp);

    // Trusted writer refuses to clobber an existing one-shot file (wx semantics).
    const trusted = await writeTrustedAiAssistFile({
      content: '-- trusted\n',
      slug: 'contract-test',
      cmoLuaRoot: tmp,
      write: true,
      now: new Date('2026-07-04T12:00:00'),
    });
    assert.equal(trusted.wroteFile, true);
    await assert.rejects(writeTrustedAiAssistFile({
      content: '-- trusted again\n',
      slug: 'contract-test',
      cmoLuaRoot: tmp,
      write: true,
      now: new Date('2026-07-04T12:00:00'),
    }));

    console.log('PASS - CMO AI bridge contract holds.');
  } finally {
    await rm(tmp, { recursive: true, force: true });
  }
}

await run();
