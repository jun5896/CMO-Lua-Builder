#!/usr/bin/env node
/**
 * verify-transient-scenario-open.mjs
 *
 * Smoke test for POST /api/scenario/transient-open.
 * It mirrors the browser flow: upload a .scen file as octet-stream, let the
 * local adapter decode/summarize it in a temporary workspace, and verify the
 * returned summary without leaving extracted XML/JSON files behind.
 */

import { spawn } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import {
  basename,
  dirname,
  join as joinPath,
  resolve as resolvePath,
} from 'node:path';
import { once } from 'node:events';
import { setTimeout as delay } from 'node:timers/promises';
import { getSidecarIndexPath } from '../tools/sidecar-paths.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = resolvePath(HERE, '..');
const ADAPTER_PATH = resolvePath(HERE, 'ai-provider-adapter.mjs');
const ADAPTER_PORT = Number(process.env.CMO_TRANSIENT_SMOKE_PORT || 8767);
const CACHE_ROOT = resolvePath(
  process.env.CMO_TRANSIENT_SCENARIO_CACHE_ROOT
    || joinPath(PROJECT_ROOT, '.scenario-extract-cache', 'transient-open'),
);

function fileCount(root) {
  if (!existsSync(root)) return 0;
  let count = 0;
  const stack = [root];

  while (stack.length > 0) {
    const current = stack.pop();
    for (const entry of readdirSync(current, { withFileTypes: true })) {
      const next = joinPath(current, entry.name);
      if (entry.isDirectory()) stack.push(next);
      if (entry.isFile()) count += 1;
    }
  }

  return count;
}

function pickScenarioPath() {
  if (process.env.CMO_TRANSIENT_SCENARIO_PATH) {
    return resolvePath(process.env.CMO_TRANSIENT_SCENARIO_PATH);
  }

  const indexPath = getSidecarIndexPath();
  if (existsSync(indexPath)) {
    const index = JSON.parse(readFileSync(indexPath, 'utf8'));
    const match = (index.scenarios || [])
      .filter((scenario) => scenario.status === 'readyWithInternalSidecar')
      .filter((scenario) => scenario.scenarioPath && existsSync(scenario.scenarioPath))
      .filter((scenario) => !/CMANO|Lua test/i.test(scenario.scenarioPath))
      .sort((a, b) => (a.sizeBytes || 0) - (b.sizeBytes || 0))[0];

    if (match?.scenarioPath) return match.scenarioPath;
  }

  return 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations\\Scenarios\\Tutorials\\Submarine Tutorials\\Submarine Tutorial 1.scen';
}

function startAdapter() {
  const proc = spawn(process.execPath, [ADAPTER_PATH], {
    cwd: PROJECT_ROOT,
    env: { ...process.env, PORT: String(ADAPTER_PORT) },
    stdio: ['ignore', 'pipe', 'pipe'],
  });

  let logs = '';
  proc.stdout.on('data', (chunk) => { logs += chunk.toString(); });
  proc.stderr.on('data', (chunk) => { logs += chunk.toString(); });

  return { proc, getLogs: () => logs };
}

async function waitForAdapter(maxMs = 5000) {
  const started = Date.now();
  while (Date.now() - started < maxMs) {
    try {
      const response = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/health`);
      if (response.ok) return;
    } catch {
      // Adapter is still starting.
    }
    await delay(120);
  }
  throw new Error(`adapter did not respond on :${ADAPTER_PORT} within ${maxMs}ms`);
}

async function stopAdapter(adapter) {
  if (!adapter?.proc || adapter.proc.killed) return;
  adapter.proc.kill('SIGTERM');
  await Promise.race([
    once(adapter.proc, 'exit').catch(() => {}),
    delay(1500),
  ]);
}

async function main() {
  const scenarioPath = pickScenarioPath();
  if (!existsSync(scenarioPath) || !statSync(scenarioPath).isFile()) {
    throw new Error(`scenario file not found: ${scenarioPath}`);
  }

  const beforeFiles = fileCount(CACHE_ROOT);
  const adapter = startAdapter();

  try {
    await waitForAdapter();
    const payload = readFileSync(scenarioPath);
    const response = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/scenario/transient-open`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/octet-stream',
        'X-CMO-Scenario-File-Name': encodeURIComponent(basename(scenarioPath)),
      },
      body: payload,
    });
    const body = await response.json();

    const afterFiles = fileCount(CACHE_ROOT);
    const luaScripts = Array.isArray(body?.summary?.luaScripts) ? body.summary.luaScripts.length : 0;
    const title = body?.summary?.scenario?.title || '';

    console.log('=== verify-transient-scenario-open.mjs ===');
    console.log(`adapter : http://127.0.0.1:${ADAPTER_PORT}`);
    console.log(`scenario: ${scenarioPath}`);
    console.log(`status  : ${response.status}`);
    console.log(`title   : ${title || '(none)'}`);
    console.log(`lua     : ${luaScripts}`);
    console.log(`cache   : before=${beforeFiles} after=${afterFiles}`);

    if (!response.ok || !body?.ok || body.mode !== 'transient' || !body.summary?.scenario) {
      console.log('');
      console.log(JSON.stringify(body, null, 2));
      throw new Error('transient scenario open did not return a valid summary');
    }

    if (body.tempRetained) {
      throw new Error('transient temp files were retained unexpectedly');
    }

    if (afterFiles > beforeFiles) {
      throw new Error('transient cache file count increased after request cleanup');
    }

    console.log('');
    console.log('PASS - transient scenario upload returned an in-memory summary and cleaned temp files.');
  } finally {
    await stopAdapter(adapter);
  }
}

main().catch((error) => {
  console.error('[harness] error:', error.message || error);
  process.exitCode = 2;
});
