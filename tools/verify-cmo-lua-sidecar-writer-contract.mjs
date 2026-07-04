#!/usr/bin/env node
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, readFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {
  DEFAULT_CMO_LUA_ROOT,
  DEFAULT_SCRIPT_FOLDER,
  buildLuaSidecarReport,
  createLuaSidecar,
  sanitizeLuaSidecarFileName,
  validateLuaSidecarContent,
} from '../server/cmo-lua-sidecar-writer.mjs';

const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-lua-sidecar-writer-'));

try {
  assert.match(DEFAULT_CMO_LUA_ROOT, /Command - Modern Operations[\\/]Lua$/);
  assert.equal(DEFAULT_SCRIPT_FOLDER, 'AiAssist');

  assert.equal(
    sanitizeLuaSidecarFileName({ slug: 'Strike Alpha' }).startsWith('AiAssist_'),
    true,
  );
  assert.equal(sanitizeLuaSidecarFileName({ fileName: 'AiAssist_safe-name_01.lua' }), 'AiAssist_safe-name_01.lua');
  assert.throws(() => sanitizeLuaSidecarFileName({ fileName: '../AiAssist_bad.lua' }), /Invalid AiAssist Lua filename/);
  assert.throws(() => sanitizeLuaSidecarFileName({ fileName: 'LuaInit.lua' }), /Invalid AiAssist Lua filename/);

  validateLuaSidecarContent('print("hello")\nScenEdit_SpecialMessage("Blue", "Ready")');
  assert.throws(() => validateLuaSidecarContent('os.execute("calc")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('io.open("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('require("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('dofile("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('loadfile("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('package.path = "x"'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('debug.getinfo(1)'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('ScenEdit_RunScript("/x.lua")'), /Unsafe Lua surface/);

  const dryRun = await createLuaSidecar({
    cmoLuaRoot: tmp,
    content: 'print("AI draft")',
    slug: 'Strike Alpha',
    isPasteReady: true,
  });
  assert.equal(dryRun.mode, 'dry-run');
  assert.equal(dryRun.wroteFile, false);
  assert.equal(dryRun.confirmedDryRun, true);
  assert.equal(dryRun.confirmedWrite, false);
  assert.equal(dryRun.scriptFolder, 'AiAssist');
  assert.equal(Object.hasOwn(dryRun, 'lua'), false);
  assert.match(dryRun.fileName, /^AiAssist_\d{8}_\d{6}_strike-alpha\.lua$/);
  assert.match(dryRun.loaderSnippet, /^ScenEdit_RunScript\('\/AiAssist\/AiAssist_/);

  assert.throws(
    () => buildLuaSidecarReport({ cmoLuaRoot: tmp, content: 'print(1)', isPasteReady: false }),
    /isPasteReady must be true/,
  );

  await assert.rejects(
    () => createLuaSidecar({
      cmoLuaRoot: tmp,
      content: 'print("blocked")',
      slug: 'Blocked',
      isPasteReady: true,
      dryRun: false,
      confirmWrite: false,
    }),
    /confirmWrite must be true/,
  );

  const writeResult = await createLuaSidecar({
    cmoLuaRoot: tmp,
    content: 'print("write ok")',
    fileName: 'AiAssist_20260510_052500_write-ok.lua',
    isPasteReady: true,
    dryRun: false,
    confirmWrite: true,
  });
  assert.equal(writeResult.mode, 'write');
  assert.equal(writeResult.wroteFile, true);
  assert.equal(writeResult.confirmedDryRun, false);
  assert.equal(writeResult.confirmedWrite, true);
  assert.equal(Object.hasOwn(writeResult, 'lua'), false);
  assert.equal(writeResult.runScriptPath, '/AiAssist/AiAssist_20260510_052500_write-ok.lua');
  assert.equal(writeResult.loaderSnippet, "ScenEdit_RunScript('/AiAssist/AiAssist_20260510_052500_write-ok.lua')");

  const written = await readFile(path.join(tmp, 'AiAssist', 'AiAssist_20260510_052500_write-ok.lua'), 'utf8');
  assert.equal(written, 'print("write ok")\n');

  await assert.rejects(
    () => createLuaSidecar({
      cmoLuaRoot: tmp,
      content: 'print("no overwrite")',
      fileName: 'AiAssist_20260510_052500_write-ok.lua',
      isPasteReady: true,
      dryRun: false,
      confirmWrite: true,
    }),
    /already exists/,
  );

  await mkdir(path.join(tmp, 'outside'), { recursive: true });
  await assert.rejects(
    () => createLuaSidecar({
      cmoLuaRoot: tmp,
      content: 'print("unsafe")',
      fileName: 'AiAssist_20260510_052500_.._unsafe.lua',
      isPasteReady: true,
      dryRun: false,
      confirmWrite: true,
    }),
    /Invalid AiAssist Lua filename/,
  );

  console.log('PASS - CMO Lua sidecar writer contract holds.');
} finally {
  await rm(tmp, { recursive: true, force: true });
}
