import { Component, useMemo, useState } from 'react';
import { BookOpen, Check, LibraryBig, Plus, Save, Search, WandSparkles, X } from 'lucide-react';
import EventEditor from './EventEditor';
import TemplateLibrary from './TemplateLibrary';
import './PresetGuide.css';
import {
  EVENT_TEMPLATES,
  FEATURE_FORM_GROUPS,
  createEventFromTemplate,
  getTemplateDefinition,
} from '../data/templateCatalog';

const CUSTOM_PRESET_STORAGE_KEY = 'cmo-lua-ui-custom-presets';

function readCustomPresets() {
  if (typeof window === 'undefined') return [];

  try {
    const parsed = JSON.parse(window.localStorage.getItem(CUSTOM_PRESET_STORAGE_KEY) || '[]');
    return Array.isArray(parsed) ? parsed.map(sanitizeCustomPreset).filter(Boolean) : [];
  } catch {
    return [];
  }
}

function writeCustomPresets(presets) {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(CUSTOM_PRESET_STORAGE_KEY, JSON.stringify(presets));
}

function createClientId(prefix = 'preset') {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return `${prefix}-${crypto.randomUUID()}`;
  }
  return `${prefix}-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function isKnownTemplateKind(kind) {
  return EVENT_TEMPLATES.some((template) => template.kind === kind);
}

function sanitizePresetEvents(events) {
  if (!Array.isArray(events)) return [];

  return events
    .filter((event) => event && typeof event === 'object')
    .map((event, index) => {
      const fallbackKind = EVENT_TEMPLATES[0]?.kind || 'iads_ambush';
      const kind = isKnownTemplateKind(event.kind) ? event.kind : fallbackKind;
      const id = event.id || createClientId(`recovered-event-${index}`);
      const defaults = createEventFromTemplate(kind, { id });

      return {
        ...defaults,
        ...event,
        id,
        kind,
        name: event.name || defaults.name,
      };
    });
}

function sanitizeCustomPreset(preset) {
  if (!preset || typeof preset !== 'object') return null;

  const events = sanitizePresetEvents(preset.events);

  return {
    id: preset.id || createClientId('recovered-preset'),
    name: preset.name || buildPresetTitle(events),
    description: preset.description || '',
    savedAt: preset.savedAt || '',
    events,
    settings: preset.settings && typeof preset.settings === 'object' ? preset.settings : {},
  };
}

class PresetGuideBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { error: null };
  }

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidUpdate(previousProps) {
    if (previousProps.resetKey !== this.props.resetKey && this.state.error) {
      this.setState({ error: null });
    }
  }

  componentDidCatch(error) {
    console.error('Preset guide render error', error);
  }

  render() {
    if (!this.state.error) {
      return this.props.children;
    }

    return (
      <div className="preset-runtime-error">
        <p className="eyebrow">Preset Guide Recovery</p>
        <h3>프리셋 제작 화면을 안전 모드로 멈췄습니다.</h3>
        <p>
          저장된 사용자 프리셋이나 이전 작업 이벤트 중 예상 형식과 다른 값이 있어 렌더를 막았습니다.
          화면 전체가 먹통이 되지 않도록 이 카드에서 복구할 수 있습니다.
        </p>
        <button className="btn btn-primary btn-mini" type="button" onClick={() => this.setState({ error: null })}>
          다시 열기
        </button>
      </div>
    );
  }
}

function getTemplateApis(template) {
  const text = [
    template.summary,
    ...(template.notes || []),
    ...(template.fields || []).map((field) => `${field.defaultValue || ''} ${field.help || ''} ${field.hint || ''}`),
  ].join('\n');

  return [...new Set(text.match(/\b(?:ScenEdit|VP|Tool|World|Unit|Mission|Side)[A-Za-z0-9_:.]*/g) || [])].sort();
}

function getTemplateGroup(template) {
  if (template.featureGroup) return template.featureGroup;
  const matchedGroup = FEATURE_FORM_GROUPS.find((group) => group.forms.includes(template.kind));
  return matchedGroup?.name || template.presetSection || 'General Lua';
}

function getEventDisplayTitle(event) {
  if (!event) return '사용자 폼';
  return event.name || getTemplateDefinition(event.kind)?.title || '사용자 폼';
}

function buildPresetTitle(events) {
  if (!events.length) return '사용자 프리셋';
  if (events.length === 1) {
    return getEventDisplayTitle(events[0]);
  }
  return `${getEventDisplayTitle(events[0])} 외 ${events.length - 1}개`;
}

function formatSavedAt(value) {
  if (!value) return '';
  try {
    return new Intl.DateTimeFormat('ko-KR', {
      dateStyle: 'short',
      timeStyle: 'short',
    }).format(new Date(value));
  } catch {
    return value;
  }
}

function PresetEncyclopedia({ onAddTemplate }) {
  const [query, setQuery] = useState('');
  const [selectedKind, setSelectedKind] = useState(EVENT_TEMPLATES[0]?.kind || '');

  const groupedTemplates = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    const filtered = EVENT_TEMPLATES.filter((template) => {
      if (!normalizedQuery) return true;
      return [
        template.title,
        template.kind,
        template.sourceFile,
        template.summary,
        getTemplateGroup(template),
        ...(template.notes || []),
        ...(template.fields || []).map((field) => `${field.label} ${field.name} ${field.help || ''}`),
      ].join(' ').toLowerCase().includes(normalizedQuery);
    });

    return filtered.reduce((groups, template) => {
      const groupName = getTemplateGroup(template);
      if (!groups[groupName]) groups[groupName] = [];
      groups[groupName].push(template);
      return groups;
    }, {});
  }, [query]);

  const visibleTemplates = Object.values(groupedTemplates).flat();
  const selectedTemplate = visibleTemplates.find((template) => template.kind === selectedKind)
    || visibleTemplates[0]
    || null;
  const selectedApis = getTemplateApis(selectedTemplate || {});
  const clearSearch = () => {
    setQuery('');
    setSelectedKind(EVENT_TEMPLATES[0]?.kind || '');
  };

  return (
    <section className="preset-guide-grid encyclopedia-grid">
      <div className="preset-guide-list-card">
        <div className="search-box compact-search">
          <Search size={15} />
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="기능, API, 필드 검색"
          />
        </div>
        <div className="encyclopedia-list">
          {visibleTemplates.length ? (
            Object.entries(groupedTemplates).map(([groupName, templates]) => (
              <section key={groupName} className="encyclopedia-group">
                <h3>{groupName}</h3>
                {templates.map((template) => (
                  <button
                    key={template.kind}
                    className={`encyclopedia-row ${selectedTemplate?.kind === template.kind ? 'active' : ''}`}
                    type="button"
                    onClick={() => setSelectedKind(template.kind)}
                  >
                    <span>{template.title}</span>
                    <small>{template.sourceFile}</small>
                  </button>
                ))}
              </section>
            ))
          ) : (
            <div className="encyclopedia-empty-state">
              <strong>검색 결과가 없습니다.</strong>
              <p>기능명, API 이름, 필드명 기준으로 다시 검색하거나 전체 목록으로 돌아가세요.</p>
              <button className="btn btn-mini btn-ghost" type="button" onClick={clearSearch}>
                전체 보기
              </button>
            </div>
          )}
        </div>
      </div>

      {selectedTemplate ? (
        <article className="encyclopedia-detail-card">
          <div className="source-card-top">
            <div>
              <p className="eyebrow">{getTemplateGroup(selectedTemplate)}</p>
              <h2>{selectedTemplate.title}</h2>
              <div className="resource-meta">
                <span>{selectedTemplate.kind}</span>
                <span>{selectedTemplate.sourceFile}</span>
                <span>{selectedTemplate.fields?.length || 0} fields</span>
              </div>
            </div>
            <button className="btn btn-primary" type="button" onClick={() => onAddTemplate(selectedTemplate.kind)}>
              <Plus size={15} />
              제작 폼에 추가
            </button>
          </div>

          <section className="encyclopedia-section">
            <h3>기능 설명</h3>
            <p>{selectedTemplate.summary}</p>
          </section>

          <section className="encyclopedia-section">
            <h3>입력 필드</h3>
            <div className="field-dictionary">
              {(selectedTemplate.fields || []).map((field) => (
                <div key={field.name}>
                  <strong>{field.label}</strong>
                  <span>{field.name}</span>
                  <p>{field.help || field.hint || `${field.type || 'text'} 입력값입니다.`}</p>
                </div>
              ))}
            </div>
          </section>

          {(selectedTemplate.notes?.length || selectedApis.length > 0) && (
            <section className="encyclopedia-section">
              <h3>주의 / 관련 API</h3>
              <div className="tag-cloud encyclopedia-tags">
                {selectedApis.map((api) => <span key={api}>{api}</span>)}
                {(selectedTemplate.notes || []).map((note) => <span key={note}>{note}</span>)}
              </div>
            </section>
          )}
        </article>
      ) : (
        <article className="encyclopedia-detail-card encyclopedia-empty-detail">
          <p className="eyebrow">No Matching Form</p>
          <h2>표시할 프리셋 설명이 없습니다.</h2>
          <p>검색어를 지우면 공식 Builder Forms 백과 항목을 다시 확인할 수 있습니다.</p>
          <button className="btn btn-primary btn-mini" type="button" onClick={clearSearch}>
            전체 목록으로 돌아가기
          </button>
        </article>
      )}
    </section>
  );
}

function CustomPresetShelf({ customPresets, onApplyPreset, onDeletePreset }) {
  if (!customPresets.length) {
    return (
      <div className="custom-preset-empty">
        저장된 사용자 지정 프리셋이 아직 없습니다. 제작 폼에서 내용을 조정한 뒤 현재 프리셋 저장을 누르면 여기에 유지됩니다.
      </div>
    );
  }

  return (
    <div className="custom-preset-list">
      {customPresets.map((preset) => (
        <article key={preset.id} className="custom-preset-card">
          <div>
            <strong>{preset.name}</strong>
            <p>{preset.description || '설명 없음'}</p>
            <small>{sanitizePresetEvents(preset.events).length} templates · {formatSavedAt(preset.savedAt)}</small>
          </div>
          <div className="custom-preset-actions">
            <button className="btn btn-mini btn-ghost" type="button" onClick={() => onApplyPreset(preset)}>
              <Check size={14} />
              수정
            </button>
            <button
              className="btn btn-icon danger custom-preset-delete"
              type="button"
              aria-label={`${preset.name} 삭제`}
              onClick={() => onDeletePreset(preset.id)}
            >
              <X size={15} />
            </button>
          </div>
        </article>
      ))}
    </div>
  );
}

function PresetBuilder({
  events,
  settings,
  addEvent,
  updateEvent,
  replaceEvent,
  removeEvent,
  customPresets,
  setCustomPresets,
  onApplyPreset,
}) {
  const [presetName, setPresetName] = useState('');
  const [presetDescription, setPresetDescription] = useState('');
  const [selectedEventId, setSelectedEventId] = useState('');
  const safeEvents = useMemo(() => sanitizePresetEvents(events), [events]);
  const safeCustomPresets = useMemo(() => (
    customPresets.map(sanitizeCustomPreset).filter(Boolean)
  ), [customPresets]);
  const selectedEvent = safeEvents.find((event) => String(event.id) === selectedEventId)
    || safeEvents[safeEvents.length - 1]
    || null;
  const canSaveCurrentPreset = Boolean(selectedEvent);

  const addAndSelectEvent = () => {
    const nextEvent = addEvent();
    if (nextEvent?.id) setSelectedEventId(String(nextEvent.id));
  };

  const saveCustomPreset = () => {
    if (!canSaveCurrentPreset) {
      window.alert('저장할 프리셋 폼이 없습니다. 먼저 폼 추가 / Builder Forms에서 템플릿을 추가하세요.');
      return;
    }

    const now = new Date().toISOString();
    const nextPreset = {
      id: createClientId('custom'),
      name: presetName.trim() || getEventDisplayTitle(selectedEvent),
      description: presetDescription.trim() || settings.description || '',
      savedAt: now,
      events: [{ ...selectedEvent, id: createClientId('preset-event') }],
      settings: { ...settings },
    };
    const nextPresets = [nextPreset, ...safeCustomPresets];
    setCustomPresets(nextPresets);
    writeCustomPresets(nextPresets);
    setPresetName('');
    setPresetDescription('');
  };

  const deleteCustomPreset = (id) => {
    const target = safeCustomPresets.find((preset) => preset.id === id);
    if (!target) return;
    if (!window.confirm(`"${target.name}" 프리셋을 삭제하시겠습니까?`)) return;
    const nextPresets = safeCustomPresets.filter((preset) => preset.id !== id);
    setCustomPresets(nextPresets);
    writeCustomPresets(nextPresets);
  };

  return (
    <section className="preset-guide-builder">
      <div className="preset-builder-main">
        <div className="section-header compact preset-builder-header">
          <div>
            <p className="eyebrow">Preset Prompt Guide</p>
            <h2>프리셋 항목 제작</h2>
          </div>
          <button className="btn btn-primary" type="button" onClick={addAndSelectEvent}>
            <Plus size={15} />
            Template 추가
          </button>
        </div>

        <div className="preset-save-strip">
          <label>
            저장 이름
            <input
              value={presetName}
              onChange={(event) => setPresetName(event.target.value)}
              placeholder={selectedEvent ? getEventDisplayTitle(selectedEvent) : '저장할 폼이 아직 없습니다'}
            />
          </label>
          <label>
            설명
            <input
              value={presetDescription}
              onChange={(event) => setPresetDescription(event.target.value)}
              placeholder="이 프리셋을 언제 쓰는지 간단히 기록"
            />
          </label>
          <button
            className="btn btn-primary"
            type="button"
            onClick={saveCustomPreset}
            disabled={!canSaveCurrentPreset}
            title={canSaveCurrentPreset ? '현재 표시된 폼 하나만 사용자 지정 프리셋으로 저장합니다.' : '저장할 프리셋 폼이 아직 없습니다.'}
          >
            <Save size={15} />
            현재 프리셋 저장
          </button>
        </div>

        <div className="event-list editor-event-list preset-editor-list">
          {safeEvents.length ? (
            <>
              <div className="preset-selected-only-note">
                <strong>현재 표시된 프리셋 폼만 저장합니다.</strong>
                <span>템플릿 유형은 아래 편집 폼 안에서 전환하고, 저장 시 이 폼 하나만 사용자 지정 프리셋으로 유지됩니다.</span>
              </div>
              {selectedEvent && (
                <EventEditor
                  key={selectedEvent.id}
                  event={selectedEvent}
                  updateEvent={updateEvent}
                  replaceEvent={replaceEvent}
                  removeEvent={removeEvent}
                />
              )}
            </>
          ) : (
            <div className="preset-empty-builder">
              <strong>프리셋 제작 폼이 비어 있습니다.</strong>
              <p>아래 폼 추가 / Builder Forms에서 원하는 기능을 추가하면 이 영역에 편집 폼이 생성됩니다.</p>
              <div className="preset-empty-actions">
                <button className="btn btn-primary" type="button" onClick={addAndSelectEvent}>
                  <Plus size={15} />
                  기본 폼 바로 추가
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      <aside className="custom-preset-sidebar">
        <div className="mini-title">
          <LibraryBig size={16} />
          사용자 지정 프리셋
        </div>
        <p className="preset-guide-muted">
          직접 삭제하기 전까지 유지됩니다. 수정하면 현재 제작 폼과 저장 설정을 이 프리셋으로 교체합니다.
        </p>
        <CustomPresetShelf
          customPresets={safeCustomPresets}
          onApplyPreset={onApplyPreset}
          onDeletePreset={deleteCustomPreset}
        />
      </aside>
    </section>
  );
}

function PresetGuide({
  events,
  settings,
  addEvent,
  updateEvent,
  replaceEvent,
  removeEvent,
  applyCustomPreset,
  activePanel,
  setActivePanel,
}) {
  const [customPresets, setCustomPresets] = useState(readCustomPresets);

  const addTemplateToBuilder = (kind = 'iads_ambush') => {
    const templateKind = EVENT_TEMPLATES.some((template) => template.kind === kind)
      ? kind
      : EVENT_TEMPLATES[0]?.kind;
    if (!templateKind) return;
    const addedEvent = addEvent(templateKind);
    setActivePanel('builder');
    return addedEvent;
  };

  const handleApplyPreset = (preset) => {
    const presetEvents = sanitizePresetEvents(preset?.events);
    if (!presetEvents.length) {
      window.alert('적용할 수 있는 프리셋 이벤트가 없습니다. 프리셋을 다시 저장해 주세요.');
      return;
    }

    applyCustomPreset({
      events: presetEvents.map((event) => ({ ...event, id: createClientId('applied-event') })),
      settings: preset?.settings,
    });
    setActivePanel('builder');
  };

  const panels = [
    { id: 'encyclopedia', label: '기능 백과', icon: BookOpen },
    { id: 'builder', label: '프리셋 제작', icon: WandSparkles },
    { id: 'reference', label: '템플릿 / 예제', icon: LibraryBig },
  ];

  return (
    <section className="preset-guide-workspace glass-panel">
      <div className="section-header preset-guide-top">
        <div>
          <p className="eyebrow">Preset Prompt Instruction / Guide</p>
          <h2>프리셋 프롬포트 지침 / 가이드</h2>
        </div>
        <div className="preset-guide-status">
          <span>{EVENT_TEMPLATES.length} official forms</span>
          <span>{customPresets.length} custom presets</span>
        </div>
      </div>

      <div className="preset-guide-tabs" aria-label="프리셋 가이드 화면">
        {panels.map((panel) => {
          const Icon = panel.icon;
          return (
            <button
              key={panel.id}
              className={activePanel === panel.id ? 'active' : ''}
              type="button"
              onClick={() => setActivePanel(panel.id)}
            >
              <Icon size={15} />
              {panel.label}
            </button>
          );
        })}
      </div>

      <div className="preset-guide-body">
        <PresetGuideBoundary resetKey={`${activePanel}-${customPresets.length}-${Array.isArray(events) ? events.length : 0}`}>
          {activePanel === 'encyclopedia' && <PresetEncyclopedia onAddTemplate={addTemplateToBuilder} />}
          {activePanel === 'builder' && (
            <PresetBuilder
              events={events}
              settings={settings}
              addEvent={addTemplateToBuilder}
              updateEvent={updateEvent}
              replaceEvent={replaceEvent}
              removeEvent={removeEvent}
              customPresets={customPresets}
              setCustomPresets={setCustomPresets}
              onApplyPreset={handleApplyPreset}
            />
          )}
          {activePanel === 'reference' && <TemplateLibrary onAddTemplate={addTemplateToBuilder} />}
        </PresetGuideBoundary>
      </div>
    </section>
  );
}

export default PresetGuide;
