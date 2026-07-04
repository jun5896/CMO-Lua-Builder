#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  CONFIRMED_CONTEXT_SOURCES,
  CONFIRMED_CONTEXT_TYPES,
  formatConfirmedContextForFollowUp,
  formatConfirmedContextForPrompt,
  getConfirmedContextDisplayGroups,
  hasConfirmedContextEntries,
  makeConfirmedContextEntry,
  normalizeConfirmedContextEntries,
} from '../src/lib/aiConfirmedContext.js';

const entries = normalizeConfirmedContextEntries([
  {
    type: 'side',
    value: 'Blue',
    source: 'manual-cmo-ui',
    sourceDetail: 'CMO side list',
  },
  {
    type: 'side',
    value: 'Blue',
    source: 'manual-cmo-ui',
    sourceDetail: 'Duplicate from CMO side list',
  },
  {
    type: 'unitGuid',
    label: 'AEW #1',
    value: '2f25a7d1-aaaa-bbbb-cccc-0123456789ab',
    source: 'copy-unit-guid',
  },
  {
    type: 'dbid',
    value: '2990',
    source: 'database-viewer',
  },
  {
    type: 'loadout',
    value: '1404',
    source: 'database-viewer',
  },
  {
    type: 'rpZone',
    value: 'CAP Box North',
    source: 'scenario-sidecar-summary',
  },
  {
    type: 'note',
    value: 'Authorization: Bearer sk-secret-value',
    source: 'manual-cmo-ui',
  },
]);

assert.equal(CONFIRMED_CONTEXT_TYPES.length, 10);
assert.equal(CONFIRMED_CONTEXT_SOURCES.length, 6);
assert.equal(entries.length, 6);
assert.equal(hasConfirmedContextEntries(entries), true);
assert.equal(entries.find((entry) => entry.type === 'note').value, '<REDACTED>');
assert.equal(entries.find((entry) => entry.type === 'side').label, 'Blue');

const promptSection = formatConfirmedContextForPrompt(entries);
assert.match(promptSection, /## User-confirmed CMO values/);
assert.match(promptSection, /Side: Blue/);
assert.match(promptSection, /Unit GUID: AEW #1 = 2f25a7d1-aaaa-bbbb-cccc-0123456789ab/);
assert.match(promptSection, /DBID: 2990/);
assert.match(promptSection, /Use these exact values when relevant/);
assert.match(promptSection, /ask back instead of inventing/);
assert.doesNotMatch(promptSection, /sk-secret-value/);

const followUpSection = formatConfirmedContextForFollowUp(entries);
assert.match(followUpSection, /Already confirmed CMO values/);
assert.match(followUpSection, /Loadout ID: 1404/);
assert.doesNotMatch(followUpSection, /Authorization/);

const groups = getConfirmedContextDisplayGroups(entries);
assert.equal(groups.some((group) => group.type === 'side' && group.entries.length === 1), true);
assert.equal(groups.some((group) => group.type === 'unitGuid' && group.label === 'Unit GUID'), true);

const made = makeConfirmedContextEntry({
  type: 'weather',
  value: 'Sea state 2-3',
  source: 'manual-cmo-ui',
  notes: 'Confirmed before random weather event',
});
assert.equal(made.type, 'weather');
assert.equal(made.label, 'Sea state 2-3');
assert.equal(made.sourceLabel, 'CMO UI');

const emptyEntries = normalizeConfirmedContextEntries([]);
assert.equal(hasConfirmedContextEntries(emptyEntries), false);
assert.equal(formatConfirmedContextForPrompt(emptyEntries), '');
assert.equal(formatConfirmedContextForFollowUp(emptyEntries), '');
assert.deepEqual(getConfirmedContextDisplayGroups(emptyEntries), []);

const mutationInput = [{ type: 'mission', value: 'CAP North', source: 'manual-cmo-ui' }];
const normalizedOnce = normalizeConfirmedContextEntries(mutationInput);
normalizedOnce[0].value = 'MUTATED';
const normalizedAgain = normalizeConfirmedContextEntries(mutationInput);
assert.equal(normalizedAgain[0].value, 'CAP North');

console.log('PASS - confirmed context helper contract holds.');
