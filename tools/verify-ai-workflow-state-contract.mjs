#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  AI_WORKFLOW_STATES,
  deriveAiWorkflowState,
} from '../src/lib/aiWorkflowState.js';

function assertState(name, input, expected) {
  const actual = deriveAiWorkflowState(input);
  assert.equal(actual.id, expected.id, `${name}: state id`);
  assert.equal(actual.canApplyLua, expected.canApplyLua, `${name}: canApplyLua`);
  if (expected.titleIncludes) {
    assert.match(actual.title, expected.titleIncludes, `${name}: title`);
  }
  if (expected.bodyIncludes) {
    assert.match(actual.body, expected.bodyIncludes, `${name}: body`);
  }
}

const readyParsed = {
  lua: "ScenEdit_MsgBox('ready')",
  isPasteReady: true,
  blockers: [],
  warnings: [],
  followUpQuestions: [],
  missingRequiredSections: [],
};

const askBackParsed = {
  lua: '',
  isPasteReady: false,
  blockers: ['No Lua code block found.'],
  warnings: [],
  followUpQuestions: ['Confirm the Blue side name in CMO.'],
  missingRequiredSections: [],
};

const blockedParsed = {
  lua: "ScenEdit_SetUnit({guid='<UNIT_GUID>'})",
  isPasteReady: false,
  blockers: ['Placeholder tokens detected in Lua: <UNIT_GUID>'],
  warnings: [],
  followUpQuestions: [],
  missingRequiredSections: [],
};

assert.equal(AI_WORKFLOW_STATES.idle, 'idle');
assert.equal(AI_WORKFLOW_STATES.calling, 'calling');
assert.equal(AI_WORKFLOW_STATES.ready, 'ready');
assert.equal(AI_WORKFLOW_STATES.askBack, 'askBack');
assert.equal(AI_WORKFLOW_STATES.blocked, 'blocked');
assert.equal(AI_WORKFLOW_STATES.error, 'error');

assertState('idle', {}, {
  id: 'idle',
  canApplyLua: false,
  titleIncludes: /AI response/i,
});

const firstIdle = deriveAiWorkflowState({});
firstIdle.nextActions.push('mutated');
const secondIdle = deriveAiWorkflowState({});
assert.equal(secondIdle.nextActions.includes('mutated'), false);

assertState('calling', { isAiCalling: true, aiCallStatus: { state: 'calling', message: 'AI 호출 중' } }, {
  id: 'calling',
  canApplyLua: false,
  titleIncludes: /호출|calling/i,
});

assertState('calling wins over stale ready response', {
  isAiCalling: true,
  aiResponse: '## Paste-ready Lua',
  aiCallStatus: { state: 'calling', message: 'AI 호출 중' },
  parsedResponse: readyParsed,
}, {
  id: 'calling',
  canApplyLua: false,
});

assertState('ready', { aiResponse: '## Paste-ready Lua', parsedResponse: readyParsed }, {
  id: 'ready',
  canApplyLua: true,
  titleIncludes: /Lua/i,
  bodyIncludes: /CMO.*검증|검증.*CMO/i,
});

assertState('pruning hard block wins over stale ready response', {
  aiResponse: '## Paste-ready Lua',
  parsedResponse: readyParsed,
  pruningAudit: { hardBlock: 'Context Pack hard block' },
}, {
  id: 'error',
  canApplyLua: false,
  bodyIncludes: /Context Pack hard block/i,
});

assertState('askBack', { aiResponse: '## Follow-up questions or blockers', parsedResponse: askBackParsed }, {
  id: 'askBack',
  canApplyLua: false,
  titleIncludes: /확인|confirm/i,
});

assertState('blocked', { aiResponse: '## Paste-ready Lua', parsedResponse: blockedParsed }, {
  id: 'blocked',
  canApplyLua: false,
  bodyIncludes: /Placeholder|UNIT_GUID/i,
});

assertState('error', {
  aiCallStatus: { state: 'error', message: 'Provider model missing' },
}, {
  id: 'error',
  canApplyLua: false,
  bodyIncludes: /Provider model missing/i,
});

assertState('pruning error', {
  pruningAudit: { hardBlock: 'Context Pack hard block' },
}, {
  id: 'error',
  canApplyLua: false,
  bodyIncludes: /Context Pack hard block/i,
});

console.log('PASS - AI workflow state contract holds.');
