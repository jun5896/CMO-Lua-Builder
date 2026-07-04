/**
 * providers.mjs — provider implementations for ai-provider-adapter.mjs
 *
 * HTTP provider types:
 *   - openai-compatible    : OpenAI / OpenRouter / xAI Grok / Moonshot Kimi /
 *                            Zhipu GLM standard API / LM Studio
 *                            (POST /v1/chat/completions, Bearer auth)
 *   - anthropic-compatible : Anthropic Messages API shape (POST /v1/messages,
 *                            x-api-key auth). Used by coding-plan endpoints
 *                            such as Kimi for Coding (api.moonshot.ai/anthropic)
 *                            and GLM Coding Plan (api.z.ai/api/anthropic).
 *                            Responses are normalized to the OpenAI choices
 *                            shape so the client parser stays unchanged.
 *   - ollama               : Ollama local (POST /api/chat, no auth)
 *   - lm-studio            : alias of openai-compatible
 *
 * CLI provider types (implemented in cli-providers.mjs, dispatched here):
 *   - claude-cli / codex-cli / cursor-cli — subscription CLIs in one-shot
 *     headless mode; account/profile selected via cfg.cliHome.
 *
 * Design:
 *   - HTTP paths stay pure (no I/O outside the explicit fetch); CLI paths are
 *     isolated in cli-providers.mjs.
 *   - Never log or return the API key.
 *   - On non-2xx responses, return { ok: false, status, body } with status from
 *     the upstream so the UI can decide what to do.
 */

import { CLI_PROVIDER_TYPES, callCliProvider, isCliProviderType } from './cli-providers.mjs';

export { isCliProviderType } from './cli-providers.mjs';

export const PROVIDER_TYPES = new Set([
  'openai-compatible',
  'anthropic-compatible',
  'ollama',
  'lm-studio',
  ...CLI_PROVIDER_TYPES,
]);

const DEFAULT_TIMEOUT_MS = 60_000;

function joinUrl(baseUrl, path) {
  const base = baseUrl.replace(/\/+$/, '');
  const p = path.replace(/^\/+/, '');
  return `${base}/${p}`;
}

function openAiCompatibleUrl(baseUrl, path) {
  const base = baseUrl.replace(/\/+$/, '');
  const p = path.replace(/^\/+/, '');
  if (/\/v1$/i.test(base) && p.toLowerCase().startsWith('v1/')) {
    return `${base}/${p.slice(3)}`;
  }
  return `${base}/${p}`;
}

async function timedFetch(url, init, timeoutMs = DEFAULT_TIMEOUT_MS) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { ...init, signal: controller.signal });
    return res;
  } finally {
    clearTimeout(timer);
  }
}

/**
 * Wrap an upstream chat-completion fetch into the adapter response shape, with
 * upstream-non-2xx redaction.  Critical security invariant (Task 3 calibration
 * 2026-05-03): if `res.ok === false`, the upstream JSON body is NEVER forwarded
 * verbatim, because an upstream that echoes the `Authorization` header (e.g.
 * 401 with `{ echoedAuth: "Bearer sk-..." }`) would leak the API key.
 *
 * 2xx → forward parsed upstream JSON under `response`.
 * non-2xx → sanitized error shape; no upstream body bytes ever appear in the
 *           returned `body`.
 */
function wrapUpstreamResponse(res, parsed, cfg) {
  if (res.ok) {
    return {
      status: res.status,
      body: {
        ok: true,
        providerType: cfg.providerType,
        baseUrl: cfg.baseUrl,
        model: cfg.model,
        response: parsed,
      },
    };
  }
  // Non-2xx: drop `parsed` on the floor.  Do NOT include any upstream body.
  return {
    status: res.status,
    body: {
      ok: false,
      providerType: cfg.providerType,
      baseUrl: cfg.baseUrl,
      model: cfg.model,
      status: res.status,
      errorCode: null,
      errorMessage: `upstream returned HTTP ${res.status}`,
    },
  };
}

function modelListResponse(res, models, cfg) {
  if (res.ok) {
    return {
      status: res.status,
      body: {
        ok: true,
        providerType: cfg.providerType,
        baseUrl: cfg.baseUrl,
        models,
      },
    };
  }

  return {
    status: res.status,
    body: {
      ok: false,
      providerType: cfg.providerType,
      baseUrl: cfg.baseUrl,
      status: res.status,
      errorCode: null,
      errorMessage: `upstream returned HTTP ${res.status}`,
    },
  };
}

function compactModelId(value) {
  return String(value || '').trim().slice(0, 160);
}

