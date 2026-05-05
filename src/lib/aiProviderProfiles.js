const AI_PROVIDER_PROFILE_STORAGE_KEY = 'cmo-lua-ui-ai-provider-profiles';
export const MAX_AI_PROVIDER_PROFILES = 64;

function clamp(value, fallback, min, max) {
  const next = Number(value);
  if (!Number.isFinite(next)) return fallback;
  return Math.min(Math.max(next, min), max);
}

function normalizeProfile(profile) {
  const name = String(profile?.name || profile?.model || 'AI Model Profile').trim().slice(0, 64);

  return {
    id: String(profile?.id || '').trim() || `profile-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`,
    name: name || 'AI Model Profile',
    providerType: String(profile?.providerType || 'openai-compatible'),
    baseUrl: String(profile?.baseUrl || '').trim(),
    model: String(profile?.model || '').trim(),
    generationMode: profile?.generationMode === 'provider-default' ? 'provider-default' : 'manual',
    temperature: clamp(profile?.temperature, 0.3, 0, 2),
    maxTokens: clamp(profile?.maxTokens, 2048, 256, 32000),
  };
}

export function readAiProviderProfiles() {
  if (typeof window === 'undefined') return [];

  try {
    const parsed = JSON.parse(window.localStorage.getItem(AI_PROVIDER_PROFILE_STORAGE_KEY) || '[]');
    return Array.isArray(parsed)
      ? parsed.map(normalizeProfile).filter((profile) => profile.id && profile.name).slice(0, MAX_AI_PROVIDER_PROFILES)
      : [];
  } catch {
    return [];
  }
}

export function writeAiProviderProfiles(profiles) {
  if (typeof window === 'undefined') return;

  const safeProfiles = Array.isArray(profiles)
    ? profiles.map(normalizeProfile).slice(0, MAX_AI_PROVIDER_PROFILES)
    : [];

  window.localStorage.setItem(AI_PROVIDER_PROFILE_STORAGE_KEY, JSON.stringify(safeProfiles));
}

export function buildAiProviderProfile(form, name, existingId = '') {
  return normalizeProfile({
    id: existingId,
    name,
    providerType: form.providerType,
    baseUrl: form.baseUrl,
    model: form.model,
    generationMode: form.generationMode,
    temperature: form.temperature,
    maxTokens: form.maxTokens,
  });
}

export function applyAiProviderProfileToForm(profile, currentForm) {
  const safeProfile = normalizeProfile(profile);

  return {
    ...currentForm,
    providerType: safeProfile.providerType,
    baseUrl: safeProfile.baseUrl,
    model: safeProfile.model,
    generationMode: safeProfile.generationMode,
    temperature: safeProfile.temperature,
    maxTokens: safeProfile.maxTokens,
  };
}
