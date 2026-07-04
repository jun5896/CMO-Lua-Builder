import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import { importCmoStateSnapshot } from '../src/lib/aiAdapterClient.js';

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
  globalThis.fetch = handler;

  try {
    await testBody();
  } finally {
    globalThis.fetch = originalFetch;
  }
}

await withFetch(async (url, options = {}) => {
  assert.equal(url, 'http://127.0.0.1:8765/api/cmo/state-snapshot/import');
  assert.equal(options.method, 'POST');
  assert.equal(options.headers['Content-Type'], 'application/json');

  const body = JSON.parse(options.body);
  assert.deepEqual(body, {
    text: '<SimEvents><SimEvent><Description>Client Event</Description></SimEvent></SimEvents>',
    sourceHint: 'toolDumpEvents',
  });
  assert.equal(Object.hasOwn(body, 'cmoRoot'), false);
  assert.equal(Object.hasOwn(body, 'logsRoot'), false);
  assert.equal(Object.hasOwn(body, 'scenarioRoot'), false);
  assert.equal(Object.hasOwn(body, 'luaRoot'), false);
  assert.equal(Object.hasOwn(body, 'filePath'), false);
  assert.equal(Object.hasOwn(body, 'scriptPath'), false);

  return jsonResponse({
    ok: true,
    snapshotId: 'cmo-state-2026-05-11T00-00-00-000Z',
    importedAt: '2026-05-11T00:00:00.000Z',
    source: { type: 'toolDumpEvents', label: 'User pasted CMO export', live: false },
    summary: {
      eventCount: 1,
      specialActionCount: 0,
      detectedApiCount: 1,
      warningCount: 0,
      luaPreviewCharUnit: 'utf16-code-units',
      maxLuaPreviewChars: 600,
    },
    events: [{ id: 'E1', name: 'Client Event', luaScriptPreviews: [{ preview: 'print("bounded")' }] }],
    specialActions: [],
    objectContext: { sides: ['Blue'], missions: [], units: [], referencePoints: [], zones: [], specialActions: [], luaFiles: [] },
    detectedApis: ['ScenEdit_GetEvent'],
    warnings: [],
    redaction: { applied: true, count: 0 },
  });
}, async () => {
  const result = await importCmoStateSnapshot({
    text: '<SimEvents><SimEvent><Description>Client Event</Description></SimEvent></SimEvents>',
    sourceHint: 'toolDumpEvents',
    cmoRoot: 'C:/Users/should-not-be-sent',
    logsRoot: 'C:/Users/should-not-be-sent',
  });

  assert.equal(result.ok, true);
  assert.equal(result.source.live, false);
  assert.equal(result.summary.eventCount, 1);
});

await withFetch(async () => jsonResponse({
  ok: false,
  errorMessage: 'snapshot import unavailable',
}, { ok: false, status: 503 }), async () => {
  await assert.rejects(
    () => importCmoStateSnapshot({ text: '<SimEvents />' }),
    (error) => {
      assert.equal(error.message, 'snapshot import unavailable');
      assert.equal(error.status, 503);
      assert.equal(error.body.errorMessage, 'snapshot import unavailable');
      return true;
    },
  );
});

await withFetch(async () => jsonResponse({
  ok: false,
  error: 'snapshot body rejected',
}, { ok: true, status: 200 }), async () => {
  await assert.rejects(
    () => importCmoStateSnapshot({ text: '<SimEvents />' }),
    (error) => {
      assert.equal(error.message, 'snapshot body rejected');
      assert.equal(error.status, 200);
      assert.equal(error.body.error, 'snapshot body rejected');
      return true;
    },
  );
});

const clientSource = await readFile('src/lib/aiAdapterClient.js', 'utf8');
assert.match(clientSource, /export async function importCmoStateSnapshot/);
assert.match(clientSource, /\/api\/cmo\/state-snapshot\/import/);
assert.doesNotMatch(clientSource, /cmoRoot|logsRoot|scenarioRoot|luaRoot|filePath|scriptPath/);
assert.doesNotMatch(clientSource, /sendCmoAiPrompt\([^)]*stateSnapshot/i);

const luaAssistantSource = await readFile('src/components/LuaAssistant.jsx', 'utf8');
assert.match(luaAssistantSource, /importCmoStateSnapshot/);
assert.match(luaAssistantSource, /CMO 상태 스냅샷 가져오기/);
assert.match(luaAssistantSource, /실시간 연결이 아닙니다/);
assert.match(luaAssistantSource, /가져온 CMO 스냅샷/);
assert.match(luaAssistantSource, /후속 질문 초안 만들기/);
assert.match(luaAssistantSource, /setAiChatInstruction\(cmoStateSnapshot\.followUpDraft\)/);
assert.doesNotMatch(luaAssistantSource, /sendCmoAiPrompt\([^)]*cmoStateSnapshot/i);
assert.doesNotMatch(luaAssistantSource, /cmoRoot|logsRoot|scenarioRoot|luaRoot|filePath|scriptPath/);

console.log('PASS - AI adapter client CMO state snapshot contract holds.');
