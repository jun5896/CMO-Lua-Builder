#!/usr/bin/env node
/**
 * ai-backend-ask.mjs — one-shot prompt against the selected AI backend.
 *
 *   npm run ask -- --prompt "..." [--system "..."] [--backend <id>] [--model <m>]
 *   echo "..." | npm run ask
 *
 * Uses the selection written by scan-ai-backends.mjs (--use). Lets the bridge
 * workflow delegate drafting/cross-review to Codex, Kimi, GLM, Grok, or a
 * specific Claude profile without the React UI. Prints the assistant text to
 * stdout; metadata goes to stderr.
 */

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

import { callProvider } from '../server/providers.mjs';
import { BACKENDS_CONFIG_PATH, buildSelection, scanBackends } from './scan-ai-backends.mjs';

function parseArgs(argv) {
  const options = { prompt: '', system: '', backend: '', model: '', timeoutMs: 0 };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--prompt') { options.prompt = argv[index + 1] || ''; index += 1; }
    else if (value === '--system') { options.system = argv[index + 1] || ''; index += 1; }
    else if (value === '--backend') { options.backend = argv[index + 1] || ''; index += 1; }
    else if (value === '--model') { options.model = argv[index + 1] || ''; index += 1; }
    else if (value === '--timeout-ms') { options.timeoutMs = Number(argv[index + 1] || 0); index += 1; }
  }
  return options;
}

async function readStdin() {
  if (process.stdin.isTTY) return '';
  let data = '';
  for await (const chunk of process.stdin) data += chunk;
  return data.trim();
}

function loadSelection(options) {
  if (options.backend) {
    return buildSelection(scanBackends(), options.backend, { model: options.model });
  }
  try {
    const saved = JSON.parse(fs.readFileSync(BACKENDS_CONFIG_PATH, 'utf8'));
    if (options.model) saved.model = options.model;
    return saved;
  } catch {
    throw new Error('No backend selected. Run: npm run backends -- --use <id>  (or pass --backend <id>)');
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const prompt = options.prompt || await readStdin();
  if (!prompt) throw new Error('Prompt required (--prompt "..." or stdin)');

  const selection = loadSelection(options);
  const apiKey = selection.apiKeyEnv ? (process.env[selection.apiKeyEnv] || '').trim() : '';
  if (selection.apiKeyEnv && !apiKey) {
    throw new Error(`Env var ${selection.apiKeyEnv} is empty — export the API key first`);
  }

  const messages = [];
  if (options.system) messages.push({ role: 'system', content: options.system });
  messages.push({ role: 'user', content: prompt });

  const cfg = {
    providerType: selection.providerType,
    baseUrl: selection.baseUrl || '',
    apiKey,
    model: selection.model,
    cliHome: selection.cliHome || '',
    messages,
    generationMode: 'provider-default',
    ...(options.timeoutMs > 0 ? { timeoutMs: options.timeoutMs } : {}),
  };

  process.stderr.write(`[ask] backend=${selection.id} model=${cfg.model}\n`);
  const result = await callProvider(cfg);

  if (!result.body?.ok) {
    throw new Error(result.body?.errorMessage || `backend returned HTTP ${result.status}`);
  }

  const text = result.body.response?.choices?.[0]?.message?.content
    || result.body.response?.message?.content
    || '';
  if (!text) throw new Error('Backend returned an empty assistant message');
  console.log(text);
}

const isDirectRun = process.argv[1]
  && path.resolve(process.argv[1]).toLowerCase() === fileURLToPath(import.meta.url).toLowerCase();

if (isDirectRun) {
  main().catch((error) => {
    console.error(JSON.stringify({ ok: false, error: error.message }));
    process.exitCode = 1;
  });
}
