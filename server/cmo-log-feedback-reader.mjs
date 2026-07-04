import { open, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { findCmoRoot, LEGACY_DEFAULT_CMO_ROOT } from '../tools/cmo-install-locator.mjs';

export const DEFAULT_CMO_ROOT = findCmoRoot();
export const DEFAULT_CMO_LOGS_ROOT = path.join(DEFAULT_CMO_ROOT, 'Logs');

const FILE_KIND_PATTERNS = [
  { kind: 'exception', pattern: /^ExceptionLog_.*\.txt$/i },
  { kind: 'lua-history', pattern: /^LuaHistory_.*\.txt$/i },
];

function clampInt(value, fallback, min, max) {
  const numeric = Number.parseInt(String(value ?? ''), 10);
  if (!Number.isFinite(numeric)) return fallback;
  return Math.min(max, Math.max(min, numeric));
}

function coerceKind(value) {
  return ['all', 'exception', 'lua-history'].includes(value) ? value : 'all';
}

function escapeRegex(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function pathRootPattern(root) {
  const normalized = String(root || '').replace(/[\\/]+/g, '/');
  const parts = normalized.split('/').filter(Boolean).map(escapeRegex);
  if (!parts.length) return null;
  return `${parts.join('[\\\\/]')}(?:[\\\\/][^\\\\/\\r\\n\\t ]+)*`;
}

function applyRedaction(source, pattern, replacement) {
  let redactionsApplied = 0;
  const text = source.replace(pattern, () => {
    redactionsApplied += 1;
    return replacement;
  });
  return { text, redactionsApplied };
}

export function redactCmoLogText(value, options = {}) {
  let text = String(value || '');
  let redactionsApplied = 0;
  const apply = (pattern, replacement) => {
    const result = applyRedaction(text, pattern, replacement);
    text = result.text;
    redactionsApplied += result.redactionsApplied;
  };

  const cmoRoots = new Set([
    options.cmoRoot || DEFAULT_CMO_ROOT,
    DEFAULT_CMO_ROOT,
    LEGACY_DEFAULT_CMO_ROOT,
  ]);
  for (const cmoRoot of cmoRoots) {
    const cmoPattern = pathRootPattern(cmoRoot);
    if (cmoPattern) {
      apply(new RegExp(cmoPattern, 'gi'), '<REDACTED_CMO_PATH>');
    }
  }

  apply(/[A-Za-z]:[\\/](?:Users|Documents and Settings)[\\/][^\\/\r\n\t ]+(?:[\\/][^\\/\r\n\t ]+)*/gi, '<REDACTED_USER_PATH>');
  apply(/(?:\\\\|\/\/)[^\\/\r\n\t ]+[\\/][^\\/\r\n\t ]+(?:[\\/][^\\/\r\n\t ]+)*/g, '<REDACTED_PATH>');
  apply(/[A-Za-z]:[\\/][^\\/\r\n\t ]+(?:[\\/][^\\/\r\n\t ]+)*/g, '<REDACTED_PATH>');
  apply(/Authorization:\s*[^\r\n]+/gi, 'Authorization: <REDACTED_SECRET>');
  apply(/Bearer\s+[A-Za-z0-9._~+/=-]{8,}/gi, '<REDACTED_SECRET>');
  apply(/sk-[A-Za-z0-9._-]{8,}/gi, '<REDACTED_SECRET>');

  return { text, redactionsApplied };
}

export function resolveCmoLogsRoot(options = {}) {
  const configured = options.logsRoot || process.env.CMO_LOGS_ROOT || DEFAULT_CMO_LOGS_ROOT;
  return path.resolve(configured);
}

function getFileKind(fileName) {
  return FILE_KIND_PATTERNS.find((entry) => entry.pattern.test(fileName))?.kind || '';
}

async function statOrNull(filePath) {
  try {
    return await stat(filePath);
  } catch {
    return null;
  }
}

async function listLogFiles(logsRoot, kind) {
  let entries = [];
  try {
    entries = await readdir(logsRoot, { withFileTypes: true });
  } catch {
    return [];
  }

  const candidates = [];
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    const fileKind = getFileKind(entry.name);
    if (!fileKind) continue;
    if (kind !== 'all' && fileKind !== kind) continue;

    const filePath = path.join(logsRoot, entry.name);
    const fileStats = await statOrNull(filePath);
    if (!fileStats?.isFile()) continue;

    candidates.push({
      kind: fileKind,
      fileName: entry.name,
      filePath,
      lastWriteTime: fileStats.mtime.toISOString(),
      mtimeMs: fileStats.mtimeMs,
      sizeBytes: fileStats.size,
    });
  }

  return candidates.sort((a, b) => b.mtimeMs - a.mtimeMs);
}

async function readTailWindow(filePath, maxBytes) {
  const fd = await open(filePath, 'r');
  try {
    const fileStats = await fd.stat();
    const length = Math.min(maxBytes, fileStats.size);
    const start = Math.max(0, fileStats.size - length);
    const buffer = Buffer.alloc(length);
    const { bytesRead } = await fd.read(buffer, 0, length, start);
    let text = buffer.subarray(0, bytesRead).toString('utf8');

    if (start > 0) {
      const firstNewline = text.indexOf('\n');
      text = firstNewline === -1 ? '' : text.slice(firstNewline + 1);
    }

    return { text, truncated: start > 0 };
  } finally {
    await fd.close();
  }
}

function parseLineTimestamp(text) {
  const isoMatch = String(text).match(/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z)/);
  if (isoMatch) {
    const timestamp = Date.parse(isoMatch[1]);
    return Number.isFinite(timestamp) ? timestamp : null;
  }

  const localMatch = String(text).match(/^(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}:\d{2})/);
  if (localMatch) {
    const timestamp = Date.parse(`${localMatch[1]}T${localMatch[2]}Z`);
    return Number.isFinite(timestamp) ? timestamp : null;
  }

  return null;
}

