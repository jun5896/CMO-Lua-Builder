// Shared screening for untrusted drafts. This is not a Lua parser or sandbox.
// Inspect literal text too: CMO can later execute strings passed as ScriptText.
// Computed/encoded source and the effects of allowed CMO APIs need human review.
export const LUA_SAFETY_POLICY_VERSION = '2026-10-10.1';
export const MAX_LUA_SOURCE_CHARS = 320_000; // UTF-16 code units, before normalization.

// Reserve complete identifiers, including references copied into aliases and
// bracket access. Global environment access and dynamic loaders evade ordinary
// call-pattern checks. Comments/strings can conservatively trigger rejection.
const UNSAFE_IDENTIFIERS = /\b(?:os|io|package|debug|require|dofile|loadfile|ScenEdit_RunScript|load|loadstring|_G|_ENV|getfenv|setfenv)\b/gi;

export function inspectLuaSafety(content) {
  const issues = [];
  const result = (normalizedLua = '') => ({
    ok: issues.length === 0,
    policyVersion: LUA_SAFETY_POLICY_VERSION,
    issues,
    normalizedLua,
  });

  if (typeof content !== 'string') {
    issues.push({ code: 'invalid-type', message: 'Lua content must be a string' });
    return result();
  }
  if (content.length > MAX_LUA_SOURCE_CHARS) {
    issues.push({ code: 'too-large', message: `Lua content exceeds ${MAX_LUA_SOURCE_CHARS} UTF-16 code units` });
    return result();
  }
  if (!content.trim()) {
    issues.push({ code: 'empty', message: 'Lua content is required' });
    return result();
  }
  if (content.includes('\0')) {
    issues.push({ code: 'nul-byte', message: 'Lua content must not contain NUL characters' });
  }

  const identifiers = [...new Set(Array.from(content.matchAll(UNSAFE_IDENTIFIERS), (match) => match[0]))];
  if (identifiers.length) {
    issues.push({
      code: 'unsafe-identifier',
      message: `Unsafe Lua surface rejected: ${identifiers.join(', ')}`,
      identifiers,
    });
  }
  return result(issues.length ? '' : `${content.trimEnd()}\n`);
}
