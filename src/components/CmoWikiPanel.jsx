import { useDeferredValue, useEffect, useMemo, useState } from 'react';
import { AlertTriangle, BookOpen, CheckCircle2, MessageSquareText, Search, Sparkles } from 'lucide-react';
import {
  formatWikiQuestionDraft,
  matchesQuickFilter,
} from '../lib/cmoWikiEntries';
import { loadCmoWikiEntries } from '../lib/cmoWikiDataClient';
import './CmoWikiPanel.css';

const QUICK_FILTERS = [
  { id: 'event', label: 'Event' },
  { id: 'mission', label: 'Mission' },
  { id: 'unit', label: 'Unit' },
  { id: 'dbidLoadout', label: 'DBID / Loadout' },
  { id: 'rpZone', label: 'RP / Zone' },
  { id: 'doctrineEmcon', label: 'Doctrine / EMCON' },
  { id: 'keyvalue', label: 'KeyValue' },
];

function compactList(items = [], fallback) {
  return items.length ? items : [fallback];
}

function EntryBadges({ badges = [] }) {
  if (!badges.length) return null;

  return (
    <div className="cmo-wiki-badges">
      {badges.slice(0, 5).map((badge) => (
        <span key={badge.id} className={`cmo-wiki-badge ${badge.tone}`}>
          {badge.label}
        </span>
      ))}
    </div>
  );
}

function EntryListItem({ entry, active, onSelect }) {
  return (
    <button
      className={`cmo-wiki-entry ${active ? 'active' : ''}`}
      type="button"
      onClick={() => onSelect(entry.id)}
    >
      <span>{entry.title}</span>
      <small>{entry.category || 'CMO Lua'} · {entry.sourceFile}</small>
      <EntryBadges badges={entry.badges} />
    </button>
  );
}