function parseSince(value) {
  if (!value) return null;
  const timestamp = Date.parse(String(value));
  return Number.isFinite(timestamp) ? timestamp : null;
}

function tailLines(text, limit, sinceTime) {
  return String(text || '')
    .split(/\r?\n/)
    .map((line, index) => ({
      lineNumber: index + 1,
      text: line.trimEnd(),
      timestamp: parseLineTimestamp(line),
    }))
    .filter((entry) => entry.text.trim())
    .filter((entry) => !sinceTime || !entry.timestamp || entry.timestamp >= sinceTime)
    .slice(-limit)
    .map(({ lineNumber, text }) => ({ lineNumber, text }));
}

function buildFollowUpDraft(files) {
  const entries = files.flatMap((file) => file.entries.map((entry) => `${file.fileName}:${entry.lineNumber} ${entry.text}`));
  if (!entries.length) {
    return 'No recent CMO log lines were found. If CMO showed an error, verify the log file and paste the relevant line manually.';
  }

  return [
    'Review these CMO log lines and draft a correction.',
    'Do not invent missing Side, Mission, Unit GUID, DBID, Loadout ID, RP, Zone, posture, doctrine, EMCON, or coordinates.',
    'If the logs are insufficient, ask for the exact CMO value before producing paste-ready Lua.',
    '',
    entries.slice(0, 12).join('\n'),
  ].join('\n');
}

export async function buildCmoLogFeedback(options = {}) {
  const logsRoot = resolveCmoLogsRoot({ logsRoot: options.logsRoot });
  const kind = coerceKind(options.kind || 'all');
  const limit = clampInt(options.limit, 20, 1, 50);
  const maxBytes = clampInt(options.maxBytes, 24000, 4096, 65536);
  const sinceTime = parseSince(options.since);
  const logsRootStats = await statOrNull(logsRoot);

  if (!logsRootStats?.isDirectory()) {
    return {
      ok: true,
      logsRootConfigured: false,
      kind,
      files: [],
      summary: {
        filesScanned: 0,
        entriesReturned: 0,
        redactionsApplied: 0,
        partialReadFailures: 0,
        truncatedFiles: 0,
      },
      followUpDraft: buildFollowUpDraft([]),
    };
  }

  const candidates = await listLogFiles(logsRoot, kind);
  const files = [];
  let remaining = limit;
  let redactionsApplied = 0;
  let partialReadFailures = 0;
  let truncatedFiles = 0;
  let filesScanned = 0;

  for (const candidate of candidates.slice(0, 4)) {
    if (remaining <= 0) break;
    filesScanned += 1;

    let tail;
    try {
      tail = await readTailWindow(candidate.filePath, maxBytes);
    } catch {
      partialReadFailures += 1;
      continue;
    }

    if (tail.truncated) truncatedFiles += 1;
    const entries = tailLines(tail.text, remaining, sinceTime).map((entry) => {
      const redacted = redactCmoLogText(entry.text, { cmoRoot: options.cmoRoot });
      redactionsApplied += redacted.redactionsApplied;
      return { ...entry, text: redacted.text };
    });

    if (!entries.length) continue;
    remaining -= entries.length;
    files.push({
      kind: candidate.kind,
      fileName: candidate.fileName,
      lastWriteTime: candidate.lastWriteTime,
      sizeBytes: candidate.sizeBytes,
      entries,
    });
  }

  const entriesReturned = files.reduce((total, file) => total + file.entries.length, 0);
  return {
    ok: true,
    logsRootConfigured: true,
    kind,
    files,
    summary: {
      filesScanned,
      entriesReturned,
      redactionsApplied,
      partialReadFailures,
      truncatedFiles,
    },
    followUpDraft: buildFollowUpDraft(files),
  };
}
