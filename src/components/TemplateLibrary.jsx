import { useEffect, useMemo, useState, useTransition } from 'react';
import { Check, Copy, Database, FileCode2, Plus, RefreshCw, Search, Sparkles } from 'lucide-react';
import { getTemplateForSource } from '../data/templateCatalog';

const TEMPLATE_ANNOTATIONS_URL = '/template-annotations.json';

function resourceLabel(resource) {
  if (resource.type === 'preset') return `preset/${resource.file}`;
  if (resource.type === 'installed-example') return resource.relativePath;
  return `template/${resource.file}`;
}

function resourceSearchText(resource) {
  return [
    resource.file,
    resource.relativePath,
    resource.scenario,
    resource.category,
    resource.type,
    ...(resource.features || []),
    ...(resource.apis || []),
  ].filter(Boolean).join(' ').toLowerCase();
}

function loadJson(url) {
  return fetch(url).then((response) => {
    if (!response.ok) {
      throw new Error(`${url}: ${response.status}`);
    }
    return response.json();
  });
}

function SourceSummary({ builderManifest, installedManifest }) {
  return (
    <div className="source-summary-grid">
      <div className="source-stat">
        <span>Builder</span>
        <strong>{builderManifest?.templates?.length || 0}</strong>
        <small>templates</small>
      </div>
      <div className="source-stat">
        <span>Presets</span>
        <strong>{builderManifest?.presets?.length || 0}</strong>
        <small>builder files</small>
      </div>
      <div className="source-stat">
        <span>Installed</span>
        <strong>{installedManifest?.fileCount || 0}</strong>
        <small>CMO Lua examples</small>
      </div>
      <div className="source-stat">
        <span>API</span>
        <strong>{installedManifest?.apiIndex?.length || 0}</strong>
        <small>detected calls</small>
      </div>
    </div>
  );
}

function FeatureIndex({ installedManifest, onPick }) {
  if (!installedManifest?.featureIndex?.length) return null;

  return (
    <details className="feature-index">
      <summary className="mini-title">
        <Sparkles size={15} />
        Feature index
        <span>{installedManifest.featureIndex.length} groups</span>
      </summary>
      <div className="feature-chip-list">
        {installedManifest.featureIndex.map((feature) => (
          <button
            key={feature.name}
            className="feature-chip"
            type="button"
            title={feature.description}
            onClick={() => onPick(feature.name)}
          >
            <span>{feature.name}</span>
            <strong>{feature.count}</strong>
          </button>
        ))}
      </div>
    </details>
  );
}

function ResourceMeta({ selected }) {
  if (!selected) return null;

  if (selected.type === 'installed-example') {
    return (
      <div className="resource-meta">
        <span>{selected.scenario}</span>
        <span>{selected.lines} lines</span>
        <span>{selected.apis?.length || 0} APIs</span>
      </div>
    );
  }

  return (
    <div className="resource-meta">
      <span>{selected.type}</span>
      <span>{selected.lines} lines</span>
      {selected.category && <span>{selected.category}</span>}
    </div>
  );
}

const FALLBACK_GUIDE_RULES = [
  {
    id: 'event',
    keywords: ['event', 'trigger', 'condition', 'action'],
    title: 'Event Automation',
    plain: 'CMO Event Editor의 Trigger/Condition/Action 구조에 Lua Script Action을 붙이는 계열입니다.',
    prerequisites: ['Trigger와 Condition은 가능하면 CMO UI에서 만들고, Lua는 Action 본문으로 붙입니다.'],
    safePattern: '반복 실행 가능성이 있으면 KeyValue 또는 명확한 상태 체크를 둡니다.',
    aiHint: 'AI에게 이벤트 이름, 트리거 방식, 반복 정책, Lua를 붙일 위치를 분리해서 응답하도록 요구합니다.',
  },
];

function inferGuideRule(resource, guideRules = FALLBACK_GUIDE_RULES) {
  const text = [
    resource?.file,
    resource?.relativePath,
    resource?.category,
    ...(resource?.features || []),
    ...(resource?.apis || []),
  ].filter(Boolean).join(' ').toLowerCase();

  const rules = Array.isArray(guideRules) && guideRules.length ? guideRules : FALLBACK_GUIDE_RULES;
  return rules.find((rule) => rule.keywords.some((keyword) => text.includes(keyword))) || rules[0];
}

