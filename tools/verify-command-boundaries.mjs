#!/usr/bin/env node
import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import { PassThrough } from 'node:stream';
import { spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { callCliProvider, cliShellMode, buildCliInvocation } from '../server/cli-providers.mjs';
import { buildScenarioCommands, buildScenarioDecoderCommand, quotePowerShellArgument } from '../src/lib/scenarioCommands.js';

const payload = 'plain " & echo SHELL_MARKER & rem " %PATH% !name! \r\n second line';
const cfg = { providerType: 'grok-cli', model: 'auto', messages: [{ role: 'user', content: payload }] };
let spawns = 0;
for (const executable of ['C:\\mock\\grok.cmd', 'C:\\mock\\grok.BAT']) {
  const result = await callCliProvider(cfg, {
    resolveExecutable: () => executable,
    spawnProcess: () => { spawns += 1; throw new Error('Unsafe spawn must never be reached'); },
  });
  assert.equal(result.status, 502);
  assert.match(result.body.errorMessage, /native executable/);
}
assert.equal(spawns, 0);
for (const [providerType, executable, expectedShell] of [
  ['grok-cli', 'C:\\mock\\grok.exe', false],
  ['grok-cli', 'C:\\mock\\grok.com', false],
  ['grok-cli', '/mock/grok', false],
  ['claude-cli', 'C:\\mock\\claude.cmd', true],
]) {
  let stdin = '';
  let captured;
  const result = await callCliProvider({ ...cfg, providerType }, {
    resolveExecutable: () => executable,
    spawnProcess: (command, args, options) => {
      captured = { command, args, options };
      const child = new EventEmitter();
      child.stdin = new PassThrough();
      child.stdout = new PassThrough();
      child.stderr = new PassThrough();
      child.kill = () => {};
      child.stdin.on('data', (chunk) => { stdin += chunk; });
      queueMicrotask(() => { child.stdout.write('safe mock response'); child.emit('close', 0); });
      return child;
    },
  });
  assert.equal(result.status, 200);
  assert.equal(captured.command, executable);
  assert.equal(captured.options.shell, expectedShell);
  if (providerType === 'grok-cli') {
    assert.ok(captured.args[1].includes(payload));
    assert.equal(stdin, '');
  } else {
    assert.ok(stdin.includes(payload));
    assert.ok(!captured.args.some((arg) => arg.includes(payload)));
  }
}
assert.throws(() => cliShellMode('grok.cmd', buildCliInvocation({ ...cfg, prompt: payload })), /native executable/);
console.log('PASS - batch prompt rejection before spawn; native argv and stdin CLI controls');

const quotes = ["'", '\u2018', '\u2019', '\u201a', '\u201b'];
const paths = [
  'C:\\scenario folder\\ordinary 한글.scen',
  'C:\\scenario\\$(Write-Output MARKER).scen',
  ...quotes.map((quote) => 'C:\\scenario\\file' + quote + ';Write-Output MARKER;#.scen'),
  'C:\\scenario\\line\r\n#name.scen',
  'C:\\scenario\\backtick' + String.fromCharCode(96) + 'dollar$paren().scen',
];
const fixtures = [];
for (const source of paths) {
  const context = { sourcePath: source, decoderCommands: { prepare: 'Write-Output UNTRUSTED', extractXml: 'Write-Output BAD', scan: 'BAD', summarize: 'BAD' } };
  const command = buildScenarioDecoderCommand('file.scen', context);
  assert.equal(command, buildScenarioCommands(source).prepare);
  assert.ok(!command.includes('UNTRUSTED'));
  fixtures.push({ command, expected: [source] });
  for (const [name, generated] of Object.entries(buildScenarioCommands(source, 'same-name-0123abcd'))) {
    fixtures.push({ command: generated, expected: name === 'summarize'
      ? ['scenario-sidecars\\same-name-0123abcd.scenario.xml', 'scenario-sidecars\\same-name-0123abcd.summary.json']
      : [source] });
  }
}
const fallback = buildScenarioDecoderCommand('$(Write-Output MARKER).scen');
fixtures.push({ command: fallback, expected: ['C:\\path\\to\\$(Write-Output MARKER).scen'] });
assert.equal(quotePowerShellArgument("owner's.scen"), "'owner''s.scen'");

// Parse only: never execute copied commands, npm, a decoder, or the game.
const parser = "\n$ErrorActionPreference = 'Stop'\n$fixtureJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String([Console]::In.ReadToEnd()))\n$fixtures = ConvertFrom-Json $fixtureJson\nforeach ($fixture in $fixtures) {\n  $tokens = $null\n  $errors = $null\n  $ast = [System.Management.Automation.Language.Parser]::ParseInput([string]$fixture.command, [ref]$tokens, [ref]$errors)\n  if ($errors.Count -ne 0) { throw 'PowerShell parse error' }\n  $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))\n  if ($commands.Count -ne 1) { throw 'Unexpected nested or second command' }\n  $arguments = @($commands[0].CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.StringConstantExpressionAst] } | ForEach-Object { $_.Value })\n  foreach ($expected in $fixture.expected) {\n    if (-not ($arguments -ccontains $expected)) { throw 'Literal argument did not round-trip' }\n  }\n}\nWrite-Output ('PASS - PowerShell AST literal round trips: ' + $fixtures.Count)\n";
const shell = process.platform === 'win32' ? 'powershell.exe' : 'pwsh';
const parsed = spawnSync(shell, ['-NoProfile', '-NonInteractive', '-Command', parser], {
  input: Buffer.from(JSON.stringify(fixtures), 'utf8').toString('base64'),
  encoding: 'utf8', windowsHide: true,
});
if (parsed.error) throw parsed.error;
assert.equal(parsed.status, 0, parsed.stderr || parsed.stdout);
console.log(parsed.stdout.trim());
console.log('PASS - cached commands ignored; prepare/scan/extract/summary use literal arguments');

// Exercise the actual index writer and verifier using tiny XML wrappers only.
const fixtureRoot = await mkdtemp(path.join(os.tmpdir(), 'cmo-command-index-'));
try {
  const scenariosRoot = path.join(fixtureRoot, 'scenarios');
  for (const folder of ['a', 'b']) {
    await mkdir(path.join(scenariosRoot, folder), { recursive: true });
    await writeFile(path.join(scenariosRoot, folder, "owner'\u2019.scen"), '<Scenario><Title>Fixture</Title></Scenario>');
  }
  const indexPath = path.join(fixtureRoot, 'index.json');
  const env = {
    ...process.env,
    USERPROFILE: fixtureRoot,
    CMO_ROOT: fixtureRoot,
    CMO_SCENARIO_SIDECAR_ROOT: path.join(fixtureRoot, 'sidecars'),
  };
  const audit = spawnSync(process.execPath, [
    'tools/audit-cmo-scenario-openability.mjs', '--root', scenariosRoot, '--out', indexPath,
  ], { env, encoding: 'utf8', windowsHide: true });
  assert.equal(audit.status, 0, audit.stderr);
  const index = JSON.parse(await readFile(indexPath, 'utf8'));
  assert.equal(index.scenarios.length, 2);
  assert.notEqual(index.scenarios[0].slug, index.scenarios[1].slug);
  const verify = () => spawnSync(process.execPath, [
    'tools/verify-cmo-scenario-loader.mjs', '--index', indexPath, '--json',
  ], { env, encoding: 'utf8', windowsHide: true });
  const valid = verify();
  assert.equal(valid.status, 0, valid.stdout || valid.stderr);
  index.scenarios[0].commands.prepare += '; Write-Output UNTRUSTED';
  await writeFile(indexPath, JSON.stringify(index));
  const tampered = verify();
  assert.equal(tampered.status, 1);
  assert.equal(JSON.parse(tampered.stdout).ok, false);
} finally {
  assert.equal(path.dirname(path.resolve(fixtureRoot)), path.resolve(os.tmpdir()));
  await rm(fixtureRoot, { recursive: true, force: true });
}
console.log('PASS - index CLI round trip preserves duplicate-name slugs and rejects tampered commands');
