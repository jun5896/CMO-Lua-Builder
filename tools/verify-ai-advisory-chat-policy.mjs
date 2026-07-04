import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  buildAdvisorySystemGuidance,
  classifyAdvisoryTopic,
  formatOffTopicRedirect,
} from '../src/lib/aiAdvisoryChatPolicy.js';

const guidance = buildAdvisorySystemGuidance({
  confirmedContextCount: 2,
  hasScenarioSnapshot: false,
});

assert.ok(guidance.includes('CMO mission scripting advisor'));
assert.ok(guidance.includes('ask one focused follow-up question'));
assert.ok(guidance.includes('Do not claim live CMO state'));
assert.ok(guidance.includes('CMO engine verification is required'));

assert.equal(classifyAdvisoryTopic('CAP 미션 자동화 스크립트 만들어줘').scope, 'cmo');
assert.equal(classifyAdvisoryTopic('Lua 코드 문법 확인해줘').scope, 'cmo');
assert.equal(classifyAdvisoryTopic('오늘 저녁 뭐 먹지?').scope, 'offTopic');

const redirect = formatOffTopicRedirect('오늘 저녁 뭐 먹지?');
assert.ok(redirect.includes('CMO'));
assert.ok(redirect.includes('시나리오'));
assert.equal(/꺼져|불가|지원하지 않/.test(redirect), false);

const luaAssistantSource = readFileSync(
  new URL('../src/components/LuaAssistant.jsx', import.meta.url),
  'utf8',
);

assert.ok(luaAssistantSource.includes('buildAdvisorySystemGuidance'));
assert.ok(luaAssistantSource.includes('## Advisory Chat Mode'));
assert.ok(luaAssistantSource.includes('hasImportedStateSnapshot'));

console.log('PASS - AI advisory chat policy contract holds.');
