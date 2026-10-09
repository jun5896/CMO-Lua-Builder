import { useState } from 'react';
import './AiAdapterSettings.css';
import {
  AI_ADAPTER_BASE_URL,
  AI_PROVIDER_TYPES,
  DEFAULT_AI_PROVIDER_FORM,
  fetchAiAdapterHealth,
  fetchAiAdapterSettings,
  fetchAiProviderModels,
  saveAiAdapterSettings,
  testAiAdapterProvider,
} from '../lib/aiAdapterClient';
import {
  MAX_AI_PROVIDER_PROFILES,
  applyAiProviderProfileToForm,
  buildAiProviderProfile,
  readAiProviderProfiles,
  writeAiProviderProfiles,
} from '../lib/aiProviderProfiles';

export default function AiAdapterSettings() {
  const [aiProviderForm, setAiProviderForm] = useState(DEFAULT_AI_PROVIDER_FORM);
  const [aiProfiles, setAiProfiles] = useState(readAiProviderProfiles);
  const [activeAiProfileId, setActiveAiProfileId] = useState('');
  const [aiProfileName, setAiProfileName] = useState('');
  const [aiModelOptions, setAiModelOptions] = useState([]);
  const [selectedAiModels, setSelectedAiModels] = useState([]);
  const [aiAdapterStatus, setAiAdapterStatus] = useState({
    state: 'idle',
    message: 'AI Adapter 상태를 아직 확인하지 않았습니다.',
  });
  const [isAiRequestBusy, setIsAiRequestBusy] = useState(false);
  const [isModelListBusy, setIsModelListBusy] = useState(false);
  const trimmedAiModel = String(aiProviderForm.model || '').trim();
  const modelsQueuedForSave = selectedAiModels.length || (trimmedAiModel ? 1 : 0);
  const modelProfileSaveHint = selectedAiModels.length
    ? `${selectedAiModels.length}개 선택됨 · 같은 Provider/Base URL이면 기존 프로필을 갱신합니다.`
    : (trimmedAiModel
      ? `현재 Model 칸의 "${trimmedAiModel}" 1개가 저장됩니다.`
      : '모델을 선택하거나 Model 칸에 직접 입력하면 저장할 수 있습니다.');

  const setAiStatus = (state, message) => {
    setAiAdapterStatus({ state, message });
  };

  const updateAiProviderForm = (field, value) => {
    setAiProviderForm((current) => ({ ...current, [field]: value }));
    if (['providerType', 'baseUrl', 'apiKey'].includes(field)) {
      setAiModelOptions([]);
      setSelectedAiModels([]);
    }
  };

  const getProviderLabel = (providerType) => (
    AI_PROVIDER_TYPES.find((provider) => provider.id === providerType)?.label || providerType
  );

  const persistAiProfiles = (profiles) => {
    const nextProfiles = profiles.slice(0, MAX_AI_PROVIDER_PROFILES);
    setAiProfiles(nextProfiles);
    writeAiProviderProfiles(nextProfiles);
  };

  const profileKey = (profile) => [
    profile.providerType,
    profile.baseUrl,
    profile.model,
    profile.generationMode,
  ].map((value) => String(value || '').trim().toLowerCase()).join('|');

  const toggleAiModelSelection = (model) => {
    setSelectedAiModels((current) => (
      current.includes(model)
        ? current.filter((item) => item !== model)
        : [...current, model]
    ));
  };

  const chooseAiModelFromList = (model) => {
    const nextModel = String(model || '').trim();
    if (!nextModel) return;

    setAiProviderForm((current) => ({ ...current, model: nextModel }));
    setSelectedAiModels((current) => (
      current.includes(nextModel) ? current : [...current, nextModel]
    ));
  };

  const saveCurrentAiProfile = () => {
    const profileName = aiProfileName.trim() || aiProviderForm.model || 'AI Model Profile';
    const nextProfile = buildAiProviderProfile(aiProviderForm, profileName, activeAiProfileId);
    const nextProfiles = activeAiProfileId
      ? aiProfiles.map((profile) => (profile.id === activeAiProfileId ? nextProfile : profile))
      : [nextProfile, ...aiProfiles];

    persistAiProfiles(nextProfiles);
    setActiveAiProfileId(nextProfile.id);
    setAiProfileName(nextProfile.name);
    setAiStatus('ok', `프로필 저장 완료 · ${nextProfile.name} · key 미저장`);
  };

  const saveSelectedAiModelProfiles = () => {
    const modelsToSave = (selectedAiModels.length ? selectedAiModels : [aiProviderForm.model])
      .map((model) => String(model || '').trim())
      .filter(Boolean);

    if (modelsToSave.length === 0) {
      setAiStatus('error', '저장할 모델을 먼저 선택하거나 Model 칸에 직접 입력하세요.');
      return;
    }

    let added = 0;
    let updated = 0;
    const existingByKey = new Map(aiProfiles.map((profile) => [profileKey(profile), profile]));
    let nextProfiles = [...aiProfiles];

    for (const model of modelsToSave) {
      const formForModel = { ...aiProviderForm, model };
      const draftProfile = buildAiProviderProfile(formForModel, model);
      const existing = existingByKey.get(profileKey(draftProfile));
      const nextProfile = buildAiProviderProfile(formForModel, model, existing?.id || '');

      if (existing) {
        nextProfiles = nextProfiles.map((profile) => (profile.id === existing.id ? nextProfile : profile));
        updated += 1;
      } else {
        nextProfiles = [nextProfile, ...nextProfiles];
        existingByKey.set(profileKey(nextProfile), nextProfile);
        added += 1;
      }
    }

    persistAiProfiles(nextProfiles);
    if (modelsToSave.length === 1) {
      const savedKey = profileKey({ ...aiProviderForm, model: modelsToSave[0] });
      const savedProfile = nextProfiles.find((profile) => profileKey(profile) === savedKey);
      if (savedProfile) {
        setActiveAiProfileId(savedProfile.id);
        setAiProfileName(savedProfile.name);
        setAiProviderForm((current) => applyAiProviderProfileToForm(savedProfile, current));
      }
    }
    setAiStatus('ok', `모델 프로필 반영 완료 · 추가 ${added}개 · 갱신 ${updated}개 · key 미저장`);
  };

  const applyAiProfile = (profile) => {
    setAiProviderForm((current) => ({
      ...applyAiProviderProfileToForm(profile, current),
      apiKey: '',
    }));
    setActiveAiProfileId(profile.id);
    setAiProfileName(profile.name);
    setAiStatus('idle', `프로필 불러옴 · ${profile.name} · key 입력 후 설정 적용`);
  };

  const deleteAiProfile = (profileId) => {
    const profile = aiProfiles.find((item) => item.id === profileId);
    if (!profile || !window.confirm(`${profile.name} 프로필을 삭제할까요?`)) return;

    const nextProfiles = aiProfiles.filter((item) => item.id !== profileId);
    persistAiProfiles(nextProfiles);

    if (activeAiProfileId === profileId) {
      setActiveAiProfileId('');
      setAiProfileName('');
    }

    setAiStatus('ok', `프로필 삭제 완료 · ${profile.name}`);
  };

  const checkAiAdapter = async () => {
    setIsAiRequestBusy(true);
    try {
      const health = await fetchAiAdapterHealth();
      const nextSettings = await fetchAiAdapterSettings();
      setAiProviderForm(nextSettings);
      setAiModelOptions([]);
      setActiveAiProfileId('');
      setAiProfileName(nextSettings.model || '');
      setAiStatus(
        'ok',
        `${health.service || 'AI Adapter'} 연결됨 · ${nextSettings.providerType} · ${nextSettings.model || 'model 미설정'}`,
      );
    } catch (error) {
      setAiStatus('error', `AI Adapter 연결 실패: ${error.message}`);
    } finally {
      setIsAiRequestBusy(false);
    }
  };

  const saveAiSettings = async () => {
    setIsAiRequestBusy(true);
    try {
      const nextSettings = await saveAiAdapterSettings(aiProviderForm);
      setAiProviderForm(nextSettings);
      setAiStatus(
        'ok',
        `설정 적용 완료 · ${nextSettings.providerType} · ${nextSettings.apiKeyPreview || 'API key 없음/로컬 provider'}`,
      );
    } catch (error) {
      setAiStatus('error', `설정 적용 실패: ${error.message}`);
    } finally {
      setIsAiRequestBusy(false);
    }
  };

  const runAiProviderTest = async () => {
    setIsAiRequestBusy(true);
    try {
      const result = await testAiAdapterProvider(aiProviderForm);
      setAiStatus('ok', `Provider 테스트 성공 · HTTP ${result.status || 200}`);
    } catch (error) {
      const status = error.status ? `HTTP ${error.status}` : '연결 실패';
      setAiStatus('error', `Provider 테스트 실패 · ${status}: ${error.message}`);
    } finally {
      setIsAiRequestBusy(false);
    }
  };

  const loadAiModelList = async () => {
    setIsModelListBusy(true);
    try {
      const models = await fetchAiProviderModels(aiProviderForm);
      setAiModelOptions(models);
      setSelectedAiModels([]);
      setAiStatus(
        models.length ? 'ok' : 'error',
        models.length
          ? `모델 목록 ${models.length}개를 불러왔습니다. 원하는 모델을 선택하세요.`
          : 'Provider는 응답했지만 표시 가능한 모델이 없습니다.',
      );
    } catch (error) {
      setAiModelOptions([]);
      const status = error.status ? `HTTP ${error.status}` : '연결 실패';
      setAiStatus('error', `모델 목록 조회 실패 · ${status}: ${error.message}`);
    } finally {
      setIsModelListBusy(false);
    }
  };

  return (
    <div className="settings-panel-grid ai-settings-grid">
      <section className="settings-panel-card ai-settings-card">
        <h3>Local AI Adapter</h3>
        <p>
          로컬 Node 어댑터를 통해 OpenAI 호환 API, LM Studio, Ollama 계열 모델을 호출합니다.
          API key는 브라우저 저장소에 저장하지 않고 실행 중인 어댑터 메모리에만 전달합니다.
        </p>
        <div className={`ai-adapter-status ${aiAdapterStatus.state}`}>
          {aiAdapterStatus.message}
        </div>
        <div className="settings-form-grid">
          <label>
            Provider
            <select
              value={aiProviderForm.providerType}
              onChange={(event) => updateAiProviderForm('providerType', event.target.value)}
            >
              {AI_PROVIDER_TYPES.map((provider) => (
                <option key={provider.id} value={provider.id}>{provider.label}</option>
              ))}
            </select>
          </label>
          <label>
            Model
            <input
              value={aiProviderForm.model}
              onChange={(event) => updateAiProviderForm('model', event.target.value)}
              placeholder="예: gpt-5.5, qwen, llama3"
            />
          </label>
          <label>
            Provider models
            <select
              value=""
              onChange={(event) => chooseAiModelFromList(event.target.value)}
              disabled={aiModelOptions.length === 0}
            >
              <option value="">
                {aiModelOptions.length ? '목록에서 모델 선택' : '모델 목록을 먼저 불러오세요'}
              </option>
              {aiModelOptions.map((model) => (
                <option key={model} value={model}>{model}</option>
              ))}
            </select>
          </label>
          {aiModelOptions.length > 0 && (
            <div className="ai-model-picker settings-wide-field">
              <div className="ai-model-picker-header">
                <div>
                  <strong>불러온 모델 선택</strong>
                  <span>{aiModelOptions.length} found · {modelsQueuedForSave} save target · key 미저장</span>
                </div>
                <div className="ai-model-picker-actions">
                  <button
                    className="btn btn-mini btn-ghost"
                    type="button"
                    onClick={() => setSelectedAiModels(aiModelOptions)}
                    disabled={selectedAiModels.length === aiModelOptions.length}
                  >
                    전체 선택
                  </button>
                  <button
                    className="btn btn-mini btn-ghost"
                    type="button"
                    onClick={() => setSelectedAiModels([])}
                    disabled={selectedAiModels.length === 0}
                  >
                    선택 해제
                  </button>
                </div>
              </div>
              <p className="ai-model-picker-hint">{modelProfileSaveHint}</p>
              <div className="ai-model-chip-list" aria-label="Provider 모델 다중 선택">
                {aiModelOptions.map((model) => (
                  <button
                    className={`ai-model-chip ${selectedAiModels.includes(model) ? 'selected' : ''}`}
                    key={model}
                    type="button"
                    onClick={() => toggleAiModelSelection(model)}
                  >
                    {model}
                  </button>
                ))}
              </div>
              <button
                className="btn btn-ghost"
                type="button"
                onClick={saveSelectedAiModelProfiles}
                disabled={modelsQueuedForSave === 0}
              >
                선택 모델 프로필 저장
              </button>
            </div>
          )}
          <label className="settings-wide-field">
            Base URL
            <input
              value={aiProviderForm.baseUrl}
              onChange={(event) => updateAiProviderForm('baseUrl', event.target.value)}
              placeholder="예: https://api.openai.com 또는 http://127.0.0.1:1234"
            />
          </label>
          <label className="settings-wide-field">
            API Key
            <input
              type="password"
              value={aiProviderForm.apiKey}
              onChange={(event) => updateAiProviderForm('apiKey', event.target.value)}
              placeholder={aiProviderForm.apiKeyConfigured ? `${aiProviderForm.apiKeyPreview} · 새 키 입력 시 교체` : '로컬 provider면 비워둘 수 있습니다.'}
            />
            {aiProviderForm.apiKeyConfigured && (
              <p className="ai-model-picker-hint">
                API key 입력칸은 보안상 비웁니다. 적용된 key는 adapter 메모리에만 유지됩니다. 제공자 주소를 바꾸면 기존 key는 초기화되므로 새 설정을 먼저 저장하거나 새 key를 입력한 뒤 테스트하세요.
              </p>
            )}
          </label>
          <label className="checkbox-line settings-wide-field generation-default-toggle">
            <input
              type="checkbox"
              checked={aiProviderForm.generationMode === 'provider-default'}
              onChange={(event) => updateAiProviderForm('generationMode', event.target.checked ? 'provider-default' : 'manual')}
            />
            Provider 기본 생성 설정 사용
            <span>켜면 AI 호출 시 temperature/max tokens를 보내지 않고 provider/model 기본값을 따릅니다.</span>
          </label>
          <label>
            Temperature
            <input
              type="number"
              min="0"
              max="2"
              step="0.1"
              value={aiProviderForm.temperature}
              onChange={(event) => updateAiProviderForm('temperature', Number(event.target.value))}
              disabled={aiProviderForm.generationMode === 'provider-default'}
            />
          </label>
          <label>
            Max tokens
            <input
              type="number"
              min="256"
              max="32000"
              step="256"
              value={aiProviderForm.maxTokens}
              onChange={(event) => updateAiProviderForm('maxTokens', Number(event.target.value))}
              disabled={aiProviderForm.generationMode === 'provider-default'}
            />
          </label>
        </div>
        <div className="ai-profile-manager">
          <div className="ai-profile-manager-header">
            <div>
              <h4>Model Profiles</h4>
              <p>Provider/모델 조합을 저장합니다. API key는 저장하지 않습니다.</p>
            </div>
            <span>{aiProfiles.length}/{MAX_AI_PROVIDER_PROFILES} profiles</span>
          </div>
          <div className="ai-profile-save-row">
            <input
              value={aiProfileName}
              onChange={(event) => setAiProfileName(event.target.value)}
              placeholder={aiProviderForm.model ? `${aiProviderForm.model} profile` : '프로필 이름'}
            />
            <button
              className="btn btn-ghost"
              type="button"
              onClick={saveCurrentAiProfile}
              disabled={!String(aiProviderForm.model || '').trim()}
            >
              {activeAiProfileId ? '프로필 업데이트' : '프로필 저장'}
            </button>
          </div>
          <div className="ai-profile-list" aria-label="저장된 AI 모델 프로필">
            {aiProfiles.length === 0 && (
              <div className="ai-profile-empty">
                저장된 프로필이 없습니다. Provider, URL, Model 입력 후 저장하세요.
              </div>
            )}
            {aiProfiles.map((profile) => (
              <article
                className={`ai-profile-card ${activeAiProfileId === profile.id ? 'active' : ''}`}
                key={profile.id}
              >
                <div>
                  <strong>{profile.name}</strong>
                  <span>{getProviderLabel(profile.providerType)} · {profile.model || 'model 미설정'}</span>
                  <small>
                    {profile.baseUrl || 'base URL 미설정'} · {profile.generationMode === 'provider-default'
                      ? 'provider 기본 생성 설정'
                      : `temp ${profile.temperature} · ${profile.maxTokens} tokens`}
                  </small>
                </div>
                <div className="ai-profile-card-actions">
                  <button className="btn btn-ghost" type="button" onClick={() => applyAiProfile(profile)}>
                    선택
                  </button>
                  <button className="btn btn-danger" type="button" onClick={() => deleteAiProfile(profile.id)}>
                    삭제
                  </button>
                </div>
              </article>
            ))}
          </div>
        </div>
        <div className="assistant-actions ai-settings-actions">
          <button className="btn btn-ghost" type="button" onClick={checkAiAdapter} disabled={isAiRequestBusy}>
            상태 확인
          </button>
          <button className="btn btn-ghost" type="button" onClick={loadAiModelList} disabled={isAiRequestBusy || isModelListBusy}>
            {isModelListBusy ? '모델 조회 중' : '모델 목록 불러오기'}
          </button>
          <button className="btn btn-primary" type="button" onClick={saveAiSettings} disabled={isAiRequestBusy}>
            설정 적용
          </button>
          <button className="btn btn-ghost" type="button" onClick={runAiProviderTest} disabled={isAiRequestBusy}>
            Provider 테스트
          </button>
        </div>
      </section>
      <section className="settings-panel-card ai-workflow-card">
        <h3>Assistant 사용 흐름</h3>
        <ul className="assistant-hint-list">
          <li>`npm run start:ai-adapter`로 로컬 어댑터를 먼저 실행합니다.</li>
          <li>설정 적용 후 Provider 테스트가 통과하면 Event/Lua Assistant의 Output 탭에서 AI 호출을 사용할 수 있습니다.</li>
          <li>AI 응답은 바로 CMO에 넣지 말고 Working Draft로 적용한 뒤 CMO Lua Console 또는 Event Editor에서 검증합니다.</li>
          <li>수동 Prompt 복사 기능은 계속 유지됩니다. 어댑터가 꺼져 있어도 Codex/Claude/Chatbox에 붙여넣어 작업할 수 있습니다.</li>
        </ul>
        <div className="settings-current-note">
          Adapter endpoint: {AI_ADAPTER_BASE_URL}
        </div>
      </section>
    </div>
  );
}
