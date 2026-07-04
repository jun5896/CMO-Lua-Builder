#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  FOLLOW_UP_NEED_CATEGORIES,
  deriveAiFollowUpNeeds,
  formatFollowUpNeedsForPrompt,
} from '../src/lib/aiFollowUpNeeds.js';

function ids(needs) {
  return needs.categories.map((category) => category.id);
}

function assertHas(idsToCheck, expectedId) {
  assert.equal(idsToCheck.includes(expectedId), true, `expected ${expectedId}`);
}

const mixedParsedResponse = {
  blockers: [
    'No Lua code block found.',
    'Placeholder tokens detected in Lua: <UNIT_GUID>',
  ],
  warnings: [
    'Missing section: paste-ready lua',
    'Confirm DBID and Loadout ID from Database Viewer.',
  ],
  followUpQuestions: [
    'What is the Blue Side name and Mission name?',
    'Confirm RP / Zone names and coordinates from the CMO map.',
    'Confirm posture, doctrine, and EMCON settings.',
  ],
  prerequisites: [
    'Use Copy unit ID to clipboard GUID for the selected unit.',
    'Weather range must be explicit.',
  ],
  missingRequiredSections: ['paste-ready lua'],
};

const needs = deriveAiFollowUpNeeds(mixedParsedResponse, 'Unsafe Lua surface detected: require(');
const categoryIds = ids(needs);

assert.equal(needs.hasNeeds, true);
assertHas(categoryIds, 'side');
assertHas(categoryIds, 'mission');
assertHas(categoryIds, 'unitGuid');
assertHas(categoryIds, 'dbid');
assertHas(categoryIds, 'loadout');
assertHas(categoryIds, 'rpZone');
assertHas(categoryIds, 'postureDoctrine');
assertHas(categoryIds, 'coordinates');
assertHas(categoryIds, 'weather');
assertHas(categoryIds, 'format');
assertHas(categoryIds, 'unsafeLua');

assert.equal(categoryIds.filter((id) => id === 'dbid').length, 1);
assert.equal(needs.categories.find((category) => category.id === 'unitGuid').severity, 'confirm');
assert.equal(needs.categories.find((category) => category.id === 'format').severity, 'format');
assert.equal(needs.categories.find((category) => category.id === 'unsafeLua').severity, 'safety');

const emptyNeeds = deriveAiFollowUpNeeds({}, '');
assert.equal(emptyNeeds.hasNeeds, false);
assert.deepEqual(emptyNeeds.categories, []);
assert.equal(emptyNeeds.summary, '확인 필요값 없음');

const promptText = formatFollowUpNeedsForPrompt(needs);
assert.match(promptText, /확인 필요값/);
assert.match(promptText, /Side/);
assert.match(promptText, /Unit GUID/);
assert.match(promptText, /DBID/);
assert.match(promptText, /추측하지 말 것/);
assert.match(promptText, /Paste-ready Lua/);

const first = deriveAiFollowUpNeeds(mixedParsedResponse, '');
first.categories.push({ id: 'mutated' });
first.categories[0].evidence.push('mutated evidence');
const second = deriveAiFollowUpNeeds(mixedParsedResponse, '');
assert.equal(ids(second).includes('mutated'), false);
assert.equal(second.categories[0].evidence.includes('mutated evidence'), false);

assert.equal(FOLLOW_UP_NEED_CATEGORIES.length >= 11, true);

console.log('PASS - AI follow-up needs contract holds.');