// -----------------------------------------------------------------------------
// openai-compatible (and lm-studio alias)
// -----------------------------------------------------------------------------

async function callOpenAICompatible(cfg) {
  const url = openAiCompatibleUrl(cfg.baseUrl, '/v1/chat/completions');
  const headers = { 'Content-Type': 'application/json' };
  if (cfg.apiKey) headers['Authorization'] = `Bearer ${cfg.apiKey}`;

  const body = {
    model: cfg.model,
    messages: cfg.messages,
  };

  if (cfg.generationMode !== 'provider-default') {
    body.temperature = cfg.temperature;
    body.max_tokens = cfg.maxTokens;
  }

  const res = await timedFetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let parsed;
  try { parsed = JSON.parse(text); } catch { parsed = { raw: text.slice(0, 4096) }; }
  return wrapUpstreamResponse(res, parsed, cfg);
}

// -----------------------------------------------------------------------------
// anthropic-compatible (Kimi for Coding, GLM Coding Plan, Anthropic itself)
// -----------------------------------------------------------------------------

export function buildAnthropicRequestBody(cfg) {
  const system = [];
  const messages = [];

  for (const message of cfg.messages || []) {
    if (message.role === 'system') {
      system.push(String(message.content || ''));
    } else {
      messages.push({ role: message.role, content: String(message.content || '') });
    }
  }

  const body = {
    model: cfg.model,
    // The Messages API requires max_tokens even in provider-default mode.
    max_tokens: cfg.generationMode !== 'provider-default' && Number.isFinite(cfg.maxTokens)
      ? cfg.maxTokens
      : 4096,
    messages,
  };
  if (system.length) body.system = system.join('\n\n');
  if (cfg.generationMode !== 'provider-default') body.temperature = cfg.temperature;
  return body;
}

export function normalizeAnthropicResponse(parsed) {
  const text = Array.isArray(parsed?.content)
    ? parsed.content.filter((block) => block?.type === 'text').map((block) => block.text || '').join('')
    : '';

  return {
    model: parsed?.model || '',
    choices: [{
      index: 0,
      message: { role: 'assistant', content: text },
      finish_reason: parsed?.stop_reason || null,
    }],
    usage: {
      prompt_tokens: parsed?.usage?.input_tokens ?? null,
      completion_tokens: parsed?.usage?.output_tokens ?? null,
    },
  };
}

async function callAnthropicCompatible(cfg) {
  const url = joinUrl(cfg.baseUrl, '/v1/messages');
  const headers = {
    'Content-Type': 'application/json',
    'anthropic-version': '2023-06-01',
  };
  if (cfg.apiKey) headers['x-api-key'] = cfg.apiKey;

  const res = await timedFetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(buildAnthropicRequestBody(cfg)),
  });
  const text = await res.text();
  let parsed;
  try { parsed = JSON.parse(text); } catch { parsed = { raw: text.slice(0, 4096) }; }
  return wrapUpstreamResponse(res, res.ok ? normalizeAnthropicResponse(parsed) : parsed, cfg);
}

// -----------------------------------------------------------------------------
// ollama
// -----------------------------------------------------------------------------

async function callOllama(cfg) {
  const url = joinUrl(cfg.baseUrl, '/api/chat');
  const headers = { 'Content-Type': 'application/json' };

  const body = {
    model: cfg.model,
    messages: cfg.messages,
    stream: false,
  };

  if (cfg.generationMode !== 'provider-default') {
    body.options = {
      temperature: cfg.temperature,
      num_predict: cfg.maxTokens,
    };
  }

  const res = await timedFetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let parsed;
  try { parsed = JSON.parse(text); } catch { parsed = { raw: text.slice(0, 4096) }; }
  return wrapUpstreamResponse(res, parsed, cfg);
}

// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------

export async function callProvider(cfg) {
  if (isCliProviderType(cfg.providerType)) {
    return callCliProvider(cfg);
  }
  switch (cfg.providerType) {
    case 'openai-compatible':
    case 'lm-studio':
      return callOpenAICompatible(cfg);
    case 'anthropic-compatible':
      return callAnthropicCompatible(cfg);
    case 'ollama':
      return callOllama(cfg);
    default:
      throw new Error(`Unknown providerType: ${cfg.providerType}`);
  }
}

async function listOpenAICompatibleModels(cfg) {
  const url = openAiCompatibleUrl(cfg.baseUrl, '/v1/models');
  const headers = { 'Accept': 'application/json' };
  if (cfg.apiKey) headers['Authorization'] = `Bearer ${cfg.apiKey}`;

  const res = await timedFetch(url, { method: 'GET', headers }, 15_000);
  const text = await res.text();
  let parsed;
  try { parsed = JSON.parse(text); } catch { parsed = {}; }

  const models = Array.isArray(parsed?.data)
    ? parsed.data
      .map((item) => compactModelId(item?.id || item?.name || item?.model))
      .filter(Boolean)
      .sort((a, b) => a.localeCompare(b))
      .map((id) => ({ id, label: id }))
    : [];

  return modelListResponse(res, models, cfg);
}

