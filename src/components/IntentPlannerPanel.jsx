import { Wand2 } from 'lucide-react';

const INTENT_DETAIL_TABS = [
  {
    id: 'summary',
    label: '사용자 목표',
    field: 'summary',
    helper: '사용자가 원하는 전술 상황과 최종 동작을 자연어로 넓게 적습니다.',
    placeholder: '예: 적 폭격기가 특정 구역에 진입하면 CAP 임무에 F-15 편대를 배정하고 메시지를 출력',
  },
  {
    id: 'trigger',
    label: '트리거 세부 설명',
    field: 'triggerDetail',
    helper: 'CMO Event Editor에서 먼저 만들어야 하는 Trigger/Condition을 기록합니다.',
    placeholder: '예: Unit Enters Area 트리거, 탐지 이벤트, 정기 시간 트리거 등',
  },
  {
    id: 'condition',
    label: 'Condition / 제약',
    field: 'condition',
    helper: '반복 방지, 특정 Side/Unit 상태, 점수 조건 등 Lua에서 확인할 제약을 적습니다.',
    placeholder: '예: KeyValue가 1이면 재실행 방지, 특정 유닛이 살아 있을 때만 실행',
  },
  {
    id: 'action',
    label: 'Action / Custom Lua',
    field: 'actionDetail',
    helper: 'Lua Script Action 안에서 실제로 실행할 동작을 세부화합니다.',
    placeholder: '예: ScenEdit_AssignUnitToMission, ScenEdit_SpecialMessage, ScenEdit_SetDoctrine 등',
  },
];

export default function IntentPlannerPanel({
  intentContentWidth,
  intent,
  triggerTypes,
  actionTypes,
  activeIntentDetailTab,
  onIntentChange,
  onIntentDetailTabChange,
  onResizeStart,
  eventPlan,
  uiSetupText,
}) {
  const activeIntentDetail = INTENT_DETAIL_TABS.find((tab) => tab.id === activeIntentDetailTab) || INTENT_DETAIL_TABS[0];

  return (
    <div className="assistant-tab-grid intent-layout resizable-tab-layout" style={{ '--assistant-left-column': `${intentContentWidth}%` }}>
      <div className="assistant-card intent-editor-card">
        <div className="assistant-card-title split-card-title">
          <div className="card-title-main">
            <Wand2 size={16} />
            <span>Intent Planner</span>
          </div>
        </div>
        <p className="assistant-help-text">
          사용자의 자연어 목표를 CMO Event 구조로 쪼개고, Lua Script Action 본문 초안을 만듭니다.
        </p>
        <div className="intent-grid">
          <label>Event name<input value={intent.eventName} onChange={(event) => onIntentChange('eventName', event.target.value)} /></label>
          <label>Player / message side<input value={intent.playerSide} onChange={(event) => onIntentChange('playerSide', event.target.value)} /></label>
          <label>Trigger type<select value={intent.triggerType} onChange={(event) => onIntentChange('triggerType', event.target.value)}>{triggerTypes.map(([value, label]) => <option key={value} value={value}>{label}</option>)}</select></label>
          <label>Action type<select value={intent.actionType} onChange={(event) => onIntentChange('actionType', event.target.value)}>{actionTypes.map(([value, label]) => <option key={value} value={value}>{label}</option>)}</select></label>
          <label>Repeat mode<select value={intent.repeatMode} onChange={(event) => onIntentChange('repeatMode', event.target.value)}><option value="repeatable">Repeatable</option><option value="one_shot">One-shot KeyValue guard</option></select></label>
          <label>KeyValue key<input value={intent.oneShotKey} onChange={(event) => onIntentChange('oneShotKey', event.target.value)} placeholder="비우면 Event name 기반 자동 생성" /></label>
        </div>
        <div className="intent-detail-tabs" aria-label="Intent detail editor tabs">
          {INTENT_DETAIL_TABS.map((tab) => (
            <button
              key={tab.id}
              className={`intent-detail-tab ${activeIntentDetailTab === tab.id ? 'active' : ''}`}
              type="button"
              onClick={() => onIntentDetailTabChange(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>
        <section className="intent-detail-editor">
          <div className="intent-detail-header">
            <div>
              <strong>{activeIntentDetail.label}</strong>
              <p>{activeIntentDetail.helper}</p>
            </div>
          </div>
          <textarea
            className="intent-detail-textarea"
            value={intent[activeIntentDetail.field]}
            onChange={(event) => onIntentChange(activeIntentDetail.field, event.target.value)}
            placeholder={activeIntentDetail.placeholder}
            spellCheck={false}
          />
        </section>
      </div>

      <button
        className="assistant-tab-resize"
        type="button"
        aria-label="Intent 입력 영역과 이벤트 계획 영역 폭 조절"
        onPointerDown={onResizeStart}
      />

      <div className="assistant-card planner-section intent-preview-card">
        <h3>Generated Event Plan</h3>
        <div className="planner-columns">
          <div><strong>CMO UI setup</strong><ul className="assistant-hint-list">{eventPlan.setupItems.map((item) => <li key={item}>{item}</li>)}</ul></div>
          <div><strong>Event structure</strong><ul className="assistant-hint-list">{eventPlan.eventSteps.map((item) => <li key={item}>{item}</li>)}</ul></div>
        </div>
        <div className="missing-field-box">
          <strong>Run 전에 확인</strong>
          <ul className="assistant-hint-list">
            {(eventPlan.missingFields.length ? eventPlan.missingFields : ['필수 누락값은 감지되지 않았습니다.']).map((item) => <li key={item}>{item}</li>)}
          </ul>
        </div>
        <details className="prompt-preview" open>
          <summary>CMO UI 설정 체크리스트</summary>
          <pre>{uiSetupText}</pre>
        </details>
      </div>
    </div>
  );
}
