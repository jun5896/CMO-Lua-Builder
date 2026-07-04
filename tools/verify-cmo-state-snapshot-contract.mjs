#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  MAX_CMO_STATE_IMPORT_BYTES,
  MAX_LUA_PREVIEW_CHARS,
  buildCmoStateSnapshot,
  redactCmoStateText,
} from '../server/cmo-state-snapshot-importer.mjs';

function repeatedSimEvents(count) {
  const events = Array.from({ length: count }, (_, index) => `
    <SimEvent>
      <ID>E${index}</ID>
      <Description>AI Event ${index}</Description>
      <Triggers><Trigger>T1</Trigger></Triggers>
      <Actions><Action>A1</Action></Actions>
    </SimEvent>
  `).join('\n');

  return `
<EventTriggers>
  <EventTrigger_RegularTime>
    <ID>T1</ID>
    <Description>Every minute</Description>
  </EventTrigger_RegularTime>
</EventTriggers>
<EventActions>
  <EventAction_LuaScript>
    <ID>A1</ID>
    <Description>AI Action</Description>
    <ScriptText>print("hello from state snapshot")</ScriptText>
  </EventAction_LuaScript>
</EventActions>
<SimEvents>${events}</SimEvents>
`;
}

function repeatedSpecialActions(count) {
  return `
<SpecialActions>
${Array.from({ length: count }, (_, index) => `
  <SpecialAction>
    <ID>SA${index}</ID>
    <Name>AI Special ${index}</Name>
    <Description>Special action ${index}</Description>
    <ScriptText>print("special ${index}")</ScriptText>
  </SpecialAction>
`).join('\n')}
</SpecialActions>
`;
}

function assertNoRawOrLuaBody(value, path = 'snapshot') {
  if (!value || typeof value !== 'object') return;
  assert.equal(Object.hasOwn(value, 'raw'), false, `${path} must not expose raw parser blocks`);
  assert.equal(Object.hasOwn(value, 'luaScript'), false, `${path} must not expose full luaScript`);
  assert.equal(Object.hasOwn(value, 'luaScripts'), false, `${path} must not expose full luaScripts`);

  if (Array.isArray(value)) {
    value.forEach((item, index) => assertNoRawOrLuaBody(item, `${path}[${index}]`));
    return;
  }

  for (const [key, child] of Object.entries(value)) {
    assertNoRawOrLuaBody(child, `${path}.${key}`);
  }
}

const stateText = [
  repeatedSimEvents(55),
  repeatedSpecialActions(55),
  'C:/Users/dlwls/secret/AiAssist.lua',
  String.raw`c:\Users\dlwls\secret\lower.lua`,
  String.raw`\\server\share\private\state.txt`,
  'Authorization: Bearer abcdefghijklmnop',
  'sk-testsecretvalue',
].join('\n');

const snapshot = buildCmoStateSnapshot(stateText, {
  now: '2026-05-11T00:00:00.000Z',
  sourceHint: 'toolDumpEvents',
});

assert.equal(snapshot.ok, true);
assert.equal(snapshot.snapshotId, 'cmo-state-2026-05-11T00-00-00-000Z');
assert.equal(snapshot.importedAt, '2026-05-11T00:00:00.000Z');
assert.equal(snapshot.source.type, 'toolDumpEvents');
assert.equal(snapshot.source.live, false);
assert.equal(snapshot.summary.totalEventCount, 55);
assert.equal(snapshot.summary.eventCount, 50);
assert.equal(snapshot.summary.eventsTruncated, true);
assert.equal(snapshot.summary.totalSpecialActionCount, 55);
assert.equal(snapshot.summary.specialActionCount, 50);
assert.equal(snapshot.summary.specialActionsTruncated, true);
assert.equal(snapshot.summary.luaPreviewCharUnit, 'utf16-code-units');
assert.equal(snapshot.summary.maxLuaPreviewChars, MAX_LUA_PREVIEW_CHARS);
assert.equal(snapshot.events.length, 50);
assert.equal(snapshot.specialActions.length, 50);
assert.equal(snapshot.events[0].luaScriptPreviews.length > 0, true);
assert.equal(snapshot.events[0].luaScriptPreviews[0].charUnit, 'utf16-code-units');
assert.equal(snapshot.events[0].actions[0].luaScriptPreview.charUnit, 'utf16-code-units');
assertNoRawOrLuaBody(snapshot);

const encoded = JSON.stringify(snapshot);
assert.doesNotMatch(encoded, /dlwls/i);
assert.doesNotMatch(encoded, /server\\share/i);
assert.doesNotMatch(encoded, /Bearer abcdefgh/i);
assert.doesNotMatch(encoded, /sk-testsecretvalue/i);
assert.equal(snapshot.redaction.count >= 4, true);

const redacted = redactCmoStateText('C:/Users/demo/path.lua Authorization: Bearer abcdefghijklmnop sk-proj-example');
assert.doesNotMatch(redacted.text, /Users\/demo/i);
assert.doesNotMatch(redacted.text, /Bearer abcdefgh/i);
assert.doesNotMatch(redacted.text, /sk-proj-example/i);
assert.equal(redacted.redactionsApplied >= 3, true);

const unknown = buildCmoStateSnapshot('plain text without CMO event shape', {
  now: '2026-05-11T00:01:00.000Z',
});
assert.equal(unknown.ok, true);
assert.equal(unknown.source.live, false);
assert.equal(unknown.summary.eventCount, 0);
assert.equal(unknown.warnings.length >= 1, true);

assert.throws(
  () => buildCmoStateSnapshot('x'.repeat(MAX_CMO_STATE_IMPORT_BYTES + 1)),
  /too large/i,
);
assert.throws(
  () => buildCmoStateSnapshot('   '),
  /empty/i,
);

const helperSource = await readFile('server/cmo-state-snapshot-importer.mjs', 'utf8');
assert.doesNotMatch(helperSource, /\b(?:writeFile|appendFile|truncate|unlink|rename|rm|watch)\b/);
assert.doesNotMatch(helperSource, /\b(?:spawn|exec|execFile|fork)\b/);
assert.match(helperSource, /Redact before parse/i);

console.log('PASS - CMO state snapshot helper contract holds.');
