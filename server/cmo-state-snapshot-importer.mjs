import { parse } from '../tools/parse-cmo-event-export.mjs';

export const MAX_CMO_STATE_IMPORT_BYTES = 256 * 1024;
export const MAX_STATE_EVENTS = 50;
export const MAX_STATE_SPECIAL_ACTIONS = 50;
export const MAX_STATE_WARNINGS = 20;
export const MAX_LUA_PREVIEW_CHARS = 600;
export const LUA_PREVIEW_CHAR_UNIT = 'utf16-code-units';

const VALID_SOURCE_HINTS = new Set([
  'toolDumpEvents',
  'scenEditGetEvent',
  'pastedLuaConsole',
  'mixed',
  'unknown',
]);

function applyRedaction(source, pattern, replacement) {
  let redactionsApplied = 0;
  const text = source.replace(pattern, () => {
    redactionsApplied += 1;
    return replacement;
  });
  return { text, redactionsApplied };
}

export function redactCmoStateText(value) {
  let text = String(value || '');
  let redactionsApplied = 0;
  const apply = (pattern, replacement) => {
    const result = applyRedaction(text, pattern, replacement);
    text = result.text;
    redactionsApplied += result.redactionsApplied;
  };

  apply(/[A-Za-z]:[\\/](?:Users|Documents and Settings)[\\/][^\\/\r\n\t ]+(?:[\\/][^\\/\r\n\t ]+)*/gi, 'REDACTED_USER_PATH');
  apply(/(?:\\\\|\/\/)[^\\/\r\n\t ]+[\\/][^\\/\r\n\t ]+(?:[\\/][^\\/\r\n\t ]+)*/g, 'REDACTED_PATH');
  apply(/[A-Za-z]:[\\/][^\\/\r\n\t ]+(?:[\\/][^\\/\r\n\t ]+)*/g, 'REDACTED_PATH');
  apply(/Authorization:\s*[A-Za-z]+\s+[A-Za-z0-9._~+/=-]{8,}/gi, 'Authorization: REDACTED_SECRET');
  apply(/Bearer\s+[A-Za-z0-9._~+/=-]{8,}/gi, 'REDACTED_SECRET');
  apply(/sk-[A-Za-z0-9._-]{8,}/gi, 'REDACTED_SECRET');

  return { text, redactionsApplied };
}

function snapshotIdFromTimestamp(importedAt) {
  return `cmo-state-${String(importedAt).replace(/[:.]/g, '-')}`;
}

function toLuaPreview(luaScript) {
  const text = String(luaScript || '');
  return {
    text: text.slice(0, MAX_LUA_PREVIEW_CHARS),
    truncated: text.length > MAX_LUA_PREVIEW_CHARS,
    originalLength: text.length,
    charUnit: LUA_PREVIEW_CHAR_UNIT,
  };
}

function sanitizeChild(value) {
  const child = { ...value };
  delete child.raw;
  if (typeof child.luaScript === 'string') {
    child.luaScriptPreview = toLuaPreview(child.luaScript);
    delete child.luaScript;
  }
  return child;
}

function sanitizeEvent(event) {
  const sanitized = { ...event };
  delete sanitized.raw;

  const luaScripts = Array.isArray(sanitized.luaScripts) ? sanitized.luaScripts : [];
  delete sanitized.luaScripts;
  sanitized.luaScriptPreviews = luaScripts.map(toLuaPreview);

  sanitized.triggers = Array.isArray(event.triggers) ? event.triggers.map(sanitizeChild) : [];
  sanitized.conditions = Array.isArray(event.conditions) ? event.conditions.map(sanitizeChild) : [];
  sanitized.actions = Array.isArray(event.actions) ? event.actions.map(sanitizeChild) : [];

  return sanitized;
}

function sanitizeSpecialAction(action) {
  return sanitizeChild(action);
}

function boundArray(values, max) {
  const array = Array.isArray(values) ? values : [];
  return {
    items: array.slice(0, max),
    total: array.length,
    truncated: array.length > max,
  };
}

function sanitizeObjectContext(objectContext) {
  const context = objectContext && typeof objectContext === 'object' ? objectContext : {};
  return {
    sides: Array.isArray(context.sides) ? [...context.sides] : [],
    missions: Array.isArray(context.missions) ? [...context.missions] : [],
    units: Array.isArray(context.units) ? [...context.units] : [],
    referencePoints: Array.isArray(context.referencePoints) ? [...context.referencePoints] : [],
    zones: Array.isArray(context.zones) ? [...context.zones] : [],
    specialActions: Array.isArray(context.specialActions) ? [...context.specialActions] : [],
    luaFiles: Array.isArray(context.luaFiles) ? [...context.luaFiles] : [],
  };
}

function coerceSourceHint(sourceHint) {
  return VALID_SOURCE_HINTS.has(sourceHint) ? sourceHint : undefined;
}

export function buildCmoStateSnapshot(text, options = {}) {
  const input = String(text ?? '');
  if (!input.trim()) {
    throw new Error('CMO state snapshot import is empty.');
  }

  const byteLength = Buffer.byteLength(input, 'utf8');
  if (byteLength > MAX_CMO_STATE_IMPORT_BYTES) {
    throw new Error(`CMO state snapshot import is too large (${byteLength} bytes).`);
  }

  const importedAt = options.now || new Date().toISOString();
  const redacted = redactCmoStateText(input);

  // Redact before parse so parser output cannot retain local paths or secrets.
  // Replacement tokens avoid quotes/braces/XML brackets, so they do not create
  // fake Lua tables or XML tags while preserving surrounding parse structure.
  const parsed = parse(redacted.text, { type: coerceSourceHint(options.sourceHint) });

  const boundedEvents = boundArray(parsed.events, MAX_STATE_EVENTS);
  const boundedSpecialActions = boundArray(parsed.specialActions, MAX_STATE_SPECIAL_ACTIONS);
  const boundedWarnings = boundArray(parsed.warnings, MAX_STATE_WARNINGS);
  const events = boundedEvents.items.map(sanitizeEvent);
  const specialActions = boundedSpecialActions.items.map(sanitizeSpecialAction);
  const detectedApis = Array.isArray(parsed.detectedApis) ? [...parsed.detectedApis] : [];

  return {
    ok: true,
    snapshotId: snapshotIdFromTimestamp(importedAt),
    importedAt,
    source: {
      type: parsed.source?.type || 'unknown',
      label: options.label || 'User pasted CMO export',
      live: false,
    },
    summary: {
      totalEventCount: boundedEvents.total,
      eventCount: events.length,
      eventsTruncated: boundedEvents.truncated,
      totalSpecialActionCount: boundedSpecialActions.total,
      specialActionCount: specialActions.length,
      specialActionsTruncated: boundedSpecialActions.truncated,
      detectedApiCount: detectedApis.length,
      totalWarningCount: boundedWarnings.total,
      warningCount: boundedWarnings.items.length,
      warningsTruncated: boundedWarnings.truncated,
      redactionsApplied: redacted.redactionsApplied,
      maxLuaPreviewChars: MAX_LUA_PREVIEW_CHARS,
      luaPreviewCharUnit: LUA_PREVIEW_CHAR_UNIT,
    },
    scenario: parsed.scenario || {},
    events,
    specialActions,
    objectContext: sanitizeObjectContext(parsed.objectContext),
    detectedApis,
    warnings: boundedWarnings.items,
    redaction: {
      applied: redacted.redactionsApplied > 0,
      count: redacted.redactionsApplied,
    },
  };
}
