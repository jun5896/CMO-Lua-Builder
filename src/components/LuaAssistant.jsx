import { lazy, Suspense, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  Check,
  Clipboard,
  Copy,
  Database,
  FileCode2,
  Fingerprint,
  FolderOpen,
  ChevronDown,
  ChevronRight,
  ListChecks,
  Redo2,
  RotateCcw,
  Save,
  ScanText,
  Trash2,
  Undo2,
  Wand2,
} from 'lucide-react';
import {
  fetchAiAdapterHealth,
  fetchAiAdapterSettings,
  fetchCmoLogFeedback,
  importCmoStateSnapshot,
  openScenarioTransient,
  parseAiInterpreterResponse,
  saveCmoLuaSidecar,
  sendCmoAiPrompt,
} from '../lib/aiAdapterClient';
import {
  CONFIRMED_CONTEXT_SOURCES,
  CONFIRMED_CONTEXT_TYPES,
  formatConfirmedContextForPrompt,
  getConfirmedContextDisplayGroups,
  hasConfirmedContextEntries,
  makeConfirmedContextEntry,
  normalizeConfirmedContextEntries,
} from '../lib/aiConfirmedContext';
import { buildAdvisorySystemGuidance } from '../lib/aiAdvisoryGuidance';
import { deriveAiWorkflowState } from '../lib/aiWorkflowState';

const AiResponseReviewPanel = lazy(() => import('./AiResponseReviewPanel'));
const AiInterpreterChatPanel = lazy(() => import('./AiInterpreterChatPanel'));
const AiProviderProfileSelector = lazy(() => import('./AiProviderProfileSelector'));
const IntentPlannerPanel = lazy(() => import('./IntentPlannerPanel'));
const LuaEditorReferenceHelper = lazy(() => import('./LuaEditorReferenceHelper'));

const CMO_STATE_SNAPSHOT_SOURCE_HINTS = [
  { id: 'toolDumpEvents', label: 'Tool_DumpEvents()' },
  { id: 'scenEditGetEvent', label: 'ScenEdit_GetEvent(...)' },
  { id: 'pastedLuaConsole', label: 'Lua Console paste' },
  { id: 'mixed', label: 'Mixed / unknown console text' },
  { id: 'unknown', label: 'Auto classify' },
];

const SNAPSHOT_CONTEXT_FIELDS = [
  { field: 'sides', type: 'side', label: 'Side' },
  { field: 'missions', type: 'mission', label: 'Mission' },
  { field: 'referencePoints', type: 'rpZone', label: 'Reference Point' },
  { field: 'zones', type: 'rpZone', label: 'Zone' },
  { field: 'specialActions', type: 'note', label: 'Special Action' },
  { field: 'luaFiles', type: 'note', label: 'Lua file' },
];

const SAMPLE_LUA = `-- CMO Event Editor 또는 Lua Script Console에서 복사한 Lua를 여기에 붙여넣으세요.
-- 맵/RP/Zone/Unit 위치는 CMO 내부 UI에서 만든 뒤, 이름/GUID/DBID만 이곳에서 참조하는 방식이 안전합니다.`;

const DEFAULT_OBJECTIVE = '이벤트 Lua를 안전하게 정리하고 CMO 내부 Editor에 다시 붙여넣을 수 있는 형태로 수정';
const DEFAULT_CONTEXT = 'Side/Unit/RP/Zone은 CMO 내부 UI에서 직접 생성하고, 이 도구는 이름/GUID 참조와 Lua 논리만 보조합니다.';

const DEFAULT_DATABASE_CONTEXT = {
  dbFamily: 'DB3000',
  dbVersion: 'v516',
  platformDbid: '',
  loadoutId: '',
  weaponDbid: '',
  sensorDbid: '',
  mountDbid: '',
  unitGuid: '',
  notes: 'DB Viewer에서 확인한 DBID/Loadout ID와, 유닛 우클릭 > Scenario Editor > Copy unit ID to clipboard로 복사한 GUID를 기록합니다.',
};

const DEFAULT_SCENARIO_CONTEXT = {
  fileName: '',
  title: '',
  dbVersion: '',
  buildNumber: '',
  version: '',
  setting: '',
  date: '',
  compressedLength: 0,
  decodedBytes: 0,
  extractionSummary: '',
  sidecarFileName: '',
  sidecarUrl: '',
  openabilityStatus: '',
  sourcePath: '',
  decoderCommands: {},
  note: '',
};

const DEFAULT_OBJECT_CONTEXT = {
  sides: 'Blue\nRed',
  units: '',
  missions: '',
  referencePoints: '',
  zones: '',
  events: '',
  specialActions: '',
  luaFiles: '',
  notes: 'CMO 내부 UI에서 실제 생성/확인한 이름만 기록합니다. 좌표와 맵 편집은 CMO에서 처리하고, 이곳은 이름/GUID 참조만 보관합니다.',
};

const DEFAULT_INTENT = {
  eventName: 'AI_Assisted_Event',
  summary: '사용자가 설명한 상황에 맞게 CMO Event Editor의 Lua Script Action으로 실행할 코드를 생성',
  triggerType: 'regular_time',
  triggerDetail: 'CMO Event Editor에서 Regular Time 트리거를 만들고 Interval을 지정합니다.',
  actionType: 'mission_assign',
  actionDetail: '등록한 유닛을 지정 미션에 배정하고 필요하면 메시지를 출력합니다.',
  condition: '',
  repeatMode: 'repeatable',
  oneShotKey: '',
  playerSide: 'Blue',
};

const TEMP_SESSION_TYPE = 'cmo-lua-assistant-temp-session';
const TEMP_SESSION_VERSION = 1;
const TEMP_SESSION_AUTOSAVE_STORAGE_KEY = 'cmo-lua-assistant-temp-session-autosave';
const TEMP_SESSION_MANUAL_STORAGE_KEY = 'cmo-lua-assistant-temp-session-manual';
const TEMP_SESSION_DIRECTORY = 'cmo-lua-assistant-temp';
const TEMP_SESSION_AUTOSAVE_FILE = 'autosave.cmo-lua-temp.json';
const TEMP_SESSION_MANUAL_FILE = 'manual.cmo-lua-temp.json';
const MAX_HISTORY_ENTRIES = 10;
const SCENARIO_CONTEXT_SAMPLE_LIMIT = 40;
const SCENARIO_LUA_FILE_LIMIT = 60;
const SCENARIO_SIDECAR_BASE_PATHS = ['/scenario-scan-samples', '/scenario-sidecars'];
const SCENARIO_OPENABILITY_INDEX_URLS = SCENARIO_SIDECAR_BASE_PATHS.map((basePath) => `${basePath}/scenario-openability-index.json`);
const SCENARIO_SCEN_METADATA_READ_LIMIT = 1_250_000;
const SCENARIO_XML_SIDECAR_CHAR_LIMIT = 2_500_000;
const CHAT_ATTACHMENT_TEXT_READ_LIMIT = 300_000;
const CHAT_ATTACHMENT_TOTAL_READ_LIMIT = 1_000_000;
const CHAT_ATTACHMENT_MAX_FILES = 40;
const CHAT_ATTACHMENT_PROMPT_CHAR_LIMIT = 12_000;
const CHAT_ATTACHMENT_EXTENSIONS = new Set([
  'lua',
  'txt',
  'md',
  'markdown',
  'html',
  'htm',
  'css',
  'json',
  'xml',
  'ini',
  'cfg',
  'yaml',
  'yml',
  'csv',
]);
const LUA_HIGHLIGHT_CHAR_LIMIT = 180_000;
const LUA_HIGHLIGHT_LINE_LIMIT = 4_000;
const LUA_ANALYSIS_CHAR_LIMIT = 320_000;
const TEMP_SESSION_INLINE_CHAR_LIMIT = 240_000;
const KNOWN_SCENARIO_PATHS = {
  'iran-strike-2020-2030': 'C:\\Program Files (x86)\\Steam\\steamapps\\workshop\\content\\1076160\\2855653232\\Iran Strike, 2020-2030.scen',
  'achilles-shield-2035': 'C:\\Program Files (x86)\\Steam\\steamapps\\workshop\\content\\1076160\\3701395554\\Achilles Shield 2035.scen',
};

function hasLocalTempSession(storageKey = '') {
  if (typeof window === 'undefined') return false;

  try {
    if (storageKey) {
      return Boolean(window.localStorage.getItem(storageKey));
    }

    return Boolean(
      window.localStorage.getItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY)
      || window.localStorage.getItem(TEMP_SESSION_MANUAL_STORAGE_KEY),
    );
  } catch {
    return false;
  }
}

function getLocalTempSessionAvailability() {
  return {
    manual: hasLocalTempSession(TEMP_SESSION_MANUAL_STORAGE_KEY),
    auto: hasLocalTempSession(TEMP_SESSION_AUTOSAVE_STORAGE_KEY),
  };
}

function cloneAssistantState(state) {
  return JSON.parse(JSON.stringify(state || {}));
}

function countTextLines(value) {
  const text = String(value || '');
  if (!text) return 0;
  const matches = text.match(/\n/g);
  return (matches?.length || 0) + 1;
}

function isLargeLuaText(value) {
  const text = String(value || '');
  return text.length > LUA_HIGHLIGHT_CHAR_LIMIT || countTextLines(text) > LUA_HIGHLIGHT_LINE_LIMIT;
}

function largeLuaPlaceholder(label, charCount = 0) {
  return [
    '-- Large Lua content was omitted from autosave/restore for browser safety.',
    `-- Source: ${label || 'CMO Lua'}`,
    `-- Original size: ${Number(charCount || 0).toLocaleString()} characters`,
    '-- Re-open the original .lua/.scenario.xml/.json file when you need the full script again.',
  ].join('\n');
}

function compactSessionText(value, label = 'CMO Lua') {
  const text = String(value ?? '');

  if (text.length <= TEMP_SESSION_INLINE_CHAR_LIMIT) {
    return {
      text,
      omitted: false,
      originalCharCount: text.length,
    };
  }

  return {
    text: largeLuaPlaceholder(label, text.length),
    omitted: true,
    originalCharCount: text.length,
  };
}

function compactLuaFileForSession(file, contentOverride = null) {
  const rawContent = contentOverride ?? file.content ?? '';
  const packed = compactSessionText(rawContent, file.path || file.name || 'Lua file');

  return {
    id: file.id,
    name: file.name,
    path: file.path,
    size: file.size,
    modified: file.modified,
    content: packed.text,
    contentOmitted: packed.omitted,
    originalCharCount: packed.originalCharCount,
  };
}

function findTextMatches(text, query, limit = 1000) {
  const haystack = String(text || '');
  const needle = String(query || '').trim();
  if (!haystack || !needle) return [];

  const lowerHaystack = haystack.toLowerCase();
  const lowerNeedle = needle.toLowerCase();
  const matches = [];
  let index = lowerHaystack.indexOf(lowerNeedle);
  while (index !== -1 && matches.length < limit) {
    matches.push(index);
    index = lowerHaystack.indexOf(lowerNeedle, index + Math.max(1, lowerNeedle.length));
  }
  return matches;
}

function getLineStartPosition(text, lineNumber) {
  const source = String(text || '');
  const requestedLine = Math.max(1, Number.parseInt(lineNumber, 10) || 1);
  if (requestedLine <= 1) return 0;

  let currentLine = 1;
  let position = 0;
  while (currentLine < requestedLine) {
    const nextBreak = source.indexOf('\n', position);
    if (nextBreak === -1) return source.length;
    position = nextBreak + 1;
    currentLine += 1;
  }
  return position;
}

function scrollTextareaToPosition(textarea, text, position, leadLines = 6) {
  const computedLineHeight = Number.parseFloat(window.getComputedStyle(textarea).lineHeight);
  const lineHeight = Number.isFinite(computedLineHeight) ? computedLineHeight : 22;
  const lineNumber = countTextLines(String(text || '').slice(0, position));
  textarea.scrollTop = Math.max(0, (lineNumber - leadLines) * lineHeight);
}

function getAssistantHistoryKey(state) {
  const normalized = cloneAssistantState(state);
  delete normalized.luaFileStatus;
  return JSON.stringify(normalized);
}

function normalizeTempValue(value) {
  return String(value ?? '').trim();
}

function hasContextDiff(value = {}, defaults = {}) {
  return Object.keys(defaults).some((key) => normalizeTempValue(value[key]) !== normalizeTempValue(defaults[key]));
}

function hasMeaningfulAssistantState(state = {}) {
  return Boolean(
    normalizeTempValue(state.source) && normalizeTempValue(state.source) !== normalizeTempValue(SAMPLE_LUA)
    || normalizeTempValue(state.objective) && normalizeTempValue(state.objective) !== normalizeTempValue(DEFAULT_OBJECTIVE)
    || normalizeTempValue(state.context) && normalizeTempValue(state.context) !== normalizeTempValue(DEFAULT_CONTEXT)
    || hasContextDiff(state.objectContext, DEFAULT_OBJECT_CONTEXT)
    || hasContextDiff(state.databaseContext, DEFAULT_DATABASE_CONTEXT)
    || hasConfirmedContextEntries(state.confirmedContext)
    || hasContextDiff(state.scenarioContext, DEFAULT_SCENARIO_CONTEXT)
    || hasContextDiff(state.intent, DEFAULT_INTENT)
    || normalizeTempValue(state.engineFeedback)
    || normalizeTempValue(state.workingLua)
    || normalizeTempValue(state.luaFileName)
    || (Array.isArray(state.luaFiles) && state.luaFiles.length > 0)
    || Boolean(state.isPromptDirty && normalizeTempValue(state.promptDraft))
    || normalizeTempValue(state.aiChatInstruction)
  );
}

const TRIGGER_TYPES = [
  ['regular_time', 'Regular Time'],
  ['unit_detected', 'Unit Detected'],
  ['unit_destroyed', 'Unit Destroyed / Damaged'],
  ['unit_enters_area', 'Unit Enters Area / RP Zone'],
  ['special_action', 'Special Action'],
  ['manual_console', 'Lua Console / Manual Test'],
  ['custom', 'Custom CMO Trigger'],
];

const ACTION_TYPES = [
  ['mission_assign', 'Assign Units To Mission'],
  ['loadout_scramble', 'Set Loadout / Scramble'],
  ['mission_toggle', 'Activate Mission'],
  ['zone_toggle', 'Toggle No-Nav Zone'],
  ['message', 'Special Message'],
  ['run_script', 'Run External Lua File'],
  ['score_keyvalue', 'Score / KeyValue Flag'],
  ['custom_lua', 'Custom Lua Body'],
];

const ASSISTANT_WORKSPACE_TABS = [
  { id: 'lua', label: 'Lua 분석', hint: '붙여넣은 Lua 분석', icon: ScanText },
  { id: 'context', label: 'Context Registry', hint: 'CMO 객체/DB 정보', icon: Database },
  { id: 'intent', label: 'Intent Planner', hint: '이벤트 의도 설계', icon: Wand2 },
  { id: 'output', label: 'Output & Validation', hint: 'Lua 초안/검증 루프', icon: FileCode2 },
];

const OUTPUT_PREVIEW_TABS = [
  { id: 'generated', label: 'Lua 초안' },
  { id: 'setup', label: 'CMO 체크리스트' },
  { id: 'prompt', label: 'AI 요청문' },
  { id: 'chat', label: 'AI 채팅' },
  { id: 'ai', label: 'AI 응답' },
  { id: 'smoke', label: 'ID 테스트' },
];

const LUA_KEYWORDS = new Set([
  'and',
  'break',
  'do',
  'else',
  'elseif',
  'end',
  'false',
  'for',
  'function',
  'goto',
  'if',
  'in',
  'local',
  'nil',
  'not',
  'or',
  'repeat',
  'return',
  'then',
  'true',
  'until',
  'while',
]);

const LUA_CONTEXT_KEYS = new Set([
  'area',
  'contact',
  'dbid',
  'guid',
  'loadoutid',
  'mission',
  'name',
  'side',
  'target',
  'type',
  'unit',
  'weapon_dbid',
  'zone',
]);

const CMO_API_PREFIX_PATTERN = /^(?:ScenEdit|VP|Tool|World|Unit|Mission|Side|Command)_?/;
const GUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const OBJECT_CONTEXT_TABS = [
  {
    id: 'sides',
    label: 'Sides',
    field: 'sides',
    helper: 'CMO Add/Edit Sides에서 확인한 Side 이름을 줄 단위로 기록합니다.',
    placeholder: 'Blue\nRed',
  },
  {
    id: 'units',
    label: 'Units / GUIDs',
    field: 'units',
    helper: '배치 유닛은 우클릭 > Scenario Editor > Copy unit ID to clipboard 값을 우선 기록합니다.',
    placeholder: 'Copy unit ID 값 또는 유닛 이름',
  },
  {
    id: 'missions',
    label: 'Missions',
    field: 'missions',
    helper: 'Mission Editor에서 만든 정확한 미션 이름을 줄 단위로 기록합니다.',
    placeholder: 'CAP Station\nStrike Alpha',
  },
  {
    id: 'referencePoints',
    label: 'RP',
    field: 'referencePoints',
    helper: 'CMO 내부에서 만든 Reference Point 이름을 순서대로 기록합니다.',
    placeholder: 'CAP-1\nCAP-2\nCAP-3\nCAP-4',
  },
  {
    id: 'zones',
    label: 'Zones',
    field: 'zones',
    helper: 'No-navigation / Exclusion Zone 이름을 기록합니다.',
    placeholder: 'NoNav Korea Strait',
  },
  {
    id: 'events',
    label: 'Events',
    field: 'events',
    helper: 'Event Editor에 만든 Event 이름을 기록합니다.',
    placeholder: 'Game_Start',
  },
  {
    id: 'specialActions',
    label: 'Special Actions',
    field: 'specialActions',
    helper: 'Special Actions 창에서 만든 사용자 실행 항목 이름을 기록합니다.',
    placeholder: 'Request Recon Data',
  },
  {
    id: 'luaFiles',
    label: 'Lua files',
    field: 'luaFiles',
    helper: 'RunScript 또는 시나리오 첨부로 사용할 Lua 파일 경로를 기록합니다. 폴더 불러오기 시 자동 채움됩니다.',
    placeholder: '/ScenarioFolder/Game_HourlyActions.lua',
  },
  {
    id: 'notes',
    label: 'Notes',
    field: 'notes',
    helper: 'CMO 내부 UI에서 확인한 객체 관련 주석을 자유롭게 기록합니다.',
    placeholder: 'CMO 내부 UI에서 실제 생성/확인한 이름만 기록합니다.',
  },
];

const MAX_PROMPT_FILE_CHARS = 14000;

function buildLuaDownloadName(fileName, eventName) {
  const baseName = (fileName || safeLuaName(eventName) || 'cmo_lua_assistant')
    .replace(/\.lua$/i, '')
    .replace(/[^A-Za-z0-9_.-]+/g, '_')
    .replace(/^_+|_+$/g, '');

  return `${baseName || 'cmo_lua_assistant'}_assistant.lua`;
}

function uniqueMatches(text, pattern) {
  return [...new Set([...text.matchAll(pattern)].map((match) => match[1] || match[0]))].sort();
}

function classifyLuaIdentifier(token) {
  const normalized = token.toLowerCase();
  if (LUA_KEYWORDS.has(normalized)) return normalized === 'true' || normalized === 'false' || normalized === 'nil' ? 'literal' : 'keyword';
  if (CMO_API_PREFIX_PATTERN.test(token)) return 'api';
  if (LUA_CONTEXT_KEYS.has(normalized)) return 'context';
  if (/^(?:dbid|loadout|guid|weapon|sensor|mount)/i.test(token)) return 'asset';
  return 'identifier';
}

function pushLuaToken(tokens, type, text, keyBase) {
  tokens.push(<span key={`${keyBase}-${tokens.length}`} className={`lua-token lua-token-${type}`}>{text}</span>);
}

function tokenizeLuaLine(line, lineIndex) {
  const tokens = [];
  let index = 0;

  while (index < line.length) {
    const rest = line.slice(index);

    if (rest.startsWith('--')) {
      pushLuaToken(tokens, 'comment', rest, lineIndex);
      break;
    }

    const guidMatch = rest.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i);
    if (guidMatch) {
      pushLuaToken(tokens, 'guid', guidMatch[0], lineIndex);
      index += guidMatch[0].length;
      continue;
    }

    const quote = line[index];
    if (quote === '"' || quote === "'") {
      let end = index + 1;
      while (end < line.length) {
        if (line[end] === '\\') {
          end += 2;
          continue;
        }
        if (line[end] === quote) {
          end += 1;
          break;
        }
        end += 1;
      }
      const value = line.slice(index, end);
      pushLuaToken(tokens, GUID_PATTERN.test(value.slice(1, -1)) ? 'guid' : 'string', value, lineIndex);
      index = end;
      continue;
    }

    const identifierMatch = rest.match(/^[A-Za-z_][A-Za-z0-9_]*/);
    if (identifierMatch) {
      const value = identifierMatch[0];
      pushLuaToken(tokens, classifyLuaIdentifier(value), value, lineIndex);
      index += value.length;
      continue;
    }

    const numberMatch = rest.match(/^\d+(?:\.\d+)?/);
    if (numberMatch) {
      pushLuaToken(tokens, 'number', numberMatch[0], lineIndex);
      index += numberMatch[0].length;
      continue;
    }

    const operatorMatch = rest.match(/^[{}[\](),.=:+\-*/<>#;]/);
    if (operatorMatch) {
      pushLuaToken(tokens, 'operator', operatorMatch[0], lineIndex);
      index += operatorMatch[0].length;
      continue;
    }

    tokens.push(line[index]);
    index += 1;
  }

  return tokens.length ? tokens : [''];
}

function highlightLua(source) {
  return String(source || ' ')
    .split('\n')
    .flatMap((line, lineIndex, lines) => {
      const highlightedLine = tokenizeLuaLine(line, lineIndex);
      return lineIndex === lines.length - 1 ? highlightedLine : [...highlightedLine, '\n'];
    });
}

function LuaCodeEditor({
  value,
  onChange,
  className = '',
  placeholder = '',
  ariaLabel = 'Lua code editor',
}) {
  const highlightRef = useRef(null);
  const inputRef = useRef(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeMatchIndex, setActiveMatchIndex] = useState(-1);
  const [lineJumpInput, setLineJumpInput] = useState('');
  const textValue = String(value ?? '');
  const largeLuaMode = isLargeLuaText(textValue);
  const lineCount = useMemo(() => countTextLines(textValue), [textValue]);
  const searchMatches = useMemo(() => findTextMatches(textValue, searchQuery), [textValue, searchQuery]);
  const hasSearchMatches = searchMatches.length > 0;
  const visibleMatchIndex = hasSearchMatches
    ? Math.min(Math.max(activeMatchIndex, 0), searchMatches.length - 1)
    : -1;

  const syncScroll = (event) => {
    if (!highlightRef.current || largeLuaMode) return;
    highlightRef.current.scrollTop = event.currentTarget.scrollTop;
    highlightRef.current.scrollLeft = event.currentTarget.scrollLeft;
  };

  const jumpToMatch = (direction) => {
    if (!searchMatches.length || !inputRef.current) return;
    const nextIndex = visibleMatchIndex < 0
      ? 0
      : (visibleMatchIndex + direction + searchMatches.length) % searchMatches.length;
    const position = searchMatches[nextIndex];
    const textarea = inputRef.current;
    const queryLength = String(searchQuery || '').trim().length;
    setActiveMatchIndex(nextIndex);
    requestAnimationFrame(() => {
      textarea.focus();
      textarea.setSelectionRange(position, position + queryLength);
      scrollTextareaToPosition(textarea, textValue, position);
    });
  };

  const jumpToLine = () => {
    if (!inputRef.current) return;
    const textarea = inputRef.current;
    const targetLine = Math.min(Math.max(Number.parseInt(lineJumpInput, 10) || 1, 1), Math.max(lineCount, 1));
    const position = getLineStartPosition(textValue, targetLine);
    setLineJumpInput(String(targetLine));
    requestAnimationFrame(() => {
      textarea.focus();
      textarea.setSelectionRange(position, position);
      scrollTextareaToPosition(textarea, textValue, position, 4);
    });
  };

  return (
    <div className={`lua-code-editor ${largeLuaMode ? 'large-lua-mode' : ''} ${className}`}>
      <div className="lua-editor-searchbar">
        <input
          type="search"
          value={searchQuery}
          onChange={(event) => {
            setSearchQuery(event.target.value);
            setActiveMatchIndex(0);
          }}
          placeholder="키워드 검색"
          aria-label="Lua 코드 검색"
        />
        <span className="lua-search-count">
          {searchQuery.trim()
            ? `${hasSearchMatches ? visibleMatchIndex + 1 : 0}/${searchMatches.length}${searchMatches.length >= 1000 ? '+' : ''}`
            : '0/0'}
        </span>
        <button
          className="btn btn-mini btn-ghost"
          type="button"
          onClick={() => jumpToMatch(-1)}
          disabled={!hasSearchMatches}
          title="이전 검색 결과로 이동"
        >
          이전
        </button>
        <button
          className="btn btn-mini btn-ghost"
          type="button"
          onClick={() => jumpToMatch(1)}
          disabled={!hasSearchMatches}
          title="다음 검색 결과로 이동"
        >
          다음
        </button>
        <div className="lua-line-jump" title={`1-${lineCount.toLocaleString()} line 범위에서 이동`}>
          <input
            type="number"
            min="1"
            max={Math.max(lineCount, 1)}
            value={lineJumpInput}
            onChange={(event) => setLineJumpInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter') {
                event.preventDefault();
                jumpToLine();
              }
            }}
            placeholder="줄"
            aria-label="Lua 줄 번호 이동"
          />
          <button
            className="btn btn-mini btn-ghost"
            type="button"
            onClick={jumpToLine}
            disabled={!textValue}
            title="입력한 줄 번호로 이동"
          >
            이동
          </button>
        </div>
      </div>
      {largeLuaMode ? (
        <div className="lua-large-mode-banner">
          Large Lua safe mode: syntax color is paused for {countTextLines(textValue).toLocaleString()} lines / {textValue.length.toLocaleString()} chars.
        </div>
      ) : (
        <pre ref={highlightRef} className="lua-highlight-layer" aria-hidden="true">
          {highlightLua(textValue)}
        </pre>
      )}
      <textarea
        ref={inputRef}
        className="lua-code-input"
        value={textValue}
        onChange={(event) => onChange(event.target.value)}
        onScroll={syncScroll}
        spellCheck={false}
        placeholder={placeholder}
        aria-label={ariaLabel}
      />
    </div>
  );
}

function isGuid(value) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value.trim());
}

function formatTempSessionTime(value) {
  if (!value) return '';

  try {
    return new Date(value).toLocaleString();
  } catch {
    return String(value);
  }
}

async function writeOriginTempSession(payload, fileName = TEMP_SESSION_AUTOSAVE_FILE) {
  if (!navigator.storage?.getDirectory) return false;

  const rootHandle = await navigator.storage.getDirectory();
  const directoryHandle = await rootHandle.getDirectoryHandle(TEMP_SESSION_DIRECTORY, { create: true });
  const fileHandle = await directoryHandle.getFileHandle(fileName, { create: true });
  const writable = await fileHandle.createWritable();

  await writable.write(JSON.stringify(payload, null, 2));
  await writable.close();
  return true;
}

async function readOriginTempSession(fileName = TEMP_SESSION_AUTOSAVE_FILE) {
  if (!navigator.storage?.getDirectory) return null;

  try {
    const rootHandle = await navigator.storage.getDirectory();
    const directoryHandle = await rootHandle.getDirectoryHandle(TEMP_SESSION_DIRECTORY);
    const fileHandle = await directoryHandle.getFileHandle(fileName);
    const file = await fileHandle.getFile();
    return JSON.parse(await file.text());
  } catch {
    return null;
  }
}

