#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createAdapterTransport } from '../src/lib/adapterTransport.js';

const base = 'http://127.0.0.1:8765';
const tokenA = 'a'.repeat(64);
const tokenB = 'b'.repeat(64);
const json = (body, status = 200, headers = {}) => new Response(JSON.stringify(body), { status, headers });
let bootstrapCount = 0;
let operationCount = 0;
let currentToken = tokenA;
let unauthorizedUpstream = false;
const payload = new Blob(['synthetic upload'], { type: 'application/octet-stream' });
const transport = createAdapterTransport(base, async (url, options) => {
  if (url.endsWith('/api/session')) {
    bootstrapCount += 1;
    assert.equal(options.headers['X-CMO-Bootstrap'], '1');
    return json({ token: currentToken });
  }
  operationCount += 1;
  assert.equal(options.headers['Content-Type'], 'application/octet-stream');
  assert.equal(options.headers['X-CMO-Scenario-File-Name'], 'safe.scen');
  assert.equal(options.body, payload);
  if (options.headers['X-CMO-Session'] !== currentToken) {
    return json({ error: 'Adapter session required' }, 401, { 'X-CMO-Auth-Required': '1' });
  }
  return unauthorizedUpstream ? json({ error: 'Provider denied' }, 401) : json({ ok: true });
});
const options = { method: 'POST', headers: { 'Content-Type': 'application/octet-stream', 'X-CMO-Scenario-File-Name': 'safe.scen' }, body: payload };
const call = () => transport(base + '/api/scenario/transient-open', options);
await Promise.all([call(), call(), call()]);
assert.equal(bootstrapCount, 1);
assert.equal(operationCount, 3);
currentToken = tokenB;
await Promise.all([call(), call()]);
assert.equal(bootstrapCount, 2);
assert.equal(operationCount, 7);
unauthorizedUpstream = true;
const before = operationCount;
assert.equal((await call()).status, 401);
assert.equal(operationCount, before + 1);
assert.equal(bootstrapCount, 2);
assert.equal(options.headers['X-CMO-Session'], undefined);
await assert.rejects(() => transport('https://untrusted.example/api', options), /Invalid adapter request/);

let retries = 0;
const revoked = createAdapterTransport(base, async (url) => {
  if (url.endsWith('/api/session')) return json({ token: tokenA });
  retries += 1;
  return json({}, 401, { 'X-CMO-Auth-Required': '1' });
});
assert.equal((await revoked(base + '/api/ai/settings')).status, 401);
assert.equal(retries, 2);
let failOnce = true;
const recover = createAdapterTransport(base, async (url) => {
  if (url.endsWith('/api/session')) {
    if (failOnce) { failOnce = false; throw new Error('Disconnected'); }
    return json({ token: tokenA });
  }
  return json({ ok: true });
});
await assert.rejects(() => recover(base + '/api/ai/settings'), /Disconnected/);
assert.equal((await recover(base + '/api/ai/settings')).status, 200);
console.log('PASS - single-flight bootstrap, bounded restart recovery, preserved uploads, no upstream-401 retry');
