export const AI_ADAPTER_BASE_URL = 'http://127.0.0.1:8765';

export const AI_PROVIDER_TYPES = [
  { id: 'openai-compatible', label: 'OpenAI compatible' },
  { id: 'lm-studio', label: 'LM Studio' },
  { id: 'ollama', label: 'Ollama' },
];

export const DEFAULT_AI_PROVIDER_FORM = {
  providerType: 'openai-compatible',
  baseUrl: '',
  apiKey: '',
  apiKeyConfigured: false,
  apiKeyPreview: '',
  model: '',
  generationMode: 'provider-default',
  temperature: 0.3,
  maxTokens: 2048,
};

const AI_SYSTEM_PROMPT_URL = '/cmo-ai-system-prompt.txt';
const FALLBACK_CMO_AI_SYSTEM_PROMPT = 'CMO Lua assistant. Never invent IDs/names. Return paste-ready Lua only with complete context.';
let cachedSystemPrompt = '';

const REQUIRED_AI_RESPONSE_SECTIONS = [
  'summary',
  'assumptions',
  'cmo ui prerequisites',
  'paste-ready lua',
  'validation checklist',
  'follow-up questions or blockers',
];

const PLACEHOLDER_PATTERNS = [
  /<[^>\n]{2,80}>/g,
  /\b(?:TODO|TBD|INSERT(?:_HERE)?|REPLACE(?:_ME)?|PLACEHOLDER|YOUR_[A-Z0-9_]+|UNIT_GUID|MISSION_NAME|SIDE_NAME|DBID_HERE)\b/gi,
];

const UNSAFE_LUA_PATTERNS = [
  /\bos\s*\./i,
  /\bio\s*\./i,
  /\brequire\s*\(/i,
  /\bdofile\s*\(/i,
  /\bloadfile\s*\(/i,
  /\bpackage\s*\./i,
  /\bdebug\s*\./i,
];

function stripTrailingSlash(value) {
  return String(value || '').replace(/\/+$/, '');
}

function normalizeSettings(settings = {}) {
  return {
    ...DEFAULT_AI_PROVIDER_FORM,
    ...settings,
    apiKey: '',
    generationMode: settings.generationMode === 'provider-default' ? 'provider-default' : 'manual',
    temperature: Number.isFinite(Number(settings.temperature)) ? Number(settings.temperature) : DEFAULT_AI_PROVIDER_FORM.temperature,
    maxTokens: Number.isFinite(Number(settings.maxTokens)) ? Number(settings.maxTokens) : DEFAULT_AI_PROVIDER_FORM.maxTokens,
  };
}

function settingsPayload(settings = {}) {
  const payload = {
    providerType: settings.providerType || DEFAULT_AI_PROVIDER_FORM.providerType,
    baseUrl: stripTrailingSlash(settings.baseUrl),
    model: String(settings.model || '').trim(),
    generationMode: settings.generationMode === 'provider-default' ? 'provider-default' : 'manual',
    temperature: Number(settings.temperature),
    maxTokens: Number(settings.maxTokens),
  };

  if (String(settings.apiKey || '').trim()) {
    payload.apiKey = String(settings.apiKey).trim();
  }

  return payload;
}

async function readJsonResponse(response) {
  let body;

  try {
    body = await response.json();
  } catch {
    body = null;
  }

  if (!response.ok) {
    const message = body?.errorMessage || body?.error || `HTTP ${response.status}`;
    const error = new Error(message);
    error.status = response.status;
    error.body = body;
    throw error;
  }

  return body;
}

export async function fetchAiAdapterHealth() {
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/health`);
  return readJsonResponse(response);
}

export async function fetchAiAdapterSettings() {
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/ai/settings`);
  const body = await readJsonResponse(response);
  return normalizeSettings(body?.settings);
}

export async function saveAiAdapterSettings(settings) {
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/ai/settings`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ settings: settingsPayload(settings) }),
  });
  const body = await readJsonResponse(response);
  return normalizeSettings(body?.settings);
}

export async function testAiAdapterProvider(settings) {
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/ai/test-provider`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(settingsPayload(settings)),
  });
  return readJsonResponse(response);
}

export async function fetchAiProviderModels(settings) {
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/ai/models`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(settingsPayload(settings)),
  });
  const body = await readJsonResponse(response);
  const models = Array.isArray(body?.models) ? body.models : [];

  return [...new Set(models
    .map((model) => String(model?.id || model?.name || model?.model || model || '').trim())
    .filter(Boolean))];
}

async function getCmoAiSystemPrompt() {
  if (cachedSystemPrompt) return cachedSystemPrompt;

  try {
    const response = await fetch(AI_SYSTEM_PROMPT_URL);
    if (response.ok) {
      cachedSystemPrompt = (await response.text()).trim();
    }
  } catch {
    cachedSystemPrompt = '';
  }

  return cachedSystemPrompt || FALLBACK_CMO_AI_SYSTEM_PROMPT;
}

export async function sendCmoAiPrompt(userPrompt, options = {}) {
  const payload = {
    messages: [
      { role: 'system', content: await getCmoAiSystemPrompt() },
      { role: 'user', content: userPrompt },
    ],
  };

  if (options.providerOverride) {
    payload.providerOverride = settingsPayload(options.providerOverride);
  }

  if (options.generationMode) {
    payload.generationMode = options.generationMode;
  }

  if (options.generationMode !== 'provider-default') {
    if (typeof options.temperature === 'number') payload.temperature = options.temperature;
    if (typeof options.maxTokens === 'number') payload.maxTokens = options.maxTokens;
  }

  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/ai/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  const body = await readJsonResponse(response);
  const extracted = extractAssistantText(body);

  if (!extracted.text) {
    const error = new Error('AI 응답에서 assistant 메시지를 찾지 못했습니다.');
    error.body = body;
    throw error;
  }

  return { ...extracted, raw: body };
}

export async function openScenarioTransient(file) {
  if (!file) {
    throw new Error('Scenario file required');
  }

  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/scenario/transient-open`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/octet-stream',
      'X-CMO-Scenario-File-Name': encodeURIComponent(file.name || 'scenario.scen'),
    },
    body: file,
  });

  return readJsonResponse(response);
}