async function deleteOriginTempSession(fileName = TEMP_SESSION_AUTOSAVE_FILE) {
  if (!navigator.storage?.getDirectory) return false;

  try {
    const rootHandle = await navigator.storage.getDirectory();
    const directoryHandle = await rootHandle.getDirectoryHandle(TEMP_SESSION_DIRECTORY);
    await directoryHandle.removeEntry(fileName);
    return true;
  } catch {
    return false;
  }
}

function splitContextLines(value) {
  return value
    .split(/[\n,]/)
    .map((item) => item.trim())
    .filter(Boolean);
}

function luaQuote(value) {
  return JSON.stringify(String(value ?? ''));
}

function safeLuaName(value) {
  return String(value || 'AI_Assisted_Event')
    .replace(/[^A-Za-z0-9_]+/g, '_')
    .replace(/^_+|_+$/g, '')
    || 'AI_Assisted_Event';
}

function buildScenarioXmlName(fileName) {
  return `${String(fileName || 'Scenario.scen')
    .replace(/\.[^.]+$/, '')
    .replace(/[^A-Za-z0-9_.-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    || 'scenario'}.scenario.xml`;
}

function buildScenarioSlug(value) {
  return String(value || 'scenario')
    .replace(/\.[^.]+$/, '')
    .normalize('NFKD')
    .replace(/[^A-Za-z0-9_. -]+/g, '')
    .trim()
    .replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase()
    || 'scenario';
}

function buildScenarioDecoderCommand(fileName, scenarioContext = {}) {
  if (scenarioContext?.decoderCommands?.prepare) {
    return scenarioContext.decoderCommands.prepare;
  }

  if (scenarioContext?.decoderCommands?.extractXml) {
    return [
      scenarioContext.decoderCommands.scan,
      scenarioContext.decoderCommands.extractXml,
      scenarioContext.decoderCommands.summarize,
    ].filter(Boolean).join('\n');
  }

  const slug = buildScenarioSlug(fileName);
  const scenarioPath = scenarioContext?.sourcePath || KNOWN_SCENARIO_PATHS[slug] || `C:\\path\\to\\${fileName || 'Scenario.scen'}`;
  return `npm run prepare:scenario -- "${scenarioPath}"`;
}

function luaArray(items, fallback) {
  const values = items.length ? items : [fallback].filter(Boolean);
  return `{ ${values.map((item) => luaQuote(item)).join(', ')} }`;
}

function optionLabel(options, value) {
  return options.find(([optionValue]) => optionValue === value)?.[1] || value;
}

function truncateForPrompt(text, maxChars = MAX_PROMPT_FILE_CHARS) {
  if (!text || text.length <= maxChars) return text || '';
  return `${text.slice(0, maxChars)}\n-- [truncated for AI request preview: ${text.length - maxChars} chars omitted]`;
}

function formatBytes(value) {
  const bytes = Number(value || 0);
  if (bytes >= 1_000_000) return `${(bytes / 1_000_000).toFixed(2)} MB`;
  if (bytes >= 1_000) return `${(bytes / 1_000).toFixed(0)} KB`;
  return `${bytes} B`;
}

function attachmentPathOf(file) {
  return file.webkitRelativePath || file.name || 'attachment';
}

function extensionOf(path = '') {
  const match = String(path).toLowerCase().match(/\.([a-z0-9]+)$/);
  return match ? match[1] : '';
}

function isSupportedChatAttachment(file) {
  return CHAT_ATTACHMENT_EXTENSIONS.has(extensionOf(attachmentPathOf(file)));
}

function createChatAttachmentRecord({ file, content, index, truncated }) {
  const path = attachmentPathOf(file);
  const extension = extensionOf(path) || 'txt';

  return {
    id: `chat-attachment-${index}-${path}-${file.size}-${file.lastModified}`,
    name: file.name,
    path,
    extension,
    size: file.size,
    truncated,
    content,
  };
}

function createScenarioLuaChatAttachments(luaFiles = []) {
  return luaFiles.map((file, index) => ({
    id: `scenario-lua-${file.id || index}`,
    name: file.name || `Scenario Lua ${index + 1}.lua`,
    path: file.path || `Scenario Lua ${index + 1}.lua`,
    extension: 'lua',
    size: String(file.content || '').length,
    truncated: false,
    content: file.content || '',
  }));
}

function formatChatAttachmentsPrompt(attachments = []) {
  if (!attachments.length) return '';

  const totalBytes = attachments.reduce((sum, file) => sum + Number(file.size || 0), 0);
  const header = [
    '## User Attached Files',
    `- File count: ${attachments.length}`,
    `- Original size: ${formatBytes(totalBytes)}`,
    '- Treat these files as user-provided context for analysis only.',
    '- Do not overwrite the manual editor draft from attachments unless the user explicitly asks.',
  ];

  const bodies = attachments.flatMap((file) => [
    '',
    `### ${file.path}`,
    `- type=${file.extension || 'txt'}, originalSize=${formatBytes(file.size)}, readLimit=${formatBytes(CHAT_ATTACHMENT_TEXT_READ_LIMIT)}${file.truncated ? ', truncated=yes' : ''}`,
    `\`\`\`${file.extension === 'md' || file.extension === 'markdown' ? 'markdown' : file.extension || 'text'}`,
    truncateForPrompt(file.content, CHAT_ATTACHMENT_PROMPT_CHAR_LIMIT),
    '```',
  ]);

  return [...header, ...bodies].join('\n');
}

function analyzeLua(source) {
  const text = String(source || '').trim();
  const scanText = text.length > LUA_ANALYSIS_CHAR_LIMIT ? text.slice(0, LUA_ANALYSIS_CHAR_LIMIT) : text;
  const apiCalls = uniqueMatches(scanText, /\b((?:ScenEdit|VP|Tool|World|Unit|Mission|Side)[A-Za-z0-9_:.]*)\s*(?=\()/g);
  const eventCalls = uniqueMatches(scanText, /\b(ScenEdit_Set(?:Event|Trigger|Condition|Action)|ScenEdit_Get(?:Event|Trigger|Condition|Action))\s*(?=\()/g);
  const triggerHints = uniqueMatches(scanText, /\b(RegularTime|UnitDetected|UnitDestroyed|UnitDamaged|Points|Time|UnitRemainsInArea)\b/g);
  const dbIdentifierHints = uniqueMatches(scanText, /\b(?:DBID|dbid|databaseid|loadoutid|loadout_id|loadout_dbid|weapon_dbid|sensor_dbid|mount_dbid)\s*[=:]\s*["']?(\d{2,})["']?/gi)
    .slice(0, 18);
  const guidHints = uniqueMatches(scanText, /\b([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\b/gi)
    .slice(0, 18);
  const quotedNames = uniqueMatches(scanText, /\b(?:side|Side|name|Name|unit|Unit|mission|Mission|area|Area|guid|Guid|dbid|DBID)\s*=\s*["']([^"']+)["']/g)
    .slice(0, 18);
  const risks = [];

  if (/ScenEdit_GetUnit\s*\(/.test(scanText) && !/if\s+[^\n]*then/.test(scanText)) {
    risks.push('ScenEdit_GetUnit 결과 nil 체크가 보이지 않습니다. 유닛 이름/GUID가 틀리면 런타임 오류가 날 수 있습니다.');
  }
  if (/\b(?:ScenEdit_EndScenario|EndScenario)\b/.test(scanText)) {
    risks.push('시나리오 종료 API가 포함되어 있습니다. 조건식과 반복 이벤트 여부를 특히 확인해야 합니다.');
  }
  if (/\b(?:ScenEdit_SetKeyValue|ScenEdit_GetKeyValue)\b/.test(scanText)) {
    risks.push('KeyValue 상태를 사용합니다. 중복 실행 방지 키 이름과 초기화 조건을 확인하세요.');
  }
  if (/\bmath\.random\b/.test(scanText)) {
    risks.push('무작위 로직이 있습니다. 재현성이나 범위 제한이 필요한지 확인하세요.');
  }
  if (/\bDBID\b|\bdbid\s*=/.test(scanText)) {
    risks.push('DBID 의존 코드입니다. 현재 DB3K/CWDB 버전과 맞는지 확인하세요.');
  }
  if (/\b(?:ScenEdit_AddUnit|ScenEdit_SetLoadout|loadoutid|LoadoutID)\b/.test(scanText)) {
    risks.push('플랫폼 DBID/Loadout ID를 사용합니다. CMO Database Viewer에서 현재 시나리오 DB 기준으로 확인한 값인지 검증하세요.');
  }
  if (guidHints.length && /\bname\s*=/.test(scanText)) {
    risks.push('GUID와 이름 참조가 섞여 있습니다. 배치된 유닛은 가능하면 Copy unit ID to clipboard로 얻은 GUID를 우선 사용하세요.');
  }
  if (/\bScenEdit_Set(?:EMCON|Doctrine)|ScenEdit_SetDoctrineWRA\b/.test(scanText)) {
    risks.push('Doctrine/EMCON 변경 코드입니다. 적용 범위가 Side/Unit/Group 중 어디인지 확인하세요.');
  }

  if (scanText.length < text.length) {
    risks.push(`Large Lua analysis sampled first ${LUA_ANALYSIS_CHAR_LIMIT.toLocaleString()} characters out of ${text.length.toLocaleString()} to keep the browser responsive.`);
  }

  return {
    lineCount: countTextLines(text),
    charCount: text.length,
    apiCalls,
    eventCalls,
    triggerHints,
    dbIdentifierHints,
    guidHints,
    quotedNames,
    risks,
  };
}

function createLuaFileRecord(file, content, index) {
  const path = file.webkitRelativePath || file.name;
  return {
    id: `${index}-${path}-${file.size}-${file.lastModified}`,
    name: file.name,
    path,
    size: file.size,
    modified: false,
    content,
    analysis: analyzeLua(content),
  };
}

function safeVirtualLuaSegment(value, fallback = 'Lua') {
  return String(value || fallback)
    .replace(/\.[^.]+$/, '')
    .replace(/[^A-Za-z0-9_. -]+/g, '_')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 96)
    || fallback;
}

function createVirtualLuaFileRecord(path, content, index) {
  const normalizedPath = String(path || `Scenario Lua ${index + 1}.lua`);
  const name = normalizedPath.split(/[\\/]/).pop() || `Scenario Lua ${index + 1}.lua`;

  return {
    id: `virtual-${index}-${normalizedPath}-${content.length}`,
    name,
    path: normalizedPath,
    size: content.length,
    modified: false,
    virtual: true,
    content,
    analysis: analyzeLua(content),
  };
}

function aggregateLuaFiles(luaFiles) {
  const collect = (field) => [...new Set(luaFiles.flatMap((file) => file.analysis[field]))].sort();
  const risks = luaFiles.flatMap((file) => file.analysis.risks.map((risk) => `${file.path}: ${risk}`));

  return {
    fileCount: luaFiles.length,
    totalLines: luaFiles.reduce((sum, file) => sum + file.analysis.lineCount, 0),
    totalChars: luaFiles.reduce((sum, file) => sum + file.analysis.charCount, 0),
    apiCalls: collect('apiCalls'),
    eventCalls: collect('eventCalls'),
    triggerHints: collect('triggerHints'),
    dbIdentifierHints: collect('dbIdentifierHints'),
    guidHints: collect('guidHints'),
    quotedNames: collect('quotedNames'),
    risks,
  };
}

function uniqueLines(values) {
  return [...new Set(values.map((value) => String(value || '').trim()).filter(Boolean))].sort();
}

function mergeContextValue(currentValue, additions) {
  return uniqueLines([...splitContextLines(currentValue), ...additions]).join('\n');
}

function toLimitedNameList(values, limit = SCENARIO_CONTEXT_SAMPLE_LIMIT) {
  return uniqueLines(Array.isArray(values) ? values : []).slice(0, limit);
}

function directChildText(element, tagName) {
  if (!element) return '';
  const normalizedTag = tagName.toLowerCase();
  const child = Array.from(element.children || []).find((item) => item.tagName.toLowerCase() === normalizedTag);
  return child?.textContent?.trim() || '';
}

function directChildElement(element, tagName) {
  if (!element) return null;
  const normalizedTag = tagName.toLowerCase();
  return Array.from(element.children || []).find((item) => item.tagName.toLowerCase() === normalizedTag) || null;
}

function readFirstTag(doc, tagNames) {
  for (const tagName of tagNames) {
    const value = doc.querySelector(tagName)?.textContent?.trim();
    if (value) return value;
  }
  return '';
}

function collectDirectChildren(doc, parentSelector, formatter, limit = SCENARIO_CONTEXT_SAMPLE_LIMIT) {
  const parent = doc.querySelector(parentSelector);
  if (!parent) return [];
  return uniqueLines(Array.from(parent.children || []).map(formatter)).slice(0, limit);
}

function collectDirectChildrenFromElement(parent, formatter) {
  if (!parent) return [];
  return Array.from(parent.children || []).map(formatter);
}

function getScenarioSides(doc) {
  return Array.from(doc.querySelectorAll('Sides > Side'));
}

function formatScenarioUnit(element) {
  const name = directChildText(element, 'Name');
  const side = directChildText(element, 'Side');
  const id = directChildText(element, 'ID');
  const dbid = directChildText(element, 'DBID');
  const type = element.tagName;
  if (!name && !id) return '';
  return [
    name || id,
    side ? `[${side}]` : '',
    type ? `type=${type}` : '',
    dbid ? `DBID=${dbid}` : '',
    id ? `ID=${id}` : '',
  ].filter(Boolean).join(' ');
}

function parseInternalScenarioObjectContext(doc) {
  const sideElements = getScenarioSides(doc);
  const sides = uniqueLines(
    sideElements
      .map((side) => directChildText(side, 'Name')),
  ).slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT);

  const missions = uniqueLines(
    sideElements.flatMap((side) => {
      const sideName = directChildText(side, 'Name');
      const missionsContainer = directChildElement(side, 'Missions');
      return collectDirectChildrenFromElement(missionsContainer, (mission) => {
        const name = directChildText(mission, 'Name');
        return name ? `${name} [${sideName || 'Unknown side'}] (${mission.tagName})` : '';
      });
    }),
  ).slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT);

  const referencePoints = uniqueLines(
    sideElements.flatMap((side) => {
      const sideName = directChildText(side, 'Name');
      const referencePointContainer = directChildElement(side, 'ReferencePoints');
      return collectDirectChildrenFromElement(referencePointContainer, (rp) => {
        const name = directChildText(rp, 'Name');
        return name ? `${name}${sideName ? ` [${sideName}]` : ''}` : '';
      });
    }),
  ).slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT);

  const zones = sideElements.flatMap((side) => {
    const sideName = directChildText(side, 'Name');
    const noNavZones = collectDirectChildrenFromElement(directChildElement(side, 'NoNavZones'), (zone) => {
      const name = directChildText(zone, 'Description') || directChildText(zone, 'Name') || directChildText(zone, 'ID');
      return name ? `${name}${sideName ? ` [${sideName}]` : ''} (NoNavZone)` : '';
    });
    const exclusionZones = collectDirectChildrenFromElement(directChildElement(side, 'ExclusionZones'), (zone) => {
      const name = directChildText(zone, 'Description') || directChildText(zone, 'Name') || directChildText(zone, 'ID');
      return name ? `${name}${sideName ? ` [${sideName}]` : ''} (ExclusionZone)` : '';
    });
    return [...noNavZones, ...exclusionZones];
  });

  const units = collectDirectChildren(
    doc,
    'ActiveUnits',
    formatScenarioUnit,
    SCENARIO_CONTEXT_SAMPLE_LIMIT,
  );

  const events = [
    ...collectDirectChildren(doc, 'EventTriggers', (event) => {
      const name = directChildText(event, 'Description') || directChildText(event, 'Name') || directChildText(event, 'ID');
      return name ? `Trigger: ${name} (${event.tagName})` : '';
    }),
    ...collectDirectChildren(doc, 'EventActions', (event) => {
      const name = directChildText(event, 'Description') || directChildText(event, 'Name') || directChildText(event, 'ID');
      return name ? `Action: ${name} (${event.tagName})` : '';
    }),
    ...collectDirectChildren(doc, 'EventConditions', (event) => {
      const name = directChildText(event, 'Description') || directChildText(event, 'Name') || directChildText(event, 'ID');
      return name ? `Condition: ${name} (${event.tagName})` : '';
    }),
  ].slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT);

  const specialActions = uniqueLines(
    sideElements.flatMap((side) => {
      const sideName = directChildText(side, 'Name');
      const specialActionContainer = directChildElement(side, 'SpecialActions');
      return collectDirectChildrenFromElement(specialActionContainer, (action) => {
        const name = directChildText(action, 'Name') || directChildText(action, 'Description') || directChildText(action, 'ID');
        const activeLabel = directChildText(action, 'IsActive') === 'True' ? 'active' : 'inactive';
        return name ? `${name}${sideName ? ` [${sideName}]` : ''} (${activeLabel})` : '';
      });
    }),
  ).slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT);

  return {
    sides,
    units,
    missions,
    referencePoints,
    zones: uniqueLines(zones).slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT),
    events: uniqueLines(events).slice(0, SCENARIO_CONTEXT_SAMPLE_LIMIT),
    specialActions,
    luaFiles: [],
  };
}

function summarizeScenarioExtraction(extracted) {
  return [
    `Sides ${extracted.sides.length}`,
    `Units ${extracted.units.length}`,
    `Missions ${extracted.missions.length}`,
    `RPs ${extracted.referencePoints.length}`,
    `Zones ${extracted.zones.length}`,
    `Events ${extracted.events.length}`,
    `SpecialActions ${extracted.specialActions.length}`,
  ].join(' · ');
}

function scriptTextFromElement(element) {
  return directChildText(element, 'ScriptText')
    || directChildText(element, 'LuaScript')
    || directChildText(element, 'Script')
    || '';
}

function scenarioScriptPath(sourceName, group, name, index) {
  const scenarioName = safeVirtualLuaSegment(sourceName, 'Scenario');
  const scriptName = safeVirtualLuaSegment(name, `${group} ${index + 1}`);
  return `Scenario Lua/${scenarioName}/${group}/${scriptName}.lua`;
}

function extractScenarioLuaFilesFromXml(doc, fileName) {
  const records = [];

  Array.from(doc.querySelectorAll('EventAction_LuaScript')).forEach((action) => {
    const script = scriptTextFromElement(action);
    if (!script.trim()) return;

    const name = directChildText(action, 'Description')
      || directChildText(action, 'Name')
      || directChildText(action, 'ID')
      || `Event Action ${records.length + 1}`;

    records.push({
      path: scenarioScriptPath(fileName, 'Event Actions', name, records.length),
      content: script,
    });
  });

  Array.from(doc.querySelectorAll('SpecialAction')).forEach((action) => {
    const script = scriptTextFromElement(action);
    if (!script.trim()) return;

    const name = directChildText(action, 'Name')
      || directChildText(action, 'Description')
      || directChildText(action, 'ID')
      || `Special Action ${records.length + 1}`;

    records.push({
      path: scenarioScriptPath(fileName, 'Special Actions', name, records.length),
      content: script,
    });
  });

  return records
    .slice(0, SCENARIO_LUA_FILE_LIMIT)
    .map((record, index) => createVirtualLuaFileRecord(record.path, record.content, index));
}

function extractScenarioLuaFilesFromSummary(summary, fileName) {
  const records = [];

  (summary.events || []).forEach((event) => {
    (event.luaScripts || []).forEach((script, scriptIndex) => {
      if (!String(script || '').trim()) return;
      const name = event.name || event.id || `Event ${records.length + 1}`;
      records.push({
        path: scenarioScriptPath(fileName, 'Event Actions', `${name} ${scriptIndex + 1}`, records.length),
        content: script,
      });
    });
  });

  (summary.specialActions || []).forEach((action) => {
    const script = action?.luaScript;
    if (!String(script || '').trim()) return;
    const name = action.name || action.description || action.id || `Special Action ${records.length + 1}`;
    records.push({
      path: scenarioScriptPath(fileName, 'Special Actions', name, records.length),
      content: script,
    });
  });

  return records
    .slice(0, SCENARIO_LUA_FILE_LIMIT)
    .map((record, index) => createVirtualLuaFileRecord(record.path, record.content, index));
}

function normalizeScenarioSummaryObjectContext(summary) {
  const objectContext = summary?.objectContext && typeof summary.objectContext === 'object'
    ? summary.objectContext
    : {};

  const sides = toLimitedNameList(
    objectContext.sides || (summary.sides || []).map((side) => side?.name),
  );
  const units = toLimitedNameList(
    objectContext.units || (summary.activeUnits || []).map((unit) => {
      if (!unit?.name && !unit?.id) return '';
      return [
        unit.name || unit.id,
        unit.side ? `[${unit.side}]` : '',
        unit.kind ? `type=${unit.kind}` : '',
        unit.dbid ? `DBID=${unit.dbid}` : '',
        unit.id ? `ID=${unit.id}` : '',
      ].filter(Boolean).join(' ');
    }),
  );
  const missions = toLimitedNameList(
    objectContext.missions || (summary.missions || []).map((mission) => {
      if (!mission?.name) return '';
      return `${mission.name}${mission.sideName ? ` [${mission.sideName}]` : ''}${mission.kind ? ` (${mission.kind})` : ''}`;
    }),
  );
  const referencePoints = toLimitedNameList(
    objectContext.referencePoints || (summary.referencePoints || []).map((rp) => {
      if (!rp?.name) return '';
      return `${rp.name}${rp.sideName ? ` [${rp.sideName}]` : ''}`;
    }),
  );
  const zones = toLimitedNameList(
    objectContext.zones || (summary.zones || []).map((zone) => {
      if (!zone?.name) return '';
      return `${zone.name}${zone.sideName ? ` [${zone.sideName}]` : ''}${zone.kind ? ` (${zone.kind})` : ''}`;
    }),
  );
  const events = toLimitedNameList(
    (summary.events || []).map((event) => event?.name || event?.id),
  );
  const specialActions = toLimitedNameList(
    objectContext.specialActions || (summary.specialActions || []).map((action) => {
      if (!action?.name) return '';
      return `${action.name}${action.sideName ? ` [${action.sideName}]` : ''}`;
    }),
  );
  const luaFiles = toLimitedNameList(objectContext.luaFiles || []);

  return {
    sides,
    units,
    missions,
    referencePoints,
    zones,
    events,
    specialActions,
    luaFiles,
  };
}

function parseScenarioSummaryObject(summary, fileName) {
  if (!summary || typeof summary !== 'object' || (!summary.scenario && !summary.objectContext)) {
    throw new Error('Not a CMO scenario summary JSON');
  }

  const scenario = summary.scenario || {};
  const extractedObjectContext = normalizeScenarioSummaryObjectContext(summary);
  const extractedCount = countExtractedContext(extractedObjectContext);
  const extractionSummary = extractedCount ? summarizeScenarioExtraction(extractedObjectContext) : '';
  const warnings = Array.isArray(summary.warnings) ? summary.warnings.filter(Boolean) : [];
  const unitCount = summary.unitCounts?.total;
  const extractedLuaFiles = extractScenarioLuaFilesFromSummary(summary, fileName);

  return {
    fileName,
    title: scenario.title || summary.source?.fileName || fileName,
    dbVersion: scenario.dbVersion || '',
    buildNumber: '',
    version: scenario.gameVersion || summary.source?.type || 'scenario summary JSON',
    setting: scenario.setting || '',
    date: scenario.startTime || scenario.zeroHour || '',
    compressedLength: 0,
    decodedBytes: summary.source?.xmlLength || 0,
    extractionSummary,
    extractedObjectContext,
    extractedLuaFiles,
    note: [
      'Claude Task 2 summarizer JSON을 불러왔습니다. Side/Mission/RP/Zone/Unit/Event/SpecialAction 컨텍스트를 Object Registry에 병합할 수 있습니다.',
      extractedLuaFiles.length ? `Lua scripts: ${extractedLuaFiles.length}` : '',
      Number.isFinite(unitCount) ? `Unit total: ${unitCount}` : '',
      warnings.length ? `Warnings: ${warnings.join(' / ')}` : '',
    ].filter(Boolean).join(' '),
  };
}

function parseScenarioSummaryJson(text, fileName) {
  return parseScenarioSummaryObject(JSON.parse(text), fileName);
}

