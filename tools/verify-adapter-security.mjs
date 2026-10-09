#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createServer, request } from 'node:http';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { mkdtemp, readdir, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { createAdapterTransport } from '../src/lib/adapterTransport.js';
import { mergeProviderConfig } from '../server/provider-config.mjs';

const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-adapter-security-'));
const calls = [];
const key = 'synthetic-provider-key-not-a-real-secret';
let redirectTo = '';
const upstream = createServer((req, res) => {
  calls.push({ url: req.url, bearer: req.headers.authorization, key: req.headers['x-api-key'] });
  req.resume();
  if (redirectTo) { res.writeHead(307, { Location: redirectTo }); res.end(); return; }
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify({ data: [{ id: 'mock' }], choices: [{ message: { content: 'safe fixture' } }] }));
});
await new Promise((resolve) => upstream.listen(0, '127.0.0.1', resolve));
const upstreamUrl = 'http://127.0.0.1:' + upstream.address().port;
const sinkCalls = [];
const sink = createServer((req, res) => { sinkCalls.push(req.url); req.resume(); res.end('{}'); });
await new Promise((resolve) => sink.listen(0, '127.0.0.1', resolve));
const sinkUrl = 'http://127.0.0.1:' + sink.address().port;
let logs = '';
let adapter;
let base;

