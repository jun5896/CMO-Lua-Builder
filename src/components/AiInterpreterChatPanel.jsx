import { useEffect, useRef, useState } from 'react';
import './AiInterpreterChatPanel.css';

const MAX_CHAT_HISTORY = 5;
let sessionChatHistory = [];

function countTextLines(value) {
  const text = String(value || '');
  if (!text) return 0;
  return (text.match(/\n/g)?.length || 0) + 1;
}

function buildInterpreterPrompt(basePrompt, instruction) {
  const trimmedInstruction = String(instruction || '').trim();

  return [
    String(basePrompt || '').trim(),
    '',
    '## Interpreter chat instruction',
    trimmedInstruction || '요청문을 검토하고, 부족한 전제(Side/Mission/GUID/DBID 등)는 추측하지 말고 되물어주세요. 안전한 경우에만 paste-ready Lua를 작성하세요.',
    '',
    '## Response mode',
    '- Keep the required interpreter response headings.',
    '- If Side, Mission, Unit GUID, DBID, Loadout ID, RP, or Zone is missing, ask back instead of inventing it.',
    '- Only include paste-ready Lua when it is safe to apply in CMO.',
  ].filter(Boolean).join('\n');
}

function formatAuditList(items, fallback = 'none') {
  const values = (items || []).filter(Boolean);
  if (!values.length) return fallback;
  return values.join(', ');
}

function makeHistoryItem({ instruction, aiResponse, aiCallStatus, parsedResponse, canApplyLua }) {
  return {
    id: `chat-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`,
    time: new Date().toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' }),
    instruction: String(instruction || '').trim() || '기본 검토 요청',
    response: String(aiResponse || '').trim(),
    status: aiCallStatus?.state || 'idle',
    ready: Boolean(canApplyLua),
    luaLines: parsedResponse?.lua ? countTextLines(parsedResponse.lua) : 0,
    blockers: parsedResponse?.blockers?.length || 0,
    warnings: parsedResponse?.warnings?.length || 0,
  };
}

function nextActionItems(responseTone) {
  switch (responseTone) {
    case 'ready':
      return [
        'AI 응답 탭에서 assumptions와 validation checklist를 빠르게 확인합니다.',
        '문제가 없으면 Lua 적용으로 Working Draft에 반영합니다.',
        'CMO Lua Console 또는 Event Editor에서 실행 검증합니다.',
      ];
    case 'ask':
      return [
        'AI가 요구한 Side, Mission, GUID, DBID, RP/Zone 값을 CMO UI에서 확인합니다.',
        '추가 지시 칸에 확인한 값을 붙여 넣고 다시 AI에게 보냅니다.',
        '값이 불확실하면 임의 작성 대신 질문을 더 구체화합니다.',
      ];
    case 'hold':
      return [
        'AI 응답 탭에서 blocker, warning, missing section을 먼저 확인합니다.',
        '재질문 초안이 필요하면 응답 탭에서 초안을 만든 뒤 채팅으로 이어갑니다.',
        'Lua 적용 버튼이 활성화되기 전까지는 CMO에 붙여넣지 않습니다.',
      ];
    default:
      return [
        '현재 요청문을 그대로 보낼지, 추가 지시를 덧붙일지 선택합니다.',
        '어댑터가 불안정하면 요청문 복사로 수동 대체 경로를 사용합니다.',
        '응답은 항상 parser 검토와 Lua 적용 게이트를 통과해야 합니다.',
      ];
  }
}

