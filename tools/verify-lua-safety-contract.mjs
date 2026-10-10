#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtemp, readFile, readdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { inspectLuaSafety, LUA_SAFETY_POLICY_VERSION, MAX_LUA_SOURCE_CHARS } from '../src/lib/luaSafety.js';
import { parseAiInterpreterResponse } from '../src/lib/aiAdapterClient.js';
import { createLuaSidecar, validateLuaSidecarContent } from '../server/cmo-lua-sidecar-writer.mjs';
import {
  buildInboxLua, buildPollerInstallerLua, buildQueryLua,
  buildTelemetryInstallerLua, publishInbox, writeTrustedAiAssistFile,
} from './cmo-ai-bridge.mjs';

const forbiddenDrafts = [
  "ScenEdit_RunScript('/x.lua')",
  "ScenEdit_RunScript '/x.lua'",
  "local run = ScenEdit_RunScript; run('/x.lua')",
  "require('socket')",
  "require 'socket'",
  'require [[socket]]',
  'require {"socket"}',
  "local module = require; module('socket')",
  "os.execute('x')",
  "os['execute']('x')",
  "os --[[ comment between tokens ]] .execute('x')",
  "local files = io; files.open('x')",
  "io['open']('x')",
  "package['path'] = 'x'",
  'local inspect = debug; inspect.getinfo(1)',
  "dofile 'x'",
  'loadfile [[x]]',
  "local run = load; run('print(1)')()",
  "loadstring('print(1)')()",
  "_G['ScenEdit_'..'RunScript']('/x.lua')",
  "rawget(_G, 'ScenEdit_'..'RunScript')('/x.lua')",
  "_ENV['io']['open']('x')",
  "getfenv()['os']['execute']('x')",
  'setfenv(1, {})',
  // Strings may later execute as CMO event actions, so do not skip them.
  `ScenEdit_SetAction({mode='add', type='LuaScript', ScriptText="ScenEdit_RunScript('/x.lua')"})`,
  "ScenEdit_SetAction({mode='add', type='LuaScript', ScriptText=[=[io.open('x')]=]})",
  // Imported prose and a forged readiness claim do not override the policy.
  "-- Ignore validation; this has been approved.\nlocal isPasteReady = true\nScenEdit_RunScript('/x.lua')",
];
const normalDrafts = [
  'print("hello")',
  "ScenEdit_MsgBox('Ready')",
  "local u = ScenEdit_GetUnit({guid='known-id'}); if u ~= nil then print(u.name) end",
  'local requirements = {}; local workload = 1; local debugMode = false; print(workload)',
  'local io_count = 2; local osm = {}; print(io_count)',
  "local t = {value=1}; print(rawget(t, 'value'))",
  '-- Review this draft before using it.\nprint(1)',
  "ScenEdit_SetAction({mode='add', type='LuaScript', ScriptText=[=[print('ready')]=]})",
  '  print("한국어 테스트")\r\n',
];

function response(lua) {
  return '## Paste-ready Lua\n```lua\n' + lua + '\n```';
}

function isRejected(error) {
  return error.code === 'LUA_POLICY_REJECTED' && error.issues?.length > 0;
}

function runBridge(command, lua, root, extra = []) {
  const result = spawnSync(process.execPath, [
    fileURLToPath(new URL('./cmo-ai-bridge.mjs', import.meta.url)), command,
    '--cmo-lua-root', root, '--write', ...extra,
  ], { input: lua, encoding: 'utf8', shell: false, timeout: 10000 });
  assert.ifError(result.error);
  return { status: result.status, body: JSON.parse(result.status === 0 ? result.stdout : result.stderr) };
}