async function startAdapter(port = 0, initialBaseUrl = upstreamUrl) {
  const proc = spawn(process.execPath, ['server/ai-provider-adapter.mjs'], {
    cwd: process.cwd(),
    env: {
      ...process.env, PORT: String(port),
      AI_PROVIDER_TYPE: 'openai-compatible', AI_PROVIDER_BASE_URL: initialBaseUrl,
      AI_PROVIDER_API_KEY: key, AI_PROVIDER_MODEL: 'mock',
      CMO_ROOT: tmp, CMO_LUA_ROOT: tmp, CMO_LOGS_ROOT: tmp,
      CMO_TRANSIENT_SCENARIO_CACHE_ROOT: path.join(tmp, 'decode'),
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let startup = '';
  proc.stdout.on('data', (chunk) => { logs += chunk; startup += chunk; });
  proc.stderr.on('data', (chunk) => { logs += chunk; });
  for (let attempt = 0; attempt < 150; attempt += 1) {
    const match = startup.match(/listening on (http:\/\/127\.0\.0\.1:\d+)/);
    if (match) return { proc, base: match[1] };
    if (proc.exitCode !== null) throw new Error('Adapter exited during startup');
    await new Promise((resolve) => setTimeout(resolve, 30));
  }
  proc.kill();
  throw new Error('Adapter startup timed out');
}
async function stopAdapter() {
  if (adapter?.proc && adapter.proc.exitCode === null) {
    const exited = once(adapter.proc, 'exit');
    adapter.proc.kill();
    await exited;
  }
}
function jsonOptions(body, headers = {}) {
  return { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body) };
}
const messages = [{ role: 'user', content: 'print a harmless marker' }];

try {
  adapter = await startAdapter(); base = adapter.base;
  const health = await (await fetch(base + '/api/health')).json();
  assert.deepEqual(Object.keys(health).sort(), ['ok', 'service', 'version']);
  assert.equal((await fetch(base + '/api/session')).status, 403);
  for (const origin of ['https://untrusted.example', 'null', 'http://localhost:5173.evil.example']) {
    for (const endpoint of ['/api/session', '/api/ai/settings']) {
      assert.equal((await fetch(base + endpoint, {
        headers: { Origin: origin, 'X-CMO-Bootstrap': '1' },
      })).status, 403);
    }
  }
  // Actual Host header test (avoids any Fetch Host normalization).
  const badHost = await new Promise((resolve, reject) => {
    const req = request(base + '/api/session', { headers: { Host: 'rebind.example', 'X-CMO-Bootstrap': '1' } },
      (res) => { res.resume(); resolve(res.statusCode); });
    req.on('error', reject); req.end();
  });
  assert.equal(badHost, 403);
  const preflight = await fetch(base + '/api/ai/chat', {
    method: 'OPTIONS', headers: { Origin: 'http://localhost:5173', 'Access-Control-Request-Headers': 'X-CMO-Session, Content-Type' },
  });
  assert.equal(preflight.status, 204);
  assert.match(preflight.headers.get('access-control-allow-headers'), /X-CMO-Session/);
  assert.equal((await fetch(base + '/api/ai/chat', {
    method: 'OPTIONS', headers: { Origin: 'https://untrusted.example' },
  })).status, 403);
  const bootstrap = await fetch(base + '/api/session', {
    headers: { Origin: 'http://localhost:5173', 'X-CMO-Bootstrap': '1' },
  });
  assert.equal(bootstrap.status, 200);
  assert.equal(bootstrap.headers.get('cache-control'), 'no-store');
  assert.equal(bootstrap.headers.get('x-content-type-options'), 'nosniff');
  const { token } = await bootstrap.json();
  assert.match(token, /^[a-f0-9]{64}$/);
  const auth = { 'X-CMO-Session': token, Origin: 'http://localhost:5173' };
  const protectedPosts = [
    '/api/ai/settings', '/api/ai/test-provider', '/api/ai/models', '/api/ai/chat',
    '/api/cmo/lua-sidecar', '/api/cmo/state-snapshot/import', '/api/scenario/transient-open',
  ];
  for (const endpoint of protectedPosts) {
    assert.equal((await fetch(base + endpoint, jsonOptions({}))).status, 401);
    assert.equal((await fetch(base + endpoint, jsonOptions({}, { ...auth, Origin: 'https://untrusted.example' }))).status, 403);
    assert.equal((await fetch(base + endpoint, { method: 'POST', headers: { ...auth, 'Content-Type': 'text/plain' }, body: '{}' })).status, 415);
  }
  for (const endpoint of ['/api/ai/settings', '/api/cmo/log-feedback']) {
    assert.equal((await fetch(base + endpoint)).status, 401);
  }
  assert.equal(calls.length, 0);
  assert.equal(sinkCalls.length, 0);
  assert.deepEqual(await readdir(tmp), []);
  console.log('PASS - Host/Origin/token/media-type gates prevent dispatch and side effects');

  const client = createAdapterTransport(base); // originless local client also authenticates
  const post = (endpoint, body) => client(base + endpoint, jsonOptions(body));
  assert.equal((await post('/api/ai/chat', { messages })).status, 200);
  assert.equal(calls.at(-1).bearer, 'Bearer ' + key);
  assert.equal((await fetch(base + '/api/ai/chat', jsonOptions({ messages }, auth))).status, 200);

  for (const endpoint of ['/api/ai/chat', '/api/ai/models', '/api/ai/test-provider']) {
    const override = { baseUrl: sinkUrl };
    const count = calls.length;
    const payload = endpoint.endsWith('/chat') ? { messages, providerOverride: override } : override;
    assert.equal((await post(endpoint, payload)).status, 400);
    assert.equal(calls.length, count);
  }
  assert.equal(sinkCalls.length, 0);
  for (const baseUrl of [upstreamUrl + '/v1', upstreamUrl + '/v1/']) {
    assert.equal((await post('/api/ai/chat', { messages, providerOverride: { baseUrl, providerType: 'lm-studio', model: 'another' } })).status, 200);
    assert.equal(calls.at(-1).bearer, 'Bearer ' + key);
  }
  for (const patch of [{ baseUrl: upstreamUrl + '/other' }, { baseUrl: upstreamUrl + '/V1' }, { providerType: 'anthropic-compatible' }]) {
    assert.equal((await post('/api/ai/chat', { messages, providerOverride: patch })).status, 400);
  }
  for (const explicitKey of ['', 'separate-synthetic-key']) {
    assert.equal((await post('/api/ai/chat', { messages, providerOverride: { baseUrl: upstreamUrl + '/other', apiKey: explicitKey } })).status, 200);
    assert.equal(calls.at(-1).bearer, explicitKey ? 'Bearer ' + explicitKey : undefined);
  }
  assert.equal((await post('/api/ai/chat', { messages })).status, 200);
  assert.equal(calls.at(-1).bearer, 'Bearer ' + key);
  assert.equal((await post('/api/ai/settings', { baseUrl: upstreamUrl + '/other' })).status, 200);
  assert.equal((await (await client(base + '/api/ai/settings')).json()).settings.apiKeyConfigured, false);
  await post('/api/ai/settings', { baseUrl: upstreamUrl });
  await post('/api/ai/chat', { messages });
  assert.equal(calls.at(-1).bearer, undefined);
  await post('/api/ai/settings', { apiKey: key });
  const before = await (await client(base + '/api/ai/settings')).json();
  assert.equal((await post('/api/ai/settings', { baseUrl: sinkUrl, maxTokens: null })).status, 400);
  assert.deepEqual(await (await client(base + '/api/ai/settings')).json(), before);
  // Redirects may otherwise carry custom x-api-key headers to a new recipient.
  redirectTo = sinkUrl;
  assert.equal((await post('/api/ai/chat', { messages, providerOverride: { providerType: 'anthropic-compatible', apiKey: key } })).status, 502);
  assert.equal(sinkCalls.length, 0);
  redirectTo = '';
  console.log('PASS - credential destination binding, aliases, explicit keys, atomic settings and redirects');

  for (const endpoint of protectedPosts.filter((route) => route !== '/api/scenario/transient-open')) {
    for (const raw of ['null', '[]', '"text"', '12', 'true', '{', '']) {
      const result = await client(base + endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: raw });
      assert.equal(result.status, 400, endpoint + ' ' + raw);
    }
  }
  for (const body of [{ messages: [null] }, { messages, providerOverride: null }, { messages, providerOverride: [] }, { messages, maxTokens: '3' }]) {
    assert.equal((await post('/api/ai/chat', body)).status, 400);
  }
  for (const body of [{ settings: null }, { settings: [] }, { settings: 'text' }]) {
    assert.equal((await post('/api/ai/settings', body)).status, 400);
  }
  assert.equal((await post('/api/scenario/transient-open', null)).status, 400);
  assert.equal((await client(base + '/api/scenario/transient-open', {
    method: 'POST', headers: { 'Content-Type': 'application/octet-stream', 'X-CMO-Scenario-File-Name': 'safe.scen' }, body: new Uint8Array(),
  })).status, 400); // upload reaches its own empty-upload validation, no decoder execution
  assert.equal((await post('/api/ai/chat', { messages })).status, 200);
  assert.equal((await post('/api/ai/models', {})).status, 200);
  assert.equal((await post('/api/ai/test-provider', {})).status, 200);
  assert.equal(adapter.proc.exitCode, null);
  console.log('PASS - malformed inputs return controlled errors; subsequent chat/models/test remain usable');

  const currentPort = new URL(base).port;
  await stopAdapter();
  adapter = await startAdapter(currentPort);
  assert.equal((await client(base + '/api/ai/settings')).status, 200);
  assert.equal((await fetch(base + '/api/ai/settings', { headers: auth })).status, 401);
  assert.ok(!logs.includes(key) && !logs.includes(token));
  console.log('PASS - adapter restart rotates capability and client reauthenticates');

  await stopAdapter();
  adapter = await startAdapter(currentPort, upstreamUrl + '/v1/.');
  assert.equal((await post('/api/ai/chat', { messages })).status, 200);
  assert.equal(calls.at(-1).url, '/v1/v1/chat/completions');
  const priorCalls = calls.length;
  assert.equal((await post('/api/ai/chat', { messages, providerOverride: { baseUrl: upstreamUrl + '/v1' } })).status, 400);
  assert.equal(calls.length, priorCalls);
  await stopAdapter();
  adapter = await startAdapter(currentPort, 'missing-scheme.example');
  assert.equal((await post('/api/ai/settings', { baseUrl: upstreamUrl })).status, 200);
  assert.equal((await (await client(base + '/api/ai/settings')).json()).settings.apiKeyConfigured, false);
  assert.equal((await post('/api/ai/chat', { messages })).status, 200);
  assert.equal(calls.at(-1).bearer, undefined);
  console.log('PASS - raw startup URL path binding and recovery from invalid startup settings');

  const cfg = { providerType: 'openai-compatible', baseUrl: 'HTTP://EXAMPLE.TEST:80/', apiKey: key };
  const empty = { ...cfg, baseUrl: '', apiKey: '' };
  assert.equal(mergeProviderConfig(empty, { model: 'mock' }, { settings: true }).baseUrl, '');
  assert.equal(mergeProviderConfig(empty, { baseUrl: 'http://localhost:11434' }, { settings: true }).apiKey, '');
  assert.equal(mergeProviderConfig(cfg, { baseUrl: 'http://example.test/v1' }).apiKey, key);
  for (const baseUrl of ['https://example.test', 'http://example.test:81', 'http://user:pass@example.test', 'http://example.test?q=1', 'http://example.test#fragment']) {
    assert.throws(() => mergeProviderConfig(cfg, { baseUrl }));
  }
  for (const oldUrl of ['missing-scheme.example', 'https://example.test?old=1']) {
    const invalid = { ...cfg, baseUrl: oldUrl };
    assert.throws(() => mergeProviderConfig(invalid, { baseUrl: 'http://localhost:11434' }));
    assert.equal(mergeProviderConfig(invalid, { baseUrl: 'http://localhost:11434' }, { settings: true }).apiKey, '');
    for (const apiKey of ['', 'replacement-fixture']) {
      assert.equal(mergeProviderConfig(invalid, { baseUrl: 'http://localhost:11434', apiKey }, { settings: true }).apiKey, apiKey);
    }
  }
} finally {
  await stopAdapter();
  upstream.closeAllConnections(); sink.closeAllConnections();
  await Promise.all([new Promise((resolve) => upstream.close(resolve)), new Promise((resolve) => sink.close(resolve))]);
  assert.equal(path.dirname(path.resolve(tmp)), path.resolve(os.tmpdir()));
  await rm(tmp, { recursive: true, force: true });
}
console.log('PASS - adapter security regression suite');
