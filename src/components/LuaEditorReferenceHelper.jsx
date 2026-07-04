import { useEffect, useMemo, useState } from 'react';
import { BookOpen, MessageSquareText, Search } from 'lucide-react';
import {
  formatWikiQuestionDraft,
  matchCmoWikiEntriesForLua,
} from '../lib/cmoWikiEntries';
import { loadCmoWikiEntries } from '../lib/cmoWikiDataClient';
import './LuaEditorReferenceHelper.css';

export default function LuaEditorReferenceHelper({ luaText = '', onDraftQuestion }) {
  const [wikiEntries, setWikiEntries] = useState([]);
  const [status, setStatus] = useState('백과사전 항목을 불러오는 중입니다.');
  const matches = useMemo(
    () => matchCmoWikiEntriesForLua(luaText, wikiEntries, { limit: 4 }),
    [luaText, wikiEntries],
  );

  useEffect(() => {
    let cancelled = false;

    loadCmoWikiEntries().then((entries) => {
      if (cancelled) return;
      setWikiEntries(entries);
      setStatus(`${entries.length}개 백과사전 항목을 기준으로 코드 단서를 찾습니다.`);
    }).catch((error) => {
      if (!cancelled) setStatus(`백과사전 항목을 불러오지 못했습니다: ${error.message}`);
    });

    return () => {
      cancelled = true;
    };
  }, []);

  const draftQuestion = (entry) => {
    onDraftQuestion?.(formatWikiQuestionDraft(entry, { luaText }));
  };

  return (
    <aside className="lua-reference-helper">
      <div className="mini-title">
        <Search size={15} />
        Lua 참조 도우미
      </div>
      <p className="lua-reference-status">{status}</p>
      {matches.length ? (
        <div className="lua-reference-list">
          {matches.map((entry) => (
            <article key={entry.id} className="lua-reference-card">
              <div>
                <strong>{entry.title}</strong>
                <small>{entry.sourceFile}</small>
              </div>
              <p>{entry.useCase || entry.summary}</p>
              <ul>
                {(entry.requiredValues?.length ? entry.requiredValues.slice(0, 3) : ['CMO 내부 UI에서 실제 값 확인']).map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
              <button className="btn btn-mini btn-ghost" type="button" onClick={() => draftQuestion(entry)}>
                <MessageSquareText size={13} />
                AI 채팅창에 검토 질문 넣기
              </button>
            </article>
          ))}
        </div>
      ) : (
        <div className="lua-reference-empty">
          <BookOpen size={18} />
          <strong>알려진 패턴을 찾을 수 없습니다</strong>
          <p>
            붙여넣은 코드에서 알려진 CMO API나 템플릿 단서를 찾지 못했습니다.
            백과사전에서 기능을 검색하거나 AI 에이전트에게 코드의 의미를 물어보세요.
          </p>
        </div>
      )}
      <p className="lua-reference-footnote">
        이 패널은 정적 참조 도움말입니다. 버튼은 AI 채팅창에 초안만 넣고 자동 전송되지 않습니다.
      </p>
    </aside>
  );
}
