#!/usr/bin/env node
/**
 * ai-provider-adapter.mjs  (Claude Task 3, 2026-05-02)
 *
 * Local Node HTTP server that lets the CMO Lua UI call external LLM providers
 * via a uniform OpenAI-compatible interface. Implements the contract in
 * handoff/to-codex/Task-3-AI-Adapter/ai-provider-backend-contract.md.
 *
 * Design principles (from codex relay):
 *   - DO NOT read or reuse Chatbox's stored API keys.
 *   - DO NOT scan the Chatbox install for secrets — we only model after its
 *     "register OpenAI-compatible provider" UX pattern, nothing more.
 *   - REDACT all keys/tokens in any logged or returned output.
 *   - No edits to codex's UI src/. Backend lives strictly under Claude tools/.
 *
 * Usage:
 *     node tools/server/ai-provider-adapter.mjs
 *     # listens on http://127.0.0.1:8765
 *
 *     # override port:
 *     PORT=9999 node tools/server/ai-provider-adapter.mjs
 *
 *     # load config from .env (see .env.example):
 *     #   AI_PROVIDER_BASE_URL=http://localhost:11434
 *     #   AI_PROVIDER_API_KEY=...
 *     #   AI_PROVIDER_MODEL=llama3
 *     #   AI_PROVIDER_TYPE=openai-compatible | ollama | lm-studio
 *
 * Endpoints:
 *     GET  /api/ai/settings            -> redacted current config
 *     POST /api/ai/settings            -> update config (in-memory only by default)
 *     POST /api/ai/test-provider       -> ping configured provider, return ok/error
 *     POST /api/ai/models              -> list configured provider models
 *     POST /api/ai/chat                -> proxy chat-completion request
 *     POST /api/cmo/lua-sidecar        -> dry-run or write an AiAssist Lua sidecar
 *     GET  /api/cmo/log-feedback       -> read sanitized recent CMO log snippets
 *     POST /api/cmo/state-snapshot/import -> import a user-pasted CMO state snapshot
 *     POST /api/scenario/transient-open -> temporary .scen decode + summary
 *
 * Security:
 *     - Binds to 127.0.0.1 only.
 *     - CORS limited to http://127.0.0.1:5173 / http://localhost:5173 (Vite dev).
 *     - API keys never appear in logs or responses (preview-only when needed).
 *     - .env values are loaded into process.env at startup; not echoed.
 *     - Settings PUT/POST never persists to disk in this prototype (codex
 *       reviews persistence path before we add it).
 */

import { createServer } from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import {
  basename,
  dirname,
  extname,
  join as joinPath,
  resolve as resolvePath,
} from 'node:path';

import {
  PROVIDER_TYPES,
  callProvider,
  isCliProviderType,
  listProviderModels,
  testProvider,
} from './providers.mjs';
import { createLuaSidecar } from './cmo-lua-sidecar-writer.mjs';
import { buildCmoLogFeedback } from './cmo-log-feedback-reader.mjs';
import { buildCmoStateSnapshot } from './cmo-state-snapshot-importer.mjs';
import { findCmoRoot } from '../tools/cmo-install-locator.mjs';

// -----------------------------------------------------------------------------
// Boot
// -----------------------------------------------------------------------------

const HERE = dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = resolvePath(HERE, '..');
loadEnvIfPresent(resolvePath(HERE, '.env'));

const HOST = '127.0.0.1';
const PORT = parseInt(process.env.PORT || '8765', 10);
const DEFAULT_CMO_ROOT = findCmoRoot();
const TRANSIENT_SCENARIO_LIMIT_BYTES = parseIntSafe(process.env.CMO_TRANSIENT_SCENARIO_LIMIT_BYTES, 120_000_000);
const TRANSIENT_SCENARIO_CACHE_ROOT = resolvePath(
  process.env.CMO_TRANSIENT_SCENARIO_CACHE_ROOT
    || joinPath(PROJECT_ROOT, '.scenario-extract-cache', 'transient-open'),
);