function TemplateGuideNotes({ selected, linkedTemplate, annotations, guideRules }) {
  if (!selected) return null;

  const rule = inferGuideRule(selected, guideRules);
  const annotation = annotations?.[selected.file] || null;
  const apis = (selected.apis || linkedTemplate?.apis || []).slice(0, 8);
  const title = annotation?.title || rule.title;
  const summary = annotation?.summary || linkedTemplate?.summary || rule.plain;
  const prerequisites = annotation?.prerequisites || rule.prerequisites;
  const safePattern = annotation?.safePattern || rule.safePattern;
  const aiHint = annotation?.aiHint || rule.aiHint;

  return (
    <details className="template-guide-notes">
      <summary className="template-guide-heading">
        <Sparkles size={15} />
        <div>
          <strong>{title}</strong>
          <span>사용자 해설 + AI 작업 지침 · 클릭하면 펼쳐집니다.</span>
        </div>
      </summary>
      <div className="template-guide-grid">
        <section>
          <h4>무엇을 하나요?</h4>
          <p>{summary}</p>
          {apis.length > 0 && <p className="guide-api-line">관련 API: {apis.join(', ')}</p>}
        </section>
        <section>
          <h4>CMO에서 먼저 준비</h4>
          <ul>
            {prerequisites.map((item) => <li key={item}>{item}</li>)}
          </ul>
        </section>
        <section>
          <h4>안전한 코딩 패턴</h4>
          <p>{safePattern}</p>
        </section>
        <section>
          <h4>AI에게 줄 지시</h4>
          <p>{aiHint}</p>
        </section>
      </div>
      {annotation?.beginnerNotes?.length > 0 && (
        <section className="template-beginner-notes">
          <h4>초보자용 해설</h4>
          <ul>
            {annotation.beginnerNotes.map((item) => <li key={item}>{item}</li>)}
          </ul>
        </section>
      )}
      {annotation?.checks?.length > 0 && (
        <section className="template-verification-notes">
          <h4>Codex 확인 필요</h4>
          <ul>
            {annotation.checks.map((item) => <li key={item}>{item}</li>)}
          </ul>
        </section>
      )}
    </details>
  );
}