function CmoWikiPanel({ onDraftQuestion }) {
  const [entries, setEntries] = useState([]);
  const [query, setQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('all');
  const [selectedId, setSelectedId] = useState('');
  const [status, setStatus] = useState('CMO Lua 백과사전을 불러오는 중입니다.');
  const [templatePreview, setTemplatePreview] = useState('');
  const [previewStatus, setPreviewStatus] = useState('');
  const deferredQuery = useDeferredValue(query.trim().toLowerCase());

  useEffect(() => {
    let cancelled = false;

    loadCmoWikiEntries().then((nextEntries) => {
      if (cancelled) return;
      setEntries(nextEntries);
      setSelectedId((current) => (
        current && nextEntries.some((entry) => entry.id === current)
          ? current
          : nextEntries.find((entry) => entry.sourceFile === 'event_regular_time.tpl.lua')?.id || nextEntries[0]?.id || ''
      ));
      setStatus(`${nextEntries.length}개 CMO Lua 항목을 준비했습니다. AI 자동 전송은 하지 않습니다.`);
    }).catch((error) => {
      if (!cancelled) setStatus(`CMO Lua 백과사전을 불러오지 못했습니다: ${error.message}`);
    });

    return () => {
      cancelled = true;
    };
  }, []);

  const filteredEntries = useMemo(() => entries.filter((entry) => {
    const filterMatch = activeFilter === 'all' || matchesQuickFilter(entry, entry.annotation, activeFilter);
    const queryMatch = !deferredQuery || entry.searchText.includes(deferredQuery);
    return filterMatch && queryMatch;
  }), [activeFilter, deferredQuery, entries]);

  const selectedEntry = useMemo(() => (
    entries.find((entry) => entry.id === selectedId)
    || filteredEntries[0]
    || entries[0]
    || null
  ), [entries, filteredEntries, selectedId]);

  useEffect(() => {
    let cancelled = false;

    if (!selectedEntry?.path) {
      const handle = window.setTimeout(() => {
        if (cancelled) return;
        setTemplatePreview('');
        setPreviewStatus('원본 템플릿 경로가 없는 항목입니다. 설명과 안전 패턴을 참고하세요.');
      }, 0);
      return () => {
        cancelled = true;
        window.clearTimeout(handle);
      };
    }

    fetch(selectedEntry.path)
      .then((response) => {
        if (!response.ok) throw new Error(`${response.status}`);
        return response.text();
      })
      .then((text) => {
        if (cancelled) return;
        setTemplatePreview(text.slice(0, 6000));
        setPreviewStatus(text.length > 6000
          ? '참고용 템플릿 예제 일부만 표시합니다.'
          : '참고용 템플릿 예제를 표시합니다.');
      })
      .catch((error) => {
        if (cancelled) return;
        setTemplatePreview('');
        setPreviewStatus(`참고용 템플릿 예제를 불러오지 못했습니다: ${error.message}`);
      });

    return () => {
      cancelled = true;
    };
  }, [selectedEntry]);

  const relatedEntries = useMemo(() => {
    if (!selectedEntry) return [];
    return entries
      .filter((entry) => entry.id !== selectedEntry.id)
      .filter((entry) => entry.category && entry.category === selectedEntry.category)
      .slice(0, 4);
  }, [entries, selectedEntry]);

  const draftQuestion = () => {
    if (!selectedEntry) return;
    onDraftQuestion?.(formatWikiQuestionDraft(selectedEntry, { luaText: templatePreview }));
  };

  return (
    <section className="cmo-wiki-panel">
      <header className="cmo-wiki-hero glass-panel">
        <div>
          <p className="eyebrow">Lua Assistant / Encyclopedia</p>
          <h2>CMO Lua 백과사전</h2>
          <p>
            CMO에서 자주 쓰이는 Lua 기능과 검증된 템플릿 예제를 한 곳에서 확인합니다.
            이 화면은 정적인 참조 도구이며, AI 호출이나 CMO 실행을 자동으로 하지 않습니다.
          </p>
        </div>
        <div className="cmo-wiki-hero-card">
          <Sparkles size={18} />
          <strong>하네싱된 정보</strong>
          <span>51 / 51 템플릿 주석과 공개 예제를 연결해 설명합니다.</span>
        </div>
      </header>

      <div className="cmo-wiki-shell">
        <aside className="cmo-wiki-sidebar glass-panel">
          <label className="cmo-wiki-search">
            <Search size={16} />
            <input
              type="search"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="기능, API, DBID, Mission 검색"
            />
          </label>
          <div className="cmo-wiki-filters" aria-label="CMO Lua wiki filters">
            <button type="button" className={activeFilter === 'all' ? 'active' : ''} onClick={() => setActiveFilter('all')}>
              전체
            </button>
            {QUICK_FILTERS.map((filter) => (
              <button
                key={filter.id}
                type="button"
                className={activeFilter === filter.id ? 'active' : ''}
                onClick={() => setActiveFilter(filter.id)}
              >
                {filter.label}
              </button>
            ))}
          </div>
          <p className="cmo-wiki-status">{status}</p>
          <div className="cmo-wiki-list">
            {filteredEntries.map((entry) => (
              <EntryListItem
                key={entry.id}
                entry={entry}
                active={selectedEntry?.id === entry.id}
                onSelect={setSelectedId}
              />
            ))}
            {!filteredEntries.length && (
              <div className="cmo-wiki-empty">
                <BookOpen size={18} />
                <strong>검색 결과가 없습니다.</strong>
                <span>다른 키워드나 전체 필터로 다시 확인해 보세요.</span>
              </div>
            )}
          </div>
        </aside>

        <article className="cmo-wiki-detail glass-panel">
          {selectedEntry ? (
            <>
              <div className="cmo-wiki-detail-header">
                <div>
                  <p className="eyebrow">{selectedEntry.category || 'CMO Lua'} · {selectedEntry.sourceFile}</p>
                  <h3>{selectedEntry.title}</h3>
                  <p>{selectedEntry.summary}</p>
                </div>
                <EntryBadges badges={selectedEntry.badges} />
              </div>

              <section className="cmo-wiki-section">
                <h4><CheckCircle2 size={16} /> 언제 쓰나요?</h4>
                <p>{selectedEntry.useCase || selectedEntry.summary || 'CMO Lua 기능을 시나리오 자동화에 적용할 때 참고합니다.'}</p>
              </section>

              <section className="cmo-wiki-section">
                <h4><AlertTriangle size={16} /> CMO에서 직접 확인할 값</h4>
                <ul>
                  {compactList(selectedEntry.requiredValues, 'Side, Mission, Unit GUID, DBID, RP/Zone 값은 CMO 내부 UI에서 확인하세요.').map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </section>

              <section className="cmo-wiki-section">
                <h4><BookOpen size={16} /> 참고용 템플릿 예제</h4>
                <p>{previewStatus}</p>
                {templatePreview ? (
                  <pre className="cmo-wiki-code"><code>{templatePreview}</code></pre>
                ) : (
                  <p className="cmo-wiki-muted">{selectedEntry.safePattern || '예제 코드 대신 안전 패턴과 필수 값을 먼저 확인하세요.'}</p>
                )}
              </section>

              <section className="cmo-wiki-section">
                <h4><Sparkles size={16} /> AI가 참고해야 할 안전 패턴</h4>
                <p>{selectedEntry.safePattern || '이 항목은 CMO 엔진에서 직접 검증해야 하는 Lua 초안으로만 사용하세요.'}</p>
                <p className="cmo-wiki-muted">{selectedEntry.aiHint}</p>
              </section>

              {relatedEntries.length ? (
                <section className="cmo-wiki-section">
                  <h4><BookOpen size={16} /> 관련 항목</h4>
                  <div className="cmo-wiki-related">
                    {relatedEntries.map((entry) => (
                      <button key={entry.id} type="button" onClick={() => setSelectedId(entry.id)}>
                        {entry.title}
                      </button>
                    ))}
                  </div>
                </section>
              ) : null}

              <div className="cmo-wiki-actions">
                <button className="btn btn-primary" type="button" onClick={draftQuestion}>
                  <MessageSquareText size={16} />
                  AI 채팅창에 질문 초안 넣기
                </button>
                <span>클릭해도 자동 전송되지 않습니다. 채팅 입력창에서 직접 확인 후 보내세요.</span>
              </div>

              <footer className="cmo-wiki-footer">
                주의: 이 코드는 AI가 참고할 수 있는 초안(Draft)입니다. 실제 GUID, DBID, Side, Mission 값을 확인하고 CMO 엔진에서 직접 테스트해야 합니다.
              </footer>
            </>
          ) : (
            <div className="cmo-wiki-empty detail-empty">
              <BookOpen size={24} />
              <strong>CMO Lua 항목을 준비하는 중입니다.</strong>
            </div>
          )}
        </article>
      </div>
    </section>
  );
}

export default CmoWikiPanel;
