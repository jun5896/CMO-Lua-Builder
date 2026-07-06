#!/usr/bin/env node
/**
 * scan-ai-backends.mjs — discover usable AI backends on this machine and let
 * the user pick one for the adapter/bridge.
 *
 *   node tools/scan-ai-backends.mjs                 # human-readable list
 *   node tools/scan-ai-backends.mjs --json          # machine-readable
 *   node tools/scan-ai-backends.mjs --use <id>      # select backend
 *   node tools/scan-ai-backends.mjs --use <id> --key-env MOONSHOT_API_KEY
 *
 * Discovered backend classes:
 *   1. Subscription CLIs with multiple local accounts/profiles:
 *      - Claude Code : ~/.claude plus ~/.claude-* profile dirs (CLAUDE_CONFIG_DIR)
 *      - Codex       : ~/.codex plus ~/.codex-*   account homes (CODEX_HOME)
 *      - Cursor      : cursor-agent CLI if installed (Composer via subscription;
 *                      Cursor blocks BYOK HTTP access to Composer)
 *   2. BYOK HTTP presets (API key via environment variable, never stored):
 *      - Kimi (Moonshot), GLM (Zhipu/Z.AI), Grok (xAI)
 *
 * Selection is written to server/.cmo-ai-backends.json (gitignored). API keys
 * are NEVER written — only the env-var NAME that holds the key.
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { resolveCliExecutable } from '../server/cli-providers.mjs';

const PROJECT_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
export const BACKENDS_CONFIG_PATH = path.join(PROJECT_ROOT, 'server', '.cmo-ai-backends.json');

// Keep the per-backend model menu short by design (user request: ~2 entries).
const CLAUDE_MODELS = ['fable', 'opus'];
const CODEX_FALLBACK_MODEL = 'gpt-5.5-codex';

export const BYOK_PRESETS = [
  {
    id: 'byok:kimi',
    label: 'Kimi for Coding — Anthropic-compatible (검증: 2026-07-05)',
    providerType: 'anthropic-compatible',
    // Kimi for Coding 구독 키 전용 엔드포인트 (open-platform 키는 byok:kimi-openai 사용).
    baseUrl: 'https://api.kimi.com/coding',
    models: ['kimi-for-coding'],
    keyEnvCandidates: ['MOONSHOT_API_KEY', 'KIMI_API_KEY'],
    notes: 'K2.7은 thinking 블록 포함 응답 — 파서가 text 블록만 추출함',
  },
  {
    id: 'byok:kimi-openai',
    label: 'Kimi (Moonshot) — standard API / OpenAI-compatible',
    providerType: 'openai-compatible',
    baseUrl: 'https://api.moonshot.ai/v1',
    models: ['kimi-latest', 'kimi-k2.5'],
    keyEnvCandidates: ['MOONSHOT_API_KEY', 'KIMI_API_KEY'],
  },
  {
    id: 'byok:glm',
    label: 'GLM (Z.AI) — coding plan / Anthropic-compatible',
    providerType: 'anthropic-compatible',
    baseUrl: 'https://api.z.ai/api/anthropic',
    models: ['glm-5.2', 'glm-4.7'],
    keyEnvCandidates: ['ZAI_API_KEY', 'GLM_API_KEY', 'ZHIPU_API_KEY'],
    notes: '표준 키는 openai-compatible + https://api.z.ai/api/paas/v4 로도 사용 가능',
  },
  {
    id: 'byok:glm-openai',
    label: 'GLM (Z.AI) — standard API / OpenAI-compatible',
    providerType: 'openai-compatible',
    baseUrl: 'https://api.z.ai/api/paas/v4',
    models: ['glm-5.2', 'glm-4.7'],
    keyEnvCandidates: ['ZAI_API_KEY', 'GLM_API_KEY', 'ZHIPU_API_KEY'],
  },
  {
    id: 'byok:grok',
    label: 'Grok (xAI) — OpenAI-compatible',
    providerType: 'openai-compatible',
    baseUrl: 'https://api.x.ai/v1',
    models: ['grok-4-1', 'grok-code-fast-1'],
    keyEnvCandidates: ['XAI_API_KEY', 'GROK_API_KEY'],
    notes: 'SuperGrok 채팅 구독과 별개로 console.x.ai에서 발급한 API 키 필요',
  },
];

function readJsonSafe(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

function listProfileDirs(prefix) {
  const home = os.homedir();
  const results = [];
  const base = path.join(home, prefix);
  if (fs.existsSync(base) && fs.statSync(base).isDirectory()) results.push(base);

  for (const entry of fs.readdirSync(home, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    if (entry.name.startsWith(`${prefix}-`)) results.push(path.join(home, entry.name));
  }
  return results;
}

function profileSuffix(dirPath, prefix) {
  const name = path.basename(dirPath);
  return name === prefix ? 'default' : name.slice(prefix.length + 1);
}

function claudeAccountEmail(profileDir) {
  const inDir = readJsonSafe(path.join(profileDir, '.claude.json'));
  if (inDir?.oauthAccount?.emailAddress) return inDir.oauthAccount.emailAddress;
  if (path.basename(profileDir) === '.claude') {
    const atHome = readJsonSafe(path.join(os.homedir(), '.claude.json'));
    if (atHome?.oauthAccount?.emailAddress) return atHome.oauthAccount.emailAddress;
  }
  return '';
}

function decodeJwtEmail(token) {
  try {
    const payload = JSON.parse(Buffer.from(
      String(token).split('.')[1].replace(/-/g, '+').replace(/_/g, '/'),
      'base64',
    ).toString('utf8'));
    return payload.email || '';
  } catch {
    return '';
  }
}

function codexAccountEmail(homeDir) {
  const auth = readJsonSafe(path.join(homeDir, 'auth.json'));
  const idToken = auth?.tokens?.id_token || auth?.id_token;
  return idToken ? decodeJwtEmail(idToken) : '';
}

function codexConfiguredModel(homeDir) {
  try {
    const toml = fs.readFileSync(path.join(homeDir, 'config.toml'), 'utf8');
    const match = toml.match(/^model\s*=\s*"([^"]+)"/m);
    return match ? match[1] : '';
  } catch {
    return '';
  }
}

export function scanBackends() {
  const backends = [];

  const claudeCli = resolveCliExecutable('claude');
  for (const dir of listProfileDirs('.claude')) {
    const suffix = profileSuffix(dir, '.claude');
    backends.push({
      id: `claude:${suffix}`,
      class: 'cli',
      providerType: 'claude-cli',
      label: `Claude Code — ${suffix}`,
      account: claudeAccountEmail(dir),
      cliHome: dir,
      cliAvailable: Boolean(claudeCli),
      models: CLAUDE_MODELS,
      defaultModel: CLAUDE_MODELS[0],
    });
  }

  const codexCli = resolveCliExecutable('codex');
  for (const dir of listProfileDirs('.codex')) {
    if (!fs.existsSync(path.join(dir, 'auth.json'))) continue;
    const suffix = profileSuffix(dir, '.codex');
    const configured = codexConfiguredModel(dir);
    const models = [...new Set([configured, CODEX_FALLBACK_MODEL].filter(Boolean))];
    backends.push({
      id: `codex:${suffix}`,
      class: 'cli',
      providerType: 'codex-cli',
      label: `Codex — ${suffix}`,
      account: codexAccountEmail(dir),
      cliHome: dir,
      cliAvailable: Boolean(codexCli),
      models,
      defaultModel: models[0],
    });
  }

  const cursorCli = resolveCliExecutable('cursor-agent');
  backends.push({
    id: 'cursor:default',
    class: 'cli',
    providerType: 'cursor-cli',
    label: 'Cursor — Composer (subscription CLI)',
    account: '',
    cliHome: '',
    cliAvailable: Boolean(cursorCli),
    models: ['composer'],
    defaultModel: 'composer',
    notes: cursorCli ? '' : 'cursor-agent 미설치 — `npm i -g @cursor/cli` 후 사용 가능. Composer는 BYOK HTTP 차단(구독 CLI 전용)',
  });

  const grokCli = resolveCliExecutable('grok');
  backends.push({
    id: 'grok:default',
    class: 'cli',
    providerType: 'grok-cli',
    label: 'Grok — Build CLI (subscription)',
    account: '',
    cliHome: '',
    cliAvailable: Boolean(grokCli),
    models: ['auto'],
    defaultModel: 'auto',
    notes: 'auto = CLI 기본 모델 (-m 오버라이드는 --model로). 프롬프트가 argv로 전달되어 28K자 제한',
  });

  for (const preset of BYOK_PRESETS) {
    const keyEnv = preset.keyEnvCandidates.find((name) => (process.env[name] || '').trim());
    backends.push({
      id: preset.id,
      class: 'byok',
      providerType: preset.providerType,
      label: preset.label,
      baseUrl: preset.baseUrl,
      models: preset.models,
      defaultModel: preset.models[0],
      keyEnvCandidates: preset.keyEnvCandidates,
      keyEnvDetected: keyEnv || '',
      ...(preset.notes ? { notes: preset.notes } : {}),
    });
  }

  return backends;
}

export function buildSelection(backends, id, { model = '', keyEnv = '' } = {}) {
  const backend = backends.find((entry) => entry.id === id);
  if (!backend) {
    throw new Error(`Unknown backend id: ${id}. Run without --use to list ids.`);
  }

  const chosenModel = model || backend.defaultModel;
  if (model && !backend.models.includes(model)) {
    // Allowed, but surface it — curated lists are short on purpose.
    process.stderr.write(`note: model "${model}" is not in the curated list [${backend.models.join(', ')}]\n`);
  }

  const selection = {
    selectedAt: new Date().toISOString(),
    id: backend.id,
    label: backend.label,
    providerType: backend.providerType,
    model: chosenModel,
    baseUrl: backend.baseUrl || '',
    cliHome: backend.cliHome || '',
  };

  if (backend.class === 'byok') {
    const envName = keyEnv || backend.keyEnvDetected;
    if (!envName) {
      throw new Error(
        `API key env var not set. Set one of [${backend.keyEnvCandidates.join(', ')}] `
        + 'or pass --key-env <NAME>. The key itself is never written to disk.',
      );
    }
    selection.apiKeyEnv = envName;
  }

  if (backend.class === 'cli' && !backend.cliAvailable) {
    process.stderr.write(`warning: ${backend.providerType} CLI not found on PATH — selection saved but calls will fail until installed\n`);
  }

  return selection;
}

function formatHuman(backends, selected) {
  const lines = ['AI backends discovered on this machine:', ''];

  const groups = [
    ['Subscription CLIs', backends.filter((b) => b.class === 'cli')],
    ['BYOK (API key via env var)', backends.filter((b) => b.class === 'byok')],
  ];

  for (const [title, entries] of groups) {
    lines.push(`## ${title}`);
    for (const b of entries) {
      const mark = selected?.id === b.id ? '▶' : ' ';
      const status = b.class === 'cli'
        ? (b.cliAvailable ? 'CLI OK' : 'CLI 미설치')
        : (b.keyEnvDetected ? `key: ${b.keyEnvDetected}` : `key env 필요 (${b.keyEnvCandidates.join('/')})`);
      const account = b.account ? `  [${b.account}]` : '';
      lines.push(`${mark} ${b.id.padEnd(18)} ${status.padEnd(14)} models: ${b.models.join(', ')}${account}`);
      if (b.notes) lines.push(`    └ ${b.notes}`);
    }
    lines.push('');
  }

  lines.push('Select:  npm run backends -- --use <id> [--model <m>] [--key-env <NAME>]');
  if (selected) lines.push(`Current: ${selected.id} / ${selected.model}`);
  return lines.join('\n');
}

function parseArgs(argv) {
  const options = { json: false, use: '', model: '', keyEnv: '' };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--json') options.json = true;
    else if (value === '--use') { options.use = argv[index + 1] || ''; index += 1; }
    else if (value === '--model') { options.model = argv[index + 1] || ''; index += 1; }
    else if (value === '--key-env') { options.keyEnv = argv[index + 1] || ''; index += 1; }
  }
  return options;
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const backends = scanBackends();
  const current = readJsonSafe(BACKENDS_CONFIG_PATH);

  if (options.use) {
    const selection = buildSelection(backends, options.use, { model: options.model, keyEnv: options.keyEnv });
    fs.writeFileSync(BACKENDS_CONFIG_PATH, `${JSON.stringify(selection, null, 2)}\n`, 'utf8');
    console.log(JSON.stringify({ ok: true, saved: BACKENDS_CONFIG_PATH, selection }, null, 2));
    return;
  }

  if (options.json) {
    console.log(JSON.stringify({ ok: true, backends, selected: current || null }, null, 2));
    return;
  }

  console.log(formatHuman(backends, current));
}

const isDirectRun = process.argv[1]
  && path.resolve(process.argv[1]).toLowerCase() === fileURLToPath(import.meta.url).toLowerCase();

if (isDirectRun) {
  try {
    main();
  } catch (error) {
    console.error(JSON.stringify({ ok: false, error: error.message }));
    process.exitCode = 1;
  }
}
