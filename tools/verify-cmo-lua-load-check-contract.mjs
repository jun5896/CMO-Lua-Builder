#!/usr/bin/env node
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {
  buildLuaLoadCheck,
  parseLoadCheckArgs,
  runLuaLoadCheck,
} from './prepare-cmo-lua-load-check.mjs';

async function exists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), 'cmo-lua-load-check-'));
try {
  const cmoLuaRoot = path.join(tempRoot, 'Command - Modern Operations', 'Lua');
  await fs.mkdir(cmoLuaRoot, { recursive: true });

  const built = buildLuaLoadCheck({
    cmoLuaRoot,
    marker: 'AiAssist_B0LoadCheck_TEST',
  });
  assert.equal(built.fileName, 'AiAssist_B0LoadCheck.lua');
  assert.equal(built.scriptFolder, 'AiAssist_B0');
  assert.equal(built.targetFile, path.join(cmoLuaRoot, 'AiAssist_B0', 'AiAssist_B0LoadCheck.lua'));
  assert.equal(built.runScriptPath, '/AiAssist_B0/AiAssist_B0LoadCheck.lua');
  assert.match(built.lua, /AiAssist_B0LoadCheck_TEST/);
  assert.match(built.lua, /print\(marker\)/);
  assert.doesNotMatch(built.lua, /ScenEdit_SetKeyValue/);
  assert.doesNotMatch(built.lua, /\bos\./);
  assert.doesNotMatch(built.lua, /\bio\./);
  assert.doesNotMatch(built.lua, /\brequire\b/);
  assert.equal(built.loaderSnippet, "ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')");
  assert.doesNotMatch(built.loaderSnippet, /dofile/);

  const dryRun = await runLuaLoadCheck({
    cmoLuaRoot,
    marker: 'AiAssist_B0LoadCheck_DRY',
  });
  assert.equal(dryRun.mode, 'dry-run');
  assert.equal(dryRun.wroteFile, false);
  assert.equal(await exists(dryRun.targetFile), false);
  assert.equal(dryRun.manualSteps.some((step) => step.includes('ScenEdit_RunScript')), true);
  assert.equal(dryRun.manualSteps.some((step) => step.includes('dofile as nil')), true);

  const missingYes = await runLuaLoadCheck({
    cmoLuaRoot,
    write: true,
  });
  assert.equal(missingYes.mode, 'dry-run');
  assert.equal(missingYes.wroteFile, false);
  assert.equal(missingYes.writeBlockedReason, 'Writing requires --write and --yes.');

  const writeRun = await runLuaLoadCheck({
    cmoLuaRoot,
    write: true,
    yes: true,
    marker: 'AiAssist_B0LoadCheck_WRITE',
  });
  assert.equal(writeRun.mode, 'write');
  assert.equal(writeRun.wroteFile, true);
  assert.equal(await exists(writeRun.targetFile), true);
  assert.match(await fs.readFile(writeRun.targetFile, 'utf8'), /AiAssist_B0LoadCheck_WRITE/);

  await assert.rejects(
    () => runLuaLoadCheck({ cmoLuaRoot, write: true, yes: true }),
    /already exists/,
  );

  const overwriteRun = await runLuaLoadCheck({
    cmoLuaRoot,
    write: true,
    yes: true,
    overwrite: true,
    marker: 'AiAssist_B0LoadCheck_OVERWRITE',
  });
  assert.equal(overwriteRun.mode, 'write');
  assert.match(await fs.readFile(overwriteRun.targetFile, 'utf8'), /AiAssist_B0LoadCheck_OVERWRITE/);

  assert.throws(
    () => buildLuaLoadCheck({ cmoLuaRoot, fileName: '..\\bad.lua' }),
    /Unsafe load-check file name/,
  );
  assert.throws(
    () => buildLuaLoadCheck({ cmoLuaRoot, fileName: 'LuaInit.lua' }),
    /Unsafe load-check file name/,
  );
  assert.throws(
    () => buildLuaLoadCheck({ cmoLuaRoot, scriptFolder: '..\\bad' }),
    /Unsafe load-check script folder/,
  );
  assert.throws(
    () => parseLoadCheckArgs(['--scenario-folder', cmoLuaRoot]),
    /--scenario-folder is no longer supported/,
  );

  const parsed = parseLoadCheckArgs([
    '--cmo-lua-root',
    cmoLuaRoot,
    '--script-folder',
    'AiAssist_B0CustomFolder',
    '--file-name',
    'AiAssist_B0Custom.lua',
    '--marker',
    'custom-marker',
    '--write',
    '--yes',
    '--overwrite',
    '--json',
  ]);
  assert.equal(parsed.cmoLuaRoot, cmoLuaRoot);
  assert.equal(parsed.scriptFolder, 'AiAssist_B0CustomFolder');
  assert.equal(parsed.fileName, 'AiAssist_B0Custom.lua');
  assert.equal(parsed.marker, 'custom-marker');
  assert.equal(parsed.write, true);
  assert.equal(parsed.yes, true);
  assert.equal(parsed.overwrite, true);
  assert.equal(parsed.json, true);
} finally {
  await fs.rm(tempRoot, { recursive: true, force: true });
}

console.log('PASS - CMO Lua load-check contract holds.');
