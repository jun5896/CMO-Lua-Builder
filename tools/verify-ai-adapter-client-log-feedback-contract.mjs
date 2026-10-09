import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import { fetchCmoLogFeedback } from '../src/lib/aiAdapterClient.js';

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

await withFetch(async (url, options = {}) => {
  const parsed = new URL(url);
  assert.equal(parsed.origin + parsed.pathname, 'http://127.0.0.1:8765/api/cmo/log-feedback');
  assert.equal(parsed.searchParams.get('kind'), 'all');
  assert.equal(parsed.searchParams.get('since'), '2026-05-11T00:00:00.000Z');
  assert.equal(parsed.searchParams.get('limit'), '20');
  assert.equal(parsed.searchParams.get('maxBytes'), '24000');
  assert.equal(parsed.searchParams.has('logsRoot'), false);
  assert.equal(options.method ?? 'GET', 'GET');
  assert.equal(Object.hasOwn(options, 'body'), false);

  return jsonResponse({
    ok: true,
    files: [
      {
        kind: 'exception',
        fileName: 'ExceptionLog_2026_05_11.txt',
        entries: ['ERROR: sanitized stack line'],
      },
    ],
    summary: { entriesReturned: 1, filesScanned: 2 },
    followUpDraft: 'CMO 로그를 바탕으로 원인을 진단해 주세요. 부족한 값은 추측하지 마세요.',
  });
}, async () => {
  const result = await fetchCmoLogFeedback({
    kind: 'all',
    since: '2026-05-11T00:00:00.000Z',
    limit: 20,
    maxBytes: 24000,
    logsRoot: 'C:/Users/should-not-be-sent',
  });

  assert.equal(result.ok, true);
  assert.equal(result.summary.entriesReturned, 1);
  assert.match(result.followUpDraft, /추측하지 마세요/);
});

await withFetch(async () => jsonResponse({
  ok: false,
  errorMessage: 'log feedback unavailable',
}, { ok: false, status: 503 }), async () => {
  await assert.rejects(
    () => fetchCmoLogFeedback(),
    (error) => {
      assert.equal(error.message, 'log feedback unavailable');
      assert.equal(error.status, 503);
      assert.equal(error.body.errorMessage, 'log feedback unavailable');
      return true;
    },
  );
});

await withFetch(async () => jsonResponse({
  ok: false,
  error: 'body rejected',
}, { ok: true, status: 200 }), async () => {
  await assert.rejects(
    () => fetchCmoLogFeedback(),
    (error) => {
      assert.equal(error.message, 'body rejected');
      assert.equal(error.status, 200);
      assert.equal(error.body.error, 'body rejected');
      return true;
    },
  );
});

const clientSource = await readFile('src/lib/aiAdapterClient.js', 'utf8');
assert.match(clientSource, /export async function fetchCmoLogFeedback/);
assert.doesNotMatch(clientSource, /logsRoot/);

const luaAssistantSource = await readFile('src/components/LuaAssistant.jsx', 'utf8');
assert.match(luaAssistantSource, /fetchCmoLogFeedback/);
assert.match(luaAssistantSource, /CMO 로그 확인/);
assert.match(luaAssistantSource, /후속 질문 초안/);
assert.match(luaAssistantSource, /setAiChatInstruction\(cmoLogFeedback\.followUpDraft\)/);
assert.doesNotMatch(luaAssistantSource, /sendCmoAiPrompt\([^)]*cmoLogFeedback/i);
assert.doesNotMatch(luaAssistantSource, /logsRoot/);

console.log('PASS - AI adapter client CMO log feedback contract holds.');
