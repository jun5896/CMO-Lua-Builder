#!/usr/bin/env node
/**
 * launch-ai-driver.mjs — pick an agent CLI and open it interactively in the
 * repo context, as the conversation driver for the CMO AI bridge.
 *
 *   node tools/launch-ai-driver.mjs                  # numbered menu (Enter = default)
 *   node tools/launch-ai-driver.mjs --backend codex:pro2
 *   node tools/launch-ai-driver.mjs --list           # print menu and exit
 *
 * Only CLI-class backends can drive an interactive session (Claude profiles,
 * Codex accounts, Grok, Cursor). BYOK HTTP backends (Kimi/GLM/Grok API) are
 * delegation targets via `npm run ask` from inside the session, not drivers.
 * The saved bridge selection (scan-ai-backends --use) becomes the menu
 * default when it is a CLI backend.
 *
 * The game is NOT launched here — run CMO separately; the bridge auto-detects
 * the install and reads its logs regardless of how the game was started.
 */

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import readline from 'node:readline';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

import { resolveCliExecutable } from '../server/cli-providers.mjs';
import { BACKENDS_CONFIG_PATH, scanBackends } from './scan-ai-backends.mjs';

const PROJECT_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const DRIVER_COMMANDS = {
  'claude-cli': { command: 'claude', homeEnv: 'CLAUDE_CONFIG_DIR' },
  'codex-cli': { command: 'codex', homeEnv: 'CODEX_HOME' },
  'grok-cli': { command: 'grok', homeEnv: '' },
  'cursor-cli': { command: 'cursor-agent', homeEnv: '' },
};

function savedSelectionId() {
  try {
    return JSON.parse(fs.readFileSync(BACKENDS_CONFIG_PATH, 'utf8'))?.id || '';
  } catch {
    return '';
  }
}

function driverBackends() {
  return scanBackends()
    .filter((backend) => backend.class === 'cli' && DRIVER_COMMANDS[backend.providerType])
    .filter((backend) => backend.cliAvailable);
}

function formatMenu(backends, defaultId) {
  const lines = ['', 'CMO AI Bridge — 대화 드라이버 선택 (게임은 따로 실행하세요; 브리지가 자동 감지합니다)', ''];
  backends.forEach((backend, index) => {
    const mark = backend.id === defaultId ? ' (기본)' : '';
    const account = backend.account ? `  [${backend.account}]` : '';
    lines.push(`  ${index + 1}. ${backend.label}${account}${mark}`);
  });
  lines.push('');
  lines.push('BYOK(Kimi/GLM/Grok API)는 세션 안에서 `npm run ask`로 위임하는 대상입니다.');
  return lines.join('\n');
}

function askNumber(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(String(answer || '').trim());
    });
  });
}

function launch(backend) {
  const driver = DRIVER_COMMANDS[backend.providerType];
  const executable = resolveCliExecutable(driver.command);
  if (!executable) {
    console.error(`${driver.command} CLI를 PATH에서 찾지 못했습니다.`);
    process.exitCode = 1;
    return;
  }

  const env = { ...process.env };
  if (driver.homeEnv && backend.cliHome) env[driver.homeEnv] = backend.cliHome;

  console.log(`\n[CMO AI Bridge] ${backend.label} 시작 — 리포: ${PROJECT_ROOT}\n`);
  const child = spawn(executable, [], {
    cwd: PROJECT_ROOT,
    env,
    stdio: 'inherit',
    shell: /\.(cmd|bat)$/i.test(executable),
  });
  child.on('close', (code) => { process.exitCode = code ?? 0; });
}

async function main() {
  const argv = process.argv.slice(2);
  const listOnly = argv.includes('--list');
  const backendFlag = argv.includes('--backend') ? argv[argv.indexOf('--backend') + 1] || '' : '';

  const backends = driverBackends();
  if (!backends.length) {
    console.error('사용 가능한 드라이버 CLI가 없습니다 (claude/codex/grok/cursor-agent 설치 확인).');
    process.exitCode = 1;
    return;
  }

  const saved = savedSelectionId();
  const defaultBackend = backends.find((backend) => backend.id === saved) || backends[0];

  if (backendFlag) {
    const chosen = backends.find((backend) => backend.id === backendFlag);
    if (!chosen) {
      console.error(`드라이버 백엔드가 아닙니다: ${backendFlag}. --list로 확인하세요.`);
      process.exitCode = 1;
      return;
    }
    launch(chosen);
    return;
  }

  console.log(formatMenu(backends, defaultBackend.id));

  if (listOnly) return;

  const answer = await askNumber(`번호 선택 (엔터 = ${defaultBackend.label}): `);
  let chosen = defaultBackend;
  if (answer) {
    const index = Number(answer) - 1;
    if (!Number.isInteger(index) || index < 0 || index >= backends.length) {
      console.error('잘못된 번호입니다.');
      process.exitCode = 1;
      return;
    }
    chosen = backends[index];
  }
  launch(chosen);
}

await main();
