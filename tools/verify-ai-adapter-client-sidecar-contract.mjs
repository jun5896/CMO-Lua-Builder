import assert from 'node:assert/strict';

import { saveCmoLuaSidecar } from '../src/lib/aiAdapterClient.js';

function jsonResponse(body, { ok = true, status = 200 } = {}) {
  return {
    ok,
    status,
    async json() {
      return body;
    },
  };
}

async function withFetch(handler, testBody) {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async (url, options) => {
    if (url.endsWith('/api/session')) {
      assert.equal(options.headers['X-CMO-Bootstrap'], '1');
      return jsonResponse({ token: 'a'.repeat(64) });
    }
    assert.equal(options.headers['X-CMO-Session'], 'a'.repeat(64));
    return handler(url, options);
  };

  try {
    await testBody();
  } finally {
    globalThis.fetch = originalFetch;
  }
}

await withFetch(async (url, options) => {
  assert.equal(url, 'http://127.0.0.1:8765/api/cmo/lua-sidecar');
  assert.equal(options.method, 'POST');
  assert.equal(options.headers['Content-Type'], 'application/json');
  assert.deepEqual(JSON.parse(options.body), {
    content: 'print("ready")',
    dryRun: true,
    isPasteReady: true,
  });

  return jsonResponse({
    ok: true,
    dryRun: true,
    fileName: 'AiAssist_ready.lua',
    loaderSnippet: "ScenEdit_RunScript('/AiAssist/AiAssist_ready.lua')",
  });
}, async () => {
  const result = await saveCmoLuaSidecar({
    content: 'print("ready")',
    dryRun: true,
    isPasteReady: true,
  });

  assert.equal(result.ok, true);
  assert.equal(result.fileName, 'AiAssist_ready.lua');
  assert.equal(result.loaderSnippet, "ScenEdit_RunScript('/AiAssist/AiAssist_ready.lua')");
});

await withFetch(async () => jsonResponse({
  ok: false,
  errorMessage: 'paste-ready required',
}, { ok: false, status: 400 }), async () => {
  await assert.rejects(
    () => saveCmoLuaSidecar({ content: 'print("blocked")' }),
    (error) => {
      assert.equal(error.message, 'paste-ready required');
      assert.equal(error.status, 400);
      assert.equal(error.body.errorMessage, 'paste-ready required');
      return true;
    },
  );
});

await withFetch(async () => jsonResponse({
  ok: false,
  error: 'response body rejected',
}, { ok: true, status: 200 }), async () => {
  await assert.rejects(
    () => saveCmoLuaSidecar({ content: 'print("body rejected")' }),
    (error) => {
      assert.equal(error.message, 'response body rejected');
      assert.equal(error.status, 200);
      assert.equal(error.body.error, 'response body rejected');
      return true;
    },
  );
});

console.log('PASS - AI adapter client CMO Lua sidecar contract holds.');
