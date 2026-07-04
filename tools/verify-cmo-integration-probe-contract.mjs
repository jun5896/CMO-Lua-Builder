#!/usr/bin/env node
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {
  formatProbeReport,
  parseProbeArgs,
  runCmoIntegrationProbe,
} from './probe-cmo-integration.mjs';

async function listRelativeFiles(root) {
  const files = [];

  async function visit(directory) {
    const entries = await fs.readdir(directory, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(directory, entry.name);
      if (entry.isDirectory()) {
        await visit(fullPath);
      } else if (entry.isFile()) {
        files.push(path.relative(root, fullPath).replace(/\\/g, '/'));
      }
    }
  }

  await visit(root);
  return files.sort();
}

const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), 'cmo-probe-'));
try {
  const cmoRoot = path.join(tempRoot, 'Command - Modern Operations');
  const scenariosRoot = path.join(cmoRoot, 'Scenarios');
  const logsRoot = path.join(cmoRoot, 'Logs');
  const scenarioFolder = path.join(scenariosRoot, 'Probe Scenario');

  await fs.mkdir(scenarioFolder, { recursive: true });
  await fs.mkdir(logsRoot, { recursive: true });
  await fs.writeFile(path.join(scenarioFolder, 'Probe Scenario.scen'), 'scenario fixture', 'utf8');
  await fs.writeFile(path.join(logsRoot, 'ExceptionLog_2026_05_09.txt'), 'fixture exception', 'utf8');
  await fs.writeFile(path.join(logsRoot, 'LuaHistory_2026_05_09_120000.txt'), 'fixture lua history', 'utf8');

  const beforeFiles = await listRelativeFiles(tempRoot);
  const result = await runCmoIntegrationProbe({
    cmoRoot,
    scenariosRoot,
    logsRoot,
    scenarioFolder,
  });
  const afterFiles = await listRelativeFiles(tempRoot);

  assert.deepEqual(afterFiles, beforeFiles, 'probe must not write files');
  assert.equal(result.summary.total, 8);
  assert.equal(result.summary.failed, 0);
  assert.equal(result.capabilities.cmoRoot.status, 'pass');
  assert.equal(result.capabilities.scenariosRoot.status, 'pass');
  assert.equal(result.capabilities.logsRoot.status, 'pass');
  assert.equal(result.capabilities.scenarioWriteAccess.status, 'pass');
  assert.equal(result.capabilities.exceptionLogPattern.status, 'pass');
  assert.equal(result.capabilities.exceptionLogPattern.count, 1);
  assert.equal(result.capabilities.luaHistoryPattern.status, 'pass');
  assert.equal(result.capabilities.luaHistoryPattern.count, 1);
  assert.equal(result.capabilities.luaAutoLoad.status, 'manual');
  assert.equal(result.capabilities.safePathPrefixes.status, 'pass');
  assert.deepEqual(result.safePathPrefixes, [cmoRoot, scenariosRoot, logsRoot]);

  const report = formatProbeReport(result);
  assert.match(report, /Track B0 CMO Integration Probe/);
  assert.match(report, /manual check required/i);
  assert.match(report, /ExceptionLog_\*\.txt/);
  assert.match(report, /LuaHistory_\*\.txt/);
  assert.match(report, /does not write files/i);

  const parsed = parseProbeArgs([
    '--cmo-root',
    cmoRoot,
    '--scenarios-root',
    scenariosRoot,
    '--logs-root',
    logsRoot,
    '--scenario-folder',
    scenarioFolder,
    '--json',
    '--strict',
  ]);
  assert.equal(parsed.cmoRoot, cmoRoot);
  assert.equal(parsed.scenariosRoot, scenariosRoot);
  assert.equal(parsed.logsRoot, logsRoot);
  assert.equal(parsed.scenarioFolder, scenarioFolder);
  assert.equal(parsed.json, true);
  assert.equal(parsed.strict, true);

  const missingResult = await runCmoIntegrationProbe({
    cmoRoot: path.join(tempRoot, 'Missing CMO'),
    scenariosRoot: path.join(tempRoot, 'Missing CMO', 'Scenarios'),
    logsRoot: path.join(tempRoot, 'Missing CMO', 'Logs'),
  });
  assert.equal(missingResult.capabilities.cmoRoot.status, 'fail');
  assert.equal(missingResult.capabilities.scenarioWriteAccess.status, 'unknown');
  assert.equal(missingResult.summary.failed > 0, true);
} finally {
  await fs.rm(tempRoot, { recursive: true, force: true });
}

console.log('PASS - CMO integration probe contract holds.');
