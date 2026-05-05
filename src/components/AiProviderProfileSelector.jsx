import { useState } from 'react';
import './AiProviderProfileSelector.css';
import { readAiProviderProfiles } from '../lib/aiProviderProfiles';

function providerLabel(providerType) {
  switch (providerType) {
    case 'lm-studio':
      return 'LM Studio';
    case 'ollama':
      return 'Ollama';
    default:
      return 'OpenAI 호환';
  }
}

function profileSummary(profile, totalProfiles) {
  if (!profile) {
    return totalProfiles
      ? `${totalProfiles} profiles · Settings 기본 모델 사용 중`
      : 'Settings에서 모델 프로필을 저장하면 여기서 빠르게 전환할 수 있습니다.';
  }

  const generation = profile.generationMode === 'provider-default'
    ? 'provider 기본 생성값'
    : `temp ${profile.temperature} · ${profile.maxTokens} tokens`;

  return `${providerLabel(profile.providerType)} · ${profile.model || 'model 미설정'} · ${generation} · key 미저장`;
}

function toProviderOverride(profile) {
  if (!profile) return null;
  return {
    name: profile.name,
    providerType: profile.providerType,
    baseUrl: profile.baseUrl,
    model: profile.model,
    generationMode: profile.generationMode,
    temperature: profile.temperature,
    maxTokens: profile.maxTokens,
  };
}

export default function AiProviderProfileSelector({ disabled, onProfileChange }) {
  const [profiles, setProfiles] = useState(readAiProviderProfiles);
  const [activeProfileId, setActiveProfileId] = useState('');
  const activeProfile = profiles.find((item) => item.id === activeProfileId) || null;

  const selectProfile = (profileId, nextProfiles = profiles) => {
    const profile = nextProfiles.find((item) => item.id === profileId) || null;
    setActiveProfileId(profile?.id || '');
    onProfileChange(toProviderOverride(profile));
  };

  const refreshProfiles = () => {
    const nextProfiles = readAiProviderProfiles();
    setProfiles(nextProfiles);

    if (!activeProfileId) return;
    selectProfile(activeProfileId, nextProfiles);
  };

  return (
    <div className="ai-readiness-profile-row">
      <div className="ai-readiness-profile-select">
        <select
          value={activeProfileId}
          onChange={(event) => selectProfile(event.target.value)}
          aria-label="AI 모델 프로필 선택"
          disabled={disabled}
        >
          <option value="">현재 Settings 모델 사용</option>
          {profiles.map((profile) => (
            <option key={profile.id} value={profile.id}>
              {profile.name} · {profile.model || 'model 미설정'}
            </option>
          ))}
        </select>
        <span className="ai-readiness-profile-summary">
          {profileSummary(activeProfile, profiles.length)}
        </span>
      </div>
      <button
        className="btn btn-mini btn-ghost"
        type="button"
        onClick={refreshProfiles}
        disabled={disabled}
      >
        새로고침
      </button>
    </div>
  );
}
