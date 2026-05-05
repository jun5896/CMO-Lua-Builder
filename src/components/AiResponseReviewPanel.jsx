import './AiResponseReviewPanel.css';

function countTextLines(value) {
  const text = String(value || '');
  if (!text) return 0;
  const matches = text.match(/\n/g);
  return (matches?.length || 0) + 1;
}

function buildFollowUpInstruction(parsedResponse, applyBlockedReason) {
  const blockers = parsedResponse.blockers || [];
  const warnings = parsedResponse.warnings || [];
  const followUps = parsedResponse.followUpQuestions || [];
  const missingSections = parsedResponse.missingRequiredSections || [];
  const prerequisites = parsedResponse.prerequisites || [];
  const parts = [
    '아래 AI 응답 검토 결과를 반영해서 다시 작성해줘.',
    '',
    '목표:',
    '- 부족한 CMO 정보는 임의로 만들지 말고 명확히 되물어줘.',
    '- 적용 가능한 경우에만 ## Paste-ready Lua 섹션에 안전한 Lua를 작성해줘.',
    '- placeholder, unsafe Lua, 누락 섹션이 생기지 않게 응답 형식을 지켜줘.',
    '',
    applyBlockedReason ? `주요 적용 차단 사유: ${applyBlockedReason}` : '',
    blockers.length ? `Blockers:\n${blockers.map((item) => `- ${item}`).join('\n')}` : '',
    warnings.length ? `Warnings:\n${warnings.map((item) => `- ${item}`).join('\n')}` : '',
    followUps.length ? `Follow-up questions:\n${followUps.map((item) => `- ${item}`).join('\n')}` : '',
    missingSections.length ? `Missing required sections:\n${missingSections.map((item) => `- ${item}`).join('\n')}` : '',
    prerequisites.length ? `CMO UI prerequisites:\n${prerequisites.slice(0, 8).map((item) => `- ${item}`).join('\n')}` : '',
  ].filter(Boolean);

  return parts.join('\n');
}

function formatAuditList(items, fallback = 'none') {
  const values = (items || []).filter(Boolean);
  if (!values.length) return fallback;
  return values.join(', ');
}

export default function AiResponseReviewPanel({
  parsedResponse,
  canApplyLua,
  applyBlockedReason,
  pruningAudit,
  onApplyLua,
  onDraftFollowUp,
}) {
  if (!parsedResponse) return null;

  const totalRequiredSections = parsedResponse.sectionsPresent.length + parsedResponse.missingRequiredSections.length;
  const sectionCount = `${parsedResponse.sectionsPresent.length}/${totalRequiredSections}`;
  const extractedLuaLineCount = parsedResponse.lua ? countTextLines(parsedResponse.lua) : 0;
  const diagnosticItems = [
    { label: 'Sections', value: sectionCount, tone: parsedResponse.missingRequiredSections.length ? 'warning' : 'ok' },
    { label: 'Blockers', value: parsedResponse.blockers.length, tone: parsedResponse.blockers.length ? 'error' : 'ok' },
    { label: 'Warnings', value: parsedResponse.warnings.length, tone: parsedResponse.warnings.length ? 'warning' : 'ok' },
    { label: 'Lua', value: parsedResponse.lua ? 'found' : 'missing', tone: parsedResponse.lua ? 'ok' : 'error' },
  ];
  const responseGroups = [
    {
      title: 'Assumptions',
      helper: 'AI가 전제로 둔 조건입니다. 틀리면 Prompt를 고쳐 다시 호출하세요.',
      items: parsedResponse.assumptions,
    },
    {
      title: 'CMO UI prerequisites',
      helper: 'CMO 내부 Editor에서 먼저 맞춰야 하는 Side, Mission, Trigger, RP, GUID 항목입니다.',
      items: parsedResponse.prerequisites,
    },
    {
      title: 'Validation checklist',
      helper: 'CMO Lua Console 또는 Event 실행 후 확인할 검증 순서입니다.',
      items: parsedResponse.validationChecklist,
    },
    {
      title: 'Follow-up / blockers',
      helper: '추가 정보가 필요하거나 적용 전 확인해야 하는 질문입니다.',
      items: parsedResponse.followUpQuestions,
    },
  ];

  return (
    <div className="ai-response-diagnostics">
      <div className={`ai-lua-ready-card ${canApplyLua ? 'ok' : 'warning'}`}>
        <div>
          <strong>{canApplyLua ? 'Paste-ready Lua 적용 가능' : 'AI Lua 적용 전 확인 필요'}</strong>
          <span>
            {canApplyLua
              ? `${extractedLuaLineCount} lines Lua가 감지되었습니다. 적용 후 CMO 엔진에서 실행 검증하세요.`
              : applyBlockedReason || '응답 섹션, placeholder, unsafe Lua 여부를 먼저 확인하세요.'}
          </span>
        </div>
        <div className="ai-lua-ready-actions">
          {!canApplyLua && (
            <button
              className="btn btn-mini btn-ghost"
              type="button"
              onClick={() => onDraftFollowUp(buildFollowUpInstruction(parsedResponse, applyBlockedReason))}
            >
              재질문 초안 만들기
            </button>
          )}
          <button
            className="btn btn-mini btn-primary"
            type="button"
            onClick={onApplyLua}
            disabled={!canApplyLua}
          >
            Lua 적용
          </button>
        </div>
      </div>
      <div className="ai-response-diagnostic-grid">
        {diagnosticItems.map((item) => (
          <span className={`ai-response-diagnostic ${item.tone}`} key={item.label}>
            <strong>{item.value}</strong>
            <small>{item.label}</small>
          </span>
        ))}
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
      {(parsedResponse.blockers.length > 0 || parsedResponse.warnings.length > 0) && (
        <div className="ai-response-diagnostic-details">
          {parsedResponse.blockers.length > 0 && (
            <details open>
              <summary>적용 차단 사유</summary>
              <ul>{parsedResponse.blockers.map((item) => <li key={item}>{item}</li>)}</ul>
            </details>
          )}
          {parsedResponse.warnings.length > 0 && (
            <details>
              <summary>응답 형식 경고</summary>
              <ul>{parsedResponse.warnings.map((item) => <li key={item}>{item}</li>)}</ul>
            </details>
          )}
        </div>
      )}
      <div className="ai-response-section-grid">
        {responseGroups.map((group) => (
          <article className="ai-response-section-card" key={group.title}>
            <strong>{group.title}</strong>
            <p>{group.helper}</p>
            {group.items.length ? (
              <ul>
                {group.items.map((item) => <li key={item}>{item}</li>)}
              </ul>
            ) : (
              <span>응답에서 분리된 항목이 없습니다.</span>
            )}
          </article>
        ))}
      </div>
    </div>
  );
}