export function extractAssistantText(body) {
  if (!body?.ok) {
    return {
      ok: false,
      text: '',
      finishReason: null,
      modelEcho: body?.model || null,
      errorMessage: body?.errorMessage || body?.error || 'AI adapter error',
    };
  }

  const response = body.response;

  if (body.providerType === 'ollama') {
    return {
      ok: true,
      text: response?.message?.content || '',
      finishReason: response?.done_reason || (response?.done ? 'stop' : null),
      modelEcho: response?.model || body.model || null,
      errorMessage: null,
    };
  }

  const choice = response?.choices?.[0];
  return {
    ok: true,
    text: choice?.message?.content || '',
    finishReason: choice?.finish_reason || null,
    modelEcho: response?.model || body.model || null,
    errorMessage: null,
  };
}

function normalizeSectionName(value) {
  return String(value || '').trim().toLowerCase().replace(/\s+/g, ' ');
}

function collectSections(text) {
  const sections = new Map();
  const matches = [...String(text || '').matchAll(/^##\s+(.+?)\s*$/gim)];

  for (let index = 0; index < matches.length; index += 1) {
    const current = matches[index];
    const next = matches[index + 1];
    const name = normalizeSectionName(current[1]);
    const start = current.index + current[0].length;
    const end = next?.index ?? text.length;
    sections.set(name, String(text).slice(start, end).trim());
  }

  return sections;
}

function extractLuaFence(text) {
  const source = String(text || '');
  const luaMatch = source.match(/```lua\s*([\s\S]*?)```/i);
  if (luaMatch) return luaMatch[1].trim();

  const genericMatch = source.match(/```\s*([\s\S]*?)```/);
  return genericMatch?.[1]?.trim() || '';
}

function findPatternHits(text, patterns) {
  const hits = [];
  for (const pattern of patterns) {
    const matches = String(text || '').match(pattern);
    if (matches?.length) hits.push(...matches.slice(0, 10));
  }
  return [...new Set(hits)];
}

function splitListSection(value) {
  return String(value || '')
    .split(/\r?\n/)
    .map((line) => line.replace(/^[-*]\s*/, '').trim())
    .filter(Boolean);
}

export function parseAiInterpreterResponse(text) {
  const source = String(text || '');
  const sections = collectSections(source);
  const pasteReadySection = sections.get('paste-ready lua') || '';
  const lua = extractLuaFence(pasteReadySection) || extractLuaFence(source);
  const blockers = [];
  const warnings = [];
  const sectionsPresent = [];
  const missingRequiredSections = [];

  for (const sectionName of REQUIRED_AI_RESPONSE_SECTIONS) {
    if (sections.has(sectionName)) {
      sectionsPresent.push(sectionName);
    } else {
      missingRequiredSections.push(sectionName);
      warnings.push(`Missing section: ${sectionName}`);
    }
  }

  if (/\bBLOCKER\b/i.test(source)) {
    blockers.push('AI response contains BLOCKER; missing CMO context must be resolved first.');
  }

  if (!lua) {
    blockers.push('No Lua code block found.');
  }

  const placeholderHits = findPatternHits(lua, PLACEHOLDER_PATTERNS);
  if (placeholderHits.length) {
    blockers.push(`Placeholder tokens detected in Lua: ${placeholderHits.join(', ')}`);
  }

  const unsafeHits = findPatternHits(lua, UNSAFE_LUA_PATTERNS);
  if (unsafeHits.length) {
    blockers.push(`Unsafe Lua surface detected: ${unsafeHits.join(', ')}`);
  }

  if (!sections.has('paste-ready lua')) {
    blockers.push('Required section missing: Paste-ready Lua.');
  } else if (lua && !pasteReadySection.includes('```')) {
    blockers.push('Paste-ready Lua section exists, but no fenced Lua block was found inside it.');
  }

  return {
    ok: true,
    lua,
    isPasteReady: Boolean(lua) && blockers.length === 0,
    blockers,
    warnings,
    assumptions: splitListSection(sections.get('assumptions')),
    prerequisites: splitListSection(sections.get('cmo ui prerequisites')),
    validationChecklist: splitListSection(sections.get('validation checklist')),
    followUpQuestions: splitListSection(sections.get('follow-up questions or blockers')),
    sectionsPresent,
    missingRequiredSections,
    hasPlaceholders: placeholderHits.length > 0,
  };
}