const ALLOWED_ORIGINS = new Set([
  'http://127.0.0.1:5173',
  'http://localhost:5173',
  'http://127.0.0.1:4173',  // Vite preview
  'http://localhost:4173',
]);

// In-memory config. NOT persisted in this prototype.
const config = {
  providerType: validProviderType(process.env.AI_PROVIDER_TYPE) || 'openai-compatible',
  baseUrl:      process.env.AI_PROVIDER_BASE_URL || '',
  apiKey:       process.env.AI_PROVIDER_API_KEY || '',
  model:        process.env.AI_PROVIDER_MODEL || '',
  cliHome:      '',
  backendId:    '',
  generationMode: process.env.AI_PROVIDER_GENERATION_MODE === 'manual' ? 'manual' : 'provider-default',
  temperature:  parseFloatSafe(process.env.AI_PROVIDER_TEMPERATURE, 0.7),
  maxTokens:    parseIntSafe(process.env.AI_PROVIDER_MAX_TOKENS, 1024),
};

// Backend selection written by tools/scan-ai-backends.mjs (--use). Explicit
// AI_PROVIDER_* env vars win; the selection fills whatever they left blank.
// Only the env-var NAME of the API key is stored on disk, never the key.
(() => {
  const selectionPath = resolvePath(HERE, '.cmo-ai-backends.json');
  if (!existsSync(selectionPath)) return;
  try {
    const selection = JSON.parse(readFileSync(selectionPath, 'utf-8'));
    if (!process.env.AI_PROVIDER_TYPE && validProviderType(selection.providerType)) {
      config.providerType = selection.providerType;
      config.backendId = String(selection.id || '');
      if (!process.env.AI_PROVIDER_BASE_URL) config.baseUrl = String(selection.baseUrl || '');
      if (!process.env.AI_PROVIDER_MODEL) config.model = String(selection.model || '');
      config.cliHome = String(selection.cliHome || '');
      if (!process.env.AI_PROVIDER_API_KEY && selection.apiKeyEnv) {
        config.apiKey = (process.env[selection.apiKeyEnv] || '').trim();
      }
    }
  } catch {
    // tolerated -- selection file is optional
  }
})();

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

function loadEnvIfPresent(path) {
  if (!existsSync(path)) return;
  try {
    const text = readFileSync(path, 'utf-8');
    for (const rawLine of text.split(/\r?\n/)) {
      const line = rawLine.trim();
      if (!line || line.startsWith('#')) continue;
      const m = line.match(/^([A-Z_][A-Z0-9_]*)\s*=\s*(.*)$/);
      if (!m) continue;
      let val = m[2].trim();
      if ((val.startsWith('"') && val.endsWith('"'))
          || (val.startsWith("'") && val.endsWith("'"))) {
        val = val.slice(1, -1);
      }
      if (process.env[m[1]] === undefined) process.env[m[1]] = val;
    }
  } catch {
    // tolerated -- env load is optional
  }
}

function validProviderType(t) {
  return t && PROVIDER_TYPES.has(t) ? t : null;
}

function parseFloatSafe(s, fallback) {
  if (!s) return fallback;
  const n = Number(s);
  return Number.isFinite(n) ? n : fallback;
}

function parseIntSafe(s, fallback) {
  if (!s) return fallback;
  const n = parseInt(s, 10);
  return Number.isFinite(n) ? n : fallback;
}

function redactKey(key) {
  if (!key) return '';
  if (key.length < 8) return '***';
  return `${key.slice(0, 4)}***${key.slice(-2)}`;
}

function redactedConfig() {
  return {
    providerType:     config.providerType,
    baseUrl:          config.baseUrl,
    model:            config.model,
    cliHome:          config.cliHome,
    backendId:        config.backendId,
    generationMode:   config.generationMode,
    temperature:      config.temperature,
    maxTokens:        config.maxTokens,
    apiKeyConfigured: !!config.apiKey,
    apiKeyPreview:    redactKey(config.apiKey),
    supportedProviders: [...PROVIDER_TYPES],
  };
}

