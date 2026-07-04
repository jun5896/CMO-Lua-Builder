#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  extractAssistantText,
  parseAiInterpreterResponse,
} from '../src/lib/aiAdapterClient.js';

function okResponse() {
  return [
    '## Summary',
    '- Ready.',
    '',
    '## Assumptions',
    '- Existing side and unit names are confirmed.',
    '',
    '## CMO UI prerequisites',
    '- Confirm the mission exists in CMO.',
    '',
    '## Paste-ready Lua',
    '```lua',
    'ScenEdit_MsgBox("ready")',
    '```',
    '',
    '## Validation checklist',
    '- Run in CMO Lua Console.',
    '',
    '## Follow-up questions or blockers',
    '- None.',
  ].join('\n');
}

function run() {
  const openAi = extractAssistantText({
    ok: true,
    providerType: 'openai-compatible',
    model: 'fallback-model',
    response: {
      model: 'gpt-test',
      choices: [{ finish_reason: 'stop', message: { content: 'OpenAI text' } }],
    },
  });
  assert.equal(openAi.ok, true);
  assert.equal(openAi.text, 'OpenAI text');
  assert.equal(openAi.finishReason, 'stop');
  assert.equal(openAi.modelEcho, 'gpt-test');

  const ollama = extractAssistantText({
    ok: true,
    providerType: 'ollama',
    model: 'fallback-ollama',
    response: {
      model: 'llama-test',
      done: true,
      message: { content: 'Ollama text' },
    },
  });
  assert.equal(ollama.ok, true);
  assert.equal(ollama.text, 'Ollama text');
  assert.equal(ollama.finishReason, 'stop');
  assert.equal(ollama.modelEcho, 'llama-test');

  const error = extractAssistantText({
    ok: false,
    model: 'mock-model',
    errorMessage: 'upstream returned HTTP 401',
  });
  assert.equal(error.ok, false);
  assert.equal(error.text, '');
  assert.equal(error.errorMessage, 'upstream returned HTTP 401');

  const parsedReady = parseAiInterpreterResponse(okResponse());
  assert.equal(parsedReady.isPasteReady, true);
  assert.equal(parsedReady.lua, 'ScenEdit_MsgBox("ready")');
  assert.deepEqual(parsedReady.missingRequiredSections, []);

  const missingPasteReady = parseAiInterpreterResponse(okResponse().replace('## Paste-ready Lua', '## Lua Draft'));
  assert.equal(missingPasteReady.isPasteReady, false);
  assert.ok(missingPasteReady.blockers.some((item) => item.includes('Paste-ready Lua')));

  const placeholder = parseAiInterpreterResponse(okResponse().replace('ScenEdit_MsgBox("ready")', 'ScenEdit_GetUnit({guid="<UNIT_GUID>"})'));
  assert.equal(placeholder.isPasteReady, false);
  assert.equal(placeholder.hasPlaceholders, true);
  assert.ok(placeholder.blockers.some((item) => item.includes('Placeholder tokens')));

  const unsafe = parseAiInterpreterResponse(okResponse().replace('ScenEdit_MsgBox("ready")', 'require("socket")'));
  assert.equal(unsafe.isPasteReady, false);
  assert.ok(unsafe.blockers.some((item) => item.includes('Unsafe Lua surface')));

  const blocker = parseAiInterpreterResponse(okResponse().replace('- None.', 'BLOCKER: Missing Unit GUID.'));
  assert.equal(blocker.isPasteReady, false);
  assert.ok(blocker.blockers.some((item) => item.includes('BLOCKER')));
}

run();
console.log('PASS - AI adapter client parser contract smoke checks passed.');
