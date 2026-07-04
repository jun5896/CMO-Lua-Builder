#!/usr/bin/env node
import assert from 'node:assert/strict';

import { buildCliInvocation, flattenMessagesToPrompt } from '../server/cli-providers.mjs';
import { buildAnthropicRequestBody, normalizeAnthropicResponse, PROVIDER_TYPES } from '../server/providers.mjs';
import { BYOK_PRESETS, buildSelection, scanBackends } from './scan-ai-backends.mjs';

// --- provider type surface -------------------------------------------------
for (const type of ['openai-compatible', 'anthropic-compatible', 'ollama', 'lm-studio', 'claude-cli', 'codex-cli', 'cursor-cli', 'grok-cli']) {
  assert.ok(PROVIDER_TYPES.has(type), `PROVIDER_TYPES missing ${type}`);
}

// --- message flattening ------------------------------------------------------
const prompt = flattenMessagesToPrompt([
  { role: 'system', content: 'You are a CMO Lua assistant.' },
  { role: 'user', content: 'Write a marker print.' },
]);
assert.match(prompt, /^\[system\]/);
assert.match(prompt, /\[user\]/);
assert.match(prompt, /assistant message only/);

// --- CLI invocation builders -------------------------------------------------
const claudePlan = buildCliInvocation({ providerType: 'claude-cli', model: 'fable', cliHome: 'C:\\Users\\x\\.claude-work' });
assert.equal(claudePlan.command, 'claude');
assert.deepEqual(claudePlan.args.slice(0, 2), ['-p', '--output-format']);
assert.ok(claudePlan.args.includes('--model') && claudePlan.args.includes('fable'));
assert.equal(claudePlan.envOverrides.CLAUDE_CONFIG_DIR, 'C:\\Users\\x\\.claude-work');
assert.equal(claudePlan.promptViaStdin, true);

const codexPlan = buildCliInvocation({ providerType: 'codex-cli', model: 'gpt-5.5', cliHome: 'C:\\Users\\x\\.codex-pro2', lastMessageFile: 'C:\\tmp\\last.txt' });
assert.equal(codexPlan.command, 'codex');
assert.equal(codexPlan.args[0], 'exec');
assert.ok(codexPlan.args.includes('--sandbox') && codexPlan.args.includes('read-only'));
assert.ok(codexPlan.args.includes('--output-last-message'));
assert.equal(codexPlan.args.at(-1), '-');
assert.equal(codexPlan.envOverrides.CODEX_HOME, 'C:\\Users\\x\\.codex-pro2');

const cursorPlan = buildCliInvocation({ providerType: 'cursor-cli', model: 'composer' });
assert.equal(cursorPlan.command, 'cursor-agent');
assert.ok(cursorPlan.args.includes('composer'));
assert.ok(cursorPlan.args.includes('--trust'));

const grokPlan = buildCliInvocation({ providerType: 'grok-cli', model: 'auto', prompt: 'hello grok' });
assert.equal(grokPlan.command, 'grok');
assert.deepEqual(grokPlan.args.slice(0, 2), ['-p', 'hello grok']);
assert.equal(grokPlan.promptViaStdin, false);
assert.ok(!grokPlan.args.includes('-m'), "model 'auto' omits the -m flag");
const grokModelPlan = buildCliInvocation({ providerType: 'grok-cli', model: 'grok-4-1', prompt: 'x' });
assert.ok(grokModelPlan.args.includes('-m') && grokModelPlan.args.includes('grok-4-1'));
assert.throws(() => buildCliInvocation({ providerType: 'grok-cli', prompt: 'x'.repeat(28_001) }), /argv limit/);
assert.throws(() => buildCliInvocation({ providerType: 'grok-cli', prompt: '' }), /requires the prompt/);

assert.throws(() => buildCliInvocation({ providerType: 'claude-cli', model: 'bad model!' }), /Invalid CLI model/);

// --- anthropic-compatible builders -------------------------------------------
const anthropicBody = buildAnthropicRequestBody({
  model: 'glm-5.2',
  generationMode: 'provider-default',
  messages: [
    { role: 'system', content: 'sys' },
    { role: 'user', content: 'hello' },
  ],
});
assert.equal(anthropicBody.model, 'glm-5.2');
assert.equal(anthropicBody.system, 'sys');
assert.equal(anthropicBody.messages.length, 1);
assert.ok(Number.isFinite(anthropicBody.max_tokens), 'max_tokens is mandatory for /v1/messages');
assert.equal(anthropicBody.temperature, undefined);

const normalized = normalizeAnthropicResponse({
  model: 'kimi-for-coding',
  stop_reason: 'end_turn',
  content: [{ type: 'text', text: 'hello ' }, { type: 'text', text: 'world' }],
  usage: { input_tokens: 10, output_tokens: 5 },
});
assert.equal(normalized.choices[0].message.content, 'hello world');
assert.equal(normalized.choices[0].finish_reason, 'end_turn');
assert.equal(normalized.usage.prompt_tokens, 10);

// --- scanner -------------------------------------------------------------------
const backends = scanBackends();
assert.ok(backends.length >= BYOK_PRESETS.length, 'scanner returns at least the BYOK presets');
for (const backend of backends) {
  assert.ok(backend.id && backend.providerType && Array.isArray(backend.models) && backend.models.length >= 1);
  assert.ok(backend.models.length <= 2, `curated model list stays short for ${backend.id}`);
}
const ids = backends.map((backend) => backend.id);
assert.equal(new Set(ids).size, ids.length, 'backend ids are unique');

// --- selection building ----------------------------------------------------------
const fake = [{
  id: 'byok:test', class: 'byok', providerType: 'anthropic-compatible',
  label: 't', baseUrl: 'https://example.test/anthropic',
  models: ['m1', 'm2'], defaultModel: 'm1',
  keyEnvCandidates: ['CMO_TEST_KEY_ENV'], keyEnvDetected: '',
}];
assert.throws(() => buildSelection(fake, 'byok:test'), /env var not set/i);
const picked = buildSelection(fake, 'byok:test', { keyEnv: 'CMO_TEST_KEY_ENV' });
assert.equal(picked.apiKeyEnv, 'CMO_TEST_KEY_ENV');
assert.equal(picked.model, 'm1');
assert.ok(!JSON.stringify(picked).includes('sk-'), 'selection never embeds key material');
assert.throws(() => buildSelection(fake, 'nope:missing'), /Unknown backend id/);

const cliFake = [{
  id: 'claude:test', class: 'cli', providerType: 'claude-cli',
  label: 't', cliHome: 'C:\\x', cliAvailable: true,
  models: ['fable', 'opus'], defaultModel: 'fable',
}];
const cliPicked = buildSelection(cliFake, 'claude:test', { model: 'opus' });
assert.equal(cliPicked.model, 'opus');
assert.equal(cliPicked.cliHome, 'C:\\x');
assert.equal(cliPicked.apiKeyEnv, undefined);

console.log('PASS - AI backends contract holds.');
