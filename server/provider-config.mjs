import { PROVIDER_TYPES, isCliProviderType, joinUrl, openAiCompatibleUrl } from './providers.mjs';
import { RequestError, requireObject } from './adapter-security.mjs';

const STRING_FIELDS = ['providerType', 'baseUrl', 'apiKey', 'model', 'cliHome', 'backendId'];

function checkedBaseUrl(value) {
  if (!value) return '';
  let url;
  try { url = new URL(value); } catch { throw new RequestError('Invalid provider baseUrl'); }
  if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password
      || url.search || url.hash || /[\s\u0000-\u001f\u007f]/u.test(value)) {
    throw new RequestError('Provider baseUrl must be HTTP(S), without credentials, query or fragment');
  }
  // Preserve raw path syntax until provider endpoint assembly. Canonicalizing
  // /v1/. first would change the provider's /v1 de-duplication behavior.
  return value.replace(/\/+$/, '');
}

function credentialRecipient(cfg) {
  const family = cfg.providerType === 'lm-studio' ? 'openai-compatible' : cfg.providerType;
  if (isCliProviderType(family)) return family;
  const base = checkedBaseUrl(cfg.baseUrl);
  if (!base) return `${family}:unconfigured`;
  // Use the very same assembly as the transport, then canonicalize the final
  // URL. Preserve path case; /v1/. and /v1 can reach different endpoints.
  const endpoint = family === 'openai-compatible'
    ? openAiCompatibleUrl(base, '/v1/chat/completions')
    : joinUrl(base, family === 'anthropic-compatible' ? '/v1/messages' : '/api/chat');
  return `${family}:${new URL(endpoint).href}`;
}

export function mergeProviderConfig(current, update, { settings = false } = {}) {
  requireObject(update, 'Provider settings');
  const patch = {};
  for (const field of STRING_FIELDS) {
    if (!Object.hasOwn(update, field)) continue;
    if (typeof update[field] !== 'string' || /[\u0000\r\n]/u.test(update[field])) {
      throw new RequestError(`${field} must be a string without NUL or line breaks`);
    }
    patch[field] = update[field];
  }
  if (Object.hasOwn(patch, 'providerType') && !PROVIDER_TYPES.has(patch.providerType)) {
    throw new RequestError('Unsupported providerType');
  }
  if (Object.hasOwn(patch, 'baseUrl')) patch.baseUrl = checkedBaseUrl(patch.baseUrl);
  if (Object.hasOwn(update, 'generationMode')) {
    if (!['manual', 'provider-default'].includes(update.generationMode)) {
      throw new RequestError('Invalid generationMode');
    }
    patch.generationMode = update.generationMode;
  }
  for (const field of ['temperature', 'maxTokens']) {
    if (!Object.hasOwn(update, field)) continue;
    if (typeof update[field] !== 'number' || !Number.isFinite(update[field])
        || (field === 'maxTokens' && (!Number.isInteger(update[field]) || update[field] < 1))) {
      throw new RequestError(`Invalid ${field}`);
    }
    patch[field] = update[field];
  }
  const merged = { ...current, ...patch };
  const recipient = credentialRecipient(merged);
  if (Object.hasOwn(patch, 'apiKey')) return merged;
  let sameRecipient = false;
  try {
    sameRecipient = credentialRecipient(current) === recipient;
  } catch (error) {
    if (!(error instanceof RequestError)) throw error;
    // An invalid startup URL must be repairable through settings. Its key has
    // no validated recipient and is never carried over to the replacement.
  }
  if (!sameRecipient) {
    if (current.apiKey && !settings) {
      throw new RequestError('Provider destination changed. Save the new settings first or supply an explicit apiKey (empty for a keyless provider).');
    }
    merged.apiKey = '';
  }
  return merged;
}