function extractLuaObjectContext(luaFiles) {
  const text = luaFiles.map((file) => file.content).join('\n');
  const collect = (pattern, limit = 40) => uniqueMatches(text, pattern).slice(0, limit);
  const guidRefs = collect(/\b([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\b/gi, 80);
  const sideRefs = collect(/\b(?:side|Side|sideName|side_name)\s*=\s*["']([^"']+)["']/g)
    .concat(collect(/VP_GetSide\s*\(\s*\{\s*Name\s*=\s*["']([^"']+)["']/g))
    .concat(collect(/ScenEdit_SpecialMessage\s*\(\s*["']([^"']+)["']/g));
  const unitRefs = guidRefs
    .concat(collect(/ScenEdit_GetUnit\s*\(\s*\{[^}]*\bname\s*=\s*["']([^"']+)["']/gi))
    .concat(collect(/\b(?:unit|Unit|unitName|unit_name)\s*=\s*["']([^"']+)["']/g));
  const missionRefs = collect(/\b(?:mission|Mission|missionName|mission_name)\s*=\s*["']([^"']+)["']/g)
    .concat(collect(/ScenEdit_SetMission\s*\([^,]+,\s*["']([^"']+)["']/g));
  const rpRefs = collect(/\b(?:referencePoint|ReferencePoint|refpoint|rp|RP|area|Area)\s*=\s*["']([^"']+)["']/g);
  const zoneRefs = collect(/\b(?:zone|Zone|zoneName|zone_name)\s*=\s*["']([^"']+)["']/g)
    .concat(collect(/get(?:no)?navzone\s*\(\s*["']([^"']+)["']\s*\)/gi));
  const eventRefs = collect(/\b(?:event|Event|eventName|event_name)\s*=\s*["']([^"']+)["']/g)
    .concat(collect(/ScenEdit_SetEvent\s*\(\s*["']([^"']+)["']/g));
  const specialActionRefs = collect(/\b(?:specialAction|SpecialAction|actionName|action_name)\s*=\s*["']([^"']+)["']/g);

  return {
    sides: uniqueLines(sideRefs),
    units: uniqueLines(unitRefs),
    missions: uniqueLines(missionRefs),
    referencePoints: uniqueLines(rpRefs),
    zones: uniqueLines(zoneRefs),
    events: uniqueLines(eventRefs),
    specialActions: uniqueLines(specialActionRefs),
    luaFiles: uniqueLines(luaFiles.map((file) => file.path)),
  };
}

function mergeObjectContext(current, extracted) {
  return {
    ...current,
    sides: mergeContextValue(current.sides, extracted.sides),
    units: mergeContextValue(current.units, extracted.units),
    missions: mergeContextValue(current.missions, extracted.missions),
    referencePoints: mergeContextValue(current.referencePoints, extracted.referencePoints),
    zones: mergeContextValue(current.zones, extracted.zones),
    events: mergeContextValue(current.events, extracted.events),
    specialActions: mergeContextValue(current.specialActions, extracted.specialActions),
    luaFiles: mergeContextValue(current.luaFiles, extracted.luaFiles),
  };
}

function countExtractedContext(extracted) {
  return Object.values(extracted || {}).reduce((sum, values) => sum + (Array.isArray(values) ? values.length : 0), 0);
}

function formatLuaBundlePrompt(luaFiles, bundleAnalysis) {
  if (!luaFiles.length) return '';

  const header = [
    '## Lua File Bundle Context',
    `- Lua file count: ${bundleAnalysis.fileCount}`,
    `- Total lines: ${bundleAnalysis.totalLines}`,
    `- Total chars: ${bundleAnalysis.totalChars}`,
    `- Combined APIs: ${bundleAnalysis.apiCalls.join(', ') || '(none detected)'}`,
    `- Combined event helpers: ${bundleAnalysis.eventCalls.join(', ') || '(none detected)'}`,
    `- Combined trigger hints: ${bundleAnalysis.triggerHints.join(', ') || '(none detected)'}`,
    `- Combined DB/Loadout IDs: ${bundleAnalysis.dbIdentifierHints.join(', ') || '(none detected)'}`,
    `- Combined GUIDs: ${bundleAnalysis.guidHints.join(', ') || '(none detected)'}`,
    '',
    '### Per-file analysis',
    ...luaFiles.map((file) => [
      `- ${file.path}`,
      `  - lines=${file.analysis.lineCount}, chars=${file.analysis.charCount}, apis=${file.analysis.apiCalls.join(', ') || '(none)'}`,
      `  - triggers=${[...file.analysis.eventCalls, ...file.analysis.triggerHints].join(', ') || '(none)'}`,
      `  - ids=${[...file.analysis.dbIdentifierHints, ...file.analysis.guidHints].join(', ') || '(none)'}`,
    ].join('\n')),
  ];

  const sources = luaFiles.flatMap((file) => [
    '',
    `### ${file.path}`,
    '```lua',
    truncateForPrompt(file.content),
    '```',
  ]);

  return [...header, ...sources].join('\n');
}

function formatDatabaseContext(databaseContext) {
  const rows = [
    `- Scenario DB: ${databaseContext.dbFamily || '(unknown)'} ${databaseContext.dbVersion || '(version not noted)'}`,
    `- Platform DBID: ${databaseContext.platformDbid || '(not provided)'}`,
    `- Loadout ID: ${databaseContext.loadoutId || '(not provided)'}`,
    `- Weapon DBID: ${databaseContext.weaponDbid || '(not provided)'}`,
    `- Sensor DBID: ${databaseContext.sensorDbid || '(not provided)'}`,
    `- Mount DBID: ${databaseContext.mountDbid || '(not provided)'}`,
    `- Scenario unit GUID: ${databaseContext.unitGuid || '(not provided)'}`,
  ];

  if (databaseContext.notes.trim()) {
    rows.push(`- Notes: ${databaseContext.notes.trim()}`);
  }

  return rows.join('\n');
}

function inferDatabaseFromScenario(dbVersion) {
  const text = String(dbVersion || '');
  const versionMatch = text.match(/(\d{3,4})/);
  const dbFamily = /CWDB/i.test(text) ? 'CWDB' : /DB3K|DB3000/i.test(text) ? 'DB3000' : '';

  return {
    dbFamily,
    dbVersion: versionMatch ? `v${versionMatch[1]}` : text,
  };
}

function estimateBase64ByteLength(value) {
  const compact = String(value || '').replace(/\s+/g, '');
  if (!compact) return 0;
  const padding = compact.endsWith('==') ? 2 : compact.endsWith('=') ? 1 : 0;
  return Math.max(0, Math.floor((compact.length * 3) / 4) - padding);
}

function decodeXmlEntities(value = '') {
  return String(value || '')
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, '&')
    .replace(/&#(\d+);/g, (_, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCodePoint(Number.parseInt(code, 16)));
}

function readScenarioTagText(text, tagName) {
  const match = new RegExp(`<${tagName}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i').exec(text);
  return match ? decodeXmlEntities(match[1].trim()) : '';
}

function readFirstScenarioTagText(text, tagNames) {
  for (const tagName of tagNames) {
    const value = readScenarioTagText(text, tagName);
    if (value) return value;
  }
  return '';
}

function estimateCompressedFromWrapper(text, fileSize = 0) {
  const openMatch = /<Scenario_Compressed(?:\s[^>]*)?>/i.exec(text);
  if (!openMatch) {
    return { present: false, base64Chars: 0, estimatedBytes: 0 };
  }

  const contentStart = openMatch.index + openMatch[0].length;
  const closeIndex = text.search(/<\/Scenario_Compressed>/i);
  if (closeIndex > contentStart) {
    const rawLength = text.slice(contentStart, closeIndex).replace(/\s+/g, '').length;
    return {
      present: true,
      base64Chars: rawLength,
      estimatedBytes: Math.max(0, Math.floor((rawLength * 3) / 4)),
    };
  }

  const approximateChars = Math.max(0, (Number(fileSize) || text.length) - contentStart);
  return {
    present: true,
    base64Chars: approximateChars,
    estimatedBytes: Math.max(0, Math.floor((approximateChars * 3) / 4)),
  };
}

function emptyScenarioObjectContext() {
  return {
    sides: [],
    units: [],
    missions: [],
    referencePoints: [],
    zones: [],
    events: [],
    specialActions: [],
    luaFiles: [],
  };
}

function parseScenarioWrapperMetadata(text, fileName, fileSize = 0) {
  const compressed = estimateCompressedFromWrapper(text, fileSize);
  return {
    fileName,
    title: readFirstScenarioTagText(text, ['ScenTitle', 'Title']) || fileName.replace(/\.[^.]+$/, ''),
    dbVersion: readScenarioTagText(text, 'DBVersion'),
    buildNumber: readScenarioTagText(text, 'BuildNumber'),
    version: readScenarioTagText(text, 'Version'),
    setting: readFirstScenarioTagText(text, ['ScenSetting', 'Meta_ScenSetting']),
    date: readScenarioTagText(text, 'ScenDate'),
    compressedLength: compressed.base64Chars,
    decodedBytes: compressed.estimatedBytes,
    extractionSummary: '',
    extractedObjectContext: emptyScenarioObjectContext(),
    extractedLuaFiles: [],
    note: compressed.present
      ? '시나리오의 기본 정보만 읽었습니다. 내부 스크립트와 이벤트를 보려면 prepare:scenario 공통 명령으로 sidecar를 생성하거나 기존 summary sidecar를 자동 연결해야 합니다.'
      : 'Scenario_Compressed 블록이 감지되지 않았습니다. 작은 XML 컨테이너만 메타데이터 모드로 읽었습니다.',
  };
}

function parseScenarioContainer(text, fileName) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(text, 'application/xml');
  const parserError = doc.querySelector('parsererror');

  if (parserError) {
    throw new Error('XML parser error');
  }

  const read = (tagName) => doc.querySelector(tagName)?.textContent?.trim() || '';
  const compressed = read('Scenario_Compressed');
  const extractedObjectContext = compressed ? emptyScenarioObjectContext() : parseInternalScenarioObjectContext(doc);
  const extractedCount = countExtractedContext(extractedObjectContext);
  const extractionSummary = extractedCount ? summarizeScenarioExtraction(extractedObjectContext) : '';
  const extractedLuaFiles = compressed ? [] : extractScenarioLuaFilesFromXml(doc, fileName);

  return {
    fileName,
    title: readFirstTag(doc, ['ScenTitle', 'Title']),
    dbVersion: read('DBVersion'),
    buildNumber: read('BuildNumber'),
    version: read('Version'),
    setting: readFirstTag(doc, ['ScenSetting', 'Meta_ScenSetting']),
    date: read('ScenDate'),
    compressedLength: compressed.length,
    decodedBytes: estimateBase64ByteLength(compressed),
    extractionSummary,
    extractedObjectContext,
    extractedLuaFiles,
    note: compressed
      ? 'Scenario_Compressed 블록이 감지되었습니다. CMO 엔진 기반 디코더 도구는 준비되어 있으며, 현재 브라우저 .scen 읽기는 보안상 컨테이너 메타데이터만 반영합니다. 내부 이벤트/Lua/Side는 npm run prepare:scenario 공통 명령으로 생성한 summary sidecar와 결합해 가져옵니다.'
      : extractedCount
        ? `내부 Scenario XML에서 객체 컨텍스트를 자동 추출했습니다. ${extractionSummary}${extractedLuaFiles.length ? ` / Lua scripts ${extractedLuaFiles.length}` : ''}`
        : 'Scenario_Compressed 블록이 없습니다. 텍스트 XML 범위에서만 분석됩니다.',
  };
}

function scenarioSidecarCandidateUrls(fileName, title = '') {
  const fileSlug = buildScenarioSlug(fileName);
  const titleSlug = buildScenarioSlug(title);
  const slugs = uniqueLines([
    fileSlug,
    String(fileName || '').replace(/\.[^.]+$/, '').toLowerCase(),
    titleSlug,
  ]);
  const exactXmlName = buildScenarioXmlName(fileName);

  return [...new Set([
    ...SCENARIO_SIDECAR_BASE_PATHS.flatMap((basePath) => slugs.flatMap((slug) => [
      `${basePath}/${slug}.summary.json`,
      `${basePath}/${slug}.scenario.xml`,
      `${basePath}/${slug}.json`,
    ])),
    ...SCENARIO_SIDECAR_BASE_PATHS.map((basePath) => `${basePath}/${exactXmlName}`),
  ])];
}

function findScenarioOpenabilityRecord(index, fileName, title = '') {
  const scenarios = Array.isArray(index?.scenarios) ? index.scenarios : [];
  if (!scenarios.length) return null;

  const fileSlug = buildScenarioSlug(fileName);
  const titleSlug = buildScenarioSlug(title);
  const lowerFileName = String(fileName || '').toLowerCase();
  const lowerFileBase = String(fileName || '').replace(/\.[^.]+$/, '').toLowerCase();
  const exactFileSlugs = new Set([fileSlug, lowerFileBase].filter(Boolean));
  const exactFileNames = new Set([lowerFileName].filter(Boolean));

  const exactFileMatch = scenarios.find((scenario) => {
    const recordValues = [
      scenario.slug,
      scenario.fileName,
      scenario.scenarioPath?.split(/[\\/]/).pop(),
    ].filter(Boolean);
    return recordValues.some((value) => exactFileSlugs.has(buildScenarioSlug(value)) || exactFileNames.has(String(value).toLowerCase()));
  });

  if (exactFileMatch) return exactFileMatch;

  if (!titleSlug || titleSlug !== fileSlug) return null;

  return scenarios.find((scenario) => buildScenarioSlug(scenario.title) === titleSlug) || null;
}

async function fetchScenarioOpenabilityRecord(fileName, title = '') {
  if (typeof fetch !== 'function') return null;

  for (const url of SCENARIO_OPENABILITY_INDEX_URLS) {
    try {
      const response = await fetch(url, { cache: 'no-store' });
      if (!response.ok) continue;
      const index = await response.json();
      const record = findScenarioOpenabilityRecord(index, fileName, title);
      if (record) return record;
    } catch {
      // Some launch modes may not expose every sidecar alias. Try the next one.
    }
  }

  return null;
}

function parseScenarioSidecarText(text, fileName) {
  return fileName.toLowerCase().endsWith('.json')
    ? parseScenarioSummaryJson(text, fileName)
    : parseScenarioContainer(text, fileName);
}

async function fetchScenarioSidecar(fileName, title = '') {
  if (typeof fetch !== 'function') return null;

  for (const url of scenarioSidecarCandidateUrls(fileName, title)) {
    try {
      const response = await fetch(url, { cache: 'no-store' });
      if (!response.ok) continue;

      const isXmlSidecar = /\.xml$/i.test(url);
      const expectedLength = Number(response.headers.get('content-length') || 0);
      if (isXmlSidecar && expectedLength > SCENARIO_XML_SIDECAR_CHAR_LIMIT) {
        // Large internal XML can lock the browser. Prefer the summarizer JSON sidecar.
        continue;
      }

      const text = await response.text();
      if (isXmlSidecar && text.length > SCENARIO_XML_SIDECAR_CHAR_LIMIT) {
        continue;
      }

      const sidecarName = url.split('/').pop() || url;
      const parsed = parseScenarioSidecarText(text, sidecarName);
      const extractedCount = countExtractedContext(parsed.extractedObjectContext || {});
      const luaCount = parsed.extractedLuaFiles?.length || 0;

      if (!extractedCount && !luaCount) continue;

      return {
        ...parsed,
        sidecarFileName: sidecarName,
        sidecarUrl: url,
      };
    } catch {
      // Some public JSON files are metadata-only. Try the next candidate.
    }
  }

  return null;
}

async function fetchTransientScenarioSidecar(file) {
  if (!file || !file.name?.toLowerCase().endsWith('.scen')) return null;

  const result = await openScenarioTransient(file);
  if (!result?.ok || !result.summary) return null;

  const parsed = parseScenarioSummaryObject(result.summary, `${file.name} (transient)`);
  const extractedCount = countExtractedContext(parsed.extractedObjectContext || {});
  const luaCount = parsed.extractedLuaFiles?.length || 0;
  if (!extractedCount && !luaCount) return null;

  return {
    ...parsed,
    fileName: file.name,
    sidecarFileName: '임시 메모리 summary',
    sidecarUrl: 'adapter://scenario/transient-open',
    openabilityStatus: 'readyWithInternalSidecar',
    note: [
      parsed.note,
      '임시 열기: summary JSON을 메모리에서 생성했고 임시 파일은 정리되었습니다.',
    ].filter(Boolean).join(' '),
  };
}

function mergeScenarioWithSidecar(baseScenario, sidecarScenario) {
  if (!sidecarScenario) return baseScenario;

  const sidecarNote = [
    `Sidecar 연결: ${sidecarScenario.sidecarFileName || sidecarScenario.fileName}.`,
    sidecarScenario.extractionSummary ? `컨텍스트: ${sidecarScenario.extractionSummary}.` : '',
    sidecarScenario.extractedLuaFiles?.length ? `Lua scripts: ${sidecarScenario.extractedLuaFiles.length}.` : '',
  ].filter(Boolean).join(' ');

  return {
    ...baseScenario,
    title: baseScenario.title || sidecarScenario.title,
    dbVersion: baseScenario.dbVersion || sidecarScenario.dbVersion,
    buildNumber: baseScenario.buildNumber || sidecarScenario.buildNumber,
    version: baseScenario.version || sidecarScenario.version,
    setting: baseScenario.setting || sidecarScenario.setting,
    date: baseScenario.date || sidecarScenario.date,
    decodedBytes: Math.max(baseScenario.decodedBytes || 0, sidecarScenario.decodedBytes || 0),
    extractionSummary: sidecarScenario.extractionSummary || baseScenario.extractionSummary,
    extractedObjectContext: sidecarScenario.extractedObjectContext || baseScenario.extractedObjectContext,
    extractedLuaFiles: sidecarScenario.extractedLuaFiles || baseScenario.extractedLuaFiles || [],
    sidecarFileName: sidecarScenario.sidecarFileName || sidecarScenario.fileName,
    sidecarUrl: sidecarScenario.sidecarUrl || '',
    openabilityStatus: baseScenario.openabilityStatus || 'readyWithInternalSidecar',
    note: [baseScenario.note, sidecarNote].filter(Boolean).join(' '),
  };
}

function mergeScenarioWithOpenabilityRecord(baseScenario, record) {
  if (!record) return baseScenario;

  const openabilityNote = [
    `Openability: ${record.status}.`,
    record.status === 'metadataOnlyNeedsDecoder'
      ? '이 시나리오는 정상 파일이지만 브라우저 단독으로는 내부 압축 본문을 풀 수 없어 디코더 산출물이 필요합니다.'
      : '',
    record.status === 'decoderFailed'
      ? `이 시나리오는 디코더가 내부 XML을 복원하지 못한 항목입니다${record.lastAttempt?.code ? ` (${record.lastAttempt.code})` : ''}.`
      : '',
    record.scenarioPath ? `Source: ${record.scenarioPath}.` : '',
  ].filter(Boolean).join(' ');

  return {
    ...baseScenario,
    openabilityStatus: record.status || baseScenario.openabilityStatus || '',
    sourcePath: record.scenarioPath || baseScenario.sourcePath || '',
    decoderCommands: record.commands || baseScenario.decoderCommands || {},
    lastDecoderAttempt: record.lastAttempt || baseScenario.lastDecoderAttempt || null,
    note: [baseScenario.note, openabilityNote].filter(Boolean).join(' '),
  };
}

function formatScenarioContext(scenarioContext) {
  if (!scenarioContext?.fileName) {
    return '- Scenario file: (not loaded)';
  }

  return [
    `- Scenario file: ${scenarioContext.fileName}`,
    `- Title: ${scenarioContext.title || '(unknown)'}`,
    `- DBVersion: ${scenarioContext.dbVersion || '(unknown)'}`,
    `- Build: ${scenarioContext.buildNumber || scenarioContext.version || '(unknown)'}`,
    `- Setting/Date: ${[scenarioContext.setting, scenarioContext.date].filter(Boolean).join(' / ') || '(not noted)'}`,
    `- Compressed payload: ${scenarioContext.compressedLength ? `${scenarioContext.compressedLength} base64 chars, about ${scenarioContext.decodedBytes} bytes decoded` : '(none detected)'}`,
    `- Openability: ${scenarioContext.openabilityStatus || '(not indexed)'}`,
    `- Source path: ${scenarioContext.sourcePath || '(not indexed)'}`,
    `- Sidecar: ${scenarioContext.sidecarFileName || '(none loaded)'}`,
    `- Extracted context: ${scenarioContext.extractionSummary || '(none)'}`,
    `- Note: ${scenarioContext.note || '(none)'}`,
  ].join('\n');
}

function scenarioOpenabilityLabel(status) {
  if (status === 'readyWithInternalSidecar') return '내부 컨텍스트 준비됨';
  if (status === 'metadataOnlyNeedsDecoder') return '압축 해제 필요';
  if (status === 'decoderFailed') return '레거시 디코더 제한';
  if (status === 'plainXmlReadable') return 'XML 직접 읽기 가능';
  if (status === 'readError') return '읽기 확인 필요';
  return '인덱스 미확인';
}

function scenarioOpenabilityDescription(scenarioContext) {
  const status = scenarioContext?.openabilityStatus;
  if (status === 'readyWithInternalSidecar') {
    return '이미 XML/summary sidecar가 있어 Side, Mission, Event, Lua 컨텍스트를 자동 연결할 수 있습니다.';
  }
  if (status === 'metadataOnlyNeedsDecoder') {
    return '시나리오의 기본 정보만 읽었습니다. 내부 스크립트와 이벤트를 보려면 prepare:scenario 공통 명령으로 sidecar를 생성해야 합니다.';
  }
  if (status === 'decoderFailed') {
    const code = scenarioContext?.lastDecoderAttempt?.code;
    return code === 'decoderLegacyCmano'
      ? '구형 CMANO 시나리오 형식이라 현대 CMO 디코더가 내부 XML을 복원하지 못했습니다. 원본은 수정하지 않으며, 배치 준비에서는 자동 재시도하지 않습니다.'
      : '이전 디코더 실행에서 내부 XML 추출 실패가 기록되었습니다. 상세 진단 파일을 확인한 뒤 필요할 때만 재시도하세요.';
  }
  if (status === 'plainXmlReadable') {
    return '압축 본문 없이 XML을 직접 읽을 수 있는 시나리오입니다.';
  }
  if (status === 'readError') {
    return '전수조사 단계에서 읽기 오류가 감지된 항목입니다. 원본 경로와 파일 상태 확인이 필요합니다.';
  }
  if (scenarioContext?.compressedLength > 0) {
    return '전수조사 인덱스가 없으면 브라우저는 압축 컨테이너 메타데이터만 표시합니다.';
  }
  return '시나리오 파일을 열면 여기에서 로딩 상태와 다음 작업을 확인합니다.';
}

function summarizeScenarioInspectorCounts(scenarioContext) {
  const extracted = scenarioContext?.extractedObjectContext || {};
  return {
    sides: extracted.sides?.length || 0,
    missions: extracted.missions?.length || 0,
    units: extracted.units?.length || 0,
    events: extracted.events?.length || 0,
    specialActions: extracted.specialActions?.length || 0,
    luaScripts: scenarioContext?.extractedLuaFiles?.length || extracted.luaFiles?.length || 0,
  };
}

function buildScenarioInspectorSteps(scenarioContext) {
  const contextCount = countExtractedContext(scenarioContext?.extractedObjectContext || {});
  const luaCount = scenarioContext?.extractedLuaFiles?.length || 0;
  const hasSidecar = Boolean(scenarioContext?.sidecarFileName);
  const hasDecodedContext = Boolean(contextCount || luaCount);

  return [
    {
      label: '.scen 메타 읽기',
      done: Boolean(scenarioContext?.fileName),
      detail: scenarioContext?.fileName || '아직 시나리오 파일이 없습니다.',
    },
    {
      label: '전수조사 인덱스 매칭',
      done: Boolean(scenarioContext?.openabilityStatus || scenarioContext?.sourcePath),
      detail: scenarioContext?.openabilityStatus || 'scenario-openability-index.json에 매칭된 항목 없음',
    },
    {
      label: '내부 XML/summary sidecar',
      done: hasSidecar,
      detail: hasSidecar ? scenarioContext.sidecarFileName : 'sidecar가 없으면 adapter 임시 열기 또는 prepare:scenario 명령이 필요합니다.',
    },
    {
      label: 'Object/Lua 컨텍스트 적용',
      done: hasDecodedContext,
      detail: hasDecodedContext ? `${contextCount} context items / ${luaCount} Lua scripts` : 'sidecar 또는 임시 메모리 summary를 연결한 뒤 다시 확인하세요.',
    },
  ];
}

function buildObjectContextSummary(objectContext) {
  return [
    `- Sides: ${splitContextLines(objectContext.sides).join(', ') || '(not provided)'}`,
    `- Units / GUIDs: ${splitContextLines(objectContext.units).join(', ') || '(not provided)'}`,
    `- Missions: ${splitContextLines(objectContext.missions).join(', ') || '(not provided)'}`,
    `- Reference Points: ${splitContextLines(objectContext.referencePoints).join(', ') || '(not provided)'}`,
    `- Zones: ${splitContextLines(objectContext.zones).join(', ') || '(not provided)'}`,
    `- Events: ${splitContextLines(objectContext.events).join(', ') || '(not provided)'}`,
    `- Special Actions: ${splitContextLines(objectContext.specialActions).join(', ') || '(not provided)'}`,
    `- Lua files: ${splitContextLines(objectContext.luaFiles).join(', ') || '(not provided)'}`,
    `- Notes: ${objectContext.notes.trim() || '(none)'}`,
  ].join('\n');
}

function buildSmokeTest(databaseContext) {
  const lines = [
    '-- CMO Lua Console smoke-test helper',
    `print("DB context noted by user: ${databaseContext.dbFamily || 'unknown'} ${databaseContext.dbVersion || 'unknown'}")`,
  ];

  if (databaseContext.unitGuid.trim()) {
    const unitRef = databaseContext.unitGuid.trim();
    const lookupKey = isGuid(unitRef) ? 'guid' : 'name';
    lines.push(`local unit = ScenEdit_GetUnit({ ${lookupKey} = "${unitRef}" })`);
    lines.push('print(unit and ("UNIT OK: " .. unit.name .. " / " .. unit.guid) or "UNIT NOT FOUND")');
  } else {
    lines.push('-- local unit = ScenEdit_GetUnit({ guid = "paste copied unit GUID here" })');
  }

  if (databaseContext.platformDbid.trim()) {
    lines.push(`print("Platform DBID from Database Viewer: ${databaseContext.platformDbid.trim()}")`);
  }

  if (databaseContext.loadoutId.trim()) {
    lines.push(`print("Loadout ID from Database Viewer: ${databaseContext.loadoutId.trim()}")`);
    lines.push('-- ScenEdit_SetLoadout 변경은 실제 적용 명령이므로 테스트 후 필요한 경우에만 별도 실행하세요.');
  }

  return lines.join('\n');
}

function buildDatabaseWarnings(databaseContext, analysis) {
  const warnings = [];
  const hasDbDrivenLua = analysis.dbIdentifierHints.length > 0
    || /\b(?:ScenEdit_AddUnit|ScenEdit_SetLoadout|loadoutid|LoadoutID)\b/.test(databaseContext.notes);

  if ((analysis.dbIdentifierHints.length > 0 || databaseContext.platformDbid || databaseContext.loadoutId) && !databaseContext.dbVersion.trim()) {
    warnings.push('DBID/Loadout ID가 있는데 DB 버전이 비어 있습니다. DB3000 v516 또는 CWDB v516처럼 현재 시나리오 DB를 기록하세요.');
  }
  if (databaseContext.loadoutId.trim() && !databaseContext.platformDbid.trim()) {
    warnings.push('Loadout ID는 플랫폼/DB 조합에 종속됩니다. 가능하면 항공기/플랫폼 DBID도 함께 기록하세요.');
  }
  if (databaseContext.unitGuid.trim() && !isGuid(databaseContext.unitGuid)) {
    warnings.push('유닛 ID 입력값이 표준 GUID 형식이 아닙니다. 이름 참조라면 CMO에서 같은 이름이 중복되지 않는지 확인하세요.');
  }
  if (hasDbDrivenLua && !databaseContext.dbFamily.trim()) {
    warnings.push('DB 계열이 비어 있습니다. DB3000과 CWDB는 같은 숫자 ID라도 의미가 달라질 수 있습니다.');
  }

  return warnings;
}

function classifyChip(value) {
  const text = String(value || '');

  if (/없음|none detected|not provided/i.test(text)) return 'chip-muted';
  if (isGuid(text) || /\bguid\b/i.test(text)) return 'chip-guid';
  if (/^\d{2,}$/.test(text) || /\b(?:dbid|loadout|database)\b/i.test(text)) return 'chip-db';
  if (/\b(?:Event|Trigger|Condition|Action|RegularTime|UnitDetected|UnitDestroyed|UnitDamaged|Points|Time|UnitRemainsInArea)\b/.test(text)) return 'chip-event';
  if (/^(?:ScenEdit|VP_|Tool_|World|Unit|Mission|Side)/.test(text)) return 'chip-api';
  return 'chip-asset';
}

function classifyPreviewTone(text, tabId) {
  if (tabId === 'prompt') return 'tone-prompt';
  if (tabId === 'setup') return 'tone-event';
  if (tabId === 'smoke') return 'tone-db';
  if (/\b(?:DBID|loadoutid|ScenEdit_SetLoadout|ScenEdit_AddUnit)\b/i.test(text)) return 'tone-db';
  if (/\b(?:ScenEdit_AssignUnitToMission|ScenEdit_SetMission|Mission)\b/.test(text)) return 'tone-mission';
  if (/\b(?:ScenEdit_RunScript|\.lua)\b/i.test(text)) return 'tone-script';
  if (/\b(?:ScenEdit_SetKeyValue|ScenEdit_GetKeyValue|Trigger|Event)\b/.test(text)) return 'tone-event';
  return 'tone-api';
}

function buildAutoHelperHints({ analysis, databaseWarnings, objectContext, databaseContext, intent }) {
  const apiText = analysis.apiCalls.join(' ');
  const hints = [];
  const pushHint = (type, title, body) => {
    if (!hints.some((hint) => hint.title === title)) {
      hints.push({ type, title, body });
    }
  };

  if (!analysis.apiCalls.length) {
    pushHint(
      'helper-muted',
      'Lua API 감지 대기',
      'Lua를 붙여넣거나 직접 입력하면 ScenEdit/VP/World 계열 호출을 기준으로 완성 방향을 제안합니다.',
    );
  }

  if (/ScenEdit_GetUnit/.test(apiText) || splitContextLines(objectContext.units).length || databaseContext.unitGuid.trim()) {
    pushHint(
      'helper-asset',
      'Unit 참조 보강',
      'GUID 우선 조회, Side+Name 보조 조회, nil 체크 후 실행 순서로 구성하면 CMO 엔진 오류를 줄일 수 있습니다.',
    );
  }

  if (/ScenEdit_AssignUnitToMission|ScenEdit_SetMission/.test(apiText) || intent.actionType.includes('mission')) {
    pushHint(
      'helper-mission',
      'Mission 동작 완성',
      'Mission 이름은 CMO Mission Editor에서 만든 정확한 이름을 쓰고, 유닛 조회 성공 후 Assign/Activate를 실행하는 형태가 안전합니다.',
    );
  }

  if (/ScenEdit_SetLoadout|ScenEdit_AddUnit|loadout/i.test(apiText) || databaseContext.loadoutId.trim()) {
    pushHint(
      'helper-db',
      'DBID / Loadout 검증',
      'Platform DBID와 Loadout ID는 현재 시나리오 DB 버전 조합으로 확인해야 하며, 숫자는 tonumber 처리 후 적용하는 편이 좋습니다.',
    );
  }

  if (/ScenEdit_SetKeyValue|ScenEdit_GetKeyValue/.test(apiText) || intent.repeatMode === 'one_shot') {
    pushHint(
      'helper-event',
      '반복 실행 보호',
      'KeyValue guard를 Event 이름 기반 키로 만들고, 성공 지점에서만 SetKeyValue를 호출하면 중복 실행을 막기 쉽습니다.',
    );
  }

  if (analysis.eventCalls.length || analysis.triggerHints.length) {
    pushHint(
      'helper-trigger',
      'Trigger / Event 분리',
      'Trigger와 Condition은 CMO Event Editor UI로 만들고, Lua Action은 실제 조치만 담당하게 나누면 디버깅이 쉬워집니다.',
    );
  }

  if (databaseWarnings.length) {
    pushHint(
      'helper-risk',
      '먼저 확인할 위험 신호',
      databaseWarnings[0],
    );
  }

  return hints.slice(0, 6);
}

function buildEventPlan({ objectContext, intent, databaseContext }) {
  const sides = splitContextLines(objectContext.sides);
  const units = splitContextLines(objectContext.units);
  const missions = splitContextLines(objectContext.missions);
  const rps = splitContextLines(objectContext.referencePoints);
  const zones = splitContextLines(objectContext.zones);
  const luaFiles = splitContextLines(objectContext.luaFiles);
  const hasUnitRef = units.length > 0 || databaseContext.unitGuid.trim();
  const setupItems = [
    `현재 시나리오 DB가 ${databaseContext.dbFamily || 'DB 계열 미기록'} ${databaseContext.dbVersion || '버전 미기록'}인지 CMO Database Viewer에서 확인합니다.`,
    'CMO Event Editor에서 Trigger/Condition은 가능한 한 내부 UI로 만들고, Action은 Lua Script로 연결합니다.',
  ];
  const missingFields = [];

  if (sides.length) {
    setupItems.push(`Side 이름 확인: ${sides.join(', ')}`);
  } else {
    missingFields.push('Side 이름이 비어 있습니다.');
  }

  if (intent.actionType.includes('mission') && missions.length) {
    setupItems.push(`Mission 이름 확인: ${missions.join(', ')}`);
  } else if (intent.actionType.includes('mission')) {
    missingFields.push('Mission 기반 동작인데 Mission 이름이 비어 있습니다.');
  }

  if ((intent.actionType === 'mission_assign' || intent.actionType === 'loadout_scramble') && !hasUnitRef) {
    missingFields.push('유닛 조작 동작인데 Unit GUID/이름이 비어 있습니다.');
  }

  if (intent.actionType === 'loadout_scramble' && !databaseContext.loadoutId.trim()) {
    missingFields.push('Loadout 변경 동작인데 Loadout ID가 비어 있습니다.');
  }

  if (intent.triggerType === 'unit_enters_area' && !rps.length) {
    missingFields.push('Area/RP 트리거인데 Reference Point 이름이 비어 있습니다.');
  }

  if (intent.actionType === 'zone_toggle' && !zones.length) {
    missingFields.push('Zone 제어 동작인데 Zone 이름이 비어 있습니다.');
  }

  if (intent.actionType === 'run_script' && !luaFiles.length) {
    missingFields.push('RunScript 동작인데 .lua 파일 경로가 비어 있습니다.');
  }

  return {
    setupItems,
    eventSteps: [
      `Event 이름: ${intent.eventName || 'AI_Assisted_Event'}`,
      `Trigger 방식: ${optionLabel(TRIGGER_TYPES, intent.triggerType)}`,
      `Action 방식: ${optionLabel(ACTION_TYPES, intent.actionType)}`,
      `반복 정책: ${intent.repeatMode === 'one_shot' ? 'KeyValue로 1회 실행 보호' : '반복 실행 허용'}`,
      '생성 Lua는 CMO Event Editor의 Lua Script Action 또는 Lua Script Console 테스트용으로 사용합니다.',
    ],
    missingFields,
  };
}

function buildGeneratedLua({ objectContext, intent, databaseContext }) {
  const sides = splitContextLines(objectContext.sides);
  const units = splitContextLines(objectContext.units);
  const missions = splitContextLines(objectContext.missions);
  const zones = splitContextLines(objectContext.zones);
  const luaFiles = splitContextLines(objectContext.luaFiles);
  const unitRefs = [...units];
  const copiedUnit = databaseContext.unitGuid.trim();

  if (copiedUnit && !unitRefs.includes(copiedUnit)) {
    unitRefs.unshift(copiedUnit);
  }

  const side = intent.playerSide.trim() || sides[0] || 'Blue';
  const mission = missions[0] || 'Mission Name';
  const eventName = intent.eventName.trim() || 'AI_Assisted_Event';
  const oneShotKey = intent.oneShotKey.trim() || `${safeLuaName(eventName)}_done`;
  const loadoutId = databaseContext.loadoutId.trim();
  const messageText = intent.actionDetail.trim() || intent.summary.trim() || 'AI-assisted CMO event executed.';
  const body = [
    '-- Generated by CMO Lua Assistant',
    `-- Event: ${eventName}`,
    `-- Trigger: ${optionLabel(TRIGGER_TYPES, intent.triggerType)}`,
    `-- Action: ${optionLabel(ACTION_TYPES, intent.actionType)}`,
    `-- DB: ${databaseContext.dbFamily || 'unknown'} ${databaseContext.dbVersion || 'unknown'}`,
    `-- Intent: ${intent.summary || 'No summary provided.'}`,
  ];

  if (intent.condition.trim()) {
    body.push(`-- Condition / operator note: ${intent.condition.trim()}`);
  }

  body.push('', 'local __should_run = true');

  if (intent.repeatMode === 'one_shot') {
    body.push(`local __key = ${luaQuote(oneShotKey)}`);
    body.push('if ScenEdit_GetKeyValue(__key) == "1" then');
    body.push(`    print("SKIP: " .. ${luaQuote(eventName)} .. " already executed")`);
    body.push('    __should_run = false');
    body.push('end');
  }

  body.push('', 'if __should_run then');

  if (intent.actionType === 'mission_assign') {
    body.push(`    local units = ${luaArray(unitRefs, 'Paste copied unit GUID here')}`);
    body.push(`    local mission = ${luaQuote(mission)}`);
    body.push('    for _, unit_id in ipairs(units) do');
    body.push('        local unit = ScenEdit_GetUnit({ guid = unit_id })');
    body.push(`        if not unit then unit = ScenEdit_GetUnit({ side = ${luaQuote(side)}, name = unit_id }) end`);
    body.push('        if not unit then unit = ScenEdit_GetUnit({ name = unit_id }) end');
    body.push('        if unit then');
    body.push('            ScenEdit_AssignUnitToMission(unit.guid, mission)');
    body.push('            print("ASSIGNED: " .. unit.name .. " -> " .. mission)');
    body.push('        else');
    body.push('            print("WARNING: unit not found: " .. tostring(unit_id))');
    body.push('        end');
    body.push('    end');
  } else if (intent.actionType === 'loadout_scramble') {
    body.push(`    local units = ${luaArray(unitRefs, 'Paste copied unit GUID here')}`);
    body.push(`    local mission = ${luaQuote(mission)}`);
    body.push(`    local loadout_id = tonumber(${luaQuote(loadoutId)}) or 0`);
    body.push('    for _, unit_id in ipairs(units) do');
    body.push('        local unit = ScenEdit_GetUnit({ guid = unit_id })');
    body.push(`        if not unit then unit = ScenEdit_GetUnit({ side = ${luaQuote(side)}, name = unit_id }) end`);
    body.push('        if not unit then unit = ScenEdit_GetUnit({ name = unit_id }) end');
    body.push('        if unit then');
    body.push('            if loadout_id > 0 then');
    body.push('                ScenEdit_SetLoadout({ unitName = unit.guid, loadoutid = loadout_id, TimeToReady_Minutes = 0 })');
    body.push('            else');
    body.push('                print("WARNING: Loadout ID is missing; loadout unchanged for " .. unit.name)');
    body.push('            end');
    body.push('            if mission ~= "" then ScenEdit_AssignUnitToMission(unit.guid, mission) end');
    body.push('            print("SCRAMBLE READY: " .. unit.name)');
    body.push('        else');
    body.push('            print("WARNING: unit not found: " .. tostring(unit_id))');
    body.push('        end');
    body.push('    end');
  } else if (intent.actionType === 'mission_toggle') {
    body.push(`    local side = ${luaQuote(side)}`);
    body.push(`    local missions = ${luaArray(missions, 'Mission Name')}`);
    body.push('    for _, mission_name in ipairs(missions) do');
    body.push('        ScenEdit_SetMission(side, mission_name, { isactive = true })');
    body.push('        print("MISSION ACTIVE: " .. mission_name)');
    body.push('    end');
  } else if (intent.actionType === 'zone_toggle') {
    body.push(`    local side_name = ${luaQuote(side)}`);
    body.push(`    local zones = ${luaArray(zones, 'Zone Name')}`);
    body.push('    local side_obj = VP_GetSide({ Name = side_name })');
    body.push('    for _, zone_name in ipairs(zones) do');
    body.push('        local zone = side_obj and side_obj:getnonavzone(zone_name)');
    body.push('        if zone then');
    body.push('            zone.isactive = true');
    body.push('            print("ZONE ACTIVE: " .. zone_name)');
    body.push('        else');
    body.push('            print("WARNING: No-Nav zone not found: " .. tostring(zone_name))');
    body.push('        end');
    body.push('    end');
  } else if (intent.actionType === 'run_script') {
    body.push(`    local script_path = ${luaQuote(luaFiles[0] || '/ScenarioFolder/Script.lua')}`);
    body.push('    local ok = ScenEdit_RunScript(script_path)');
    body.push('    print(ok and ("RUNSCRIPT OK: " .. script_path) or ("RUNSCRIPT FAILED: " .. script_path))');
  } else if (intent.actionType === 'score_keyvalue') {
    body.push(`    local side = ${luaQuote(side)}`);
    body.push(`    local key = ${luaQuote(oneShotKey)}`);
    body.push('    ScenEdit_SetKeyValue(key, "1")');
    body.push(`    ScenEdit_SpecialMessage(side, ${luaQuote(messageText)})`);
  } else if (intent.actionType === 'custom_lua') {
    body.push('    -- Custom Lua body from Intent Planner');
    body.push(...(intent.actionDetail.trim() ? intent.actionDetail.split(/\r?\n/).map((line) => `    ${line}`) : ['    -- 여기에 사용자 정의 Lua를 입력하세요.']));
  } else {
    body.push(`    ScenEdit_SpecialMessage(${luaQuote(side)}, ${luaQuote(messageText)})`);
  }

  if (intent.repeatMode === 'one_shot') {
    body.push('    ScenEdit_SetKeyValue(__key, "1")');
  }

  body.push('end');
  return body.join('\n');
}

function buildUiSetupText({ objectContext, intent, databaseContext }) {
  const plan = buildEventPlan({ objectContext, intent, databaseContext });
  return [
    'CMO UI setup checklist',
    '',
    'AI에게 요청하기 전 확인사항',
    '- DB 버전 확인: 로드된 시나리오가 현재 CMO 엔진의 DB(DB3K/CWDB)와 일치하는지 확인합니다.',
    '- 고유 이름 복사: Side, Unit, Mission 이름은 CMO 내부 Editor에서 정확히 복사합니다. 오타가 있으면 Lua 조회가 실패합니다.',
    '- RP/Zone 배치: 위치와 구역은 CMO 지도 UI에서 먼저 만들고, 이 도구에는 이름/GUID만 기록합니다.',
    '- DBID 확인: 새 유닛/로드아웃/무장/센서를 생성할 때는 Database Viewer에서 현재 시나리오 DB 기준 ID를 확인합니다.',
    '- 엔진 검증: 웹 어시스턴트는 paste-ready Lua를 작성하지만 최종 문법/동작은 CMO Lua Console 또는 Event 실행으로 테스트해야 합니다.',
    '',
    ...plan.setupItems.map((item) => `- ${item}`),
    '',
    'Event Editor structure',
    ...plan.eventSteps.map((item) => `- ${item}`),
    '',
    'Missing / verify before run',
    ...(plan.missingFields.length ? plan.missingFields.map((item) => `- ${item}`) : ['- 필수 누락값은 감지되지 않았습니다.']),
  ].join('\n');
}

function analyzeEngineFeedback(feedback) {
  const text = feedback.trim();
  const hints = [];

  if (!text) {
    return ['CMO Lua Console 또는 Event 실행 결과를 붙여넣으면 다음 수정 방향을 추정합니다.'];
  }
  if (/unit not found|not found/i.test(text)) {
    hints.push('유닛/미션/RP/Zone 이름 또는 GUID가 실제 시나리오 객체와 다를 가능성이 큽니다.');
  }
  if (/attempt to index|nil value/i.test(text)) {
    hints.push('객체 조회 결과가 nil인데 바로 속성을 읽은 것으로 보입니다. ScenEdit_GetUnit/GetMission/GetReferencePoint 뒤 nil 체크를 추가하세요.');
  }
  if (/bad argument|invalid/i.test(text)) {
    hints.push('API 인자 형식 또는 DBID/Loadout ID 타입이 맞지 않을 수 있습니다. 숫자 ID와 문자열 GUID를 구분하세요.');
  }
  if (/loadout|DBID|database/i.test(text)) {
    hints.push('DB Viewer에서 현재 시나리오 DB와 Loadout/Platform ID 조합이 맞는지 다시 확인하세요.');
  }
  if (/success|ok|assigned|active/i.test(text)) {
    hints.push('성공 메시지가 감지됩니다. Event 반복 여부와 KeyValue 중복 실행 방지만 확인하면 됩니다.');
  }

  return hints.length ? hints : ['명확한 오류 패턴은 감지되지 않았습니다. 전체 로그와 의도한 동작을 함께 AI 요청문에 포함하세요.'];
}

function buildAssistantPrompt({
  source,
  objective,
  context,
  scenarioContext,
  objectContext,
  databaseContext,
  confirmedContext,
  intent,
  generatedLua,
  uiSetupText,
  engineFeedback,
  analysis,
  luaFiles,
  luaBundleAnalysis,
  chatAttachments,
  hasImportedStateSnapshot,
}) {
  const bundlePrompt = formatLuaBundlePrompt(luaFiles, luaBundleAnalysis);
  const confirmedContextPrompt = formatConfirmedContextForPrompt(confirmedContext);
  const chatAttachmentsPrompt = formatChatAttachmentsPrompt(chatAttachments);
  const advisoryGuidance = buildAdvisorySystemGuidance({
    confirmedContextCount: confirmedContext.length,
    hasScenarioSnapshot: hasImportedStateSnapshot,
  });

  return [
    '# CMO Lua/Event Assistant Request',
    '',
    '## Advisory Chat Mode',
    advisoryGuidance,
    '',
    '## Context Pack / Pruning Audit',
    '- v1 stub; v2 audit is applied immediately before AI call. pruning=off safety=applyGate,promptCopy',
    '',
    '## Goal',
    objective || '- 현재 Lua/Event 코드를 CMO에서 안전하게 실행되도록 점검하고 필요한 수정안을 제안해 주세요.',
    '',
    '## In-Game Context',
    context || '- RP, Zone, Unit, Mission, Side 정보는 CMO 내부 UI에서 만든 실제 이름/GUID를 기준으로 합니다.',
    '',
    '## Scenario Container Context',
    formatScenarioContext(scenarioContext),
    '',
    '## Registered CMO Objects',
    buildObjectContextSummary(objectContext),
    '',
    '## Database / Clipboard Context',
    formatDatabaseContext(databaseContext),
    '',
    ...(confirmedContextPrompt ? [confirmedContextPrompt, ''] : []),
    '## User Intent',
    `- Event name: ${intent.eventName || '(not provided)'}`,
    `- Summary: ${intent.summary || '(not provided)'}`,
    `- Trigger: ${optionLabel(TRIGGER_TYPES, intent.triggerType)}`,
    `- Trigger detail: ${intent.triggerDetail || '(not provided)'}`,
    `- Action: ${optionLabel(ACTION_TYPES, intent.actionType)}`,
    `- Action detail: ${intent.actionDetail || '(not provided)'}`,
    `- Condition: ${intent.condition || '(none)'}`,
    `- Repeat mode: ${intent.repeatMode}`,
    '',
    '## Proposed CMO UI Setup',
    uiSetupText,
    '',
    '## Generated Lua Draft',
    '```lua',
    generatedLua,
    '```',
    '',
    '## Latest Engine Feedback',
    engineFeedback || '(none yet)',
    '',
    '## Detected API/Trigger Hints',
    `- APIs: ${analysis.apiCalls.join(', ') || '(none detected)'}`,
    `- Event helpers: ${analysis.eventCalls.join(', ') || '(none detected)'}`,
    `- Trigger hints: ${analysis.triggerHints.join(', ') || '(none detected)'}`,
    `- DB/Loadout IDs in Lua: ${analysis.dbIdentifierHints.join(', ') || '(none detected)'}`,
    `- Scenario GUIDs in Lua: ${analysis.guidHints.join(', ') || '(none detected)'}`,
    '',
    ...(bundlePrompt ? [bundlePrompt, ''] : []),
    ...(chatAttachmentsPrompt ? [chatAttachmentsPrompt, ''] : []),
    '## Constraints',
    '- Do not invent map coordinates, RP names, unit names, GUIDs, DBIDs, or side names.',
    '- DBID and Loadout ID must come from the same CMO scenario database shown in Database Viewer.',
    '- Scenario unit GUIDs should come from CMO right-click > Scenario Editor > Copy unit ID to clipboard when possible.',
    '- Preserve existing CMO object names unless the user explicitly requests a rename.',
    '- Add nil checks around object lookups where appropriate.',
    '- Keep the output as paste-ready Lua for CMO Event Editor or Lua Script Console.',
    '',
    luaFiles.length > 1 ? '## Selected Lua File' : '## Current Lua',
    '```lua',
    truncateForPrompt(source || '-- paste CMO Lua here'),
    '```',
  ].join('\n');
}

function LuaAssistant({ focusOutputPreviewTab = '' }) {
  const luaFileInputRef = useRef(null);
  const luaBundleInputRef = useRef(null);
  const scenarioFileInputRef = useRef(null);
  const chatScenarioFileInputRef = useRef(null);
  const chatAttachmentInputRef = useRef(null);
  const chatAttachmentFolderInputRef = useRef(null);
  const skipNextAutoSaveRef = useRef(false);
  const autoSaveClearedContentKeyRef = useRef('');
  const historyBypassRef = useRef(false);
  const [source, setSource] = useState('');
  const [objective, setObjective] = useState(DEFAULT_OBJECTIVE);
  const [context, setContext] = useState(DEFAULT_CONTEXT);
  const [objectContext, setObjectContext] = useState(DEFAULT_OBJECT_CONTEXT);
  const [databaseContext, setDatabaseContext] = useState(DEFAULT_DATABASE_CONTEXT);
  const [confirmedContext, setConfirmedContext] = useState([]);
  const [confirmedContextDraft, setConfirmedContextDraft] = useState({
    type: 'side',
    value: '',
    source: 'manual-cmo-ui',
    sourceDetail: '',
    notes: '',
  });
  const [scenarioContext, setScenarioContext] = useState(DEFAULT_SCENARIO_CONTEXT);
  const [intent, setIntent] = useState(DEFAULT_INTENT);
  const [engineFeedback, setEngineFeedback] = useState('');
  const [workingLua, setWorkingLua] = useState('');
  const [chatAttachments, setChatAttachments] = useState([]);
  const [chatAttachmentStatus, setChatAttachmentStatus] = useState('첨부된 보조 파일이 없습니다.');
  const [copied, setCopied] = useState('');
  const [luaFileName, setLuaFileName] = useState('');
  const [luaFileStatus, setLuaFileStatus] = useState('아직 불러온 .lua 파일이 없습니다. 붙여넣기 또는 .lua 열기를 사용할 수 있습니다.');
  const [luaFiles, setLuaFiles] = useState([]);
  const [activeLuaFileId, setActiveLuaFileId] = useState('');
  const [luaBundleExpanded, setLuaBundleExpanded] = useState(false);
  const [bundleApiSummaryExpanded, setBundleApiSummaryExpanded] = useState(false);
  const [primaryAssistantTab, setPrimaryAssistantTab] = useState('output');
  const [assistantContentWidth, setAssistantContentWidth] = useState(58);
  const [luaFrameHeight, setLuaFrameHeight] = useState(220);
  const [scenarioInspectorExpanded, setScenarioInspectorExpanded] = useState(false);
  const [intentContentWidth, setIntentContentWidth] = useState(68);
  const [activeObjectContextTab, setActiveObjectContextTab] = useState('sides');
  const [activeIntentDetailTab, setActiveIntentDetailTab] = useState('summary');
  const [outputPreviewTab, setOutputPreviewTab] = useState('generated');
  const [promptDraft, setPromptDraft] = useState('');
  const [isPromptDirty, setIsPromptDirty] = useState(false);
  const [aiChatInstruction, setAiChatInstruction] = useState('');
  const [aiResponse, setAiResponse] = useState('');
  const [aiCallStatus, setAiCallStatus] = useState({
    state: 'idle',
    message: 'AI Adapter를 호출하면 응답이 여기에 표시됩니다.',
  });
  const [luaSidecarSave, setLuaSidecarSave] = useState({
    state: 'idle',
    message: '',
    loaderSnippet: '',
    fileName: '',
  });
  const [cmoLogFeedback, setCmoLogFeedback] = useState({
    state: 'idle',
    message: '',
    files: [],
    followUpDraft: '',
    summary: null,
  });
  const [cmoStateSnapshot, setCmoStateSnapshot] = useState({
    state: 'idle',
    message: '',
    text: '',
    sourceHint: 'toolDumpEvents',
    snapshot: null,
    followUpDraft: '',
  });
  const [aiPruningAudit, setAiPruningAudit] = useState(null);
  const [aiAdapterReadiness, setAiAdapterReadiness] = useState({
    state: 'idle',
    message: 'AI Adapter 상태를 아직 확인하지 않았습니다.',
    service: '',
    providerType: '',
    model: '',
    generationMode: '',
    apiKeyPreview: '',
    apiKeyConfigured: false,
  });
  const [activeAiProviderOverride, setActiveAiProviderOverride] = useState(null);
  const [isAiCalling, setIsAiCalling] = useState(false);
  const [isCheckingAiAdapter, setIsCheckingAiAdapter] = useState(false);
  const [undoStack, setUndoStack] = useState([]);
  const [redoStack, setRedoStack] = useState([]);
  const [tempSessionAvailability, setTempSessionAvailability] = useState(getLocalTempSessionAvailability);
  const [autoSaveInfo, setAutoSaveInfo] = useState(() => {
    if (typeof window === 'undefined') return '';

    try {
      const payload = JSON.parse(window.localStorage.getItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY) || 'null');
      return formatTempSessionTime(payload?.savedAt);
    } catch {
      return '';
    }
  });

  const eventPlan = useMemo(() => buildEventPlan({ objectContext, intent, databaseContext }), [objectContext, intent, databaseContext]);
  const generatedLua = useMemo(() => buildGeneratedLua({ objectContext, intent, databaseContext }), [objectContext, intent, databaseContext]);
  const analysis = useMemo(() => analyzeLua(source), [source]);
  const workingAnalysis = useMemo(() => analyzeLua(workingLua || generatedLua), [workingLua, generatedLua]);
  const luaBundleAnalysis = useMemo(() => aggregateLuaFiles(luaFiles), [luaFiles]);
  const databaseWarnings = useMemo(() => buildDatabaseWarnings(databaseContext, analysis), [databaseContext, analysis]);
  const workingDatabaseWarnings = useMemo(() => buildDatabaseWarnings(databaseContext, workingAnalysis), [databaseContext, workingAnalysis]);
  const uiSetupText = useMemo(() => buildUiSetupText({ objectContext, intent, databaseContext }), [objectContext, intent, databaseContext]);
  const engineHints = useMemo(() => analyzeEngineFeedback(engineFeedback), [engineFeedback]);
  const smokeTest = useMemo(() => buildSmokeTest(databaseContext), [databaseContext]);
  const autoHelperHints = useMemo(
    () => buildAutoHelperHints({ analysis, databaseWarnings, objectContext, databaseContext, intent }),
    [analysis, databaseWarnings, objectContext, databaseContext, intent],
  );
  const workingAutoHelperHints = useMemo(
    () => buildAutoHelperHints({
      analysis: workingAnalysis,
      databaseWarnings: workingDatabaseWarnings,
      objectContext,
      databaseContext,
      intent,
    }),
    [workingAnalysis, workingDatabaseWarnings, objectContext, databaseContext, intent],
  );
  const aiParsedResponse = useMemo(() => parseAiInterpreterResponse(aiResponse), [aiResponse]);
  const aiExtractedLua = aiParsedResponse.lua;
  const aiWorkflowState = useMemo(
    () => deriveAiWorkflowState({
      aiResponse,
      isAiCalling,
      aiCallStatus,
      parsedResponse: aiParsedResponse,
      applyBlockedReason: aiParsedResponse.blockers[0] || '',
      pruningAudit: aiPruningAudit,
    }),
    [aiResponse, isAiCalling, aiCallStatus, aiParsedResponse, aiPruningAudit],
  );
  const canApplyAiLua = aiWorkflowState.canApplyLua;
  const aiApplyBlockedReason = aiWorkflowState.applyBlockedReason || aiParsedResponse.blockers[0] || '';

  const prompt = useMemo(
    () => buildAssistantPrompt({
      source,
      objective,
      context,
      scenarioContext,
      objectContext,
      databaseContext,
      confirmedContext,
      intent,
      generatedLua,
      uiSetupText,
      engineFeedback,
      analysis,
      luaFiles,
      luaBundleAnalysis,
      chatAttachments,
      hasImportedStateSnapshot: Boolean(cmoStateSnapshot.snapshot),
    }),
    [source, objective, context, scenarioContext, objectContext, databaseContext, confirmedContext, intent, generatedLua, uiSetupText, engineFeedback, analysis, luaFiles, luaBundleAnalysis, chatAttachments, cmoStateSnapshot.snapshot],
  );
  const tempSessionPayload = useMemo(() => {
    const packedSource = compactSessionText(source, luaFileName || 'Current Lua');
    const packedWorkingLua = compactSessionText(workingLua, 'Working Lua');
    const syncedLuaFiles = luaFiles.map((file) => compactLuaFileForSession(
      file.id === activeLuaFileId ? { ...file, modified: true } : file,
      file.id === activeLuaFileId ? source : file.content,
    ));

    return {
      type: TEMP_SESSION_TYPE,
      version: TEMP_SESSION_VERSION,
      savedAt: new Date().toISOString(),
      state: {
        source: packedSource.text,
        sourceContentOmitted: packedSource.omitted,
        sourceOriginalCharCount: packedSource.originalCharCount,
        objective,
        context,
        scenarioContext,
        objectContext,
        databaseContext,
        confirmedContext: normalizeConfirmedContextEntries(confirmedContext),
        intent,
        engineFeedback,
        workingLua: packedWorkingLua.text,
        workingLuaContentOmitted: packedWorkingLua.omitted,
        workingLuaOriginalCharCount: packedWorkingLua.originalCharCount,
        luaFileName,
        luaFileStatus,
        luaFiles: syncedLuaFiles,
        activeLuaFileId,
        primaryAssistantTab,
        assistantContentWidth,
        luaFrameHeight,
        intentContentWidth,
        activeObjectContextTab,
        activeIntentDetailTab,
        outputPreviewTab,
        promptDraft,
        isPromptDirty,
        aiChatInstruction,
        aiResponse,
        aiCallStatus,
        aiPruningAudit,
      },
    };
  }, [
    source,
    objective,
    context,
    scenarioContext,
    objectContext,
    databaseContext,
    confirmedContext,
    intent,
    engineFeedback,
    workingLua,
    luaFileName,
    luaFileStatus,
    luaFiles,
    activeLuaFileId,
    primaryAssistantTab,
    assistantContentWidth,
    luaFrameHeight,
    intentContentWidth,
    activeObjectContextTab,
    activeIntentDetailTab,
    outputPreviewTab,
    promptDraft,
    isPromptDirty,
    aiChatInstruction,
    aiResponse,
    aiCallStatus,
    aiPruningAudit,
  ]);
  const tempSessionContentKey = useMemo(() => {
    const stableState = { ...tempSessionPayload.state };
    delete stableState.luaFileStatus;
    return JSON.stringify(stableState);
  }, [tempSessionPayload]);
  const effectivePrompt = isPromptDirty ? promptDraft : prompt;
  const hasMeaningfulTempSession = useMemo(() => hasMeaningfulAssistantState(tempSessionPayload.state), [tempSessionPayload]);
  const hasManualTempSession = tempSessionAvailability.manual;
  const hasAutoSavedTempSession = tempSessionAvailability.auto;
  const hasStoredTempSession = hasManualTempSession || hasAutoSavedTempSession;
  const scenarioDecoderCommand = useMemo(
    () => buildScenarioDecoderCommand(scenarioContext.fileName, scenarioContext),
    [scenarioContext],
  );
  const scenarioInspectorCounts = useMemo(() => summarizeScenarioInspectorCounts(scenarioContext), [scenarioContext]);
  const scenarioInspectorSteps = useMemo(() => buildScenarioInspectorSteps(scenarioContext), [scenarioContext]);
  const activeObjectContext = OBJECT_CONTEXT_TABS.find((tab) => tab.id === activeObjectContextTab) || OBJECT_CONTEXT_TABS[0];
  const confirmedContextGroups = useMemo(
    () => getConfirmedContextDisplayGroups(confirmedContext),
    [confirmedContext],
  );

  const refreshTempSessionAvailability = useCallback(async () => {
    const availability = getLocalTempSessionAvailability();

    if (!availability.manual) {
      const manualPayload = await readOriginTempSession(TEMP_SESSION_MANUAL_FILE);
      availability.manual = Boolean(manualPayload?.state && manualPayload.type === TEMP_SESSION_TYPE);
    }

    if (!availability.auto) {
      const autoPayload = await readOriginTempSession(TEMP_SESSION_AUTOSAVE_FILE);
      availability.auto = Boolean(autoPayload?.state && autoPayload.type === TEMP_SESSION_TYPE);
    }

    setTempSessionAvailability(availability);
    return availability;
  }, []);

  const applyAssistantState = useCallback((state, statusMessage = '', savedAt = '') => {
    historyBypassRef.current = true;
    autoSaveClearedContentKeyRef.current = '';
    const restoredFiles = Array.isArray(state.luaFiles)
      ? state.luaFiles.map((file, index) => {
        const path = String(file.path || file.name || `temp_${index + 1}.lua`);
        const rawContent = file.contentOmitted
          ? largeLuaPlaceholder(path, file.originalCharCount || file.size || 0)
          : String(file.content ?? '');
        const packedContent = compactSessionText(rawContent, path).text;

        return {
          id: String(file.id || `temp-${index}-${path}`),
          name: String(file.name || path),
          path,
          size: Number(file.size) || file.originalCharCount || packedContent.length,
          modified: Boolean(file.modified),
          content: packedContent,
          contentOmitted: Boolean(file.contentOmitted || packedContent !== rawContent),
          originalCharCount: Number(file.originalCharCount) || rawContent.length,
          analysis: analyzeLua(packedContent),
        };
      })
      : [];
    const restoredActiveId = restoredFiles.some((file) => file.id === state.activeLuaFileId)
      ? state.activeLuaFileId
      : restoredFiles[0]?.id || '';
    const restoreNumber = (value, fallback, min, max) => {
      const numeric = Number(value);
      return Number.isFinite(numeric) ? Math.min(Math.max(numeric, min), max) : fallback;
    };

    const rawSource = state.sourceContentOmitted
      ? largeLuaPlaceholder(state.luaFileName || 'Restored Lua', state.sourceOriginalCharCount || 0)
      : String(state.source ?? restoredFiles[0]?.content ?? '');
    const rawWorkingLua = state.workingLuaContentOmitted
      ? largeLuaPlaceholder('Working Lua', state.workingLuaOriginalCharCount || 0)
      : String(state.workingLua ?? '');

    setSource(compactSessionText(rawSource, state.luaFileName || 'Restored Lua').text);
    setObjective(String(state.objective ?? DEFAULT_OBJECTIVE));
    setContext(String(state.context ?? DEFAULT_CONTEXT));
    setObjectContext({ ...DEFAULT_OBJECT_CONTEXT, ...(state.objectContext || {}) });
    setDatabaseContext({ ...DEFAULT_DATABASE_CONTEXT, ...(state.databaseContext || {}) });
    setConfirmedContext(normalizeConfirmedContextEntries(state.confirmedContext || []));
    setScenarioContext({ ...DEFAULT_SCENARIO_CONTEXT, ...(state.scenarioContext || {}) });
    setIntent({ ...DEFAULT_INTENT, ...(state.intent || {}) });
    setEngineFeedback(String(state.engineFeedback ?? ''));
    setWorkingLua(compactSessionText(rawWorkingLua, 'Working Lua').text);
    setLuaFileName(String(state.luaFileName || (restoredFiles.length > 1 ? `${restoredFiles.length}개 Lua 묶음` : restoredFiles[0]?.path || '화면 임시 초안')));
    setLuaFiles(restoredFiles);
    setActiveLuaFileId(restoredActiveId);
    setPrimaryAssistantTab(focusOutputPreviewTab ? 'output' : state.primaryAssistantTab || 'lua');
    setAssistantContentWidth(focusOutputPreviewTab ? 44 : restoreNumber(state.assistantContentWidth, 58, 35, 84));
    setLuaFrameHeight(restoreNumber(state.luaFrameHeight, 220, 150, 900));
    setIntentContentWidth(restoreNumber(state.intentContentWidth, 68, 44, 88));
    setActiveObjectContextTab(state.activeObjectContextTab || 'sides');
    setActiveIntentDetailTab(state.activeIntentDetailTab || 'summary');
    setOutputPreviewTab(focusOutputPreviewTab || state.outputPreviewTab || 'generated');
    setPromptDraft(String(state.promptDraft ?? ''));
    setIsPromptDirty(Boolean(state.isPromptDirty && state.promptDraft));
    setAiChatInstruction(String(state.aiChatInstruction ?? ''));
    setAiResponse(String(state.aiResponse ?? ''));
    setAiCallStatus(state.aiCallStatus || {
      state: 'idle',
      message: 'AI Adapter를 호출하면 응답이 여기에 표시됩니다.',
    });
    setAiPruningAudit(state.aiPruningAudit || null);
    if (savedAt) {
      setAutoSaveInfo(formatTempSessionTime(savedAt));
    }
    if (statusMessage) {
      setLuaFileStatus(statusMessage);
    }
    historyBypassRef.current = false;
  }, [focusOutputPreviewTab]);

  const restoreTempSessionPayload = useCallback((payload, label = '임시 세션') => {
    if (!payload?.state || payload.type !== TEMP_SESSION_TYPE) {
      setLuaFileStatus('이 파일은 CMO Lua Assistant 임시 세션 형식이 아닙니다.');
      return false;
    }

    const state = payload.state;
    applyAssistantState(
      state,
      `${label} 복원 완료: ${formatTempSessionTime(payload.savedAt) || '저장 시간 없음'}`,
      payload.savedAt,
    );
    return true;
  }, [applyAssistantState]);

  const recordHistoryBeforeChange = useCallback(() => {
    if (historyBypassRef.current) return;

    const snapshot = cloneAssistantState(tempSessionPayload.state);
    const snapshotKey = getAssistantHistoryKey(snapshot);

    setUndoStack((current) => {
      if (current[0]?.key === snapshotKey) return current;
      return [{ key: snapshotKey, state: snapshot }, ...current].slice(0, MAX_HISTORY_ENTRIES);
    });
    setRedoStack([]);
  }, [tempSessionPayload]);

  useEffect(() => {
    const handleLuaInsertRequest = (event) => {
      const detail = event.detail || {};
      if (!detail.content) return;

      recordHistoryBeforeChange();
      setSource((current) => {
        const text = String(current || '');
        return text.trim() ? `${text.replace(/\s*$/, '')}\n\n${detail.content}` : detail.content;
      });
      setPrimaryAssistantTab('lua');
      setLuaFileName(detail.label || 'Inserted preset');
      setLuaFileStatus(`${detail.label || 'Preset'} 내용을 Lua 분석 편집기에 추가했습니다.`);
    };

    window.addEventListener('cmo-lua-insert-request', handleLuaInsertRequest);
    return () => window.removeEventListener('cmo-lua-insert-request', handleLuaInsertRequest);
  }, [recordHistoryBeforeChange]);

  const rollbackAssistantHistory = () => {
    const target = undoStack[0];
    if (!target) return;

    const currentSnapshot = cloneAssistantState(tempSessionPayload.state);
    const currentKey = getAssistantHistoryKey(currentSnapshot);
    const nextUndoStack = undoStack.slice(1);

    setUndoStack(nextUndoStack);
    setRedoStack((current) => [{ key: currentKey, state: currentSnapshot }, ...current].slice(0, MAX_HISTORY_ENTRIES));
    applyAssistantState(target.state, `수정 이전으로 롤백했습니다. 남은 롤백 ${nextUndoStack.length}/${MAX_HISTORY_ENTRIES}회.`);
  };

  const redoAssistantHistory = () => {
    const target = redoStack[0];
    if (!target) return;

    const currentSnapshot = cloneAssistantState(tempSessionPayload.state);
    const currentKey = getAssistantHistoryKey(currentSnapshot);
    const nextRedoStack = redoStack.slice(1);

    setRedoStack(nextRedoStack);
    setUndoStack((current) => [{ key: currentKey, state: currentSnapshot }, ...current].slice(0, MAX_HISTORY_ENTRIES));
    applyAssistantState(target.state, `롤백 취소로 최신 작업 쪽으로 이동했습니다. 남은 다시 실행 ${nextRedoStack.length}/${MAX_HISTORY_ENTRIES}회.`);
  };

  const resetAssistantWorkspace = async () => {
    if (!window.confirm('현재 Assistant 작업 내용을 초기화하시겠습니까? 임시저장/자동복구 슬롯도 함께 삭제됩니다.')) return;

    historyBypassRef.current = true;
    setUndoStack([]);
    setRedoStack([]);
    applyAssistantState({
      source: '',
      objective: DEFAULT_OBJECTIVE,
      context: DEFAULT_CONTEXT,
      scenarioContext: DEFAULT_SCENARIO_CONTEXT,
      objectContext: DEFAULT_OBJECT_CONTEXT,
      databaseContext: DEFAULT_DATABASE_CONTEXT,
      confirmedContext: [],
      intent: DEFAULT_INTENT,
      engineFeedback: '',
      workingLua: '',
      luaFileName: '',
      luaFileStatus: '작업을 초기화했습니다. 새 Lua 또는 시나리오 파일을 불러올 수 있습니다.',
      luaFiles: [],
      activeLuaFileId: '',
      primaryAssistantTab: 'lua',
      assistantContentWidth: 58,
      luaFrameHeight: 220,
      intentContentWidth: 68,
      activeObjectContextTab: 'sides',
      activeIntentDetailTab: 'summary',
      outputPreviewTab: 'generated',
      promptDraft: '',
      isPromptDirty: false,
      aiChatInstruction: '',
      aiResponse: '',
      aiCallStatus: {
        state: 'idle',
        message: 'AI Adapter를 호출하면 응답이 여기에 표시됩니다.',
      },
      aiPruningAudit: null,
    }, '작업을 초기화했습니다. 새 Lua 또는 시나리오 파일을 불러올 수 있습니다.');
    await clearSavedTempSessions();
  };

  useEffect(() => {
    let cancelled = false;

    const restoreAutosavedSession = async () => {
      const searchParams = new URLSearchParams(window.location.search);
      if (searchParams.has('resetAssistant') || searchParams.has('safeMode')) {
        try {
          window.localStorage.removeItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY);
          window.localStorage.removeItem(TEMP_SESSION_MANUAL_STORAGE_KEY);
        } catch {
          // Browser storage cleanup is best-effort.
        }

        await Promise.all([
          deleteOriginTempSession(TEMP_SESSION_AUTOSAVE_FILE).catch(() => false),
          deleteOriginTempSession(TEMP_SESSION_MANUAL_FILE).catch(() => false),
        ]);

        if (!cancelled) {
          setTempSessionAvailability({ manual: false, auto: false });
          setAutoSaveInfo('');
          setLuaFileStatus('안전 진입 모드: 자동복구/임시저장 슬롯을 지우고 빈 작업공간으로 시작했습니다.');
        }
        return;
      }

      let payload = null;

      try {
        payload = JSON.parse(window.localStorage.getItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY) || 'null');
      } catch {
        // Malformed localStorage data is ignored; OPFS fallback can still recover a session.
      }

      if (!payload) {
        payload = await readOriginTempSession(TEMP_SESSION_AUTOSAVE_FILE);
      }

      if (!cancelled && payload?.state) {
        restoreTempSessionPayload(payload, '자동 저장 세션');
      }
    };

    restoreAutosavedSession();

    return () => {
      cancelled = true;
    };
  }, [restoreTempSessionPayload]);

  useEffect(() => {
    const refreshHandle = window.setTimeout(() => {
      refreshTempSessionAvailability();
    }, 0);

    return () => window.clearTimeout(refreshHandle);
  }, [refreshTempSessionAvailability]);

  useEffect(() => {
    if (!hasMeaningfulTempSession) {
      return undefined;
    }

    if (autoSaveClearedContentKeyRef.current === tempSessionContentKey) {
      return undefined;
    }

    if (skipNextAutoSaveRef.current) {
      skipNextAutoSaveRef.current = false;
      return undefined;
    }

    const saveHandle = window.setTimeout(() => {
      try {
        window.localStorage.setItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY, JSON.stringify(tempSessionPayload));
        setAutoSaveInfo(formatTempSessionTime(tempSessionPayload.savedAt));
        setTempSessionAvailability((current) => ({ ...current, auto: true }));
      } catch {
        setAutoSaveInfo('브라우저 자동저장 실패');
      }

      writeOriginTempSession(tempSessionPayload, TEMP_SESSION_AUTOSAVE_FILE).catch(() => {});
    }, 900);

    return () => window.clearTimeout(saveHandle);
  }, [hasMeaningfulTempSession, tempSessionContentKey, tempSessionPayload]);

  useEffect(() => {
    const flushTempSession = () => {
      if (!hasMeaningfulTempSession) {
        return;
      }

      if (autoSaveClearedContentKeyRef.current === tempSessionContentKey) {
        return;
      }

      const payload = {
        ...tempSessionPayload,
        savedAt: new Date().toISOString(),
      };

      try {
        window.localStorage.setItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY, JSON.stringify(payload));
      } catch {
        // Closing-time persistence is best-effort; regular autosave continues while the page is open.
      }
    };
    const flushWhenHidden = () => {
      if (document.visibilityState === 'hidden') {
        flushTempSession();
      }
    };

    window.addEventListener('pagehide', flushTempSession);
    window.addEventListener('beforeunload', flushTempSession);
    document.addEventListener('visibilitychange', flushWhenHidden);

    return () => {
      window.removeEventListener('pagehide', flushTempSession);
      window.removeEventListener('beforeunload', flushTempSession);
      document.removeEventListener('visibilitychange', flushWhenHidden);
    };
  }, [hasMeaningfulTempSession, tempSessionContentKey, tempSessionPayload]);

  const renderChipList = (items, fallback, listClass = '') => (
    <div className={`chip-list ${listClass}`}>
      {(items.length ? items : [fallback]).map((item) => (
        <span key={item} className={classifyChip(item)}>{item}</span>
      ))}
    </div>
  );

  const copyText = async (label, text) => {
    await navigator.clipboard.writeText(text);
    setCopied(label);
    window.setTimeout(() => setCopied(''), 1500);
  };

  const refreshAiAdapterReadiness = useCallback(async () => {
    setIsCheckingAiAdapter(true);

    try {
      const [health, settings] = await Promise.all([
        fetchAiAdapterHealth(),
        fetchAiAdapterSettings(),
      ]);
      const missing = [];
      if (!settings.model) missing.push('model');
      if (!settings.baseUrl && settings.providerType !== 'ollama') missing.push('base URL');
      const nextReadiness = {
        state: missing.length ? 'warning' : 'ok',
        message: missing.length
          ? `AI Adapter 연결됨 · 추가 설정 필요: ${missing.join(', ')}`
          : `AI Adapter 준비됨 · ${settings.providerType} · ${settings.model}`,
        service: health.service || 'AI Adapter',
        providerType: settings.providerType,
        model: settings.model,
        generationMode: settings.generationMode,
        apiKeyPreview: settings.apiKeyPreview,
        apiKeyConfigured: settings.apiKeyConfigured,
      };

      setAiAdapterReadiness(nextReadiness);
      return nextReadiness;
    } catch (error) {
      const nextReadiness = {
        state: 'error',
        message: `AI Adapter 연결 실패: ${error.message}`,
        service: '',
        providerType: '',
        model: '',
        generationMode: '',
        apiKeyPreview: '',
        apiKeyConfigured: false,
      };

      setAiAdapterReadiness(nextReadiness);
      return nextReadiness;
    } finally {
      setIsCheckingAiAdapter(false);
    }
  }, []);

  const callAiAdapter = async (promptOverride, statusLabel = '현재 요청문', nextPreviewTab = 'ai') => {
    const overridePrompt = typeof promptOverride === 'string' ? promptOverride.trim() : '';
    let requestPrompt = overridePrompt || effectivePrompt;
    setAiPruningAudit(null);

    if (!requestPrompt.includes('## Context Pack / Pruning Audit')) {
      setAiResponse('');
      setAiCallStatus({
        state: 'error',
        message: 'AI 호출 차단: Context Pack이 빠졌습니다. Prompt를 재생성한 뒤 다시 시도하세요.',
      });
      return;
    }

    try {
      const { applyContextPruning, applyContextPruningAudit } = await import('../lib/aiContextPruning');
      const pruningContext = {
        source,
        objective,
        userContext: context,
        intent,
        objectContext,
        databaseContext,
        confirmedContext,
        scenarioContext,
        engineFeedback,
        luaFiles,
        previousAiBlockers: aiParsedResponse.blockers,
      };
      const prunedResult = applyContextPruning(requestPrompt, pruningContext);
      const nextPruningAudit = {
        mode: prunedResult.decisions.omitted.length || prunedResult.decisions.summarized.length ? 'phase3' : 'judge-only',
        actualOmit: prunedResult.decisions.omitted,
        summarized: prunedResult.decisions.summarized,
        preserved: prunedResult.decisions.preserved,
        askBackHints: prunedResult.askBackHints,
        tokens: prunedResult.tokenEstimate,
        tokenLimit: 12000,
        hardBlock: prunedResult.hardBlock,
        failures: [],
      };

      if (prunedResult.hardBlock) {
        setAiPruningAudit(nextPruningAudit);
        setAiResponse('');
        setAiCallStatus({
          state: 'error',
          message: `AI 호출 차단: Context pruning 변환 실패 (${prunedResult.hardBlock}).`,
        });
        return;
      }

      const pruningResult = applyContextPruningAudit(prunedResult.prompt, {
        ...pruningContext,
        decisions: prunedResult.decisions,
        askBackHints: prunedResult.askBackHints,
      });

      if (pruningResult.failures.length) {
        setAiPruningAudit({
          ...nextPruningAudit,
          failures: pruningResult.failures,
        });
        setAiResponse('');
        setAiCallStatus({
          state: 'error',
          message: `AI 호출 차단: Context pruning 안전 검증 실패 (${pruningResult.failures.join(', ')}).`,
        });
        return;
      }

      setAiPruningAudit({
        ...nextPruningAudit,
        failures: [],
      });
      requestPrompt = pruningResult.prompt;
    } catch (error) {
      setAiResponse('');
      setAiCallStatus({
        state: 'error',
        message: `AI 호출 차단: Context pruning 모듈을 불러오지 못했습니다. ${error.message}`,
      });
      return;
    }

    setIsAiCalling(true);
    setOutputPreviewTab(nextPreviewTab);
    setLuaSidecarSave({
      state: 'idle',
      message: '',
      loaderSnippet: '',
      fileName: '',
    });
    setAiCallStatus({ state: 'loading', message: `AI Adapter에 ${statusLabel}을 보내는 중입니다.` });

    try {
      const readiness = await refreshAiAdapterReadiness();

      if (readiness.state === 'error') {
        setAiResponse('');
        setAiCallStatus({ state: 'error', message: readiness.message });
        return;
      }

      const selectedProfile = activeAiProviderOverride;
      const selectedModel = selectedProfile?.model || readiness.model;
      const selectedBaseUrl = selectedProfile?.baseUrl || '';

      if (!selectedModel) {
        setAiResponse('');
        setAiCallStatus({
          state: 'error',
          message: 'AI 호출 차단: Settings에서 Provider 모델을 선택하거나 직접 입력한 뒤 설정 적용을 먼저 실행하세요.',
        });
        return;
      }

      if (selectedProfile && !selectedBaseUrl) {
        setAiResponse('');
        setAiCallStatus({
          state: 'error',
          message: 'AI 호출 차단: 선택한 프로필에 Base URL이 없습니다. Settings에서 프로필을 다시 저장하세요.',
        });
        return;
      }

      const result = await sendCmoAiPrompt(requestPrompt, selectedProfile ? {
        providerOverride: selectedProfile,
        generationMode: selectedProfile.generationMode,
        temperature: selectedProfile.temperature,
        maxTokens: selectedProfile.maxTokens,
      } : {});
      const nextText = result.text.trim();
      const parsedResponse = parseAiInterpreterResponse(nextText);

      setAiResponse(nextText);
      setAiCallStatus({
        state: parsedResponse.isPasteReady ? 'ok' : 'error',
        message: parsedResponse.isPasteReady
          ? `AI 응답 수신 완료${result.modelEcho ? ` · ${result.modelEcho}` : ''}${result.finishReason ? ` · ${result.finishReason}` : ''}`
          : `AI 응답 수신 완료, Lua 적용 차단: ${parsedResponse.blockers[0] || '필수 응답 형식이 부족합니다.'}`,
      });
    } catch (error) {
      setAiResponse('');
      setAiCallStatus({
        state: 'error',
        message: `AI 호출 실패: ${error.message}`,
      });
    } finally {
      setIsAiCalling(false);
    }
  };

  const applyAiLuaBlock = () => {
    if (!canApplyAiLua) {
      setAiCallStatus({
        state: 'error',
        message: `AI Lua 적용 차단: ${aiApplyBlockedReason || 'Paste-ready Lua 형식이 아니거나 추가 확인이 필요합니다.'}`,
      });
      return;
    }

    if (!aiExtractedLua) {
      setAiCallStatus({
        state: 'error',
        message: 'AI 응답에서 ```lua 코드블록을 찾지 못했습니다. 응답을 직접 확인하거나 Prompt를 다시 조정하세요.',
      });
      return;
    }

    applyWorkingLuaDraft(aiExtractedLua);
    setAiCallStatus({
      state: 'ok',
      message: 'AI 응답의 Paste-ready Lua를 Working Draft에 적용했습니다. CMO Lua Console에서 검증하세요.',
    });
  };

  const saveAiLuaSidecar = async ({ dryRun = true } = {}) => {
    if (!canApplyAiLua || !aiExtractedLua.trim()) {
      setLuaSidecarSave({
        state: 'error',
        message: 'paste-ready Lua 초안만 CMO Lua 파일로 저장할 수 있습니다.',
        loaderSnippet: '',
        fileName: '',
      });
      return;
    }

    setLuaSidecarSave((previous) => ({
      ...previous,
      state: 'loading',
      message: dryRun
        ? 'CMO Lua 파일 저장 위치를 확인하는 중입니다...'
        : 'CMO Lua 폴더에 파일을 저장하는 중입니다...',
    }));

    try {
      const result = await saveCmoLuaSidecar({
        content: aiExtractedLua,
        slug: intent.actionType || 'ai-draft',
        isPasteReady: aiParsedResponse.isPasteReady,
        dryRun,
        confirmWrite: !dryRun,
      });

      setLuaSidecarSave({
        state: 'ok',
        message: dryRun
          ? `저장 준비 완료: ${result.fileName}. CMO 실행은 수동으로 확인하세요.`
          : `CMO Lua 폴더에 저장됨: ${result.fileName}. CMO에서 loader snippet을 직접 실행하세요.`,
        loaderSnippet: result.loaderSnippet || '',
        fileName: result.fileName || '',
      });
    } catch (error) {
      const alreadyExists = /already exists|EEXIST/i.test(error?.message || '');

      setLuaSidecarSave({
        state: 'error',
        message: alreadyExists
          ? '같은 이름의 AiAssist Lua 파일이 이미 있습니다. CMO 파일 준비를 다시 눌러 새 timestamp 파일명으로 재시도하세요.'
          : (error?.message || 'CMO Lua 파일 저장에 실패했습니다.'),
        loaderSnippet: '',
        fileName: '',
      });
    }
  };

  const refreshCmoLogFeedback = async () => {
    setCmoLogFeedback({
      state: 'loading',
      message: 'CMO 로그를 읽는 중입니다. 경로와 시크릿은 어댑터에서 제거됩니다...',
      files: [],
      followUpDraft: '',
      summary: null,
    });

    try {
      const result = await fetchCmoLogFeedback({
        kind: 'all',
        limit: 20,
        maxBytes: 24000,
      });
      const files = Array.isArray(result?.files) ? result.files : [];
      const entriesReturned = Number(result?.summary?.entriesReturned || 0);

      setCmoLogFeedback({
        state: 'ok',
        message: entriesReturned
          ? `CMO 로그 ${entriesReturned}줄을 읽었습니다. AI 호출은 자동으로 실행되지 않습니다.`
          : '최근 CMO 로그 항목이 없습니다. 필요하면 CMO 로그를 수동으로 붙여넣어 주세요.',
        files,
        followUpDraft: String(result?.followUpDraft || ''),
        summary: result?.summary || null,
      });
    } catch (error) {
      setCmoLogFeedback({
        state: 'error',
        message: error?.message || 'CMO 로그 확인에 실패했습니다.',
        files: [],
        followUpDraft: '',
        summary: null,
      });
    }
  };

  const draftCmoLogFollowUp = () => {
    if (!cmoLogFeedback.followUpDraft) return;
    setAiChatInstruction(cmoLogFeedback.followUpDraft);
    setOutputPreviewTab('chat');
    setAiCallStatus((current) => ({
      ...current,
      message: 'CMO 로그 기반 후속 질문 초안을 AI 채팅 입력에 넣었습니다. 자동 호출은 하지 않습니다.',
    }));
  };

  const buildCmoStateSnapshotFollowUp = (snapshot) => {
    if (!snapshot) return '';
    const summary = snapshot.summary || {};
    const events = Array.isArray(snapshot.events) ? snapshot.events : [];
    const specialActions = Array.isArray(snapshot.specialActions) ? snapshot.specialActions : [];
    const warnings = Array.isArray(snapshot.warnings) ? snapshot.warnings : [];
    const detectedApis = Array.isArray(snapshot.detectedApis) ? snapshot.detectedApis : [];

    return [
      '가져온 CMO 상태 스냅샷을 바탕으로 다음 Lua 수정 방향을 진단해 주세요.',
      '이 스냅샷은 사용자가 수동으로 붙여넣은 가져온 스냅샷이며, 실시간 연결이 아닙니다.',
      `Snapshot ID: ${snapshot.snapshotId || '(unknown)'}`,
      `Imported at: ${snapshot.importedAt || '(unknown)'}`,
      `Source: ${snapshot.source?.type || 'unknown'} / live=${snapshot.source?.live === true ? 'true' : 'false'}`,
      `Counts: events ${summary.eventCount ?? 0}/${summary.totalEventCount ?? summary.eventCount ?? 0}, special actions ${summary.specialActionCount ?? 0}/${summary.totalSpecialActionCount ?? summary.specialActionCount ?? 0}, warnings ${summary.warningCount ?? 0}`,
      events.length ? `Events: ${events.slice(0, 8).map((event) => event.name || event.description || event.id || 'unnamed').join(', ')}` : 'Events: none in imported snapshot',
      specialActions.length ? `Special actions: ${specialActions.slice(0, 8).map((action) => action.name || action.description || action.id || 'unnamed').join(', ')}` : 'Special actions: none in imported snapshot',
      detectedApis.length ? `Detected APIs: ${detectedApis.slice(0, 12).join(', ')}` : 'Detected APIs: none',
      warnings.length ? `Warnings: ${warnings.slice(0, 6).join(' / ')}` : 'Warnings: none',
      '부족한 Side, Mission, Unit GUID, DBID, RP/Zone 값은 추측하지 말고 되물어주세요.',
      'AI 응답은 초안이며 CMO 엔진 검증은 별도로 필요합니다.',
    ].join('\n');
  };

  const importCmoStateSnapshotFromText = async () => {
    const text = cmoStateSnapshot.text.trim();
    if (!text) {
      setCmoStateSnapshot((current) => ({
        ...current,
        state: 'error',
        message: 'CMO에서 복사한 Tool_DumpEvents 또는 ScenEdit_GetEvent 출력 텍스트를 먼저 붙여넣으세요.',
        snapshot: null,
        followUpDraft: '',
      }));
      return;
    }

    setCmoStateSnapshot((current) => ({
      ...current,
      state: 'loading',
      message: 'CMO 상태 스냅샷을 가져오는 중입니다. 원문과 시크릿은 어댑터에서 정리됩니다...',
      snapshot: null,
      followUpDraft: '',
    }));

    try {
      const snapshot = await importCmoStateSnapshot({
        text,
        sourceHint: cmoStateSnapshot.sourceHint,
      });
      const eventCount = Number(snapshot?.summary?.eventCount || 0);
      const actionCount = Number(snapshot?.summary?.specialActionCount || 0);
      const followUpDraft = buildCmoStateSnapshotFollowUp(snapshot);

      setCmoStateSnapshot((current) => ({
        ...current,
        state: 'ok',
        message: `가져온 스냅샷: 이벤트 ${eventCount}개, Special Action ${actionCount}개. AI는 자동 호출하지 않습니다.`,
        snapshot,
        followUpDraft,
      }));
    } catch (error) {
      setCmoStateSnapshot((current) => ({
        ...current,
        state: 'error',
        message: error?.message || 'CMO 상태 스냅샷 가져오기에 실패했습니다.',
        snapshot: null,
        followUpDraft: '',
      }));
    }
  };

  const draftCmoStateSnapshotFollowUp = () => {
    if (!cmoStateSnapshot.followUpDraft) return;
    setAiChatInstruction(cmoStateSnapshot.followUpDraft);
    setOutputPreviewTab('chat');
    setAiCallStatus((current) => ({
      ...current,
      message: '가져온 CMO 스냅샷 기반 후속 질문 초안을 AI 채팅 입력에 넣었습니다. 자동 호출은 하지 않습니다.',
    }));
  };

  const draftAiChatFollowUp = (instruction) => {
    setAiChatInstruction(String(instruction || ''));
    setOutputPreviewTab('chat');
    setAiCallStatus((current) => ({
      ...current,
      message: 'AI 응답 검토 내용을 AI 채팅 재질문 초안으로 옮겼습니다. 필요한 CMO 정보를 보강한 뒤 다시 호출하세요.',
    }));
  };

  const clearAutoSavedSession = useCallback(async () => {
    autoSaveClearedContentKeyRef.current = tempSessionContentKey;
    skipNextAutoSaveRef.current = true;

    try {
      window.localStorage.removeItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY);
    } catch {
      // Temp cleanup is best-effort across browsers.
    }

    await deleteOriginTempSession(TEMP_SESSION_AUTOSAVE_FILE).catch(() => false);
    await refreshTempSessionAvailability();
    setAutoSaveInfo('');
  }, [refreshTempSessionAvailability, tempSessionContentKey]);

  const clearManualTempSession = useCallback(async () => {
    try {
      window.localStorage.removeItem(TEMP_SESSION_MANUAL_STORAGE_KEY);
    } catch {
      // Temp cleanup is best-effort across browsers.
    }

    await deleteOriginTempSession(TEMP_SESSION_MANUAL_FILE).catch(() => false);
    await refreshTempSessionAvailability();
  }, [refreshTempSessionAvailability]);

  const clearSavedTempSessions = useCallback(async () => {
    await Promise.all([clearAutoSavedSession(), clearManualTempSession()]);
    setTempSessionAvailability({ manual: false, auto: false });
  }, [clearAutoSavedSession, clearManualTempSession]);

  const syncIntentSideFromExtracted = (extracted) => {
    const detectedSide = extracted.sides[0];
    if (!detectedSide) return;

    setIntent((current) => {
      const currentSide = current.playerSide.trim();
      const shouldSync = !currentSide
        || currentSide === DEFAULT_INTENT.playerSide
        || !extracted.sides.includes(currentSide);

      return shouldSync ? { ...current, playerSide: detectedSide } : current;
    });
  };

  const applyExtractedObjectContext = (loadedFiles) => {
    const extracted = extractLuaObjectContext(loadedFiles);
    const extractedCount = countExtractedContext(extracted);

    if (extractedCount) {
      setObjectContext((current) => mergeObjectContext(current, extracted));
      syncIntentSideFromExtracted(extracted);
    }

    return { extracted, extractedCount };
  };

  const syncLuaFileList = (loadedFiles) => {
    setLuaFiles(loadedFiles);
    return applyExtractedObjectContext(loadedFiles);
  };

  const applyCurrentLuaToObjectContext = () => {
    recordHistoryBeforeChange();
    const currentRecord = {
      id: activeLuaFileId || 'current-source',
      name: luaFileName || 'Current Lua',
      path: luaFileName || 'Current Lua',
      content: source,
      analysis,
    };
    const { extractedCount } = applyExtractedObjectContext([currentRecord]);
    setLuaFileStatus(
      extractedCount
        ? `현재 Lua에서 ${extractedCount}개 객체/파일 힌트를 Object Context와 Intent Side에 병합했습니다.`
        : '현재 Lua에서 자동 채움 가능한 객체 힌트를 찾지 못했습니다.',
    );
  };

  const setActiveLuaFile = (fileId) => {
    const file = luaFiles.find((item) => item.id === fileId);
    if (!file) return;
    setActiveLuaFileId(file.id);
    setSource(file.content);
    setWorkingLua(file.content);
    setLuaFileName(file.path);
  };

  const updateSource = (value) => {
    recordHistoryBeforeChange();
    setSource(value);
    if (!activeLuaFileId) return;
    setLuaFiles((current) => current.map((file) => (
      file.id === activeLuaFileId
        ? { ...file, content: value, modified: true, analysis: analyzeLua(value) }
        : file
    )));
  };

  const handleLuaFileLoad = async (event) => {
    const file = event.target.files?.[0];

    if (!file) return;

    if (!file.name.toLowerCase().endsWith('.lua')) {
      setLuaFileStatus('Lua 파일만 불러올 수 있습니다. 확장자가 .lua인 파일을 선택하세요.');
      event.target.value = '';
      return;
    }

    const text = await file.text();
    const loadedFile = createLuaFileRecord(file, text, 0);
    const loadedAt = new Date().toLocaleString();

    recordHistoryBeforeChange();
    setSource(text);
    setWorkingLua(text);
    setLuaFileName(loadedFile.path);
    setActiveLuaFileId(loadedFile.id);
    const { extractedCount } = syncLuaFileList([loadedFile]);
    setLuaFileStatus(`${loadedFile.path} 불러옴: Lua 분석 탭, Object Context, Intent Side, AI 요청문에 자동 반영했습니다. 자동 채움 ${extractedCount}개. (${loadedAt})`);
    setPrimaryAssistantTab('lua');
    event.target.value = '';
  };

  const handleLuaBundleLoad = async (event) => {
    const selectedFiles = Array.from(event.target.files || [])
      .filter((file) => file.name.toLowerCase().endsWith('.lua'))
      .sort((a, b) => (a.webkitRelativePath || a.name).localeCompare(b.webkitRelativePath || b.name));

    if (!selectedFiles.length) {
      setLuaFileStatus('선택한 묶음/폴더에서 .lua 파일을 찾지 못했습니다.');
      event.target.value = '';
      return;
    }

    const loadedFiles = await Promise.all(selectedFiles.map(async (file, index) => {
      const text = await file.text();
      return createLuaFileRecord(file, text, index);
    }));
    const firstFile = loadedFiles[0];
    const totalLines = loadedFiles.reduce((sum, file) => sum + file.analysis.lineCount, 0);
    const loadedAt = new Date().toLocaleString();

    recordHistoryBeforeChange();
    setSource(firstFile.content);
    setWorkingLua(firstFile.content);
    setLuaFileName(`${loadedFiles.length}개 Lua 묶음`);
    setActiveLuaFileId(firstFile.id);
    const { extractedCount } = syncLuaFileList(loadedFiles);
    setLuaFileStatus(`${loadedFiles.length}개 .lua 파일 불러옴: 파일별 분석, Object Context, Intent Side, 통합 AI 요청문을 갱신했습니다. 총 ${totalLines} lines, 자동 채움 ${extractedCount}개. (${loadedAt})`);
    setPrimaryAssistantTab('lua');
    event.target.value = '';
  };

  const handleChatAttachmentLoad = async (event) => {
    const selectedFiles = Array.from(event.target.files || [])
      .filter(isSupportedChatAttachment)
      .sort((a, b) => attachmentPathOf(a).localeCompare(attachmentPathOf(b)))
      .slice(0, CHAT_ATTACHMENT_MAX_FILES);

    if (!selectedFiles.length) {
      setChatAttachmentStatus('지원되는 텍스트 파일을 찾지 못했습니다. .lua, .css, .html, .txt, .md, .json, .xml 파일만 채팅 컨텍스트로 읽습니다.');
      event.target.value = '';
      return;
    }

    const loaded = [];
    let totalReadBytes = 0;

    for (const file of selectedFiles) {
      if (totalReadBytes >= CHAT_ATTACHMENT_TOTAL_READ_LIMIT) break;
      const remainingBudget = CHAT_ATTACHMENT_TOTAL_READ_LIMIT - totalReadBytes;
      const readBytes = Math.min(file.size, CHAT_ATTACHMENT_TEXT_READ_LIMIT, remainingBudget);
      const content = await file.slice(0, readBytes).text();
      loaded.push(createChatAttachmentRecord({
        file,
        content,
        index: loaded.length,
        truncated: file.size > readBytes,
      }));
      totalReadBytes += readBytes;
    }

    setChatAttachments(loaded);
    setChatAttachmentStatus(`${loaded.length}개 파일을 채팅 컨텍스트로 첨부했습니다. 읽은 용량 ${formatBytes(totalReadBytes)} / 총 한도 ${formatBytes(CHAT_ATTACHMENT_TOTAL_READ_LIMIT)}.`);
    event.target.value = '';
  };

  const handleScenarioFileLoad = async (event, options = {}) => {
    const file = event.target.files?.[0];
    const preserveEditors = Boolean(options.preserveEditors);

    if (!file) return;

    const lowerFileName = file.name.toLowerCase();
    const isSupportedScenarioContext = lowerFileName.endsWith('.scen')
      || lowerFileName.endsWith('.xml')
      || lowerFileName.endsWith('.scenario.xml')
      || lowerFileName.endsWith('.json');

    if (!isSupportedScenarioContext) {
      setLuaFileStatus('CMO 시나리오 컨텍스트는 .scen, extract:scenario-xml로 만든 .scenario.xml/.xml, 또는 summarize:scenario로 만든 .json 파일만 불러올 수 있습니다.');
      event.target.value = '';
      return;
    }

    try {
      let parsedScenario;

      if (lowerFileName.endsWith('.json')) {
        const text = await file.text();
        parsedScenario = parseScenarioSummaryJson(text, file.name);
      } else if (lowerFileName.endsWith('.scen')) {
        const metadataText = await file.slice(0, Math.min(file.size, SCENARIO_SCEN_METADATA_READ_LIMIT)).text();
        parsedScenario = parseScenarioWrapperMetadata(metadataText, file.name, file.size);
        if (!parsedScenario.compressedLength && file.size <= SCENARIO_SCEN_METADATA_READ_LIMIT) {
          parsedScenario = parseScenarioContainer(metadataText, file.name);
        }
      } else {
        if (file.size > SCENARIO_XML_SIDECAR_CHAR_LIMIT) {
          setLuaFileStatus(`${file.name}은 대형 XML입니다. 브라우저 멈춤을 피하려면 npm run summarize:scenario로 .summary.json을 만든 뒤 그 요약본을 불러오세요.`);
          event.target.value = '';
          return;
        }
        const text = await file.text();
        parsedScenario = parseScenarioContainer(text, file.name);
      }

      const openabilityRecord = await fetchScenarioOpenabilityRecord(file.name, parsedScenario.title);
      parsedScenario = mergeScenarioWithOpenabilityRecord(parsedScenario, openabilityRecord);
      const initialExtractedCount = countExtractedContext(parsedScenario.extractedObjectContext);

      if (parsedScenario.compressedLength > 0 && !initialExtractedCount && !parsedScenario.extractedLuaFiles?.length) {
        const sidecarScenario = await fetchScenarioSidecar(file.name, parsedScenario.title);
        parsedScenario = mergeScenarioWithSidecar(parsedScenario, sidecarScenario);

        const sidecarExtractedCount = countExtractedContext(parsedScenario.extractedObjectContext);
        if (!sidecarExtractedCount && !parsedScenario.extractedLuaFiles?.length) {
          try {
            setLuaFileStatus(`${file.name}: 매칭된 sidecar가 없어 AI adapter로 임시 메모리 열기를 시도합니다...`);
            const transientScenario = await fetchTransientScenarioSidecar(file);
            parsedScenario = mergeScenarioWithSidecar(parsedScenario, transientScenario);
          } catch (error) {
            parsedScenario = {
              ...parsedScenario,
              transientError: error?.message || '임시 메모리 열기를 사용할 수 없습니다.',
              note: [
                parsedScenario.note,
                `임시 메모리 열기 실패: ${error?.message || 'AI adapter 서버가 꺼져 있거나 디코더가 실패했습니다.'}`,
              ].filter(Boolean).join(' '),
            };
          }
        }
      }

      const inferredDb = inferDatabaseFromScenario(parsedScenario.dbVersion);
      const extractedScenarioContext = parsedScenario.extractedObjectContext || {};
      const extractedCount = countExtractedContext(extractedScenarioContext);
      const scenarioLuaFiles = parsedScenario.extractedLuaFiles || [];
      const loadedAt = new Date().toLocaleString();

      recordHistoryBeforeChange();
      setScenarioContext(parsedScenario);
      if (extractedCount) {
        setObjectContext((current) => mergeObjectContext(current, extractedScenarioContext));
        syncIntentSideFromExtracted(extractedScenarioContext);
      }
      if (scenarioLuaFiles.length) {
        if (preserveEditors) {
          applyExtractedObjectContext(scenarioLuaFiles);
          setChatAttachments(createScenarioLuaChatAttachments(scenarioLuaFiles));
          setChatAttachmentStatus(`${scenarioLuaFiles.length}개 시나리오 Lua 스크립트를 채팅 첨부로 읽었습니다. 기존 수동 편집창은 변경하지 않았습니다.`);
        } else {
          const firstLuaFile = scenarioLuaFiles[0];
          setSource(firstLuaFile.content);
          setWorkingLua(firstLuaFile.content);
          setLuaFileName(`${scenarioLuaFiles.length} scenario Lua scripts`);
          setActiveLuaFileId(firstLuaFile.id);
          syncLuaFileList(scenarioLuaFiles);
        }
      }
      if (inferredDb.dbFamily || inferredDb.dbVersion) {
        setDatabaseContext((current) => ({
          ...current,
          dbFamily: inferredDb.dbFamily || current.dbFamily,
          dbVersion: inferredDb.dbVersion || current.dbVersion,
          notes: [
            current.notes,
            `Scenario file loaded: ${parsedScenario.fileName}`,
            `Scenario title: ${parsedScenario.title || '(unknown)'}`,
            `Scenario DBVersion: ${parsedScenario.dbVersion || '(unknown)'}`,
            parsedScenario.note,
          ].filter(Boolean).join('\n'),
        }));
      }
      setContext((current) => [
        current,
        `Scenario context: ${parsedScenario.title || parsedScenario.fileName}, ${parsedScenario.dbVersion || 'DB unknown'}, ${parsedScenario.buildNumber || parsedScenario.version || 'build unknown'}.`,
        parsedScenario.extractionSummary ? `Scenario extracted context: ${parsedScenario.extractionSummary}.` : '',
        scenarioLuaFiles.length ? `Scenario Lua scripts loaded: ${scenarioLuaFiles.length}.` : '',
      ].filter(Boolean).join('\n'));
      setLuaFileStatus(extractedCount || scenarioLuaFiles.length
        ? `${file.name} 시나리오 로드 완료: context ${extractedCount} items, Lua scripts ${scenarioLuaFiles.length}. ${parsedScenario.sidecarFileName ? `Sidecar ${parsedScenario.sidecarFileName} 자동 연결. ` : ''}(${loadedAt})`
        : `${file.name} 메타데이터 로드 완료: DB/build/compressed 정보만 AI 요청에 추가했습니다. 내부 Event/Lua 컨텍스트가 필요하면 prepare:scenario로 sidecar를 만들거나 AI adapter 임시 열기를 확인하세요. (${loadedAt})`);
      if (!preserveEditors) {
        setPrimaryAssistantTab(scenarioLuaFiles.length ? 'lua' : 'context');
      }
    } catch {
      setLuaFileStatus(`${file.name}을 CMO .scen/.scenario.xml/.json 컨텍스트로 읽지 못했습니다. 파일이 손상되었거나 지원하지 않는 형식일 수 있습니다.`);
    } finally {
      event.target.value = '';
    }
  };

  const saveLuaFile = async (content, label = '작업 Lua') => {
    const luaText = content || workingLua || source || generatedLua;
    const suggestedName = buildLuaDownloadName(luaFileName, intent.eventName);
    const blob = new Blob([luaText], { type: 'text/x-lua;charset=utf-8' });

    try {
      if ('showSaveFilePicker' in window) {
        const handle = await window.showSaveFilePicker({
          suggestedName,
          types: [
            {
              description: 'Lua script',
              accept: { 'text/x-lua': ['.lua'], 'text/plain': ['.lua'] },
            },
          ],
        });
        const writable = await handle.createWritable();
        await writable.write(blob);
        await writable.close();
        await clearSavedTempSessions();
        setLuaFileName(handle.name);
        setLuaFileStatus(`${label} 저장 완료: 브라우저 저장 대화상자에서 선택한 위치 / ${handle.name} · 자동복구/임시저장 슬롯을 정리했습니다.`);
        return;
      }

      const url = URL.createObjectURL(blob);
      const anchor = document.createElement('a');
      anchor.href = url;
      anchor.download = suggestedName;
      anchor.click();
      URL.revokeObjectURL(url);
      await clearSavedTempSessions();
      setLuaFileStatus(`${label} 저장 요청 완료: 브라우저 기본 다운로드 폴더 / ${suggestedName} · 자동복구/임시저장 슬롯을 정리했습니다.`);
    } catch (error) {
      if (error?.name === 'AbortError') {
        setLuaFileStatus('저장을 취소했습니다. 파일 내용은 현재 화면 상태에 그대로 남아 있습니다.');
        return;
      }
      setLuaFileStatus(`저장 실패: ${error?.message || '브라우저 저장 API를 사용할 수 없습니다.'}`);
    }
  };

  const saveLuaBundle = async () => {
    if (!luaFiles.length) {
      await saveLuaFile(source, '현재 Lua');
      return;
    }

    const filesToSave = luaFiles.map((file) => (
      file.id === activeLuaFileId
        ? { ...file, content: source, analysis: analyzeLua(source), modified: true }
        : file
    ));

    try {
      if ('showDirectoryPicker' in window) {
        const rootHandle = await window.showDirectoryPicker({ mode: 'readwrite' });

        for (const file of filesToSave) {
          const pathParts = String(file.path || file.name || 'script.lua')
            .split(/[\\/]+/)
            .map((part) => part.trim())
            .filter((part) => part && part !== '.' && part !== '..');
          const fileName = pathParts.pop() || `${safeLuaName(file.name || file.id)}.lua`;
          let directoryHandle = rootHandle;

          for (const part of pathParts) {
            directoryHandle = await directoryHandle.getDirectoryHandle(part, { create: true });
          }

          const fileHandle = await directoryHandle.getFileHandle(fileName, { create: true });
          const writable = await fileHandle.createWritable();
          await writable.write(new Blob([file.content || ''], { type: 'text/x-lua;charset=utf-8' }));
          await writable.close();
        }

        setLuaFiles(filesToSave);
        await clearSavedTempSessions();
        setLuaFileStatus(`${filesToSave.length}개 Lua 묶음 저장 완료: 선택한 폴더에 상대경로 구조대로 분리 저장했습니다. 자동복구/임시저장 슬롯을 정리했습니다.`);
        return;
      }

      filesToSave.forEach((file, index) => {
        const blob = new Blob([file.content || ''], { type: 'text/x-lua;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = String(file.path || file.name || `script_${index + 1}.lua`).replace(/[\\/]+/g, '__');
        anchor.click();
        window.setTimeout(() => URL.revokeObjectURL(url), 1500);
      });

      setLuaFiles(filesToSave);
      await clearSavedTempSessions();
      setLuaFileStatus(`${filesToSave.length}개 Lua 파일 저장 요청 완료: 현재 브라우저는 폴더 저장을 지원하지 않아 개별 다운로드로 처리했습니다. 자동복구/임시저장 슬롯을 정리했습니다.`);
    } catch (error) {
      if (error?.name === 'AbortError') {
        setLuaFileStatus('묶음 저장을 취소했습니다. 파일 내용은 현재 화면 상태에 그대로 남아 있습니다.');
        return;
      }
      setLuaFileStatus(`묶음 저장 실패: ${error?.message || '브라우저 폴더 저장 API를 사용할 수 없습니다.'}`);
    }
  };

  const saveTempSessionFile = async () => {
    if (!hasMeaningfulTempSession) {
      setLuaFileStatus('임시저장할 작업 내용이 아직 없습니다. Lua를 불러오거나 목표/객체 정보를 입력한 뒤 다시 시도하세요.');
      return;
    }

    const payload = {
      ...tempSessionPayload,
      savedAt: new Date().toISOString(),
    };

    try {
      window.localStorage.setItem(TEMP_SESSION_MANUAL_STORAGE_KEY, JSON.stringify(payload));
      await writeOriginTempSession(payload, TEMP_SESSION_MANUAL_FILE).catch(() => false);
      await clearAutoSavedSession();
      setTempSessionAvailability((current) => ({ ...current, manual: true, auto: false }));
      setLuaFileStatus(`임시저장 완료: 내부 단일 JSON 슬롯에 덮어썼습니다. 자동복구 세션은 정리했습니다. (${formatTempSessionTime(payload.savedAt)})`);
    } catch (error) {
      setLuaFileStatus(`임시저장 실패: ${error?.message || '브라우저 내부 저장소를 사용할 수 없습니다.'}`);
    }
  };

  const restoreManualTempSession = async () => {
    let payload = null;

    try {
      payload = JSON.parse(window.localStorage.getItem(TEMP_SESSION_MANUAL_STORAGE_KEY) || 'null');
    } catch {
      // Malformed manual temp data is ignored; OPFS fallback can still recover a session.
    }

    if (!payload) {
      payload = await readOriginTempSession(TEMP_SESSION_MANUAL_FILE);
    }

    if (!payload) {
      setLuaFileStatus('불러올 임시저장 슬롯이 없습니다. 임시저장을 먼저 눌러 단일 슬롯을 만들어 주세요.');
      return;
    }

    restoreTempSessionPayload(payload, '임시저장 슬롯');
  };

  const restoreAutoSavedSession = async () => {
    let payload = null;

    try {
      payload = JSON.parse(window.localStorage.getItem(TEMP_SESSION_AUTOSAVE_STORAGE_KEY) || 'null');
    } catch {
      // Malformed localStorage data is ignored; OPFS fallback can still recover a session.
    }

    if (!payload) {
      payload = await readOriginTempSession(TEMP_SESSION_AUTOSAVE_FILE);
    }

    if (!payload) {
      setLuaFileStatus('복구할 자동저장 세션이 아직 없습니다.');
      return;
    }

    restoreTempSessionPayload(payload, '자동 저장 세션');
  };

  const deleteTempSessions = async () => {
    if (!hasStoredTempSession) return;
    await clearSavedTempSessions();
    setLuaFileStatus('자동복구 세션과 임시저장 단일 슬롯을 삭제했습니다. 현재 화면 내용은 그대로 유지됩니다.');
  };

  const updateDatabaseContext = (field, value) => {
    recordHistoryBeforeChange();
    setDatabaseContext((current) => ({ ...current, [field]: value }));
  };

  const updateObjectContext = (field, value) => {
    recordHistoryBeforeChange();
    setObjectContext((current) => ({ ...current, [field]: value }));
  };

  const updateConfirmedContextDraft = useCallback((field, value) => {
    setConfirmedContextDraft((draft) => ({ ...draft, [field]: value }));
  }, []);

  useEffect(() => {
    if (!focusOutputPreviewTab) return;
    setPrimaryAssistantTab('output');
    setAssistantContentWidth(44);
    setOutputPreviewTab(focusOutputPreviewTab);
  }, [focusOutputPreviewTab]);

  const addConfirmedContextEntry = useCallback((entry = confirmedContextDraft) => {
    const normalized = makeConfirmedContextEntry(entry);
    if (!normalized) return;

    recordHistoryBeforeChange();
    setConfirmedContext((items) => normalizeConfirmedContextEntries([...items, normalized]));
    setConfirmedContextDraft((draft) => ({
      ...draft,
      value: '',
      sourceDetail: '',
      notes: '',
    }));
  }, [confirmedContextDraft, recordHistoryBeforeChange]);

  const removeConfirmedContextEntry = useCallback((entryId) => {
    recordHistoryBeforeChange();
    setConfirmedContext((items) => items.filter((entry) => entry.id !== entryId));
  }, [recordHistoryBeforeChange]);

  const promoteDatabaseContextValue = useCallback((field, type, source, sourceDetail = '') => {
    const value = String(databaseContext[field] || '').trim();
    if (!value) return;

    addConfirmedContextEntry({
      type,
      value,
      source,
      sourceDetail,
    });
  }, [addConfirmedContextEntry, databaseContext]);

  const getStateSnapshotContextCandidates = useCallback(() => {
    const snapshot = cmoStateSnapshot.snapshot;
    const context = snapshot?.objectContext && typeof snapshot.objectContext === 'object'
      ? snapshot.objectContext
      : {};

    return SNAPSHOT_CONTEXT_FIELDS.flatMap((field) => (
      (Array.isArray(context[field.field]) ? context[field.field] : [])
        .filter(Boolean)
        .slice(0, 4)
        .map((value) => ({
          type: field.type,
          label: `${field.label}: ${value}`,
          value,
          sourceDetail: `Imported snapshot ${snapshot?.snapshotId || ''}`.trim(),
        }))
    )).slice(0, 12);
  }, [cmoStateSnapshot.snapshot]);

  const promoteStateSnapshotContextValue = useCallback((candidate) => {
    addConfirmedContextEntry({
      type: candidate.type,
      label: candidate.label,
      value: candidate.value,
      source: 'manual-cmo-ui',
      sourceDetail: candidate.sourceDetail,
      notes: 'User-selected value from imported CMO snapshot. Verify in CMO before treating it as authoritative.',
    });
  }, [addConfirmedContextEntry]);

  const updateIntent = (field, value) => {
    recordHistoryBeforeChange();
    setIntent((current) => ({ ...current, [field]: value }));
  };

  const updateObjective = (value) => {
    recordHistoryBeforeChange();
    setObjective(value);
  };

  const updateContext = (value) => {
    recordHistoryBeforeChange();
    setContext(value);
  };

  const updateWorkingLua = (value) => {
    recordHistoryBeforeChange();
    setWorkingLua(value);
  };

  const updateEngineFeedback = (value) => {
    recordHistoryBeforeChange();
    setEngineFeedback(value);
  };

  const applyWorkingLuaDraft = (value) => {
    recordHistoryBeforeChange();
    setWorkingLua(value);
  };

  const resetPromptDraft = () => {
    recordHistoryBeforeChange();
    setPromptDraft('');
    setIsPromptDirty(false);
  };

  const updatePromptDraft = (value) => {
    recordHistoryBeforeChange();
    setPromptDraft(value);
    setIsPromptDirty(true);
  };

  const startContentResize = (event, setWidth = setAssistantContentWidth, minWidth = 35, maxWidth = 84) => {
    const bounds = event.currentTarget.parentElement.getBoundingClientRect();

    const handleMove = (moveEvent) => {
      const nextWidth = ((moveEvent.clientX - bounds.left) / bounds.width) * 100;
      setWidth(Math.min(Math.max(nextWidth, minWidth), maxWidth));
    };

    const stopResize = () => {
      window.removeEventListener('pointermove', handleMove);
      window.removeEventListener('pointerup', stopResize);
    };

    window.addEventListener('pointermove', handleMove);
    window.addEventListener('pointerup', stopResize);
  };

  const startLuaFrameResize = (event) => {
    event.preventDefault();
    const startY = event.clientY;
    const startHeight = luaFrameHeight;
    const containerHeight = event.currentTarget.parentElement.getBoundingClientRect().height;

    const handleMove = (moveEvent) => {
      const nextHeight = startHeight + (moveEvent.clientY - startY);
      const maxHeight = Math.max(240, containerHeight - 220);
      setLuaFrameHeight(Math.min(Math.max(nextHeight, 150), maxHeight));
    };

    const stopResize = () => {
      window.removeEventListener('pointermove', handleMove);
      window.removeEventListener('pointerup', stopResize);
    };

    window.addEventListener('pointermove', handleMove);
    window.addEventListener('pointerup', stopResize);
  };

  const renderLuaTab = () => (
    <div className="assistant-tab-grid lua-analysis-layout resizable-tab-layout" style={{ '--assistant-left-column': `${assistantContentWidth}%` }}>
      <div className="assistant-card editor-major-card">
        <div className="assistant-card-title">
          <ScanText size={16} />
          <span>CMO에서 가져온 Lua</span>
        </div>
        <p className="assistant-help-text">
          .lua 파일을 열면 이 입력창과 AI 요청문 Current Lua에 반영됩니다. 묶음/폴더를 열면 파일별 분석과 통합 AI 요청문이 함께 생성됩니다.
        </p>
        <div className="assistant-history-toolbar compact">
          <div className="assistant-history-toolbar-actions">
            <button
              className="btn btn-mini btn-ghost"
              type="button"
              onClick={rollbackAssistantHistory}
              disabled={undoStack.length === 0}
              title={`수정 이전으로 이동: ${undoStack.length}/${MAX_HISTORY_ENTRIES}`}
            >
              <Undo2 size={13} />
              이전 {undoStack.length}/{MAX_HISTORY_ENTRIES}
            </button>
            <button
              className="btn btn-mini btn-ghost"
              type="button"
              onClick={redoAssistantHistory}
              disabled={redoStack.length === 0}
              title={`롤백 취소 후 앞으로 이동: ${redoStack.length}/${MAX_HISTORY_ENTRIES}`}
            >
              <Redo2 size={13} />
              앞으로 {redoStack.length}/{MAX_HISTORY_ENTRIES}
            </button>
          </div>
        </div>
        <div className={`lua-editor-stage ${luaFiles.length > 0 ? 'has-bundle-panel' : ''}`}>
          {luaFiles.length > 0 && (
            <div className={`lua-bundle-panel ${luaBundleExpanded ? 'expanded' : 'collapsed'}`}>
              <div className="lua-bundle-summary">
                <button
                  className="lua-bundle-toggle"
                  type="button"
                  onClick={() => setLuaBundleExpanded((current) => !current)}
                  aria-expanded={luaBundleExpanded}
                >
                  {luaBundleExpanded ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
                </button>
                <strong>{luaFiles.length === 1 ? '단일 Lua 파일' : `${luaFiles.length}개 Lua 파일 묶음`}</strong>
                <span>{luaBundleAnalysis.totalLines} lines · {luaBundleAnalysis.apiCalls.length} APIs · {luaBundleAnalysis.dbIdentifierHints.length + luaBundleAnalysis.guidHints.length} IDs</span>
              </div>
              {luaBundleExpanded && (
              <div className="lua-file-list">
                {luaFiles.map((file) => (
                  <button
                    key={file.id}
                    className={activeLuaFileId === file.id ? 'active' : ''}
                    type="button"
                    onClick={() => setActiveLuaFile(file.id)}
                    title={file.path}
                  >
                    <span>{file.modified ? '* ' : ''}{file.path}</span>
                    <small>{file.analysis.lineCount} lines / {file.analysis.apiCalls.length} APIs</small>
                  </button>
                ))}
              </div>
              )}
            </div>
          )}
          <LuaCodeEditor
            className="assistant-textarea lua-source-editor mono-input tall-editor"
            value={source}
            onChange={updateSource}
            placeholder={SAMPLE_LUA}
            ariaLabel="CMO에서 가져온 Lua"
          />
        </div>
      </div>

      <button
        className="assistant-tab-resize"
        type="button"
        aria-label="Lua 입력 영역과 분석 영역 폭 조절"
        onPointerDown={startContentResize}
      />

      <div className="assistant-card analysis-major-card">
        <Suspense fallback={<div className="lua-reference-helper">Lua 참조 도우미를 불러오는 중입니다.</div>}>
          <LuaEditorReferenceHelper
            luaText={source}
            onDraftQuestion={(draft) => {
              draftAiChatFollowUp(draft);
              setPrimaryAssistantTab('output');
            }}
          />
        </Suspense>
        <div className="lua-frame-section" style={{ '--lua-frame-height': `${luaFrameHeight}px` }}>
          <div className="assistant-card-title">
            <Clipboard size={16} />
            <span>작업 프레임 / 자동 분석</span>
          </div>
          <div className="task-frame-grid">
            <label>
              수정 목표
              <input value={objective} onChange={(event) => updateObjective(event.target.value)} />
            </label>
            <label>
              CMO 내부에서 확인한 객체 정보
              <textarea
                value={context}
                onChange={(event) => updateContext(event.target.value)}
                rows={4}
                placeholder="예: Side=Blue/Red, RP=CAP-1~4, Mission=CAP Station, Unit GUID=..."
              />
            </label>
          </div>
        </div>
        <button
          className="lua-analysis-row-resize"
          type="button"
          aria-label="작업 프레임과 자동 분석 영역 높이 조절"
          onPointerDown={startLuaFrameResize}
        />
        <div className="lua-auto-analysis-section">
          <div className="assistant-card-title inline-title">
            <Clipboard size={16} />
            <span>{luaFiles.length > 1 ? '선택 파일 자동 분석' : '자동 분석'}</span>
          </div>
          <div className="analysis-grid">
            <div className="analysis-stat">
              <span>Lines</span>
              <strong>{analysis.lineCount}</strong>
            </div>
            <div className="analysis-stat">
              <span>Chars</span>
              <strong>{analysis.charCount}</strong>
            </div>
            <div className="analysis-stat">
              <span>APIs</span>
              <strong>{analysis.apiCalls.length}</strong>
            </div>
            <div className="analysis-stat">
              <span>IDs</span>
              <strong>{analysis.dbIdentifierHints.length + analysis.guidHints.length}</strong>
            </div>
          </div>

          {luaFiles.length > 1 && (
          <div className={`analysis-section bundle-analysis-section ${bundleApiSummaryExpanded ? 'expanded' : 'collapsed'}`}>
            <button
              className="bundle-summary-toggle"
              type="button"
              onClick={() => setBundleApiSummaryExpanded((current) => !current)}
              aria-expanded={bundleApiSummaryExpanded}
            >
              {bundleApiSummaryExpanded ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
              <strong>Bundle API Summary</strong>
              <span>{luaBundleAnalysis.fileCount} files · {luaBundleAnalysis.totalLines} lines · {luaBundleAnalysis.apiCalls.length} APIs · {luaBundleAnalysis.dbIdentifierHints.length + luaBundleAnalysis.guidHints.length} IDs</span>
            </button>
            {bundleApiSummaryExpanded && (
            <div className="bundle-analysis-body">
              <div className="analysis-grid bundle-stat-grid">
                <div className="analysis-stat">
                  <span>Files</span>
                  <strong>{luaBundleAnalysis.fileCount}</strong>
                </div>
                <div className="analysis-stat">
                  <span>Lines</span>
                  <strong>{luaBundleAnalysis.totalLines}</strong>
                </div>
                <div className="analysis-stat">
                  <span>APIs</span>
                  <strong>{luaBundleAnalysis.apiCalls.length}</strong>
                </div>
                <div className="analysis-stat">
                  <span>IDs</span>
                  <strong>{luaBundleAnalysis.dbIdentifierHints.length + luaBundleAnalysis.guidHints.length}</strong>
                </div>
              </div>
              {renderChipList(luaBundleAnalysis.apiCalls, '묶음 전체 API 없음')}
              <div className="lua-bundle-table">
                {luaFiles.map((file) => (
                  <div key={file.id} className={activeLuaFileId === file.id ? 'active' : ''}>
                    <strong>{file.path}</strong>
                    <span>{file.analysis.lineCount} lines</span>
                    <span>{file.analysis.apiCalls.join(', ') || 'API 없음'}</span>
                  </div>
                ))}
              </div>
            </div>
            )}
          </div>
        )}

        {[
          ['Detected APIs', analysis.apiCalls, '감지된 API 없음'],
          ['Event / Trigger Hints', [...analysis.eventCalls, ...analysis.triggerHints], '감지된 이벤트 힌트 없음'],
          ['Object Name Hints', analysis.quotedNames, 'CMO 객체 이름 힌트 없음'],
          ['DB / Loadout ID Hints', analysis.dbIdentifierHints, 'Lua 내부 DBID/Loadout ID 힌트 없음'],
          ['Scenario Unit GUID Hints', analysis.guidHints, 'Lua 내부 GUID 힌트 없음'],
        ].map(([title, items, fallback]) => (
          <div className="analysis-section" key={title}>
            <h3>{title}</h3>
            {renderChipList(items, fallback, title.includes('GUID') ? 'guid-chip-list' : '')}
          </div>
        ))}

        <div className="analysis-section auto-helper-panel">
          <h3>CMO Auto Helper</h3>
          <div className="auto-helper-list">
            {autoHelperHints.map((hint) => (
              <article key={hint.title} className={`auto-helper-card ${hint.type}`}>
                <strong>{hint.title}</strong>
                <p>{hint.body}</p>
              </article>
            ))}
          </div>
        </div>

        <div className="analysis-section">
          <h3>Risk Checklist</h3>
          <ul className="risk-list">
            {([...analysis.risks, ...databaseWarnings].length ? [...analysis.risks, ...databaseWarnings] : ['눈에 띄는 위험 신호는 아직 없습니다. 그래도 CMO 내부에서 dry-run을 권장합니다.']).map((risk) => (
              <li key={risk}>{risk}</li>
            ))}
          </ul>
        </div>

        <div className="analysis-section">
          <h3>CMO ID Workflow</h3>
          <ul className="assistant-hint-list">
            <li>DBID/Loadout ID: Game 또는 Editor 메뉴의 Database Viewer에서 현재 DB 버전을 먼저 확인한 뒤 조회합니다.</li>
            <li>배치된 유닛 GUID: 유닛 우클릭 후 Scenario Editor {'>'} Copy unit ID to clipboard를 사용합니다.</li>
            <li>Lua 생성 시 DBID는 새 유닛/로드아웃/무장/센서용, GUID는 이미 배치된 유닛 조작용으로 구분합니다.</li>
          </ul>
        </div>
        </div>
      </div>
    </div>
  );

  const renderContextTab = () => (
    <div className="assistant-tab-grid context-layout resizable-tab-layout" style={{ '--assistant-left-column': `${assistantContentWidth}%` }}>
      <div className="assistant-card">
        <div className="assistant-card-title">
          <Database size={16} />
          <span>Database Viewer / Clipboard Context</span>
        </div>
        <p className="assistant-help-text">
          DB Viewer에서 확인한 DBID/Loadout ID와, 배치 유닛 우클릭 메뉴의 Copy unit ID to clipboard 값을 기록합니다.
        </p>
        <div className="database-context-grid">
          <label>DB 계열<select value={databaseContext.dbFamily} onChange={(event) => updateDatabaseContext('dbFamily', event.target.value)}><option value="DB3000">DB3000</option><option value="CWDB">CWDB</option><option value="Other">Other</option></select></label>
          <label>DB 버전<input value={databaseContext.dbVersion} onChange={(event) => updateDatabaseContext('dbVersion', event.target.value)} placeholder="예: v516" /></label>
          <label>Platform DBID<input value={databaseContext.platformDbid} onChange={(event) => updateDatabaseContext('platformDbid', event.target.value)} placeholder="예: 2990" /></label>
          <label>Loadout ID<input value={databaseContext.loadoutId} onChange={(event) => updateDatabaseContext('loadoutId', event.target.value)} placeholder="예: 1404" /></label>
          <label>Weapon DBID<input value={databaseContext.weaponDbid} onChange={(event) => updateDatabaseContext('weaponDbid', event.target.value)} /></label>
          <label>Sensor DBID<input value={databaseContext.sensorDbid} onChange={(event) => updateDatabaseContext('sensorDbid', event.target.value)} /></label>
          <label>Mount DBID<input value={databaseContext.mountDbid} onChange={(event) => updateDatabaseContext('mountDbid', event.target.value)} /></label>
          <label>Copied Unit GUID / Name<input value={databaseContext.unitGuid} onChange={(event) => updateDatabaseContext('unitGuid', event.target.value)} placeholder="우클릭 > Scenario Editor > Copy unit ID" /></label>
        </div>
        <label>DB/ID 메모</label>
        <textarea
          className="database-notes-textarea"
          value={databaseContext.notes}
          onChange={(event) => updateDatabaseContext('notes', event.target.value)}
          rows={12}
        />
        <div className="assistant-actions">
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('unitGuid', 'unitGuid', 'copy-unit-guid', 'Copied unit ID')}>
            Unit GUID 확정
          </button>
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('platformDbid', 'dbid', 'database-viewer', 'Platform DBID')}>
            Platform DBID 확정
          </button>
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('loadoutId', 'loadout', 'database-viewer', 'Loadout ID')}>
            Loadout ID 확정
          </button>
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('notes', 'note', 'manual-cmo-ui', 'DB/ID memo')}>
            메모 확정
          </button>
        </div>
      </div>

      <div className="assistant-card">
        <div className="assistant-card-title">
          <ListChecks size={16} />
          <span>Confirmed Context Workspace</span>
        </div>
        <p className="assistant-help-text">
          CMO에서 확인한 값만 보관합니다. AI는 이 값을 추측으로 대체하지 않고, 누락된 값은 다시 질문해야 합니다.
        </p>

        {confirmedContextGroups.length > 0 ? (
          <div className="object-context-summary-grid" aria-label="Confirmed CMO context values">
            {confirmedContextGroups.map((group) => (
              <div key={group.type} className="object-context-summary active">
                <span>{group.label}</span>
                <strong>{group.entries.length}</strong>
              </div>
            ))}
          </div>
        ) : (
          <p className="assistant-help-text">아직 확정 컨텍스트가 없습니다. CMO UI나 Database Viewer에서 확인한 값만 추가하세요.</p>
        )}

        {confirmedContextGroups.map((group) => (
          <div key={group.type} className="analysis-section">
            <h3>{group.label}</h3>
            <ul className="assistant-hint-list">
              {group.entries.map((entry) => (
                <li key={entry.id}>
                  <strong>{entry.label}</strong>
                  {entry.label !== entry.value ? ` = ${entry.value}` : ''}
                  <span> · {entry.sourceLabel}</span>
                  <button
                    className="btn btn-mini btn-ghost"
                    type="button"
                    onClick={() => removeConfirmedContextEntry(entry.id)}
                  >
                    제거
                  </button>
                </li>
              ))}
            </ul>
          </div>
        ))}

        <div className="database-context-grid">
          <label>
            Type
            <select value={confirmedContextDraft.type} onChange={(event) => updateConfirmedContextDraft('type', event.target.value)}>
              {CONFIRMED_CONTEXT_TYPES.map((typeOption) => (
                <option key={typeOption.id} value={typeOption.id}>{typeOption.label}</option>
              ))}
            </select>
          </label>
          <label>
            Source
            <select value={confirmedContextDraft.source} onChange={(event) => updateConfirmedContextDraft('source', event.target.value)}>
              {CONFIRMED_CONTEXT_SOURCES.map((sourceOption) => (
                <option key={sourceOption.id} value={sourceOption.id}>{sourceOption.label}</option>
              ))}
            </select>
          </label>
          <label>
            Value
            <input
              value={confirmedContextDraft.value}
              onChange={(event) => updateConfirmedContextDraft('value', event.target.value)}
              placeholder="예: Blue, CAP North, 2990, 2f25..."
            />
          </label>
          <label>
            Source detail
            <input
              value={confirmedContextDraft.sourceDetail}
              onChange={(event) => updateConfirmedContextDraft('sourceDetail', event.target.value)}
              placeholder="예: Database Viewer v516"
            />
          </label>
        </div>
        <label>Notes</label>
        <textarea
          className="database-notes-textarea"
          value={confirmedContextDraft.notes}
          onChange={(event) => updateConfirmedContextDraft('notes', event.target.value)}
          rows={3}
        />
        <button className="btn btn-secondary" type="button" onClick={() => addConfirmedContextEntry()}>
          확정 컨텍스트 추가
        </button>
      </div>

      <button
        className="assistant-tab-resize"
        type="button"
        aria-label="DB 컨텍스트와 객체 레지스트리 영역 폭 조절"
        onPointerDown={startContentResize}
      />

      <div className="assistant-card object-context-card">
        <div className="assistant-card-title split-card-title">
          <div className="card-title-main">
            <ListChecks size={16} />
            <span>Object Context Registry</span>
          </div>
          <button className="btn btn-mini btn-ghost" type="button" onClick={applyCurrentLuaToObjectContext}>
            현재 Lua에서 채움
          </button>
        </div>
        <p className="assistant-help-text">
          CMO 내부 Editor, Mission Editor, Ref. Point Manager, Special Actions에서 이미 만든 객체명만 적습니다. .lua 파일/폴더를 열면 추출 가능한 값은 자동 병합됩니다.
        </p>
        <div className="object-context-summary-grid">
          {OBJECT_CONTEXT_TABS.filter((tab) => tab.id !== 'notes').map((tab) => (
            <button
              key={tab.id}
              className={`object-context-summary ${activeObjectContextTab === tab.id ? 'active' : ''}`}
              type="button"
              onClick={() => setActiveObjectContextTab(tab.id)}
            >
              <span>{tab.label}</span>
              <strong>{splitContextLines(objectContext[tab.field]).length}</strong>
            </button>
          ))}
        </div>
        <div className="object-context-tabs" aria-label="Object context editor tabs">
          {OBJECT_CONTEXT_TABS.map((tab) => (
            <button
              key={tab.id}
              className={`object-context-tab ${activeObjectContextTab === tab.id ? 'active' : ''}`}
              type="button"
              onClick={() => setActiveObjectContextTab(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>
        <section className="object-context-editor">
          <div className="object-context-editor-head">
            <strong>{activeObjectContext.label}</strong>
            <p>{activeObjectContext.helper}</p>
          </div>
          <textarea
            className="object-context-textarea"
            value={objectContext[activeObjectContext.field]}
            onChange={(event) => updateObjectContext(activeObjectContext.field, event.target.value)}
            placeholder={activeObjectContext.placeholder}
            spellCheck={false}
          />
        </section>
      </div>
    </div>
  );

  const renderIntentTab = () => (
    <Suspense fallback={<div className="assistant-card">Intent Planner를 불러오는 중입니다.</div>}>
      <IntentPlannerPanel
        intentContentWidth={intentContentWidth}
        intent={intent}
        triggerTypes={TRIGGER_TYPES}
        actionTypes={ACTION_TYPES}
        activeIntentDetailTab={activeIntentDetailTab}
        onIntentChange={updateIntent}
        onIntentDetailTabChange={setActiveIntentDetailTab}
        onResizeStart={(event) => startContentResize(event, setIntentContentWidth, 44, 88)}
        eventPlan={eventPlan}
        uiSetupText={uiSetupText}
      />
    </Suspense>
  );

  const renderAiAdapterReadiness = () => (
    <div className={`ai-readiness-panel ${aiAdapterReadiness.state}`}>
      <div>
        <strong>AI Adapter</strong>
        <span>{aiAdapterReadiness.message}</span>
      </div>
      <div className="ai-readiness-meta">
        <span>{aiAdapterReadiness.providerType || 'provider 미확인'}</span>
        <span>{aiAdapterReadiness.model || 'model 미설정'}</span>
        {activeAiProviderOverride && <span>profile {activeAiProviderOverride.name}</span>}
        <span>
          {aiAdapterReadiness.generationMode
            ? (aiAdapterReadiness.generationMode === 'provider-default' ? 'provider 기본값' : 'manual 생성값')
            : '생성 설정 미확인'}
        </span>
        {aiAdapterReadiness.apiKeyPreview && <span>key {aiAdapterReadiness.apiKeyPreview}</span>}
      </div>
      <div className="ai-readiness-controls">
        <Suspense fallback={<span className="ai-profile-selector-loading">프로필 불러오는 중</span>}>
          <AiProviderProfileSelector
            disabled={isAiCalling}
            onProfileChange={setActiveAiProviderOverride}
          />
        </Suspense>
        <button
          className="btn btn-mini btn-ghost"
          type="button"
          onClick={refreshAiAdapterReadiness}
          disabled={isCheckingAiAdapter || isAiCalling}
        >
          {isCheckingAiAdapter ? '확인 중' : '상태 새로고침'}
        </button>
      </div>
    </div>
  );

  const renderOutputTab = () => {
    const previewContent = {
      generated: generatedLua,
      setup: uiSetupText,
      prompt: effectivePrompt,
      chat: aiResponse || aiCallStatus.message,
      ai: aiResponse || aiCallStatus.message,
      smoke: smokeTest,
    };
    const previewTitle = OUTPUT_PREVIEW_TABS.find((tab) => tab.id === outputPreviewTab)?.label || 'Lua 초안';
    const previewTone = classifyPreviewTone(previewContent[outputPreviewTab], outputPreviewTab);

    return (
      <div className="assistant-tab-grid output-layout resizable-tab-layout" style={{ '--assistant-left-column': `${assistantContentWidth}%` }}>
        <div className="assistant-card editor-major-card">
          <div className="assistant-card-title">
            <FileCode2 size={16} />
            <span>Generated Lua / Working Draft</span>
          </div>
          {renderAiAdapterReadiness()}
          <div className="assistant-actions">
            <button className="btn btn-primary" type="button" onClick={() => applyWorkingLuaDraft(generatedLua)}><FileCode2 size={15} />초안 적용</button>
            <button className="btn btn-ghost" type="button" onClick={() => applyWorkingLuaDraft(source)}>원본을 작업 코드로</button>
            <button className="btn btn-primary" type="button" onClick={() => copyText('lua', workingLua || generatedLua)}>{copied === 'lua' ? <Check size={15} /> : <Copy size={15} />}Lua 복사</button>
            <button className="btn btn-ghost" type="button" onClick={() => copyText('generated', generatedLua)}>{copied === 'generated' ? <Check size={15} /> : <Copy size={15} />}생성 초안 복사</button>
            <button className="btn btn-ghost" type="button" onClick={() => copyText('smoke', smokeTest)}>{copied === 'smoke' ? <Check size={15} /> : <Fingerprint size={15} />}ID 테스트 복사</button>
            <button className="btn btn-primary" type="button" onClick={() => copyText('prompt', effectivePrompt)}>{copied === 'prompt' ? <Check size={15} /> : <Copy size={15} />}Prompt 복사</button>
            <button className="btn btn-primary" type="button" onClick={callAiAdapter} disabled={isAiCalling}><Wand2 size={15} />{isAiCalling ? 'AI 호출 중' : 'AI 호출'}</button>
            <button
              className="btn btn-ghost"
              type="button"
              onClick={applyAiLuaBlock}
              disabled={!canApplyAiLua}
              title={canApplyAiLua ? '검증 게이트를 통과한 Lua 초안을 Working Draft에 적용합니다. CMO 엔진 검증은 별도 필요합니다.' : aiApplyBlockedReason || 'AI 응답이 적용 가능한 Lua 형식이 아닙니다.'}
            >
              AI Lua 적용
            </button>
            <button className="btn btn-ghost" type="button" onClick={() => saveLuaFile(workingLua || generatedLua, '작업 Lua')}><Save size={15} />작업 Lua 저장</button>
            <button
              className="btn btn-secondary"
              type="button"
              onClick={() => saveAiLuaSidecar({ dryRun: true })}
              disabled={!canApplyAiLua || luaSidecarSave.state === 'loading'}
              title="CMO Lua root 아래 AiAssist 파일 저장 위치와 RunScript 명령을 먼저 확인합니다. 실행은 CMO에서 직접 해야 합니다."
            >
              <FileCode2 size={15} />
              CMO 파일 준비
            </button>
            <button
              className="btn btn-secondary"
              type="button"
              onClick={() => saveAiLuaSidecar({ dryRun: false })}
              disabled={!canApplyAiLua || luaSidecarSave.state === 'loading'}
              title="paste-ready Lua 초안을 CMO Lua root의 AiAssist 폴더에 저장합니다. CMO 엔진 검증과 실행은 수동으로 해야 합니다."
            >
              <Save size={15} />
              CMO Lua 폴더 저장
            </button>
            <button
              className="btn btn-secondary"
              type="button"
              onClick={refreshCmoLogFeedback}
              disabled={cmoLogFeedback.state === 'loading'}
              title="CMO Logs 폴더에서 최근 ExceptionLog/LuaHistory를 읽기 전용으로 가져옵니다. AI는 자동 호출하지 않습니다."
            >
              <ScanText size={15} />
              {cmoLogFeedback.state === 'loading' ? 'CMO 로그 확인 중' : 'CMO 로그 확인'}
            </button>
          </div>
          {luaSidecarSave.message ? (
            <div className={`ai-adapter-status inline ${luaSidecarSave.state === 'ok' ? 'ok' : luaSidecarSave.state === 'error' ? 'error' : 'loading'}`}>
              {luaSidecarSave.message}
            </div>
          ) : null}
          {luaSidecarSave.loaderSnippet ? (
            <pre className="working-draft-preview">{luaSidecarSave.loaderSnippet}</pre>
          ) : null}
          {cmoLogFeedback.message ? (
            <div className={`ai-adapter-status inline ${cmoLogFeedback.state === 'ok' ? 'ok' : cmoLogFeedback.state === 'error' ? 'error' : 'loading'}`}>
              {cmoLogFeedback.message}
            </div>
          ) : null}
          {cmoLogFeedback.files.length ? (
            <div className="analysis-section">
              <h3>CMO 로그 스냅샷</h3>
              <ul className="assistant-hint-list">
                {cmoLogFeedback.files.slice(0, 3).map((file) => (
                  <li key={`${file.kind}-${file.fileName}`}>
                    <strong>{file.fileName}</strong>
                    {Array.isArray(file.entries) && file.entries.length ? (
                      <span>{` — ${file.entries.slice(0, 3).join(' / ')}`}</span>
                    ) : (
                      <span> — 표시할 최근 항목 없음</span>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          ) : null}
          {cmoLogFeedback.followUpDraft ? (
            <div className="analysis-section">
              <h3>후속 질문 초안</h3>
              <p>로그 내용은 검토용 초안으로만 채워집니다. 사용자가 확인해야 AI 채팅에 넣고 다시 호출할 수 있습니다.</p>
              <pre className="working-draft-preview">{cmoLogFeedback.followUpDraft}</pre>
              <div className="assistant-actions">
                <button className="btn btn-secondary" type="button" onClick={draftCmoLogFollowUp}>
                  <Clipboard size={15} />
                  AI 채팅에 넣기
                </button>
                <button className="btn btn-ghost" type="button" onClick={() => copyText('cmo-log-follow-up', cmoLogFeedback.followUpDraft)}>
                  {copied === 'cmo-log-follow-up' ? <Check size={15} /> : <Copy size={15} />}
                  초안 복사
                </button>
              </div>
            </div>
          ) : null}
          <div className="analysis-section">
            <h3>CMO 상태 스냅샷 가져오기</h3>
            <p>
              CMO에서 직접 복사한 Tool_DumpEvents 또는 ScenEdit_GetEvent 출력만 붙여넣습니다.
              가져온 스냅샷은 실시간 연결이 아닙니다.
            </p>
            <label>
              Source hint
              <select
                value={cmoStateSnapshot.sourceHint}
                onChange={(event) => setCmoStateSnapshot((current) => ({ ...current, sourceHint: event.target.value }))}
              >
                {CMO_STATE_SNAPSHOT_SOURCE_HINTS.map((sourceOption) => (
                  <option key={sourceOption.id} value={sourceOption.id}>{sourceOption.label}</option>
                ))}
              </select>
            </label>
            <textarea
              className="engine-feedback-input"
              value={cmoStateSnapshot.text}
              onChange={(event) => setCmoStateSnapshot((current) => ({ ...current, text: event.target.value }))}
              rows={6}
              placeholder="CMO Lua Console에서 Tool_DumpEvents() 또는 ScenEdit_GetEvent(...) 출력 텍스트를 복사해 붙여넣으세요."
            />
            <div className="assistant-actions">
              <button
                className="btn btn-secondary"
                type="button"
                onClick={importCmoStateSnapshotFromText}
                disabled={cmoStateSnapshot.state === 'loading'}
                title="붙여넣은 CMO 상태 텍스트를 어댑터에서 정화하고 bounded snapshot으로 가져옵니다. AI는 자동 호출하지 않습니다."
              >
                <ScanText size={15} />
                {cmoStateSnapshot.state === 'loading' ? '스냅샷 가져오는 중' : '스냅샷 가져오기'}
              </button>
            </div>
          </div>
          {cmoStateSnapshot.message ? (
            <div className={`ai-adapter-status inline ${cmoStateSnapshot.state === 'ok' ? 'ok' : cmoStateSnapshot.state === 'error' ? 'error' : 'loading'}`}>
              {cmoStateSnapshot.message}
            </div>
          ) : null}
          {cmoStateSnapshot.snapshot ? (
            <div className="analysis-section">
              <h3>가져온 CMO 스냅샷</h3>
              <p>
                {cmoStateSnapshot.snapshot.importedAt || '시간 정보 없음'} · source {cmoStateSnapshot.snapshot.source?.type || 'unknown'} · live=false
              </p>
              <ul className="assistant-hint-list">
                <li>Events: {cmoStateSnapshot.snapshot.summary?.eventCount ?? 0} / {cmoStateSnapshot.snapshot.summary?.totalEventCount ?? cmoStateSnapshot.snapshot.summary?.eventCount ?? 0}</li>
                <li>Special Actions: {cmoStateSnapshot.snapshot.summary?.specialActionCount ?? 0} / {cmoStateSnapshot.snapshot.summary?.totalSpecialActionCount ?? cmoStateSnapshot.snapshot.summary?.specialActionCount ?? 0}</li>
                <li>Detected APIs: {cmoStateSnapshot.snapshot.summary?.detectedApiCount ?? 0}</li>
                <li>Warnings: {cmoStateSnapshot.snapshot.summary?.warningCount ?? 0}</li>
              </ul>
              {Array.isArray(cmoStateSnapshot.snapshot.events) && cmoStateSnapshot.snapshot.events.length ? (
                <ul className="assistant-hint-list">
                  {cmoStateSnapshot.snapshot.events.slice(0, 5).map((event, index) => (
                    <li key={`${event.id || event.name || 'event'}-${index}`}>
                      <strong>{event.name || event.description || event.id || 'Unnamed event'}</strong>
                      {Array.isArray(event.luaScriptPreviews) && event.luaScriptPreviews.length ? (
                        <span> · Lua preview {event.luaScriptPreviews.length}개</span>
                      ) : null}
                    </li>
                  ))}
                </ul>
              ) : null}
              {getStateSnapshotContextCandidates().length ? (
                <div className="assistant-actions">
                  {getStateSnapshotContextCandidates().slice(0, 6).map((candidate) => (
                    <button
                      key={`${candidate.type}-${candidate.value}`}
                      className="btn btn-mini"
                      type="button"
                      onClick={() => promoteStateSnapshotContextValue(candidate)}
                      title="가져온 스냅샷에서 사용자가 선택한 값만 Confirmed Context에 추가합니다."
                    >
                      {candidate.label} 확정
                    </button>
                  ))}
                </div>
              ) : null}
            </div>
          ) : null}
          {cmoStateSnapshot.followUpDraft ? (
            <div className="analysis-section">
              <h3>스냅샷 후속 질문 초안</h3>
              <p>가져온 스냅샷 기반 초안입니다. 사용자가 검토한 뒤 필요할 때만 AI 채팅에 넣으세요.</p>
              <pre className="working-draft-preview">{cmoStateSnapshot.followUpDraft}</pre>
              <div className="assistant-actions">
                <button className="btn btn-secondary" type="button" onClick={draftCmoStateSnapshotFollowUp}>
                  <Clipboard size={15} />
                  후속 질문 초안 만들기
                </button>
                <button className="btn btn-ghost" type="button" onClick={() => copyText('cmo-state-snapshot-follow-up', cmoStateSnapshot.followUpDraft)}>
                  {copied === 'cmo-state-snapshot-follow-up' ? <Check size={15} /> : <Copy size={15} />}
                  초안 복사
                </button>
              </div>
            </div>
          ) : null}
          <LuaCodeEditor
            className="assistant-working-lua output-working-lua mono-input tall-editor"
            value={workingLua}
            onChange={updateWorkingLua}
            placeholder="AI가 수정한 Lua 또는 직접 정리한 Lua 초안을 여기에 보관하세요. CMO 엔진 검증은 별도 필요합니다."
            ariaLabel="Generated Lua / Working Draft"
          />
          <div className="output-diagnostics-panel">
            <label>CMO 실행 결과 / 오류 로그</label>
            <textarea className="engine-feedback-input" value={engineFeedback} onChange={(event) => updateEngineFeedback(event.target.value)} rows={5} placeholder="Lua Console 또는 Event 실행 결과, 오류 메시지를 붙여넣으면 수정 방향을 추정합니다." />
            <ul className="assistant-hint-list feedback-hints">{engineHints.map((hint) => <li key={hint}>{hint}</li>)}</ul>
            <div className="auto-helper-panel output-auto-helper">
              <h3>Working Lua Auto Helper</h3>
              <div className="auto-helper-list">
                {workingAutoHelperHints.map((hint) => (
                  <article key={hint.title} className={`auto-helper-card ${hint.type}`}>
                    <strong>{hint.title}</strong>
                    <p>{hint.body}</p>
                  </article>
                ))}
              </div>
            </div>
          </div>
        </div>

        <button
          className="assistant-tab-resize"
          type="button"
          aria-label="작업 코드와 미리보기 영역 폭 조절"
          onPointerDown={startContentResize}
        />

        <div className="assistant-card preview-major-card">
          <div className="assistant-card-title">
            <Clipboard size={16} />
            <span>{previewTitle} 미리보기</span>
          </div>
          {(aiResponse || isAiCalling || aiCallStatus.state === 'error') && (
            <div className={`ai-workflow-state-card ${aiWorkflowState.tone}`}>
              <span>{aiWorkflowState.label}</span>
              <div>
                <strong>{aiWorkflowState.title}</strong>
                <p>{aiWorkflowState.body}</p>
              </div>
            </div>
          )}
          <div className="assistant-preview-tabs">
            {OUTPUT_PREVIEW_TABS.map((tab) => (
              <button
                key={tab.id}
                className={outputPreviewTab === tab.id ? 'active' : ''}
                type="button"
                onClick={() => setOutputPreviewTab(tab.id)}
              >
                {tab.label}
              </button>
            ))}
          </div>
          {outputPreviewTab === 'prompt' && (
            <div className="prompt-edit-toolbar">
              <span>{isPromptDirty ? '수동 편집본 사용 중' : '자동 요청문 동기화 중'}</span>
              <button
                className="btn btn-mini btn-ghost"
                type="button"
                onClick={resetPromptDraft}
              >
                자동 생성본 다시 적용
              </button>
            </div>
          )}
          {outputPreviewTab === 'ai' && (
            <div className="prompt-edit-toolbar ai-response-toolbar">
              <span className={`ai-adapter-status inline ${aiCallStatus.state}`}>{aiCallStatus.message}</span>
              {aiResponse && !canApplyAiLua && (
                <span className="ai-adapter-status inline error">
                  적용 차단 · {aiApplyBlockedReason || '추가 확인 필요'}
                </span>
              )}
              <button
                className="btn btn-mini btn-ghost"
                type="button"
                onClick={() => copyText('ai-response', aiResponse)}
                disabled={!aiResponse}
              >
                {copied === 'ai-response' ? '복사됨' : 'AI 응답 복사'}
              </button>
              <button
                className="btn btn-mini btn-primary"
                type="button"
                onClick={applyAiLuaBlock}
                disabled={!canApplyAiLua}
                title={canApplyAiLua ? '검증 게이트를 통과한 Lua 초안을 Working Draft에 적용합니다. CMO 엔진 검증은 별도 필요합니다.' : aiApplyBlockedReason || 'AI 응답이 적용 가능한 Lua 형식이 아닙니다.'}
              >
                Lua 코드블록 적용
              </button>
            </div>
          )}
          {outputPreviewTab === 'ai' && aiResponse && (
            <Suspense fallback={<div className="ai-response-loading">AI 응답 검토 패널을 불러오는 중입니다.</div>}>
              <AiResponseReviewPanel
                parsedResponse={aiParsedResponse}
                workflowState={aiWorkflowState}
                canApplyLua={canApplyAiLua}
                applyBlockedReason={aiApplyBlockedReason}
                pruningAudit={aiPruningAudit}
                confirmedContext={confirmedContext}
                onApplyLua={applyAiLuaBlock}
                onDraftFollowUp={draftAiChatFollowUp}
              />
            </Suspense>
          )}
          {outputPreviewTab === 'chat' ? (
            <Suspense fallback={<div className="ai-chat-loading">AI 채팅 패널을 불러오는 중입니다.</div>}>
              <AiInterpreterChatPanel
                basePrompt={effectivePrompt}
                instruction={aiChatInstruction}
                onInstructionChange={setAiChatInstruction}
                aiResponse={aiResponse}
                aiCallStatus={aiCallStatus}
                isAiCalling={isAiCalling}
                parsedResponse={aiParsedResponse}
                workflowState={aiWorkflowState}
                canApplyLua={canApplyAiLua}
                applyBlockedReason={aiApplyBlockedReason}
                pruningAudit={aiPruningAudit}
                copied={copied}
                onCallAi={callAiAdapter}
                onApplyLua={applyAiLuaBlock}
                onOpenReview={() => setOutputPreviewTab('ai')}
                onCopyPrompt={(promptText) => copyText('chat-prompt', promptText)}
                onClearInstruction={() => setAiChatInstruction('')}
              />
            </Suspense>
          ) : outputPreviewTab === 'prompt' ? (
            <textarea
              className={`assistant-preview-code prompt-editable-textarea ${previewTone}`}
              value={effectivePrompt}
              onChange={(event) => updatePromptDraft(event.target.value)}
              spellCheck={false}
            />
          ) : (
            <pre className={`assistant-preview-code ${previewTone}`}>{previewContent[outputPreviewTab]}</pre>
          )}
        </div>
      </div>
    );
  };

  const renderAssistantTabContent = (tabId) => {
    if (tabId === 'context') return renderContextTab();
    if (tabId === 'intent') return renderIntentTab();
    if (tabId === 'output') return renderOutputTab();
    return renderLuaTab();
  };

  const renderSimpleAiChatPane = () => (
    <section className="assistant-pane primary simple-ai-chat-pane">
      <div className="simple-ai-chat-shell">
        <aside className="simple-ai-chat-attachments">
          <p className="eyebrow">Chat Attachments</p>
          <h3>시나리오와 참고 파일 첨부</h3>
          <p>AI Chat 전용 첨부입니다. 기존 Lua 편집창과 Working Draft는 덮어쓰지 않고, 채팅 요청문 컨텍스트에만 반영합니다.</p>
          <div className="assistant-actions compact-actions">
            <button className="btn btn-secondary" type="button" onClick={() => chatScenarioFileInputRef.current?.click()}>
              <Database size={15} />
              시나리오 첨부
            </button>
            <button className="btn btn-ghost" type="button" onClick={() => chatAttachmentInputRef.current?.click()}>
              <FileCode2 size={15} />
              Lua/문서 첨부
            </button>
            <button className="btn btn-ghost" type="button" onClick={() => chatAttachmentFolderInputRef.current?.click()}>
              <FolderOpen size={15} />
              폴더 스캔
            </button>
            <button className="btn btn-mini btn-ghost" type="button" onClick={() => { setChatAttachments([]); setChatAttachmentStatus('첨부된 보조 파일이 없습니다.'); }} disabled={!chatAttachments.length}>
              첨부 비우기
            </button>
          </div>
          <dl className="simple-ai-chat-limits">
            <div><dt>.scen</dt><dd>브라우저 메타데이터 {formatBytes(SCENARIO_SCEN_METADATA_READ_LIMIT)}까지</dd></div>
            <div><dt>XML/JSON</dt><dd>요약/sidecar {SCENARIO_XML_SIDECAR_CHAR_LIMIT.toLocaleString()}자까지</dd></div>
            <div><dt>Lua/CSS/HTML</dt><dd>파일당 {formatBytes(CHAT_ATTACHMENT_TEXT_READ_LIMIT)}, 한 번에 {CHAT_ATTACHMENT_MAX_FILES}개 / {formatBytes(CHAT_ATTACHMENT_TOTAL_READ_LIMIT)}</dd></div>
          </dl>
          <div className="simple-ai-chat-attachment-state">
            <strong>{scenarioContext.fileName ? scenarioContext.title || scenarioContext.fileName : '시나리오 미첨부'}</strong>
            <span>{scenarioContext.fileName ? `${scenarioContext.fileName} · ${scenarioContext.dbVersion || 'DB unknown'}` : '필요하면 .scen, .scenario.xml, .summary.json을 먼저 붙이세요.'}</span>
            <small>{chatAttachmentStatus}</small>
          </div>
          {chatAttachments.length ? (
            <ul className="simple-ai-chat-file-list">
              {chatAttachments.slice(0, 8).map((file) => (
                <li key={file.id}>
                  <span>{file.path}</span>
                  <small>{formatBytes(file.size)}{file.truncated ? ' · truncated' : ''}</small>
                </li>
              ))}
              {chatAttachments.length > 8 ? <li><span>+ {chatAttachments.length - 8} more</span></li> : null}
            </ul>
          ) : null}
        </aside>
        <div className="simple-ai-chat-main">
          <Suspense fallback={<div className="ai-chat-loading">AI 채팅 패널을 불러오는 중입니다.</div>}>
            <AiInterpreterChatPanel
              basePrompt={effectivePrompt}
              instruction={aiChatInstruction}
              onInstructionChange={setAiChatInstruction}
              aiResponse={aiResponse}
              aiCallStatus={aiCallStatus}
              isAiCalling={isAiCalling}
              parsedResponse={aiParsedResponse}
              workflowState={aiWorkflowState}
              canApplyLua={canApplyAiLua}
              applyBlockedReason={aiApplyBlockedReason}
              pruningAudit={aiPruningAudit}
              copied={copied}
              onCallAi={callAiAdapter}
              onApplyLua={applyAiLuaBlock}
              onOpenReview={() => setPrimaryAssistantTab('output')}
              onCopyPrompt={(promptText) => copyText('chat-prompt', promptText)}
              onClearInstruction={() => setAiChatInstruction('')}
              simpleMode
            />
          </Suspense>
        </div>
      </div>
    </section>
  );

  const renderAssistantPane = () => {
    if (focusOutputPreviewTab === 'chat') return renderSimpleAiChatPane();

    return (
    <section className="assistant-pane primary">
      <div className="assistant-pane-tabs">
        {ASSISTANT_WORKSPACE_TABS.map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              className={primaryAssistantTab === tab.id ? 'active' : ''}
              type="button"
              onClick={() => setPrimaryAssistantTab(tab.id)}
            >
              <Icon size={15} />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>
      <div className="assistant-pane-body">
        {renderAssistantTabContent(primaryAssistantTab)}
      </div>
    </section>
    );
  };

  const scenarioIsReady = scenarioContext.openabilityStatus === 'readyWithInternalSidecar';
  const showScenarioInspectorDetails = scenarioInspectorExpanded;
  const scenarioPanelCollapsed = !scenarioInspectorExpanded;
  const scenarioCompactNote = scenarioIsReady
    ? [
      scenarioContext.extractionSummary ? `Context ${scenarioContext.extractionSummary}` : '',
      scenarioInspectorCounts.luaScripts ? `Lua ${scenarioInspectorCounts.luaScripts}` : '',
      scenarioContext.sidecarFileName ? `Sidecar: ${scenarioContext.sidecarFileName}` : '',
    ].filter(Boolean).join(' · ')
    : scenarioContext.note;

  return (
    <section className="lua-assistant-panel glass-panel">
      <div className="section-header assistant-section-header">
        <div>
          <p className="eyebrow">CMO Companion Mode</p>
          <h2>{focusOutputPreviewTab === 'chat' ? 'AI Chat / Lua Assistant' : 'Event / Lua Assistant'}</h2>
        </div>
        {!focusOutputPreviewTab && (
        <div className="assistant-section-actions">
          <input
            ref={luaFileInputRef}
            className="hidden-file-input"
            type="file"
            accept=".lua,text/x-lua,text/plain"
            onChange={handleLuaFileLoad}
          />
          <input
            ref={luaBundleInputRef}
            className="hidden-file-input"
            type="file"
            accept=".lua,text/x-lua,text/plain"
            multiple
            webkitdirectory=""
            onChange={handleLuaBundleLoad}
          />
          <input
            ref={scenarioFileInputRef}
            className="hidden-file-input"
            type="file"
            accept=".scen,.xml,.json,text/xml,application/xml,application/json"
            onChange={handleScenarioFileLoad}
          />
          <button className="btn btn-ghost" type="button" onClick={() => luaFileInputRef.current?.click()}>
            <FolderOpen size={15} />
            .lua 열기
          </button>
          <button className="btn btn-ghost" type="button" onClick={() => luaBundleInputRef.current?.click()}>
            <FolderOpen size={15} />
            묶음/폴더 열기
          </button>
          <button className="btn btn-ghost" type="button" onClick={() => scenarioFileInputRef.current?.click()}>
            <Database size={15} />
            .scen/XML/JSON 읽기
          </button>
          <button className="btn btn-primary" type="button" onClick={luaFiles.length > 1 ? saveLuaBundle : () => saveLuaFile(source, '현재 Lua')}>
            <Save size={15} />
            {luaFiles.length > 1 ? '묶음 저장' : '.lua 저장'}
          </button>
          <Wand2 size={18} className="text-accent" />
        </div>
        )}
      </div>

      {focusOutputPreviewTab && (
        <>
          <input
            ref={chatScenarioFileInputRef}
            className="hidden-file-input"
            type="file"
            accept=".scen,.xml,.json,text/xml,application/xml,application/json"
            onChange={(event) => handleScenarioFileLoad(event, { preserveEditors: true })}
          />
          <input
            ref={chatAttachmentInputRef}
            className="hidden-file-input"
            type="file"
            accept=".lua,.txt,.md,.markdown,.html,.htm,.css,.json,.xml,.ini,.cfg,.yaml,.yml,.csv,text/plain,text/html,text/css,application/json,application/xml"
            multiple
            onChange={handleChatAttachmentLoad}
          />
          <input
            ref={chatAttachmentFolderInputRef}
            className="hidden-file-input"
            type="file"
            accept=".lua,.txt,.md,.markdown,.html,.htm,.css,.json,.xml,.ini,.cfg,.yaml,.yml,.csv,text/plain,text/html,text/css,application/json,application/xml"
            multiple
            webkitdirectory=""
            onChange={handleChatAttachmentLoad}
          />
        </>
      )}

      {!focusOutputPreviewTab && (
      <div className="assistant-file-strip">
        <div className="assistant-file-strip-info">
          <strong>작업 파일: {luaFileName || '화면 임시 초안'}</strong>
          <span>{luaFileStatus}{autoSaveInfo ? ` · 자동저장 ${autoSaveInfo}` : ''}</span>
        </div>
        <div className="assistant-file-strip-actions">
          <button
            className="btn btn-mini btn-ghost"
            type="button"
            onClick={saveTempSessionFile}
            disabled={!hasMeaningfulTempSession}
            title={hasMeaningfulTempSession ? '현재 Assistant 작업을 단일 임시 슬롯에 저장합니다.' : '임시저장할 작업 내용이 아직 없습니다.'}
          >
            <Save size={14} />
            임시저장
          </button>
          <button
            className="btn btn-mini btn-ghost"
            type="button"
            onClick={restoreManualTempSession}
            disabled={!hasManualTempSession}
            title={hasManualTempSession ? '임시저장 슬롯을 불러옵니다.' : '불러올 임시저장 슬롯이 없습니다.'}
          >
            <FolderOpen size={14} />
            불러오기
          </button>
          <button
            className="btn btn-mini btn-ghost"
            type="button"
            onClick={restoreAutoSavedSession}
            disabled={!hasAutoSavedTempSession}
            title={hasAutoSavedTempSession ? '마지막 자동저장 세션을 복구합니다.' : '복구할 자동저장 세션이 없습니다.'}
          >
            자동복구
          </button>
          <button className="btn btn-mini btn-ghost btn-danger" type="button" onClick={resetAssistantWorkspace}>
            <RotateCcw size={14} />
            초기화
          </button>
          <button
            className="btn btn-mini btn-ghost btn-danger"
            type="button"
            onClick={deleteTempSessions}
            disabled={!hasStoredTempSession}
            title={hasStoredTempSession ? '자동복구/임시저장 슬롯을 삭제합니다.' : '삭제할 자동복구/임시저장 슬롯이 없습니다.'}
          >
            <Trash2 size={14} />
            삭제
          </button>
        </div>
      </div>
      )}

      {!focusOutputPreviewTab && scenarioContext.fileName && (
        <div className={`scenario-context-strip ${scenarioIsReady ? 'ready-compact' : ''}`}>
          <div>
            <strong>{scenarioContext.title || scenarioContext.fileName}</strong>
            <span>{scenarioContext.dbVersion || 'DB unknown'} · {scenarioContext.buildNumber || scenarioContext.version || 'build unknown'}</span>
            {scenarioContext.compressedLength > 0 && !scenarioIsReady && (
              <button
                className="btn btn-mini btn-ghost scenario-command-button"
                type="button"
                onClick={() => copyText('scenario-extract-command', scenarioDecoderCommand)}
                title="PowerShell 터미널에서 실행할 scan/extract/summarize 명령을 복사합니다. 전수조사 인덱스가 있으면 실제 .scen 경로를 사용합니다."
              >
                <Copy size={13} />
                {copied === 'scenario-extract-command' ? '복사됨' : '디코더 명령 복사'}
              </button>
            )}
          </div>
          <p>{scenarioCompactNote}</p>
        </div>
      )}

      {!focusOutputPreviewTab && scenarioContext.fileName && (
        <div className={`scenario-inspector-panel ${scenarioContext.openabilityStatus || 'unknown'} ${scenarioIsReady ? 'compact-ready' : ''} ${scenarioPanelCollapsed ? 'is-collapsed' : 'is-expanded'} ${showScenarioInspectorDetails ? 'details-visible' : 'details-hidden'}`}>
          <div className="scenario-inspector-head">
            <div>
              <p className="eyebrow">Scenario Inspector / Loader</p>
              <h3>{scenarioOpenabilityLabel(scenarioContext.openabilityStatus)}</h3>
              <p>{scenarioOpenabilityDescription(scenarioContext)}</p>
            </div>
            <div className="scenario-inspector-actions">
              <button
                className="btn btn-mini btn-ghost"
                type="button"
                onClick={() => setScenarioInspectorExpanded((current) => !current)}
              >
                {scenarioInspectorExpanded ? '접기' : scenarioIsReady ? '상세' : '준비 단계'}
              </button>
              <button
                className="btn btn-mini btn-primary"
                type="button"
                onClick={() => copyText('scenario-loader-command', scenarioDecoderCommand)}
              >
                {copied === 'scenario-loader-command' ? <Check size={13} /> : <Copy size={13} />}
                {scenarioIsReady ? '명령 복사' : '추출 명령 복사'}
              </button>
            </div>
          </div>

          <div className="scenario-inspector-metrics">
            <article>
              <span>Openability</span>
              <strong>{scenarioContext.openabilityStatus || 'not indexed'}</strong>
            </article>
            <article>
              <span>Sidecar</span>
              <strong>{scenarioContext.sidecarFileName || 'none'}</strong>
            </article>
            <article>
              <span>Context</span>
              <strong>{scenarioContext.extractionSummary || 'none'}</strong>
            </article>
            <article>
              <span>Lua scripts</span>
              <strong>{scenarioInspectorCounts.luaScripts}</strong>
            </article>
          </div>

          <details className="scenario-inspector-details" open={scenarioInspectorExpanded}>
            <summary>{scenarioIsReady ? '상세 준비 단계 / 명령 보기' : '준비 단계 / 명령'}</summary>
            <div className="scenario-inspector-body">
            <div className="scenario-loader-steps">
              {scenarioInspectorSteps.map((step) => (
                <article key={step.label} className={step.done ? 'done' : 'pending'}>
                  <span>{step.done ? '완료' : '대기'}</span>
                  <strong>{step.label}</strong>
                  <p>{step.detail}</p>
                </article>
              ))}
            </div>
            <div className="scenario-loader-command">
              <div>
                <strong>공통 준비 명령</strong>
                <span>prepare:scenario = scan + extract XML + summarize JSON + audit</span>
              </div>
              <pre>{scenarioDecoderCommand}</pre>
              {scenarioContext.sourcePath && <p>원본: {scenarioContext.sourcePath}</p>}
            </div>
            </div>
          </details>
        </div>
      )}

      <div className={`assistant-tab-stage single ${primaryAssistantTab === 'lua' ? 'lua-tab-stage' : ''}`}>
        {renderAssistantPane()}
      </div>
    </section>
  );
}

export default LuaAssistant;
