export const CONFIRMED_CONTEXT_TYPES = Object.freeze([
  { id: 'side', label: 'Side' },
  { id: 'mission', label: 'Mission' },
  { id: 'unitGuid', label: 'Unit GUID' },
  { id: 'dbid', label: 'DBID' },
  { id: 'loadout', label: 'Loadout ID' },
  { id: 'rpZone', label: 'RP / Zone' },
  { id: 'postureDoctrine', label: 'Posture / Doctrine / EMCON' },
  { id: 'coordinates', label: 'Coordinates' },
  { id: 'weather', label: 'Weather' },
  { id: 'note', label: 'Note' },
]);

export const CONFIRMED_CONTEXT_SOURCES = Object.freeze([
  { id: 'manual-cmo-ui', label: 'CMO UI' },
  { id: 'database-viewer', label: 'Database Viewer' },
  { id: 'copy-unit-guid', label: 'Copy unit ID' },
  { id: 'scenario-sidecar-summary', label: 'Loaded sidecar summary' },
  { id: 'template-inspector', label: 'Template Inspector' },
  { id: 'ai-ask-back-resolution', label: 'AI ask-back answer' },
]);

const DEFAULT_TYPE = 'note';
const DEFAULT_SOURCE = 'manual-cmo-ui';
const SECRET_PATTERN = /\b(?:Authorization\s*:|Bearer\s+\S+|sk-[A-Za-z0-9_-]+|apiKey\s*[:=])/i;

function optionLabel(options, id, fallback) {
  return options.find((option) => option.id === id)?.label || fallback;
}

function cleanText(value) {
  return String(value ?? '').trim();
}

function redactSecrets(value) {
  const text = cleanText(value);
  return SECRET_PATTERN.test(text) ? '<REDACTED>' : text;
}

function stableSlug(value) {
  return cleanText(value)
    .toLowerCase()
    .replace(/[^a-z0-9가-힣]+/gi, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80) || 'value';
}

function normalizeType(type) {
  const candidate = cleanText(type);
  return CONFIRMED_CONTEXT_TYPES.some((option) => option.id === candidate) ? candidate : DEFAULT_TYPE;
}

function normalizeSource(source) {
  const candidate = cleanText(source);
  return CONFIRMED_CONTEXT_SOURCES.some((option) => option.id === candidate) ? candidate : DEFAULT_SOURCE;
}

function cloneEntry(entry) {
  return { ...entry };
}

export function makeConfirmedContextEntry(entry = {}) {
  const type = normalizeType(entry.type);
  const source = normalizeSource(entry.source);
  const value = redactSecrets(entry.value ?? entry.label);

  if (!value) return null;

  const rawLabel = redactSecrets(entry.label || value);
  const label = rawLabel || value;
  const sourceDetail = redactSecrets(entry.sourceDetail);
  const notes = redactSecrets(entry.notes);
  const id = cleanText(entry.id) || `ctx_${type}_${source}_${stableSlug(value)}`;

  return {
    id,
    type,
    typeLabel: optionLabel(CONFIRMED_CONTEXT_TYPES, type, type),
    label,
    value,
    source,
    sourceLabel: optionLabel(CONFIRMED_CONTEXT_SOURCES, source, source),
    sourceDetail,
    notes,
    createdAt: cleanText(entry.createdAt),
  };
}

export function normalizeConfirmedContextEntries(entries = []) {
  const byKey = new Map();

  for (const entry of Array.isArray(entries) ? entries : []) {
    const normalized = makeConfirmedContextEntry(entry);
    if (!normalized) continue;

    const key = `${normalized.type}|${normalized.source}|${normalized.value.toLowerCase()}`;
    const existing = byKey.get(key);

    if (!existing) {
      byKey.set(key, normalized);
      continue;
    }

    byKey.set(key, {
      ...existing,
      label: existing.label || normalized.label,
      sourceDetail: existing.sourceDetail || normalized.sourceDetail,
      notes: existing.notes || normalized.notes,
      createdAt: existing.createdAt || normalized.createdAt,
    });
  }

  return Array.from(byKey.values()).map(cloneEntry);
}

export function hasConfirmedContextEntries(entries = []) {
  return normalizeConfirmedContextEntries(entries).length > 0;
}

function formatEntry(entry) {
  const valuePart = entry.label && entry.label !== entry.value
    ? `${entry.label} = ${entry.value}`
    : entry.value;
  const detail = entry.sourceDetail ? `, ${entry.sourceDetail}` : '';
  return `- ${entry.typeLabel}: ${valuePart} (source: ${entry.sourceLabel}${detail})`;
}

export function formatConfirmedContextForPrompt(entries = []) {
  const normalized = normalizeConfirmedContextEntries(entries);
  if (!normalized.length) return '';

  return [
    '## User-confirmed CMO values',
    ...normalized.map(formatEntry),
    '',
    'Use these exact values when relevant. Do not replace them with guessed alternatives. If a required value is not listed here, ask back instead of inventing it.',
  ].join('\n');
}

export function formatConfirmedContextForFollowUp(entries = []) {
  const normalized = normalizeConfirmedContextEntries(entries);
  if (!normalized.length) return '';

  return [
    'Already confirmed CMO values:',
    ...normalized.map(formatEntry),
    'Do not replace these values with guessed alternatives.',
  ].join('\n');
}

export function getConfirmedContextDisplayGroups(entries = []) {
  const normalized = normalizeConfirmedContextEntries(entries);

  return CONFIRMED_CONTEXT_TYPES
    .map((typeOption) => ({
      type: typeOption.id,
      label: typeOption.label,
      entries: normalized
        .filter((entry) => entry.type === typeOption.id)
        .map(cloneEntry),
    }))
    .filter((group) => group.entries.length > 0);
}
