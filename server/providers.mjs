/**
 * providers.mjs — provider implementations for ai-provider-adapter.mjs
 *
 * Three provider types:
 *   - openai-compatible : OpenAI / OpenRouter / CrofAI / LM Studio (POST /v1/chat/completions, Bearer auth)
 *   - ollama            : Ollama local (POST /api/chat, no auth, different body)
 *   - lm-studio         : alias of openai-compatible (same path/shape; declared
 *                          separately to match the Chatbox UX of "select your provider")
 *
 * Design:
 *   - Pure async functions, no I/O outside the explicit fetch.
 *   - Never log or return the API key.
 *   - On non-2xx responses, return { ok: false, status, body } with status from
 *     the upstream so the UI can decide what to do.
 */

export const PROVIDER_TYPES = new Set([
  'openai-compatible',
  'ollama',
  'lm-studio',
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
  switch (cfg.providerType) {
    case 'openai-compatible':
    case 'lm-studio':
      return callOpenAICompatible(cfg);
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
