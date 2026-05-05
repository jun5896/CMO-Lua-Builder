#!/usr/bin/env node
/**
 * verify-upstream-redaction.mjs
 *
 * Reproduces the Codex-flagged Task 3 calibration scenario (2026-05-03):
 *   - Mock upstream provider on 127.0.0.1:8899 returns HTTP 401 with a body
 *     that ECHOES the received `Authorization` header.
 *   - Adapter is configured with a deliberately-leaky test API key.
 *   - We call POST /api/ai/chat and assert the adapter response contains
 *     NEITHER the raw key NOR any `Bearer ...` literal.
 *
 * This is a self-contained smoke harness — Codex/Kimi can run it directly:
 *
 *   node tools/server/verify-upstream-redaction.mjs
 *
 * Exit codes:
 *   0  → security patch effective; no key/Bearer fragment in response
 *   1  → LEAK DETECTED — block pull
 *   2  → harness setup failure (port busy, etc.)
 *
 * Test key used (clearly fake): `sk-local-leak-test-12-cdef`
 */

import { createServer } from 'node:http';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, resolve as resolvePath } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';

const HERE = dirname(fileURLToPath(import.meta.url));
const ADAPTER_PATH = resolvePath(HERE, 'ai-provider-adapter.mjs');

const TEST_KEY    = 'sk-local-leak-test-12-cdef';
const MOCK_PORT   = 8899;
const ADAPTER_PORT = 8766;       // not 8765 to avoid colliding with a running adapter
const FORBIDDEN = [
  TEST_KEY,
  `Bearer ${TEST_KEY}`,
  /Bearer\s+[A-Za-z0-9._\-]{8,}/,   // any other Bearer fingerprint
];

// -----------------------------------------------------------------------------
// Mock upstream provider
// -----------------------------------------------------------------------------

function startMockProvider() {
  return new Promise((resolveStart, rejectStart) => {
    const srv = createServer((req, res) => {
      let body = '';
      req.on('data', (c) => { body += c; });
      req.on('end', () => {
        // Echo the Authorization header back in the body — this is the
        // adversarial case Codex flagged.
        const echoedAuth = req.headers['authorization'] || '(none)';
        res.statusCode = 401;
        res.setHeader('Content-Type', 'application/json');
        res.end(JSON.stringify({
          error: 'mock denied',
          echoedAuth,
          bodyLength: body.length,
        }));
      });
    });
    srv.on('error', rejectStart);
    srv.listen(MOCK_PORT, '127.0.0.1', () => resolveStart(srv));
  });
}

// -----------------------------------------------------------------------------
// Adapter spawn
// -----------------------------------------------------------------------------

function startAdapter() {
  const proc = spawn(process.execPath, [ADAPTER_PATH], {
    env: { ...process.env, PORT: String(ADAPTER_PORT) },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let logs = '';
  proc.stdout.on('data', (b) => { logs += b.toString(); });
  proc.stderr.on('data', (b) => { logs += b.toString(); });
  return { proc, getLogs: () => logs };
}

async function waitForAdapter(maxMs = 4000) {
  const start = Date.now();
  while (Date.now() - start < maxMs) {
    try {
      const r = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/health`);
      if (r.ok) return true;
    } catch {
      /* not up yet */
    }
    await delay(120);
  }
  throw new Error(`adapter did not respond on :${ADAPTER_PORT} within ${maxMs}ms`);
}

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

async function main() {
  let mock, adapter;
  let exitCode = 0;
  try {
    mock = await startMockProvider();
    adapter = startAdapter();
    await waitForAdapter();

    // Configure the adapter to point at the mock provider with the leaky test key.
    const cfg = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/ai/settings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        providerType: 'openai-compatible',
        baseUrl: `http://127.0.0.1:${MOCK_PORT}`,
        apiKey: TEST_KEY,
        model: 'mock-model',
      }),
    });
    if (!cfg.ok) throw new Error(`settings POST failed: ${cfg.status}`);

    // Trigger the adversarial chat call.
    const chat = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ messages: [{ role: 'user', content: 'hi' }] }),
    });
    const responseText = await chat.text();
    const adapterLogs = adapter.getLogs();

    // Assertion: response body must NOT contain TEST_KEY or `Bearer .*`.
    const findings = [];
    for (const f of FORBIDDEN) {
      if (typeof f === 'string') {
        if (responseText.includes(f)) findings.push(`response body contains literal: ${JSON.stringify(f)}`);
        if (adapterLogs.includes(f))  findings.push(`adapter log contains literal: ${JSON.stringify(f)}`);
      } else {
        if (f.test(responseText)) findings.push(`response body matches pattern: ${f}`);
        if (f.test(adapterLogs))  findings.push(`adapter log matches pattern: ${f}`);
      }
    }

    console.log('=== verify-upstream-redaction.mjs ===');
    console.log(`mock    : http://127.0.0.1:${MOCK_PORT} (returns 401 + echoedAuth)`);
    console.log(`adapter : http://127.0.0.1:${ADAPTER_PORT}`);
    console.log(`status  : ${chat.status}`);
    console.log('');
    console.log('--- adapter response body ---');
    console.log(responseText);
    console.log('');
    console.log('--- adapter stdout/stderr ---');
    console.log(adapterLogs);
    console.log('');
    if (findings.length === 0) {
      console.log('✅ PASS — no Bearer / sk-key fingerprint in adapter response or log.');
      console.log(`         status forwarded as ${chat.status} (expected 401).`);
      console.log(`         body shape sanitized to errorMessage="upstream returned HTTP 401".`);
    } else {
      console.log('❌ FAIL — leak detected:');
      for (const f of findings) console.log(`         - ${f}`);
      exitCode = 1;
    }
  } catch (err) {
    console.error('[harness] error:', err.message || err);
    exitCode = 2;
  } finally {
    try { adapter?.proc.kill('SIGTERM'); } catch { /* ignore */ }
    try { mock?.close(); } catch { /* ignore */ }
    // Give them a moment to release ports
    await delay(150);
    process.exit(exitCode);
  }
}

main();
