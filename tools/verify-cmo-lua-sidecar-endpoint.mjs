#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createAdapterTransport } from '../src/lib/adapterTransport.js';
import { once } from 'node:events';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';

const ADAPTER_PORT = 8767;
const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-lua-sidecar-endpoint-'));

const adapterFetch = createAdapterTransport(`http://127.0.0.1:${ADAPTER_PORT}`);

function startAdapter() {
  const proc = spawn(process.execPath, ['server/ai-provider-adapter.mjs'], {
    cwd: path.resolve('.'),
    env: {
      ...process.env,
      PORT: String(ADAPTER_PORT),
      CMO_LUA_ROOT: tmp,
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

async function postSidecar(body) {
  const response = await adapterFetch(`http://127.0.0.1:${ADAPTER_PORT}/api/cmo/lua-sidecar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await response.json();
  return { status: response.status, json };
}

let adapter;
try {
  adapter = startAdapter();
  await waitForAdapter();

  const dryRun = await postSidecar({
    content: 'print("dry run")',
    fileName: 'AiAssist_20260510_060000_dry-run.lua',
    isPasteReady: true,
    cmoLuaRoot: path.join(tmp, 'malicious-root-ignored'),
  });
  assert.equal(dryRun.status, 200);
  assert.equal(dryRun.json.mode, 'dry-run');
  assert.equal(dryRun.json.wroteFile, false);
  assert.equal(dryRun.json.confirmedDryRun, true);
  assert.equal(dryRun.json.confirmedWrite, false);
  assert.equal(Object.hasOwn(dryRun.json, 'lua'), false);
  assert.equal(dryRun.json.targetFile.startsWith(path.join(tmp, 'AiAssist')), true);
  assert.equal(dryRun.json.targetFile.includes('malicious-root-ignored'), false);
  assert.equal(dryRun.json.loaderSnippet, "ScenEdit_RunScript('/AiAssist/AiAssist_20260510_060000_dry-run.lua')");

  const blocked = await postSidecar({
    content: 'print("blocked")',
    fileName: 'AiAssist_20260510_060001_blocked.lua',
    isPasteReady: true,
    dryRun: false,
  });
  assert.equal(blocked.status, 400);
  assert.match(blocked.json.errorMessage, /confirmWrite must be true/);

  const write = await postSidecar({
    content: 'print("write")',
    fileName: 'AiAssist_20260510_060002_write.lua',
    isPasteReady: true,
    dryRun: false,
    confirmWrite: true,
  });
  assert.equal(write.status, 200);
  assert.equal(write.json.wroteFile, true);
  assert.equal(Object.hasOwn(write.json, 'lua'), false);
  const written = await readFile(path.join(tmp, 'AiAssist', 'AiAssist_20260510_060002_write.lua'), 'utf8');
  assert.equal(written, 'print("write")\n');

  const unsafe = await postSidecar({
    content: 'os.execute("calc")',
    fileName: 'AiAssist_20260510_060003_unsafe.lua',
    isPasteReady: true,
  });
  assert.equal(unsafe.status, 400);
  assert.match(unsafe.json.errorMessage, /Unsafe Lua surface/);

  const notReady = await postSidecar({
    content: 'print("not ready")',
    fileName: 'AiAssist_20260510_060004_not-ready.lua',
    isPasteReady: false,
  });
  assert.equal(notReady.status, 400);
  assert.match(notReady.json.errorMessage, /isPasteReady must be true/);

  const logs = adapter.getLogs();
  assert.doesNotMatch(logs, /sk-[A-Za-z0-9]/);
  assert.doesNotMatch(JSON.stringify([dryRun.json, write.json, unsafe.json, notReady.json]), /Bearer\s+|sk-/);

  console.log('PASS - CMO Lua sidecar endpoint contract holds.');
} finally {
  if (adapter?.proc && !adapter.proc.killed) {
    adapter.proc.kill('SIGTERM');
    await Promise.race([once(adapter.proc, 'exit'), new Promise((resolve) => setTimeout(resolve, 1000))]).catch(() => {});
  }
  await rm(tmp, { recursive: true, force: true });
}