function readBody(req, limit = 1_000_000) {
  return new Promise((resolve, reject) => {
    let total = 0;
    let data = '';
    req.setEncoding('utf-8');
    req.on('data', (chunk) => {
      total += chunk.length;
      if (total > limit) {
        reject(new Error('Request body too large'));
        req.destroy();
        return;
      }
      data += chunk;
    });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

function readBinaryBody(req, limit = TRANSIENT_SCENARIO_LIMIT_BYTES) {
  return new Promise((resolve, reject) => {
    let total = 0;
    const chunks = [];

    req.on('data', (chunk) => {
      total += chunk.length;
      if (total > limit) {
        reject(new Error(`Request body too large. Limit is ${limit} bytes.`));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function applyCors(req, res) {
  const origin = req.headers.origin;
  if (origin && ALLOWED_ORIGINS.has(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-CMO-Scenario-File-Name');
}

function sendJson(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.end(JSON.stringify(body, null, 2));
}

function logSafe(line) {
  // Strip likely-secret looking sequences before logging
  const safe = line.replace(/(sk-[A-Za-z0-9_-]{8,}|Bearer\s+\S+)/g, '<REDACTED>');
  console.log(`[adapter] ${safe}`);
}

function safeScenarioFileName(value, fallback = 'scenario.scen') {
  const raw = decodeURIComponent(String(value || '')).split(/[\\/]/).pop() || fallback;
  const cleaned = raw.replace(/[<>:"/\\|?*\x00-\x1F]+/g, '_').trim() || fallback;
  return extname(cleaned).toLowerCase() === '.scen'
    ? cleaned
    : `${cleaned.replace(/\.[^.]+$/, '')}.scen`;
}

function transientRun(command, args, label) {
  const result = spawnSync(command, args, {
    cwd: PROJECT_ROOT,
    encoding: 'utf8',
    shell: false,
    windowsHide: true,
  });

  if (result.error) {
    const error = new Error(`${label} failed: ${result.error.message}`);
    error.detail = result.error.message;
    throw error;
  }

  if (result.status !== 0) {
    const error = new Error(`${label} failed with exit code ${result.status}`);
    error.detail = [result.stderr, result.stdout]
      .filter(Boolean)
      .join('\n')
      .slice(-1200);
    throw error;
  }

  return result;
}

function trimForResponse(value, limit = 1200) {
  return String(value || '').replace(/\s+/g, ' ').trim().slice(0, limit);
}

async function buildTransientScenarioSummary(scenarioPath, displayName = '') {
  const nonce = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const workDir = joinPath(TRANSIENT_SCENARIO_CACHE_ROOT, nonce);
  const xmlPath = joinPath(workDir, 'scenario.scenario.xml');
  const summaryPath = joinPath(workDir, 'scenario.summary.json');
  const keepTemp = process.env.CMO_KEEP_TRANSIENT_SCENARIO === '1';

  await mkdir(workDir, { recursive: true });

  try {
    transientRun('powershell', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      joinPath('tools', 'extract-cmo-scenario-xml.ps1'),
      scenarioPath,
      '--OutXml',
      xmlPath,
      '-CmoRoot',
      process.env.CMO_ROOT || DEFAULT_CMO_ROOT,
    ], 'scenario XML extraction');

    transientRun(process.execPath, [
      joinPath('tools', 'summarize-cmo-scenario-xml.mjs'),
      xmlPath,
      '--out',
      summaryPath,
    ], 'scenario summary generation');

    const summary = JSON.parse(await readFile(summaryPath, 'utf8'));
    return {
      ok: true,
      mode: 'transient',
      fileName: displayName || basename(scenarioPath),
      summary,
      tempRetained: keepTemp,
    };
  } finally {
    if (!keepTemp) {
      await rm(workDir, { recursive: true, force: true }).catch(() => {});
    }
  }
}

// -----------------------------------------------------------------------------
// Routes
// -----------------------------------------------------------------------------

async function handleSettingsGet(_req, res) {
  sendJson(res, 200, { ok: true, settings: redactedConfig() });
}

async function handleSettingsPost(req, res) {
  let body;
  try {
    body = JSON.parse(await readBody(req));
  } catch (e) {
    return sendJson(res, 400, { ok: false, error: 'Invalid JSON body' });
  }
  if (typeof body !== 'object' || body === null) {
    return sendJson(res, 400, { ok: false, error: 'Body must be an object' });
  }
  const update = body.settings ?? body;

  if (typeof update.providerType === 'string') {
    if (!PROVIDER_TYPES.has(update.providerType)) {
      return sendJson(res, 400, {
        ok: false,
        error: `Unsupported providerType. Supported: ${[...PROVIDER_TYPES].join(', ')}`,
      });
    }
    config.providerType = update.providerType;
  }
  if (typeof update.baseUrl === 'string')     config.baseUrl     = update.baseUrl;
  if (typeof update.apiKey === 'string')      config.apiKey      = update.apiKey;
  if (typeof update.model === 'string')       config.model       = update.model;
  if (typeof update.cliHome === 'string')     config.cliHome     = update.cliHome;
  if (update.generationMode === 'provider-default' || update.generationMode === 'manual') {
    config.generationMode = update.generationMode;
  }
  if (typeof update.temperature === 'number') config.temperature = update.temperature;
  if (typeof update.maxTokens === 'number')   config.maxTokens   = update.maxTokens;

  logSafe(`settings updated: provider=${config.providerType} model=${config.model} key=${redactKey(config.apiKey)}`);
  sendJson(res, 200, { ok: true, settings: redactedConfig() });
}

async function handleTestProvider(req, res) {
  const overrides = await readJsonOrEmpty(req);
  const merged = { ...config, ...overrides };
  if (!merged.baseUrl && !isCliProviderType(merged.providerType)) {
    return sendJson(res, 400, { ok: false, error: 'baseUrl not configured' });
  }
  try {
    const result = await testProvider(merged);
    logSafe(`test-provider ${merged.providerType} ${merged.baseUrl} -> ${result.ok ? 'ok' : 'fail'}`);
    sendJson(res, result.ok ? 200 : 502, result);
  } catch (err) {
    sendJson(res, 502, sanitizeError(err, merged));
  }
}

async function handleListModels(req, res) {
  const overrides = await readJsonOrEmpty(req);
  const merged = { ...config, ...overrides };
  if (!merged.baseUrl && !isCliProviderType(merged.providerType)) {
    return sendJson(res, 400, { ok: false, error: 'baseUrl not configured' });
  }
  try {
    const result = await listProviderModels(merged);
    logSafe(`models ${merged.providerType} ${merged.baseUrl} -> ${result.body?.models?.length || 0}`);
    sendJson(res, result.status, deepScrubSecrets(result.body));
  } catch (err) {
    sendJson(res, 502, sanitizeError(err, merged));
  }
}

async function handleChat(req, res) {
  let body;
  try {
    body = JSON.parse(await readBody(req));
  } catch (e) {
    return sendJson(res, 400, { ok: false, error: 'Invalid JSON body' });
  }
  if (!Array.isArray(body.messages) || body.messages.length === 0) {
    return sendJson(res, 400, { ok: false, error: 'messages[] required' });
  }
  const merged = {
    ...config,
    ...(body.providerOverride || {}),
    messages: body.messages,
    generationMode: body.generationMode || body.providerOverride?.generationMode || config.generationMode,
    temperature: typeof body.temperature === 'number'
      ? body.temperature
      : (typeof body.providerOverride?.temperature === 'number' ? body.providerOverride.temperature : config.temperature),
    maxTokens: typeof body.maxTokens === 'number'
      ? body.maxTokens
      : (typeof body.providerOverride?.maxTokens === 'number' ? body.providerOverride.maxTokens : config.maxTokens),
  };
  if (!merged.baseUrl && !isCliProviderType(merged.providerType)) {
    return sendJson(res, 400, { ok: false, error: 'baseUrl not configured' });
  }
  if (!merged.model) {
    return sendJson(res, 400, { ok: false, error: 'model not configured' });
  }
  try {
    const result = await callProvider(merged);
    logSafe(`chat ${merged.providerType} ${merged.model} status=${result.status}`);
    // Defense-in-depth: even though wrapUpstreamResponse drops upstream bodies on
    // non-2xx, scrub any residual Bearer/sk-key patterns that might appear in
    // 2xx response.choices[].message.content (e.g. an LLM that "remembers" a key
    // pasted in a previous turn). This is belt-and-braces — providers.mjs is the
    // primary defense; this catches anything that slips through.
    sendJson(res, result.status, deepScrubSecrets(result.body));
  } catch (err) {
    sendJson(res, 502, sanitizeError(err, merged));
  }
}

async function handleTransientScenarioOpen(req, res) {
  const contentType = String(req.headers['content-type'] || '').toLowerCase();
  let scenarioPath = '';
  let displayName = '';
  let uploadedWorkDir = '';

  try {
    if (contentType.includes('application/json')) {
      const body = JSON.parse(await readBody(req, 80_000));
      scenarioPath = String(body.scenarioPath || '').trim();
      displayName = String(body.fileName || '').trim();
      if (!scenarioPath) {
        return sendJson(res, 400, { ok: false, error: 'scenarioPath required' });
      }
    } else {
      const buffer = await readBinaryBody(req);
      if (!buffer.length) {
        return sendJson(res, 400, { ok: false, error: 'Empty scenario upload' });
      }

      displayName = safeScenarioFileName(req.headers['x-cmo-scenario-file-name']);
      uploadedWorkDir = joinPath(
        TRANSIENT_SCENARIO_CACHE_ROOT,
        `upload-${Date.now()}-${Math.random().toString(16).slice(2)}`,
      );
      await mkdir(uploadedWorkDir, { recursive: true });
      scenarioPath = joinPath(uploadedWorkDir, displayName);
      await writeFile(scenarioPath, buffer);
    }

    const result = await buildTransientScenarioSummary(scenarioPath, displayName);
    logSafe(`transient scenario open ${result.fileName} -> ok`);
    return sendJson(res, 200, result);
  } catch (err) {
    logSafe(`transient scenario open -> fail ${err?.message || err}`);
    return sendJson(res, 502, {
      ok: false,
      error: 'transient scenario decode failed',
      errorMessage: trimForResponse(err?.message || err),
      detail: trimForResponse(err?.detail || ''),
    });
  } finally {
    if (uploadedWorkDir && process.env.CMO_KEEP_TRANSIENT_SCENARIO !== '1') {
      await rm(uploadedWorkDir, { recursive: true, force: true }).catch(() => {});
    }
  }
}

async function handleCmoLuaSidecar(req, res) {
  try {
    const body = await readJsonOrEmpty(req);
    const result = await createLuaSidecar({
      content: body.content,
      slug: body.slug,
      fileName: body.fileName,
      isPasteReady: body.isPasteReady,
      dryRun: body.dryRun !== false,
      confirmWrite: body.confirmWrite === true,
    });
    logSafe(`cmo lua sidecar ${result.mode} ${result.fileName} -> ok`);
    return sendJson(res, 200, deepScrubSecrets({ ...result, lua: undefined }));
  } catch (err) {
    logSafe(`cmo lua sidecar -> fail ${err?.message || err}`);
    return sendJson(res, 400, deepScrubSecrets({
      ok: false,
      error: 'cmo lua sidecar write failed',
      errorMessage: trimForResponse(err?.message || err),
    }));
  }
}

async function handleCmoLogFeedback(_req, res, url) {
  try {
    const result = await buildCmoLogFeedback({
      kind: url.searchParams.get('kind') || 'all',
      since: url.searchParams.get('since') || '',
      limit: url.searchParams.get('limit') || '',
      maxBytes: url.searchParams.get('maxBytes') || '',
    });
    logSafe(`cmo log feedback ${result.kind} -> ${result.summary.entriesReturned} entries`);
    return sendJson(res, 200, deepScrubSecrets(result));
  } catch (err) {
    logSafe(`cmo log feedback -> fail ${err?.message || err}`);
    return sendJson(res, 400, deepScrubSecrets({
      ok: false,
      error: 'cmo log feedback failed',
      errorMessage: trimForResponse(err?.message || err),
    }));
  }
}

async function handleCmoStateSnapshotImport(req, res) {
  try {
    const body = await readJsonOrEmpty(req);
    const result = buildCmoStateSnapshot(String(body.text ?? ''), {
      sourceHint: body.sourceHint,
    });
    logSafe(`cmo state snapshot import -> ${result.summary.eventCount} events`);
    return sendJson(res, 200, deepScrubSecrets(result));
  } catch (err) {
    logSafe(`cmo state snapshot import -> fail ${err?.message || err}`);
    return sendJson(res, 400, deepScrubSecrets({
      ok: false,
      error: 'cmo state snapshot import failed',
      errorMessage: trimForResponse(err?.message || err),
    }));
  }
}

/**
 * Recursively walk a JSON-serializable value and replace any Bearer-token /
 * sk-key fingerprints inside string fields with <REDACTED>. Does not mutate
 * the input.
 */
function deepScrubSecrets(value) {
  const SECRET_RE = /(?:Bearer\s+[A-Za-z0-9._\-]{8,}|sk-[A-Za-z0-9._\-]{8,})/g;
  if (typeof value === 'string') {
    return value.replace(SECRET_RE, '<REDACTED>');
  }
  if (Array.isArray(value)) {
    return value.map(deepScrubSecrets);
  }
  if (value && typeof value === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(value)) out[k] = deepScrubSecrets(v);
    return out;
  }
  return value;
}

async function readJsonOrEmpty(req) {
  try {
    const raw = await readBody(req);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

function sanitizeError(err, ctx) {
  // Never echo back keys / Authorization headers.
  return {
    ok: false,
    providerType: ctx.providerType,
    baseUrl: ctx.baseUrl,
    model: ctx.model || null,
    errorCode: err.code || null,
    errorMessage: String(err.message || err).slice(0, 400),
  };
}

// -----------------------------------------------------------------------------
// Server
// -----------------------------------------------------------------------------

const server = createServer(async (req, res) => {
  applyCors(req, res);

  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${HOST}:${PORT}`);
  const path = url.pathname.replace(/\/+$/, '');
  const method = req.method;

  if (method === 'GET' && path === '/api/ai/settings')           return handleSettingsGet(req, res);
  if (method === 'POST' && path === '/api/ai/settings')          return handleSettingsPost(req, res);
  if (method === 'POST' && path === '/api/ai/test-provider')     return handleTestProvider(req, res);
  if (method === 'POST' && path === '/api/ai/models')            return handleListModels(req, res);
  if (method === 'POST' && path === '/api/ai/chat')              return handleChat(req, res);
  if (method === 'POST' && path === '/api/cmo/lua-sidecar')      return handleCmoLuaSidecar(req, res);
  if (method === 'GET' && path === '/api/cmo/log-feedback')      return handleCmoLogFeedback(req, res, url);
  if (method === 'POST' && path === '/api/cmo/state-snapshot/import') return handleCmoStateSnapshotImport(req, res);
  if (method === 'POST' && path === '/api/scenario/transient-open') return handleTransientScenarioOpen(req, res);
  if (method === 'GET' && (path === '/api/health' || path === '')) {
    return sendJson(res, 200, {
      ok: true,
      service: 'cmo-lua-ai-adapter',
      version: '0.1.0',
      providerType: config.providerType,
      baseUrl: config.baseUrl,
      model: config.model,
    });
  }

  sendJson(res, 404, { ok: false, error: `Not found: ${method} ${path}` });
});

server.listen(PORT, HOST, () => {
  logSafe(`listening on http://${HOST}:${PORT}`);
  logSafe(`provider=${config.providerType} baseUrl=${config.baseUrl || '(unset)'} model=${config.model || '(unset)'} key=${config.apiKey ? '<configured>' : '(unset)'}`);
});

// graceful shutdown
process.on('SIGINT', () => { logSafe('SIGINT — shutting down'); server.close(() => process.exit(0)); });
process.on('SIGTERM', () => { logSafe('SIGTERM — shutting down'); server.close(() => process.exit(0)); });
