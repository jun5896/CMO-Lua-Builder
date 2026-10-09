#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createAdapterTransport } from '../src/lib/adapterTransport.js';
import { once } from 'node:events';
import { readFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import path from 'node:path';

const ADAPTER_PORT = 8769;

const adapterFetch = createAdapterTransport(`http://127.0.0.1:${ADAPTER_PORT}`);

function startAdapter() {
  const proc = spawn(process.execPath, ['server/ai-provider-adapter.mjs'], {
    cwd: path.resolve('.'),
    env: {
      ...process.env,
      PORT: String(ADAPTER_PORT),
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

async function postStateSnapshot(body) {
  const response = await adapterFetch(`http://127.0.0.1:${ADAPTER_PORT}/api/cmo/state-snapshot/import`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await response.json();
  return { status: response.status, json };
}

function assertNoRawOrLuaBody(value, label = 'response') {
  if (!value || typeof value !== 'object') return;
  assert.equal(Object.hasOwn(value, 'raw'), false, `${label} must not expose raw parser blocks`);
  assert.equal(Object.hasOwn(value, 'luaScript'), false, `${label} must not expose full luaScript`);
  assert.equal(Object.hasOwn(value, 'luaScripts'), false, `${label} must not expose full luaScripts`);

  if (Array.isArray(value)) {
    value.forEach((item, index) => assertNoRawOrLuaBody(item, `${label}[${index}]`));
    return;
  }

  for (const [key, child] of Object.entries(value)) {
    assertNoRawOrLuaBody(child, `${label}.${key}`);
  }
}

const sample = `
<EventTriggers>
  <EventTrigger_RegularTime>
    <ID>T1</ID>
    <Description>Every minute</Description>
  </EventTrigger_RegularTime>
</EventTriggers>
<EventActions>
  <EventAction_LuaScript>
    <ID>A1</ID>
    <Description>AI Action</Description>
    <ScriptText>print("state endpoint")</ScriptText>
  </EventAction_LuaScript>
</EventActions>
<SimEvents>
  <SimEvent>
    <ID>E1</ID>
    <Description>Endpoint Event</Description>
    <Triggers><Trigger>T1</Trigger></Triggers>
    <Actions><Action>A1</Action></Actions>
  </SimEvent>
</SimEvents>
C:/Users/dlwls/private/state.txt
Authorization: Bearer abcdefghijklmnop
sk-testsecretvalue
`;

let adapter;
try {
  adapter = startAdapter();
  await waitForAdapter();

  const ok = await postStateSnapshot({
    text: sample,
    sourceHint: 'toolDumpEvents',
    cmoRoot: 'C:/Users/dlwls/malicious-cmo-root',
    logsRoot: 'C:/Users/dlwls/malicious-logs-root',
    scenarioRoot: 'C:/Users/dlwls/malicious-scenario-root',
    luaRoot: 'C:/Users/dlwls/malicious-lua-root',
    filePath: 'C:/Users/dlwls/malicious-file.txt',
    scriptPath: 'C:/Users/dlwls/malicious-script.lua',
  });

  assert.equal(ok.status, 200);
  assert.equal(ok.json.ok, true);
  assert.equal(ok.json.source.live, false);
  assert.equal(ok.json.source.type, 'toolDumpEvents');
  assert.equal(ok.json.summary.eventCount, 1);
  assert.equal(ok.json.events[0].name, 'Endpoint Event');
  assert.equal(ok.json.events[0].luaScriptPreviews.length, 1);
  assertNoRawOrLuaBody(ok.json);

  const encoded = JSON.stringify(ok.json);
  assert.doesNotMatch(encoded, /dlwls/i);
  assert.doesNotMatch(encoded, /malicious/i);
  assert.doesNotMatch(encoded, /Bearer\s+|Authorization:\s*Bearer|sk-testsecretvalue/i);
  assert.doesNotMatch(encoded, /C:\/Users/i);

  const empty = await postStateSnapshot({ text: '' });
  assert.equal(empty.status, 400);
  assert.match(empty.json.errorMessage, /empty/i);

  const oversized = await postStateSnapshot({ text: 'x'.repeat(256 * 1024 + 1) });
  assert.equal(oversized.status, 400);
  assert.match(oversized.json.errorMessage, /too large/i);

  const adapterSource = await readFile('server/ai-provider-adapter.mjs', 'utf8');
  assert.match(adapterSource, /handleCmoStateSnapshotImport/);
  assert.match(adapterSource, /\/api\/cmo\/state-snapshot\/import/);
  assert.doesNotMatch(adapterSource, /body\.(?:cmoRoot|logsRoot|scenarioRoot|luaRoot|filePath|scriptPath)/);
  assert.doesNotMatch(adapterSource, /sendCmoAiPrompt|callProvider\([^)]*stateSnapshot/i);

  const logs = adapter.getLogs();
  assert.match(logs, /cmo state snapshot import -> 1 events/);
  assert.doesNotMatch(logs, /dlwls|malicious|Bearer\s+|sk-/i);

  console.log('PASS - CMO state snapshot endpoint contract holds.');
} finally {
  if (adapter?.proc && !adapter.proc.killed) {
    adapter.proc.kill('SIGTERM');
    await Promise.race([once(adapter.proc, 'exit'), new Promise((resolve) => setTimeout(resolve, 1000))]).catch(() => {});
  }
}