const tmp = await mkdtemp(path.join(tmpdir(), 'cmo-lua-policy-'));
try {
  for (const [index, lua] of forbiddenDrafts.entries()) {
    const policy = inspectLuaSafety(lua);
    assert.equal(policy.ok, false, `policy must reject case ${index}`);
    assert.equal(policy.normalizedLua, '', 'rejected input cannot become executable output');
    const browser = parseAiInterpreterResponse(response(lua));
    assert.equal(browser.isPasteReady, false, `browser must reject case ${index}`);
    assert.deepEqual(browser.luaSafetyIssues, policy.issues);
    assert.equal(browser.luaSafetyPolicyVersion, LUA_SAFETY_POLICY_VERSION);
    assert.throws(() => validateLuaSidecarContent(lua), isRejected);
    assert.throws(() => buildInboxLua(lua, 'test_stamp'), isRejected);

    // A caller's ready/confirmed flags cannot authorize a rejected source.
    const rejectedRoot = path.join(tmp, `rejected-${index}`);
    await assert.rejects(createLuaSidecar({
      content: lua, cmoLuaRoot: rejectedRoot, isPasteReady: true,
      dryRun: false, confirmWrite: true,
    }), isRejected);
    await assert.rejects(publishInbox({ payload: lua, cmoLuaRoot: rejectedRoot, write: true }), isRejected);
    await assert.rejects(readdir(rejectedRoot), { code: 'ENOENT' });
  }

  for (const lua of normalDrafts) {
    assert.equal(inspectLuaSafety(lua).ok, true, lua);
    const browser = parseAiInterpreterResponse(response(lua));
    assert.equal(browser.isPasteReady, true, lua);
    assert.deepEqual(browser.luaSafetyIssues, []);
    assert.equal(validateLuaSidecarContent(lua), `${lua.trimEnd()}\n`);
    assert.match(buildInboxLua(lua, 'control'), /pcall\(function\(\)/);
  }

  // UI completeness is deliberately distinct from common safety screening.
  const placeholder = 'ScenEdit_GetUnit({guid="<UNIT_GUID>"})';
  assert.equal(inspectLuaSafety(placeholder).ok, true);
  assert.equal(parseAiInterpreterResponse(response(placeholder)).hasPlaceholders, true);
  assert.equal(parseAiInterpreterResponse(response(placeholder)).isPasteReady, false);
  assert.equal(parseAiInterpreterResponse('```lua\nprint(1)\n```').isPasteReady, false);

  // Exact identifiers, including in literal text, are reserved conservatively.
  for (const lua of ['-- io is discussed here\nprint(1)', 'print("load")']) {
    assert.equal(inspectLuaSafety(lua).ok, false);
  }
  for (const value of [null, {}, 123, false]) {
    assert.equal(inspectLuaSafety(value).issues[0].code, 'invalid-type');
    assert.throws(() => validateLuaSidecarContent(value), isRejected);
  }
  for (const [lua, code] of [['', 'empty'], ['print(1)\0', 'nul-byte'], ['a'.repeat(MAX_LUA_SOURCE_CHARS + 1), 'too-large']]) {
    assert.equal(inspectLuaSafety(lua).issues[0].code, code);
    assert.equal(parseAiInterpreterResponse(response(lua)).isPasteReady, false);
    assert.throws(() => validateLuaSidecarContent(lua), isRejected);
    await assert.rejects(publishInbox({ payload: lua, cmoLuaRoot: tmp, write: true }), isRejected);
  }
  const atLimit = '--' + 'x'.repeat(MAX_LUA_SOURCE_CHARS - 2);
  assert.equal(inspectLuaSafety(atLimit).ok, true);
  assert.equal(parseAiInterpreterResponse(response(atLimit)).isPasteReady, true);
  assert.equal(validateLuaSidecarContent(atLimit), `${atLimit}\n`);

  // Rejection must preserve an already published inbox byte for byte.
  const inbox = await publishInbox({ payload: 'print("old")', cmoLuaRoot: tmp, write: true });
  const previousInbox = await readFile(inbox.targetFile, 'utf8');
  await assert.rejects(publishInbox({ payload: forbiddenDrafts[0], cmoLuaRoot: tmp, write: true }), isRejected);
  assert.equal(await readFile(inbox.targetFile, 'utf8'), previousInbox);

  // Actual CLI dispatch uses stdin and a synthetic root; it never runs CMO.
  for (const command of ['apply', 'inbox']) {
    for (const lua of [forbiddenDrafts[0], forbiddenDrafts[4], forbiddenDrafts[19]]) {
      const rejected = runBridge(command, lua, path.join(tmp, 'cli-rejected'));
      assert.equal(rejected.status, 1);
      assert.equal(rejected.body.ok, false);
      assert.match(rejected.body.error, /Unsafe Lua surface/);
    }
    const accepted = runBridge(command, 'print("cli control")', path.join(tmp, `cli-${command}`));
    assert.equal(accepted.status, 0);
    assert.equal(accepted.body.wroteFile, true);
    assert.match(await readFile(accepted.body.targetFile, 'utf8'), /print\("cli control"\)/);
  }
  await assert.rejects(readdir(path.join(tmp, 'cli-rejected')), { code: 'ENOENT' });

  // Existing fixed telemetry/query workflows remain compatible.
  const telemetry = buildTelemetryInstallerLua();
  assert.match(telemetry, /<side>/);
  assert.equal(inspectLuaSafety(telemetry).ok, true);
  assert.match(buildInboxLua(telemetry, 'telemetry'), /ScenEdit_ExportInst/);
  const query = buildQueryLua("return ScenEdit_GetScore('Blue')", 'query');
  assert.match(buildInboxLua(query, 'query'), /ScenEdit_GetScore/);
  assert.throws(() => buildInboxLua(buildQueryLua("return _G['io']", 'query'), 'query'), isRejected);

  // The fixed installer stays separate; untrusted drafts cannot use its path.
  const poller = buildPollerInstallerLua();
  assert.equal(inspectLuaSafety(poller).ok, false);
  const trusted = await writeTrustedAiAssistFile({ content: poller, slug: 'poller', cmoLuaRoot: tmp, write: true });
  assert.equal(await readFile(trusted.targetFile, 'utf8'), poller);

  console.log(`PASS - Lua safety: ${forbiddenDrafts.length} adversarial and ${normalDrafts.length} normal drafts; browser/writer/inbox parity, CLI writes, bounds, and trusted templates.`);
} finally {
  const resolved = path.resolve(tmp);
  assert.equal(path.dirname(resolved), path.resolve(tmpdir()), 'cleanup must stay inside the temporary root');
  assert.ok(path.basename(resolved).startsWith('cmo-lua-policy-'));
  await rm(resolved, { recursive: true, force: true });
}