function TemplateLibrary({ onAddTemplate }) {
  const [builderManifest, setBuilderManifest] = useState(null);
  const [installedManifest, setInstalledManifest] = useState(null);
  const [selectedPath, setSelectedPath] = useState('');
  const [source, setSource] = useState('');
  const [activeSource, setActiveSource] = useState('builder');
  const [query, setQuery] = useState('');
  const [deferredQuery, setDeferredQuery] = useState('');
  const [error, setError] = useState('');
  const [manifestRefreshKey, setManifestRefreshKey] = useState(0);
  const [syncHint, setSyncHint] = useState('');
  const [copiedCommand, setCopiedCommand] = useState(false);
  const [listWidth, setListWidth] = useState(34);
  const [templateAnnotations, setTemplateAnnotations] = useState({});
  const [templateGuideRules, setTemplateGuideRules] = useState(FALLBACK_GUIDE_RULES);
  const [, startTransition] = useTransition();

  useEffect(() => {
    let alive = true;

    Promise.allSettled([
      loadJson(`/cmo-dev-work/manifest.json?refresh=${manifestRefreshKey}`),
      loadJson(`/cmo-installed-lua/manifest.json?refresh=${manifestRefreshKey}`),
    ]).then(([builderResult, installedResult]) => {
      if (!alive) return;

      const builderData = builderResult.status === 'fulfilled' ? builderResult.value : null;
      const installedData = installedResult.status === 'fulfilled' ? installedResult.value : null;

      setBuilderManifest(builderData);
      setInstalledManifest(installedData);

      if (!builderData && !installedData) {
        setError('No source manifests could be loaded.');
      } else if (!installedData) {
        setError('Installed Lua examples manifest is not available. Run npm run sync:cmo-examples.');
      } else {
        setError('');
      }
    });

    return () => {
      alive = false;
    };
  }, [manifestRefreshKey]);

  useEffect(() => {
    let alive = true;

    loadJson(`${TEMPLATE_ANNOTATIONS_URL}?refresh=${manifestRefreshKey}`)
      .then((payload) => {
        if (!alive) return;
        setTemplateAnnotations(payload?.templates || {});
        setTemplateGuideRules(Array.isArray(payload?.guideRules) && payload.guideRules.length ? payload.guideRules : FALLBACK_GUIDE_RULES);
      })
      .catch(() => {
        if (alive) {
          setTemplateAnnotations({});
          setTemplateGuideRules(FALLBACK_GUIDE_RULES);
        }
      });

    return () => {
      alive = false;
    };
  }, [manifestRefreshKey]);

  const resources = useMemo(() => {
    const builderResources = [
      ...(builderManifest?.templates || []).map((item) => ({ ...item, type: 'template', sourceGroup: 'builder' })),
      ...(builderManifest?.presets || []).map((item) => ({ ...item, type: 'preset', sourceGroup: 'builder' })),
    ];
    const installedResources = (installedManifest?.examples || []).map((item) => ({ ...item, sourceGroup: 'installed' }));

    return activeSource === 'installed' ? installedResources : builderResources;
  }, [activeSource, builderManifest, installedManifest]);

  const visibleResources = useMemo(() => {
    if (!deferredQuery) return resources;
    return resources.filter((resource) => resourceSearchText(resource).includes(deferredQuery));
  }, [deferredQuery, resources]);

  const selected = useMemo(() => {
    return visibleResources.find((resource) => resource.path === selectedPath) || visibleResources[0] || null;
  }, [visibleResources, selectedPath]);

  useEffect(() => {
    if (!selected) return;
    let alive = true;

    fetch(selected.path)
      .then((response) => response.text())
      .then((text) => {
        if (alive) setSource(text);
      })
      .catch(() => {
        if (alive) setSource('-- source load failed');
      });

    return () => {
      alive = false;
    };
  }, [selected]);

  const handleQuery = (value) => {
    setQuery(value);
    startTransition(() => {
      setDeferredQuery(value.toLowerCase());
    });
  };

  const startInspectorResize = (event) => {
    const bounds = event.currentTarget.parentElement.getBoundingClientRect();

    const handleMove = (moveEvent) => {
      const nextWidth = ((moveEvent.clientX - bounds.left) / bounds.width) * 100;
      setListWidth(Math.min(Math.max(nextWidth, 22), 58));
    };

    const stopResize = () => {
      window.removeEventListener('pointermove', handleMove);
      window.removeEventListener('pointerup', stopResize);
    };

    window.addEventListener('pointermove', handleMove);
    window.addEventListener('pointerup', stopResize);
  };

  const refreshManifests = () => {
    setManifestRefreshKey(Date.now());
    setSyncHint('현재 public manifest를 다시 읽었습니다. CMO 설치 예제 자체를 다시 스캔하려면 터미널에서 npm run sync:cmo-examples를 실행한 뒤 다시 새로고침하세요.');
  };

  const copySyncCommand = async () => {
    const command = 'npm run sync:cmo-examples';
    try {
      await navigator.clipboard.writeText(command);
      setCopiedCommand(true);
      setSyncHint(`${command} 명령을 복사했습니다. 이 브라우저 화면은 로컬 파일시스템을 직접 스캔하지 못하므로 터미널 실행 후 목록 새로고침을 사용하세요.`);
      window.setTimeout(() => setCopiedCommand(false), 1500);
    } catch {
      setSyncHint(`터미널에서 실행할 명령: ${command}`);
    }
  };

  const linkedTemplate = selected?.type === 'template' ? getTemplateForSource(selected.file) : null;
  const sourceRoot = activeSource === 'installed' ? installedManifest?.sourceRoot : builderManifest?.sourceRoot;

  return (
    <aside className="template-panel glass-panel">
      <div className="section-header">
        <div>
          <p className="eyebrow">Reference Source</p>
          <h2>Template Inspector</h2>
        </div>
        <div className="template-panel-actions">
          <button className="btn btn-mini btn-ghost" type="button" onClick={refreshManifests}>
            <RefreshCw size={14} />
            목록 새로고침
          </button>
          <button className="btn btn-mini btn-ghost" type="button" onClick={copySyncCommand}>
            {copiedCommand ? <Check size={14} /> : <Copy size={14} />}
            스캔 명령
          </button>
          <FileCode2 size={20} className="text-accent" />
        </div>
      </div>

      {syncHint && <p className="template-sync-hint">{syncHint}</p>}
      <div className="template-update-guide">
        <strong>예제 업데이트 흐름</strong>
        <span>스캔 명령 복사 → 터미널에서 실행 → 목록 새로고침 순서로 public manifest를 갱신합니다.</span>
      </div>

      <SourceSummary builderManifest={builderManifest} installedManifest={installedManifest} />

      <div className="source-tabs">
        <button
          className={activeSource === 'builder' ? 'active' : ''}
          type="button"
          onClick={() => setActiveSource('builder')}
        >
          Builder Templates
        </button>
        <button
          className={activeSource === 'installed' ? 'active' : ''}
          type="button"
          onClick={() => setActiveSource('installed')}
        >
          Installed Lua Examples
        </button>
      </div>

      <div className="db-strip">
        <Database size={16} />
        {builderManifest?.db ? (
          <span>{builderManifest.db.db3k} / {builderManifest.db.cwdb} · {builderManifest.db.componentEntries.toLocaleString()} DB entries</span>
        ) : (
          <span>{error || 'Loading manifests...'}</span>
        )}
      </div>

      {sourceRoot && (
        <p className="source-root">source: {sourceRoot}</p>
      )}

      {activeSource === 'installed' && (
        <FeatureIndex installedManifest={installedManifest} onPick={handleQuery} />
      )}

      <div className="search-box">
        <Search size={15} />
        <input
          value={query}
          onChange={(event) => handleQuery(event.target.value)}
          placeholder={activeSource === 'installed' ? 'scenario, API, feature 검색' : 'template, preset 검색'}
        />
      </div>

      <div className="inspector-body" style={{ '--inspector-list-width': `${listWidth}%` }}>
        <div className="resource-list">
          {visibleResources.length ? (
            visibleResources.map((resource) => (
              <button
                key={`${resource.sourceGroup}:${resource.relativePath || resource.file}`}
                type="button"
                className={`resource-row ${selected?.path === resource.path ? 'active' : ''}`}
                onClick={() => setSelectedPath(resource.path)}
              >
                <span>{resourceLabel(resource)}</span>
                <small>{resource.lines} lines</small>
              </button>
            ))
          ) : (
            <div className="resource-list-empty">
              <strong>표시할 예제가 없습니다.</strong>
              <p>검색어를 줄이거나 스캔 명령으로 manifest를 갱신한 뒤 목록 새로고침을 눌러주세요.</p>
            </div>
          )}
        </div>

        <button
          className="inspector-resize-handle"
          type="button"
          aria-label="템플릿 목록과 소스 창 경계 조절"
          onPointerDown={startInspectorResize}
        />

        {selected ? (
          <div className="source-card">
            <div className="source-card-top">
              <div>
                <p className="eyebrow">{selected.type}</p>
                <h3>{selected.file}</h3>
                <ResourceMeta selected={selected} />
              </div>
              {linkedTemplate && (
                <button className="btn btn-primary btn-mini" type="button" onClick={() => onAddTemplate(linkedTemplate.kind)}>
                  <Plus size={14} />
                  폼에 추가
                </button>
              )}
            </div>
            {linkedTemplate && <p className="source-summary">{linkedTemplate.summary}</p>}
            {selected.type === 'installed-example' && (
              <div className="tag-cloud">
                {(selected.features || []).map((feature) => <span key={feature}>{feature}</span>)}
                {(selected.apis || []).slice(0, 10).map((api) => <span key={api}>{api}</span>)}
              </div>
            )}
            <TemplateGuideNotes
              selected={selected}
              linkedTemplate={linkedTemplate}
              annotations={templateAnnotations}
              guideRules={templateGuideRules}
            />
            <pre className="source-code">{source}</pre>
          </div>
        ) : (
          <div className="source-card empty-source-card">
            <p className="eyebrow">No Source Selected</p>
            <h3>표시할 템플릿/예제가 없습니다.</h3>
            <p>좌측 목록에서 항목을 선택하거나, CMO Lua 예제 manifest를 갱신한 뒤 다시 확인하세요.</p>
            <button className="btn btn-mini btn-ghost" type="button" onClick={() => handleQuery('')}>
              검색 초기화
            </button>
          </div>
        )}
      </div>
    </aside>
  );
}

export default TemplateLibrary;
