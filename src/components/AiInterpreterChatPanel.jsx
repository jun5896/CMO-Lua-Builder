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

function makeHistoryItem({ instruction, aiResponse, aiCallStatus, parsedResponse, canApplyLua, workflowState }) {
  return {
    id: `chat-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`,
    time: new Date().toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' }),
    instruction: String(instruction || '').trim() || '기본 검토 요청',
    response: String(aiResponse || '').trim(),
    status: aiCallStatus?.state || 'idle',
    ready: Boolean(canApplyLua),
    workflowLabel: workflowState?.label || '',
    workflowTone: workflowState?.tone || '',
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
    case 'askBack':
      return [
        'AI가 요구한 Side, Mission, GUID, DBID, RP/Zone 값을 CMO UI에서 확인합니다.',
        '추가 지시 칸에 확인한 값을 붙여 넣고 다시 AI에게 보냅니다.',
        '값이 불확실하면 임의 작성 대신 질문을 더 구체화합니다.',
      ];
    case 'blocked':
      return [
        'AI 응답 탭에서 blocker, warning, missing section을 먼저 확인합니다.',
        '재질문 초안이 필요하면 응답 탭에서 초안을 만든 뒤 채팅으로 이어갑니다.',
        'Lua 적용 버튼이 활성화되기 전까지는 CMO에 붙여넣지 않습니다.',
      ];
    case 'calling':
      return [
        '현재 AI 호출이 끝날 때까지 기다립니다.',
        '중복 호출과 Lua 적용은 잠시 멈춘 상태로 유지합니다.',
        '응답이 돌아오면 같은 parser와 적용 게이트로 다시 분류합니다.',
      ];
    case 'error':
      return [
        'AI adapter, provider, model, Context Pack 상태를 먼저 확인합니다.',
        '필요하면 요청문 복사 fallback으로 외부 AI에 수동 질의합니다.',
        '오류가 해소된 뒤 다시 호출해 parser 결과를 확인합니다.',
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
  workflowState,
  canApplyLua,
  applyBlockedReason,
  pruningAudit,
  copied,
  onCallAi,
  onApplyLua,
  onOpenReview,
  onCopyPrompt,
  onClearInstruction,
  simpleMode = false,
}) {
  const composedPrompt = buildInterpreterPrompt(basePrompt, instruction);
  const [chatHistory, setChatHistory] = useState(sessionChatHistory);
  const [historyCopiedId, setHistoryCopiedId] = useState('');
  const lastHistoryResponseRef = useRef('');
  const hasInstruction = Boolean(String(instruction || '').trim());
  const isFollowUpDraft = String(instruction || '').includes('아래 AI 응답 검토 결과를 반영');
  const responsePreview = String(aiResponse || '').trim();
  const hasAiResponse = Boolean(responsePreview);
  const luaLineCount = hasAiResponse && parsedResponse?.lua ? countTextLines(parsedResponse.lua) : 0;
  const blockerCount = hasAiResponse ? parsedResponse?.blockers?.length || 0 : 0;
  const warningCount = hasAiResponse ? parsedResponse?.warnings?.length || 0 : 0;
  const followUpCount = hasAiResponse ? parsedResponse?.followUpQuestions?.length || 0 : 0;
  const missingSectionCount = hasAiResponse ? parsedResponse?.missingRequiredSections?.length || 0 : 0;
  const responseMode = workflowState || {
    tone: 'idle',
    label: '대기',
    title: 'AI response 대기',
    body: '요청문을 검토한 뒤 AI 호출을 실행하거나 Prompt 복사 fallback으로 외부 AI에 직접 질문할 수 있습니다.',
  };
  const responseSummary = hasAiResponse
    ? `${countTextLines(aiResponse)} lines response · Lua ${luaLineCount ? `${luaLineCount} lines` : 'not ready'}`
    : '아직 AI 응답이 없습니다.';
  const responsePreviewText = responsePreview.length > 1200
    ? `${responsePreview.slice(0, 1200)}\n\n...응답이 길어 일부만 표시합니다. 전체 구조화 검토는 AI 응답 탭에서 확인하세요.`
    : responsePreview;

  const handleSubmit = () => {
    onCallAi(composedPrompt, 'AI 채팅 지시문', 'chat');
  };

  useEffect(() => {
    const applyDraft = (text) => {
      const draft = String(text || '').trim();
      if (!draft) return;
      onInstructionChange(draft);
    };
    const pendingDraft = window.__cmoAiChatDraftRequest;

    if (pendingDraft?.text) {
      applyDraft(pendingDraft.text);
      delete window.__cmoAiChatDraftRequest;
    }

    const handleDraftRequest = (event) => {
      applyDraft(event.detail?.text);
    };

    window.addEventListener('cmo-ai-chat-draft-request', handleDraftRequest);
    return () => window.removeEventListener('cmo-ai-chat-draft-request', handleDraftRequest);
  }, [onInstructionChange]);

  const reuseHistoryInstruction = (item) => {
    onInstructionChange([
      '이전 AI 응답을 이어서 보강해줘.',
      '',
      `이전 지시: ${item.instruction}`,
      `이전 상태: ${item.ready ? 'Lua ready' : 'needs review'}${item.workflowLabel ? ` · ${item.workflowLabel}` : ''} · blockers ${item.blockers} · warnings ${item.warnings}`,
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
      workflowState,
    });
    sessionChatHistory = [item, ...sessionChatHistory].slice(0, MAX_CHAT_HISTORY);
    lastHistoryResponseRef.current = nextResponse;
    setChatHistory(sessionChatHistory);
  }, [aiResponse, aiCallStatus, canApplyLua, instruction, isAiCalling, parsedResponse, workflowState]);

  return (
    <div className="ai-chat-panel">
      <div className="ai-chat-intro">
        <div>
          <strong>{simpleMode ? 'CMO AI Chat' : 'AI Interpreter Chat'}</strong>
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
        {!simpleMode && (
        <button className="btn btn-ghost" type="button" onClick={onOpenReview} disabled={!aiResponse}>
          AI 응답 탭에서 전체 구조화 검토
        </button>
        )}
        {!simpleMode && (
        <button
          className="btn btn-ghost"
          type="button"
          onClick={onApplyLua}
          disabled={!canApplyLua}
          title={canApplyLua ? 'AI 응답에서 검증 게이트를 통과한 Lua 초안을 Working Draft에 적용합니다. CMO 엔진 검증은 별도 필요합니다.' : applyBlockedReason || '적용 가능한 Lua가 아직 없습니다.'}
        >
          Lua 적용
        </button>
        )}
      </div>

      <div className={`ai-chat-response-mode ${responseMode.tone}`} hidden={simpleMode}>
        <span>{responseMode.label}</span>
        <div>
          <strong>{responseMode.title}</strong>
          <p>{responseMode.body}</p>
        </div>
      </div>

      <div className={`ai-chat-next-actions ${responseMode.tone}`} hidden={simpleMode}>
        <strong>다음 동작</strong>
        <ol>
          {(responseMode.nextActions?.length ? responseMode.nextActions : nextActionItems(responseMode.tone)).map((item) => <li key={item}>{item}</li>)}
        </ol>
      </div>

      {!simpleMode && pruningAudit && (
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

      <div className="ai-chat-status-grid" hidden={simpleMode}>
        <span>
          <strong>{canApplyLua ? 'Ready' : 'Hold'}</strong>
          <small>{!hasAiResponse ? '응답 대기' : canApplyLua ? '초안 적용 가능 · CMO 검증 필요' : applyBlockedReason || '응답 검토 필요'}</small>
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

      <details className="ai-chat-prompt-preview" hidden={simpleMode}>
        <summary>AI에게 보낼 최종 요청문 미리보기</summary>
        <pre>{composedPrompt}</pre>
      </details>

      <div className="ai-chat-last-response">
        <strong>최근 AI 응답 미리보기</strong>
        <p>{responseSummary}</p>
        <small>구조화 검토는 AI 응답 탭에서 확인할 수 있습니다.</small>
        {responsePreviewText && (
          <pre className="ai-chat-response-preview">{responsePreviewText}</pre>
        )}
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
              <article className={`ai-chat-history-item ${item.workflowTone || (item.ready ? 'ready' : 'blocked')}`} key={item.id}>
                <div className="ai-chat-history-item-main">
                  <strong>{item.time} · {item.ready ? 'Lua ready' : 'Review needed'}</strong>
                  {item.workflowLabel && <em>{item.workflowLabel}</em>}
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