async function listOllamaModels(cfg) {
  const url = joinUrl(cfg.baseUrl, '/api/tags');
  const res = await timedFetch(url, { method: 'GET' }, 15_000);
  const text = await res.text();
  let parsed;
  try { parsed = JSON.parse(text); } catch { parsed = {}; }

  const models = Array.isArray(parsed?.models)
    ? parsed.models
      .map((item) => compactModelId(item?.name || item?.model))
      .filter(Boolean)
      .sort((a, b) => a.localeCompare(b))
      .map((id) => ({ id, label: id }))
    : [];

  return modelListResponse(res, models, cfg);
}

export async function listProviderModels(cfg) {
  switch (cfg.providerType) {
    case 'openai-compatible':
    case 'lm-studio':
      return listOpenAICompatibleModels(cfg);
    case 'ollama':
      return listOllamaModels(cfg);
    case 'anthropic-compatible':
    case 'claude-cli':
    case 'codex-cli':
    case 'cursor-cli':
    case 'grok-cli':
      // No discovery endpoint; the backends scanner supplies curated model
      // lists for these types.
      return { status: 200, body: { ok: true, providerType: cfg.providerType, baseUrl: cfg.baseUrl || '', models: [] } };
    default:
      throw new Error(`Unknown providerType: ${cfg.providerType}`);
  }
}

/**
 * Lightweight ping.
 *   - openai-compatible / lm-studio: GET /v1/models (auth required for OpenAI;
 *     LM Studio works without a key).
 *   - ollama: GET /api/tags
 */
export async function testProvider(cfg) {
  if (isCliProviderType(cfg.providerType)) {
    const { resolveCliExecutable } = await import('./cli-providers.mjs');
    const commandByType = { 'claude-cli': 'claude', 'codex-cli': 'codex', 'cursor-cli': 'cursor-agent', 'grok-cli': 'grok' };
    const executable = resolveCliExecutable(commandByType[cfg.providerType]);
    return {
      ok: Boolean(executable),
      status: executable ? 200 : 404,
      providerType: cfg.providerType,
      baseUrl: '',
      reached: Boolean(executable),
      ...(executable ? {} : { errorMessage: `${commandByType[cfg.providerType]} CLI not found on PATH` }),
    };
  }

  let url, init;
  switch (cfg.providerType) {
    case 'openai-compatible':
    case 'lm-studio': {
      url = openAiCompatibleUrl(cfg.baseUrl, '/v1/models');
      const headers = { 'Accept': 'application/json' };
      if (cfg.apiKey) headers['Authorization'] = `Bearer ${cfg.apiKey}`;
      init = { method: 'GET', headers };
      break;
    }
    case 'anthropic-compatible': {
      // The Messages API has no GET ping; POST a 1-token request instead.
      // 2xx = ok; auth/model/network failures surface as ok:false.
      url = joinUrl(cfg.baseUrl, '/v1/messages');
      const headers = { 'Content-Type': 'application/json', 'anthropic-version': '2023-06-01' };
      if (cfg.apiKey) headers['x-api-key'] = cfg.apiKey;
      init = {
        method: 'POST',
        headers,
        body: JSON.stringify({ model: cfg.model || 'ping', max_tokens: 1, messages: [{ role: 'user', content: 'ping' }] }),
      };
      break;
    }
    case 'ollama': {
      url = joinUrl(cfg.baseUrl, '/api/tags');
      init = { method: 'GET' };
      break;
    }
    default:
      return { ok: false, error: `Unknown providerType: ${cfg.providerType}` };
  }

  try {
    const res = await timedFetch(url, init, 15_000);
    if (!res.ok) {
      return {
        ok: false,
        status: res.status,
        providerType: cfg.providerType,
        baseUrl: cfg.baseUrl,
      };
    }
    return {
      ok: true,
      status: res.status,
      providerType: cfg.providerType,
      baseUrl: cfg.baseUrl,
      // Don't leak full model list; just confirm reachability.
      reached: true,
    };
  } catch (err) {
    return {
      ok: false,
      providerType: cfg.providerType,
      baseUrl: cfg.baseUrl,
      errorCode: err.code || null,
      errorMessage: String(err.message || err).slice(0, 200),
    };
  }
}