export default function AiInterpreterChatPanel({
  basePrompt,
  instruction,
  onInstructionChange,
  aiResponse,
  aiCallStatus,
  isAiCalling,
  parsedResponse,
  canApplyLua,
  applyBlockedReason,
  pruningAudit,
  copied,
  onCallAi,
  onApplyLua,
  onOpenReview,
  onCopyPrompt,
  onClearInstruction,
}) {
  const composedPrompt = buildInterpreterPrompt(basePrompt, instruction);
  const [chatHistory, setChatHistory] = useState(sessionChatHistory);
  const [historyCopiedId, setHistoryCopiedId] = useState('');
  const lastHistoryResponseRef = useRef('');
  const hasInstruction = Boolean(String(instruction || '').trim());
  const isFollowUpDraft = String(instruction || '').includes('아래 AI 응답 검토 결과를 반영');
  const luaLineCount = parsedResponse?.lua ? countTextLines(parsedResponse.lua) : 0;
  const blockerCount = parsedResponse?.blockers?.length || 0;
  const warningCount = parsedResponse?.warnings?.length || 0;
  const followUpCount = parsedResponse?.followUpQuestions?.length || 0;
  const missingSectionCount = parsedResponse?.missingRequiredSections?.length || 0;
  const responseMode = (() => {
    if (!aiResponse) {
      return {
        tone: 'idle',
        label: '대기',
        title: '아직 응답 없음',
        body: '추가 지시를 입력하거나 바로 AI에게 보내면 현재 요청문을 기준으로 응답을 받습니다.',
      };
    }

    if (canApplyLua) {
      return {
        tone: 'ready',
        label: 'Lua 준비',
        title: 'Paste-ready Lua 적용 가능',
        body: `${luaLineCount} lines Lua 감지됨. 적용 후 반드시 CMO 엔진에서 실행 검증하세요.`,
      };
    }

    if (followUpCount > 0 && !luaLineCount) {
      return {
        tone: 'ask',
        label: '되묻기',
        title: 'AI가 추가 정보를 요청했습니다',
        body: 'CMO에서 요청된 Side/Mission/GUID/DBID/RP/Zone 값을 확인해 추가 지시에 입력하세요.',
      };
    }

    return {
      tone: 'hold',
      label: '검토 필요',
      title: 'Lua 적용 전 확인 필요',
      body: applyBlockedReason || '응답 섹션, placeholder, unsafe Lua 여부를 AI 응답 탭에서 확인하세요.',
    };
  })();
  const responseSummary = aiResponse
    ? `${countTextLines(aiResponse)} lines response · Lua ${luaLineCount ? `${luaLineCount} lines` : 'not ready'}`
    : '아직 AI 응답이 없습니다.';

  const handleSubmit = () => {
    onCallAi(composedPrompt, 'AI 채팅 지시문', 'chat');
  };

  const reuseHistoryInstruction = (item) => {
    onInstructionChange([
      '이전 AI 응답을 이어서 보강해줘.',
      '',
      `이전 지시: ${item.instruction}`,
      `이전 상태: ${item.ready ? 'Lua ready' : 'needs review'} · blockers ${item.blockers} · warnings ${item.warnings}`,
      '',
      '부족한 CMO 정보는 임의로 만들지 말고 되물어줘.',
    ].join('\n'));
  };

  const copyHistoryResponse = async (item) => {
    await navigator.clipboard.writeText(item.response);
    setHistoryCopiedId(item.id);
    window.setTimeout(() => setHistoryCopiedId(''), 1500);
  };

  useEffect(() => {
    const nextResponse = String(aiResponse || '').trim();
    if (!nextResponse || isAiCalling || lastHistoryResponseRef.current === nextResponse) return;

    const item = makeHistoryItem({
      instruction,
      aiResponse: nextResponse,
      aiCallStatus,
      parsedResponse,
      canApplyLua,
    });
    sessionChatHistory = [item, ...sessionChatHistory].slice(0, MAX_CHAT_HISTORY);
    lastHistoryResponseRef.current = nextResponse;
    setChatHistory(sessionChatHistory);
  }, [aiResponse, aiCallStatus, canApplyLua, instruction, isAiCalling, parsedResponse]);

  return (
    <div className="ai-chat-panel">
      <div className="ai-chat-intro">
        <div>
          <strong>AI Interpreter Chat</strong>
          <span>현재 요청문 위에 짧은 추가 지시를 얹어 AI에게 보냅니다. 응답은 기존 parser와 Lua 적용 게이트를 그대로 통과해야 합니다.</span>
        </div>
        <span className={`ai-adapter-status inline ${aiCallStatus.state}`}>{aiCallStatus.message}</span>
      </div>

      <label className="ai-chat-input-wrap">
        <span className="ai-chat-input-label">
          <span>추가 지시 / 질문</span>
          <em>{isFollowUpDraft ? '재질문 초안' : hasInstruction ? '사용자 직접 입력' : '새 지시 대기'}</em>
        </span>
        <textarea
          className="ai-chat-input"
          value={instruction}
          onChange={(event) => onInstructionChange(event.target.value)}
          placeholder="예: 이 이벤트 Lua에서 반복 실행 방지와 nil 체크를 보강하고, CMO에서 먼저 확인할 Side/Mission/GUID를 되물어줘."
          spellCheck={false}
        />
      </label>

      <div className="ai-chat-actions">
        <button className="btn btn-primary" type="button" onClick={handleSubmit} disabled={isAiCalling}>
          {isAiCalling ? 'AI 호출 중' : 'AI에게 보내기'}
        </button>
        <button className="btn btn-ghost" type="button" onClick={onClearInstruction} disabled={!hasInstruction || isAiCalling}>
          새 지시로 초기화
        </button>
        <button className="btn btn-ghost" type="button" onClick={() => onCopyPrompt(composedPrompt)}>
          {copied === 'chat-prompt' ? '요청문 복사됨' : '요청문 복사'}
        </button>
        <button className="btn btn-ghost" type="button" onClick={onOpenReview} disabled={!aiResponse}>
          AI 응답 탭에서 구조화 검토
        </button>
        <button
          className="btn btn-ghost"
          type="button"
          onClick={onApplyLua}
          disabled={!canApplyLua}
          title={canApplyLua ? 'AI 응답의 paste-ready Lua를 Working Draft에 적용합니다. CMO 엔진 검증은 별도 필요합니다.' : applyBlockedReason || '적용 가능한 Lua가 아직 없습니다.'}
        >
          Lua 적용
        </button>
      </div>

      <div className={`ai-chat-response-mode ${responseMode.tone}`}>
        <span>{responseMode.label}</span>
        <div>
          <strong>{responseMode.title}</strong>
          <p>{responseMode.body}</p>
        </div>
      </div>

      <div className={`ai-chat-next-actions ${responseMode.tone}`}>
        <strong>다음 동작</strong>
        <ol>
          {nextActionItems(responseMode.tone).map((item) => <li key={item}>{item}</li>)}
        </ol>
      </div>

      {pruningAudit && (
        <div className={`ai-pruning-audit-card ${pruningAudit.failures?.length || pruningAudit.hardBlock ? 'warning' : ''}`}>
          <div>
            <strong>Context Pruning</strong>
            <span>최근 AI 호출 기준 · {pruningAudit.mode}</span>
          </div>
          <div className="ai-pruning-audit-grid">
            <span><b>{pruningAudit.tokens || 0}</b><small>tokens / {pruningAudit.tokenLimit}</small></span>
            <span><b>{formatAuditList(pruningAudit.actualOmit)}</b><small>actual omit</small></span>
            <span><b>{formatAuditList(pruningAudit.summarized)}</b><small>summaries</small></span>
            <span><b>{formatAuditList(pruningAudit.askBackHints)}</b><small>ask back</small></span>
          </div>
          {(pruningAudit.hardBlock || pruningAudit.failures?.length > 0) && (
            <p>{pruningAudit.hardBlock || `audit failures: ${pruningAudit.failures.join(', ')}`}</p>
          )}
        </div>
      )}

      <div className="ai-chat-status-grid">
        <span>
          <strong>{canApplyLua ? 'Ready' : 'Hold'}</strong>
          <small>{canApplyLua ? 'Lua 적용 가능' : applyBlockedReason || '응답 검토 필요'}</small>
        </span>
        <span>
          <strong>{blockerCount}</strong>
          <small>Blockers</small>
        </span>
        <span>
          <strong>{warningCount}</strong>
          <small>Warnings</small>
        </span>
        <span>
          <strong>{followUpCount}</strong>
          <small>Questions</small>
        </span>
        <span>
          <strong>{missingSectionCount}</strong>
          <small>Missing sections</small>
        </span>
        <span>
          <strong>{luaLineCount}</strong>
          <small>Lua lines</small>
        </span>
      </div>

      <details className="ai-chat-prompt-preview">
        <summary>AI에게 보낼 최종 요청문 미리보기</summary>
        <pre>{composedPrompt}</pre>
      </details>

      <div className="ai-chat-last-response">
        <strong>최근 응답 상태</strong>
        <p>{responseSummary}</p>
        <small>구조화 검토는 AI 응답 탭에서 확인할 수 있습니다.</small>
      </div>

      <section className="ai-chat-history">
        <div className="ai-chat-history-header">
          <strong>세션 대화 기록</strong>
          <span>{chatHistory.length}/{MAX_CHAT_HISTORY}</span>
        </div>
        {chatHistory.length === 0 ? (
          <p className="ai-chat-history-empty">이번 세션에서 받은 AI 채팅 응답이 아직 없습니다.</p>
        ) : (
          <div className="ai-chat-history-list">
            {chatHistory.map((item) => (
              <article className={`ai-chat-history-item ${item.ready ? 'ready' : 'hold'}`} key={item.id}>
                <div className="ai-chat-history-item-main">
                  <strong>{item.time} · {item.ready ? 'Lua ready' : 'Review needed'}</strong>
                  <span>{item.instruction}</span>
                  <small>
                    {countTextLines(item.response)} response lines · Lua {item.luaLines || 'not ready'} · blockers {item.blockers} · warnings {item.warnings}
                  </small>
                </div>
                <div className="ai-chat-history-actions">
                  <button className="btn btn-mini btn-ghost" type="button" onClick={() => reuseHistoryInstruction(item)}>
                    재사용
                  </button>
                  <button className="btn btn-mini btn-ghost" type="button" onClick={() => copyHistoryResponse(item)}>
                    {historyCopiedId === item.id ? '복사됨' : '응답 복사'}
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
