# CMO Wiki Code Assistant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a verified CMO Lua wiki data layer first, then use it for a wiki surface and deterministic editor-side reference helper without adding another AI agent.

**Architecture:** Start with a helper-only Slice 0 so both future UI surfaces share one normalized data model. Then build `CMO Lua 백과사전` on top of the helper, and finally add `Lua 참조 도우미` beside the manual Lua editor. Keep all AI actions text-only drafts until the user presses send.

**Tech Stack:** React 19, Vite, existing lazy workspace shell, existing `public/template-annotations.json`, existing template manifests, Node ESM smoke contracts.

---

## Review Disposition

Claude architecture review changed the first slice from wiki-first to helper-only:

- Extract deterministic data normalization / matching / draft formatting first.
- Do not touch `LuaAssistant.jsx` in Slice 0.
- Move pure TemplateLibrary utilities into the helper where practical.
- Enforce that `LuaAssistant.jsx` line count does not grow in the helper-only slice.

Gemini UX review changed naming and wording:

- Prefer `CMO Lua 백과사전` for the wiki surface.
- Use `Lua 참조 도우미` or `코드 분석 도움말`, not "code assistant" or another "agent".
- Show use-case first, then required CMO values, then examples.
- Label examples as reference patterns, not guaranteed final code.
- Question-draft buttons must say they only fill text and do not send or execute.

## File Map

- Create `src/lib/cmoWikiEntries.js`: pure helper for wiki entry normalization, search text, badges, Lua matching, secret-safe prompt draft formatting.
- Create `tools/verify-cmo-wiki-code-assistant-contract.mjs`: smoke contract for helper behavior, 51 / 51 annotation coverage, no secret leakage, and no unsafe behavior strings.
- Modify `package.json`: add `smoke:cmo-wiki-code-assistant` after helper is green.
- Modify `src/components/TemplateLibrary.jsx`: import shared helper utilities instead of keeping local copies.
- Create `src/components/CmoWikiPanel.jsx`: wiki reading surface for `백과사전`.
- Create `src/components/CmoWikiPanel.css`: small lazy/component CSS only.
- Create `src/components/LuaEditorReferenceHelper.jsx`: deterministic right-side editor helper.
- Create `src/components/LuaEditorReferenceHelper.css`: small component CSS only if existing classes are insufficient.
- Modify `src/App.jsx`: route `백과사전` to the new wiki panel once Slice 1 is ready.
- Modify `src/components/LuaAssistant.jsx`: wire editor-side reference helper only in Slice 2.
- Modify handoff files only after product slices are implemented and verified.

## Shared Safety Rules

- No automatic AI send.
- No automatic CMO execution.
- No polling, watcher, or live-state claim.
- No CMO file write or `.scen` mutation.
- No browser-provided privileged root.
- No new template-kind creation.
- No dependency or lockfile change.
- Text-only AI drafts must cap embedded user Lua at 2000 characters and redact credential/path-like secrets.
- Main CSS must remain below 60 kB.

## Task 1: Slice 0 Helper Contract and Implementation

**Files:**

- Create: `src/lib/cmoWikiEntries.js`
- Create: `tools/verify-cmo-wiki-code-assistant-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write the failing smoke contract**

Create `tools/verify-cmo-wiki-code-assistant-contract.mjs`:

```js
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  MAX_DRAFT_LUA_CHARS,
  buildCmoWikiEntries,
  buildResourceBadges,
  formatWikiQuestionDraft,
  matchCmoWikiEntriesForLua,
  redactWikiDraftText,
  resourceSearchText,
} from '../src/lib/cmoWikiEntries.js';
import { EVENT_TEMPLATES } from '../src/data/templateCatalog.js';

const annotationsPayload = JSON.parse(readFileSync('public/template-annotations.json', 'utf8'));
const builderManifest = JSON.parse(readFileSync('public/cmo-dev-work/manifest.json', 'utf8'));
const installedManifest = JSON.parse(readFileSync('public/cmo-installed-lua/manifest.json', 'utf8'));
const entries = buildCmoWikiEntries({
  annotationsPayload,
  templates: EVENT_TEMPLATES,
  builderManifest,
  installedManifest,
});

assert.equal(Object.keys(annotationsPayload.templates).length, 51, 'template annotations should stay 51 / 51');
assert.ok(entries.length >= 51, 'wiki entries should include every annotated template');

const regularTime = entries.find((entry) => entry.sourceFile === 'event_regular_time.tpl.lua');
assert.ok(regularTime, 'regular-time template should be normalized');
assert.equal(regularTime.title, 'Regular Time Event guide');
assert.ok(regularTime.summary.includes('반복 실행'));
assert.ok(regularTime.requiredValues.length > 0);
assert.ok(regularTime.safePattern.includes('KeyValue'));
assert.ok(regularTime.engineChecks.length > 0);
assert.ok(regularTime.searchText.includes('regular time event guide'));

const badges = buildResourceBadges(regularTime);
assert.ok(badges.some((badge) => badge.id === 'engineTest'), 'engine test badge should be derived');

const matches = matchCmoWikiEntriesForLua('ScenEdit_SetKeyValue("CAP_done", "yes")', entries);
assert.ok(matches.some((entry) => entry.sourceFile === 'kvstore_set.tpl.lua'), 'KeyValue Lua should match key-value template guidance');

const draft = formatWikiQuestionDraft(regularTime, {
  luaText: `print("safe")\n-- sk-test-secret\n-- C:/Users/example/file.lua\n${'x'.repeat(MAX_DRAFT_LUA_CHARS + 100)}`,
});
assert.ok(draft.includes('자동 전송되지 않습니다'));
assert.ok(draft.includes('CMO 엔진 검증'));
assert.ok(draft.includes('Regular Time Event guide'));
assert.ok(draft.length < 5000, 'draft should stay bounded');
assert.equal(/sk-test-secret|C:\/Users\/example/.test(draft), false, 'draft should redact secrets and local paths');

assert.equal(redactWikiDraftText('Bearer abc.def sk-proj-example C:/Users/name/file.lua').includes('Bearer abc.def'), false);
assert.ok(resourceSearchText(regularTime).includes('event_regular_time.tpl.lua'));

const helperSource = readFileSync('src/lib/cmoWikiEntries.js', 'utf8');
assert.equal(/sendCmoAiPrompt|fetch\\(|writeFile|appendFile|unlink|rm\\(|watch\\(/.test(helperSource), false);

console.log('PASS - CMO wiki code assistant helper contract holds.');
```

- [ ] **Step 2: Add the npm script**

In `package.json`, add:

```json
"smoke:cmo-wiki-code-assistant": "node tools/verify-cmo-wiki-code-assistant-contract.mjs"
```

- [ ] **Step 3: Run the smoke and confirm RED**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
```

Expected: FAIL because `src/lib/cmoWikiEntries.js` does not exist.

- [ ] **Step 4: Implement the helper**

Create `src/lib/cmoWikiEntries.js`:

```js
export const MAX_DRAFT_LUA_CHARS = 2000;

export const BADGE_DEFINITIONS = [
  { id: 'engineTest', label: 'CMO 엔진 테스트 필요', tone: 'warning' },
  { id: 'needsSide', label: 'Side 확인', tone: 'info' },
  { id: 'needsMission', label: 'Mission 확인', tone: 'info' },
  { id: 'needsUnitGuid', label: 'Unit GUID 확인', tone: 'info' },
  { id: 'needsDbid', label: 'DBID 확인', tone: 'info' },
  { id: 'needsLoadout', label: 'Loadout ID 확인', tone: 'info' },
  { id: 'needsRpZone', label: 'RP / Zone 확인', tone: 'info' },
  { id: 'affectsSideWide', label: 'Side 전체 영향', tone: 'caution' },
];

export function annotationTextParts(annotation) {
  if (!annotation) return [];
  return [
    annotation.title,
    annotation.summary,
    ...(annotation.beginnerNotes || []),
    ...(annotation.prerequisites || []),
    annotation.safePattern,
    annotation.aiHint,
    ...(annotation.checks || []),
  ].filter(Boolean);
}

export function normalizeSearchText(values) {
  return values.filter(Boolean).join(' ').toLowerCase();
}

export function annotationText(annotation, field = 'all') {
  if (!annotation) return '';
  if (field === 'prerequisites') return normalizeSearchText(annotation.prerequisites || []);
  if (field === 'checks') return normalizeSearchText(annotation.checks || []);
  return normalizeSearchText(annotationTextParts(annotation));
}

export function includesAny(text, needles) {
  return needles.some((needle) => text.includes(needle));
}

export function resourceSearchText(resource, annotation = resource?.annotation) {
  return normalizeSearchText([
    resource?.file,
    resource?.sourceFile,
    resource?.relativePath,
    resource?.scenario,
    resource?.category,
    resource?.type,
    resource?.title,
    resource?.summary,
    ...(resource?.features || []),
    ...(resource?.apis || []),
    ...annotationTextParts(annotation),
  ]);
}

export function matchesQuickFilter(resource, annotation = resource?.annotation, filterId) {
  if (resource?.type === 'preset') return false;

  const category = String(resource?.category || '').toLowerCase();
  const allText = annotationText(annotation);

  if (filterId === 'event') return category === 'event';
  if (filterId === 'mission') return category === 'mission';
  if (filterId === 'unit') return category === 'unit' || includesAny(allText, ['unit spawn', 'unit edit', 'unit lifecycle', '유닛']);
  if (filterId === 'dbidLoadout') return category === 'loadout' || includesAny(allText, ['dbid', 'loadout', 'database viewer']);
  if (filterId === 'rpZone') return ['reference', 'zone'].includes(category) || includesAny(allText, [' rp ', 'reference point', 'zone', '좌표']);
  if (filterId === 'doctrineEmcon') return category === 'doctrine' || includesAny(allText, ['doctrine', 'emcon', 'posture', '교전 규칙']);
  if (filterId === 'keyvalue') return category === 'kvstore' || includesAny(allText, ['keyvalue', 'kvstore', ' key value ', 'setkeyvalue']);

  return false;
}

export function buildResourceBadges(resource, annotation = resource?.annotation) {
  const category = String(resource?.category || '').toLowerCase();
  const prerequisiteText = annotationText(annotation, 'prerequisites');
  const checkText = annotationText(annotation, 'checks');
  const allText = annotationText(annotation);
  const badges = [];

  const addBadge = (id) => {
    const badge = BADGE_DEFINITIONS.find((item) => item.id === id);
    if (badge && !badges.some((item) => item.id === id)) badges.push(badge);
  };

  if (includesAny(allText, ['engine test', 'engine verification', 'lua console', 'event editor', 'cmo engine', '엔진 테스트', '엔진 검증'])) addBadge('engineTest');
  if (includesAny(prerequisiteText, ['side name', 'actual side', 'source side', 'target side', 'side 이름', 'side를'])) addBadge('needsSide');
  if (includesAny(prerequisiteText, ['mission name', 'actual mission', 'mission 이름'])) addBadge('needsMission');
  if (includesAny(prerequisiteText, ['unit guid', 'unit id', 'guid first', 'copy unit id', 'guid를', 'guid가'])) addBadge('needsUnitGuid');
  if (includesAny(prerequisiteText, ['dbid', 'database viewer'])) addBadge('needsDbid');
  if (includesAny(prerequisiteText, ['loadout id', 'loadout'])) addBadge('needsLoadout');
  if (includesAny(prerequisiteText, ['rp name', 'reference point', 'zone name', 'rp 이름', 'zone 이름', '좌표'])) addBadge('needsRpZone');
  if (category === 'doctrine' || includesAny(allText, ['side-wide', 'side level', 'side 전체', 'posture', 'doctrine', 'emcon'])) addBadge('affectsSideWide');

  if (!badges.some((badge) => badge.id === 'engineTest') && includesAny(checkText, ['test', 'verify', 'verification', 'check', '테스트', '검증', '확인'])) {
    addBadge('engineTest');
  }

  return badges;
}

function templateBySource(templates = []) {
  return new Map((templates || []).map((template) => [template.sourceFile, template]));
}

function resourcesByFile(...resourceLists) {
  const map = new Map();
  resourceLists.flat().filter(Boolean).forEach((resource) => {
    if (resource.file && !map.has(resource.file)) map.set(resource.file, resource);
  });
  return map;
}

export function buildCmoWikiEntries({
  annotationsPayload,
  templates = [],
  builderManifest = {},
  installedManifest = {},
} = {}) {
  const annotations = annotationsPayload?.templates || {};
  const catalog = templateBySource(templates);
  const resources = resourcesByFile(
    builderManifest.templates || [],
    builderManifest.presets || [],
    installedManifest.examples || [],
  );

  return Object.entries(annotations).map(([sourceFile, annotation]) => {
    const template = catalog.get(sourceFile) || null;
    const resource = resources.get(sourceFile) || {};
    const entry = {
      id: sourceFile,
      file: sourceFile,
      sourceFile,
      title: annotation.title || template?.title || sourceFile,
      summary: annotation.summary || template?.summary || '',
      useCase: annotation.beginnerNotes?.[0] || annotation.summary || template?.summary || '',
      beginnerNotes: annotation.beginnerNotes || [],
      requiredValues: annotation.prerequisites || [],
      safePattern: annotation.safePattern || '',
      aiHint: annotation.aiHint || '',
      engineChecks: annotation.checks || [],
      category: resource.category || template?.featureGroup || template?.presetSection || '',
      type: resource.type || 'template',
      path: resource.path || '',
      lines: resource.lines || 0,
      features: resource.features || [],
      apis: resource.apis || [],
      template,
      annotation,
    };
    return {
      ...entry,
      badges: buildResourceBadges(entry, annotation),
      searchText: resourceSearchText(entry, annotation),
    };
  }).sort((a, b) => a.title.localeCompare(b.title));
}

const API_HINTS = [
  ['ScenEdit_SetKeyValue', ['keyvalue', 'kvstore', 'state']],
  ['ScenEdit_GetKeyValue', ['keyvalue', 'kvstore', 'state']],
  ['ScenEdit_SetDoctrine', ['doctrine', 'emcon', 'posture']],
  ['ScenEdit_SetEMCON', ['doctrine', 'emcon']],
  ['ScenEdit_AssignUnitToMission', ['mission']],
  ['ScenEdit_AddReferencePoint', ['reference point', 'rp ', 'zone']],
  ['ScenEdit_SetWeather', ['weather']],
  ['ScenEdit_AddUnit', ['unit spawn', 'dbid']],
  ['ScenEdit_SetLoadout', ['loadout']],
];

export function matchCmoWikiEntriesForLua(luaText = '', entries = [], { limit = 5 } = {}) {
  const text = String(luaText).toLowerCase();
  if (!text.trim()) return [];

  const scored = entries.map((entry) => {
    let score = 0;
    const haystack = entry.searchText || resourceSearchText(entry);

    if (text.includes(entry.sourceFile.toLowerCase())) score += 8;
    for (const api of entry.apis || []) {
      if (text.includes(String(api).toLowerCase())) score += 6;
    }
    for (const [apiName, keywords] of API_HINTS) {
      if (text.includes(apiName.toLowerCase()) && keywords.some((keyword) => haystack.includes(keyword))) {
        score += 5;
      }
    }
    for (const token of [entry.category, entry.title, ...(entry.features || [])]) {
      const normalized = String(token || '').toLowerCase();
      if (normalized && text.includes(normalized)) score += 2;
    }

    return { entry, score };
  });

  return scored
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score || a.entry.title.localeCompare(b.entry.title))
    .slice(0, limit)
    .map((item) => item.entry);
}

export function redactWikiDraftText(text = '') {
  return String(text)
    .replace(/\bBearer\s+[A-Za-z0-9._~+/=-]+/gi, 'Bearer [redacted]')
    .replace(/\bsk-[A-Za-z0-9_-]{6,}/gi, 'sk-[redacted]')
    .replace(/\bsk-proj-[A-Za-z0-9_-]{6,}/gi, 'sk-proj-[redacted]')
    .replace(/\b[A-Za-z]:[\\/][^\s`'"]+/g, '[local-path-redacted]')
    .replace(/\\\\[A-Za-z0-9_.-]+\\[^\s`'"]+/g, '[unc-path-redacted]');
}

export function formatWikiQuestionDraft(entry, { luaText = '' } = {}) {
  const safeLua = redactWikiDraftText(String(luaText).slice(0, MAX_DRAFT_LUA_CHARS));
  const truncated = String(luaText).length > MAX_DRAFT_LUA_CHARS
    ? `\n\nLua 일부만 포함했습니다. (${MAX_DRAFT_LUA_CHARS}자 제한)`
    : '';
  const requiredValues = entry.requiredValues?.length
    ? entry.requiredValues.map((item) => `- ${item}`).join('\n')
    : '- CMO에서 실제 Side/Mission/Unit/RP/DBID 값을 확인해야 합니다.';

  return [
    '이 CMO Lua 기능을 사용하고 싶습니다. 이 문장은 AI 채팅 입력창에만 들어가며 자동 전송되지 않습니다.',
    '',
    `주제: ${entry.title}`,
    `관련 예문: ${entry.sourceFile}`,
    '',
    'CMO에서 직접 확인할 값:',
    requiredValues,
    '',
    '안전 패턴:',
    entry.safePattern || 'AI 초안은 CMO 엔진에서 직접 검증해야 합니다.',
    '',
    '요청:',
    '먼저 부족한 CMO 값을 한 가지씩 질문해 주세요. 충분하면 CMO 엔진 검증이 필요한 Lua 초안을 작성해 주세요.',
    safeLua ? `\n참고 Lua:\n\`\`\`lua\n${safeLua}\n\`\`\`${truncated}` : '',
  ].filter(Boolean).join('\n');
}
```

- [ ] **Step 5: Run the helper smoke**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
```

Expected: PASS.

- [ ] **Step 6: Commit Slice 0 helper**

Run:

```powershell
git add package.json src/lib/cmoWikiEntries.js tools/verify-cmo-wiki-code-assistant-contract.mjs
git commit -m "Add CMO wiki entry helper"
```

## Task 2: Slice 0 Utility Migration From TemplateLibrary

**Files:**

- Modify: `src/components/TemplateLibrary.jsx`
- Modify: `tools/verify-cmo-wiki-code-assistant-contract.mjs`

- [ ] **Step 1: Extend the smoke to guard utility reuse**

Add this assertion to `tools/verify-cmo-wiki-code-assistant-contract.mjs`:

```js
const templateLibrarySource = readFileSync('src/components/TemplateLibrary.jsx', 'utf8');
assert.ok(templateLibrarySource.includes("from '../lib/cmoWikiEntries'"));
assert.equal(/function annotationTextParts|function normalizeSearchText|function annotationText|function buildResourceBadges/.test(templateLibrarySource), false);
```

- [ ] **Step 2: Run the smoke and confirm RED**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
```

Expected: FAIL because `TemplateLibrary.jsx` still owns the utility functions.

- [ ] **Step 3: Import shared utilities**

In `src/components/TemplateLibrary.jsx`, add:

```js
import {
  annotationText,
  annotationTextParts,
  buildResourceBadges,
  matchesQuickFilter,
  normalizeSearchText,
  resourceSearchText,
} from '../lib/cmoWikiEntries';
```

- [ ] **Step 4: Remove local utility definitions**

Delete these local definitions from `src/components/TemplateLibrary.jsx`:

```js
function annotationTextParts(annotation) { /* remove local copy */ }
function normalizeSearchText(values) { /* remove local copy */ }
function resourceSearchText(resource, annotation) { /* remove local copy */ }
function includesAny(text, needles) { /* remove local copy if no longer used */ }
function annotationText(annotation, field = 'all') { /* remove local copy */ }
function matchesQuickFilter(resource, annotation, filterId) { /* remove local copy */ }
function buildResourceBadges(resource, annotation) { /* remove local copy */ }
```

Keep `QUICK_FILTERS`, `FALLBACK_GUIDE_RULES`, `TemplateGuideNotes`, and rendering logic in `TemplateLibrary.jsx`.

- [ ] **Step 5: Run verification**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
npm run smoke:ai-chat-entrypoint
npm run lint
npm run build
```

Expected:

- all PASS;
- Main JS remains below `400 kB`;
- Main CSS remains unchanged or below `60 kB`;
- `LuaAssistant.jsx` is unchanged in this commit.

- [ ] **Step 6: Commit utility migration**

Run:

```powershell
git add src/components/TemplateLibrary.jsx tools/verify-cmo-wiki-code-assistant-contract.mjs
git commit -m "Share CMO wiki utility helpers"
```

## Task 3: Slice 1 Wiki Surface

**Files:**

- Create: `src/components/CmoWikiPanel.jsx`
- Create: `src/components/CmoWikiPanel.css`
- Modify: `src/App.jsx`
- Modify: `tools/verify-cmo-wiki-code-assistant-contract.mjs`

- [ ] **Step 1: Extend smoke for wiki UI labels**

Add these assertions to `tools/verify-cmo-wiki-code-assistant-contract.mjs`:

```js
const appSource = readFileSync('src/App.jsx', 'utf8');
const wikiSource = readFileSync('src/components/CmoWikiPanel.jsx', 'utf8');
assert.ok(appSource.includes("lazy(() => import('./components/CmoWikiPanel'))"));
assert.ok(wikiSource.includes('CMO Lua 백과사전'));
assert.ok(wikiSource.includes('언제 쓰나요?'));
assert.ok(wikiSource.includes('CMO에서 직접 확인할 값'));
assert.ok(wikiSource.includes('참고용 템플릿 예제'));
assert.ok(wikiSource.includes('AI 채팅창에 질문 초안 넣기'));
assert.ok(wikiSource.includes('자동 전송되지 않습니다'));
assert.equal(/onAddTemplate|Template 추가|제작 폼에 추가/.test(wikiSource), false);
```

- [ ] **Step 2: Run smoke and confirm RED**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
```

Expected: FAIL because `CmoWikiPanel.jsx` does not exist.

- [ ] **Step 3: Create `CmoWikiPanel.jsx`**

Create `src/components/CmoWikiPanel.jsx`:

```jsx
import { useEffect, useMemo, useState, useTransition } from 'react';
import { BookOpen, Search, Sparkles } from 'lucide-react';
import { EVENT_TEMPLATES } from '../data/templateCatalog';
import {
  buildCmoWikiEntries,
  formatWikiQuestionDraft,
  matchCmoWikiEntriesForLua,
} from '../lib/cmoWikiEntries';
import './CmoWikiPanel.css';

function loadJson(url) {
  return fetch(url).then((response) => {
    if (!response.ok) throw new Error(`${url}: ${response.status}`);
    return response.json();
  });
}

export default function CmoWikiPanel({ onDraftQuestion }) {
  const [annotationsPayload, setAnnotationsPayload] = useState(null);
  const [builderManifest, setBuilderManifest] = useState(null);
  const [installedManifest, setInstalledManifest] = useState(null);
  const [query, setQuery] = useState('');
  const [deferredQuery, setDeferredQuery] = useState('');
  const [selectedId, setSelectedId] = useState('');
  const [error, setError] = useState('');
  const [, startTransition] = useTransition();

  useEffect(() => {
    let alive = true;
    Promise.allSettled([
      loadJson('/template-annotations.json'),
      loadJson('/cmo-dev-work/manifest.json'),
      loadJson('/cmo-installed-lua/manifest.json'),
    ]).then(([annotationsResult, builderResult, installedResult]) => {
      if (!alive) return;
      if (annotationsResult.status === 'fulfilled') setAnnotationsPayload(annotationsResult.value);
      if (builderResult.status === 'fulfilled') setBuilderManifest(builderResult.value);
      if (installedResult.status === 'fulfilled') setInstalledManifest(installedResult.value);
      if (annotationsResult.status !== 'fulfilled') setError('백과사전 데이터를 불러오지 못했습니다.');
    });
    return () => {
      alive = false;
    };
  }, []);

  const entries = useMemo(() => buildCmoWikiEntries({
    annotationsPayload,
    templates: EVENT_TEMPLATES,
    builderManifest,
    installedManifest,
  }), [annotationsPayload, builderManifest, installedManifest]);

  const visibleEntries = useMemo(() => {
    const text = deferredQuery.trim().toLowerCase();
    if (!text) return entries;
    return entries.filter((entry) => entry.searchText.includes(text));
  }, [deferredQuery, entries]);

  const selectedEntry = visibleEntries.find((entry) => entry.id === selectedId) || visibleEntries[0] || null;
  const relatedEntries = selectedEntry ? matchCmoWikiEntriesForLua(selectedEntry.searchText, entries, { limit: 3 }) : [];

  const handleQuery = (value) => {
    setQuery(value);
    startTransition(() => setDeferredQuery(value.toLowerCase()));
  };

  const draftQuestion = () => {
    if (!selectedEntry || !onDraftQuestion) return;
    onDraftQuestion(formatWikiQuestionDraft(selectedEntry));
  };

  return (
    <section className="cmo-wiki-panel glass-panel">
      <div className="section-header">
        <div>
          <p className="eyebrow">Verified CMO Lua Knowledge</p>
          <h2>CMO Lua 백과사전</h2>
          <p>검증된 템플릿과 예문을 먼저 이해한 뒤, 내 시나리오 값에 맞춰 AI에게 질문하세요.</p>
        </div>
        <BookOpen size={22} className="text-accent" />
      </div>

      {error && <p className="template-sync-hint">{error}</p>}

      <div className="search-box">
        <Search size={15} />
        <input value={query} onChange={(event) => handleQuery(event.target.value)} placeholder="기능, API, 필요한 CMO 값 검색" />
      </div>

      <div className="cmo-wiki-layout">
        <div className="cmo-wiki-list">
          {visibleEntries.map((entry) => (
            <button key={entry.id} className={selectedEntry?.id === entry.id ? 'active' : ''} type="button" onClick={() => setSelectedId(entry.id)}>
              <span>{entry.title}</span>
              <small>{entry.sourceFile}</small>
            </button>
          ))}
        </div>

        {selectedEntry ? (
          <article className="cmo-wiki-detail">
            <p className="eyebrow">{selectedEntry.sourceFile}</p>
            <h3>{selectedEntry.title}</h3>
            <section>
              <h4>언제 쓰나요?</h4>
              <p>{selectedEntry.useCase || selectedEntry.summary}</p>
            </section>
            <section>
              <h4>CMO에서 직접 확인할 값</h4>
              <ul>
                {selectedEntry.requiredValues.map((item) => <li key={item}>{item}</li>)}
              </ul>
            </section>
            <section>
              <h4>참고용 템플릿 예제</h4>
              <p>{selectedEntry.sourceFile}는 기본 패턴입니다. 그대로 실행하지 말고 시나리오 값으로 바꿔야 합니다.</p>
            </section>
            <section>
              <h4>검증 포인트</h4>
              <ul>
                {selectedEntry.engineChecks.map((item) => <li key={item}>{item}</li>)}
              </ul>
            </section>
            {relatedEntries.length > 0 && (
              <section>
                <h4>관련 항목</h4>
                <div className="tag-cloud">
                  {relatedEntries.map((entry) => <span key={entry.id}>{entry.title}</span>)}
                </div>
              </section>
            )}
            <button className="btn btn-primary" type="button" onClick={draftQuestion}>
              <Sparkles size={15} />
              AI 채팅창에 질문 초안 넣기
            </button>
            <p className="template-draft-footer">텍스트만 입력창에 넣습니다. 자동 전송되지 않으며 CMO 엔진 검증이 필요합니다.</p>
          </article>
        ) : (
          <article className="cmo-wiki-detail">
            <h3>표시할 백과 항목이 없습니다.</h3>
            <p>검색어를 줄이거나 다른 CMO Lua 기능명을 입력해 주세요.</p>
          </article>
        )}
      </div>
    </section>
  );
}
```

- [ ] **Step 4: Add minimal CSS**

Create `src/components/CmoWikiPanel.css`:

```css
.cmo-wiki-panel {
  display: grid;
  gap: 1rem;
}

.cmo-wiki-layout {
  display: grid;
  grid-template-columns: minmax(14rem, 0.34fr) minmax(0, 1fr);
  gap: 1rem;
  min-height: 0;
}

.cmo-wiki-list {
  display: grid;
  gap: 0.45rem;
  align-content: start;
  max-height: 62vh;
  overflow: auto;
}

.cmo-wiki-list button,
.cmo-wiki-detail {
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  background: rgba(8, 15, 26, 0.72);
}

.cmo-wiki-list button {
  display: grid;
  gap: 0.25rem;
  padding: 0.75rem;
  text-align: left;
  color: var(--text-primary);
}

.cmo-wiki-list button.active {
  border-color: rgba(255, 196, 87, 0.55);
  background: rgba(240, 184, 74, 0.12);
}

.cmo-wiki-detail {
  display: grid;
  gap: 1rem;
  padding: 1rem;
}
```

- [ ] **Step 5: Lazy-load wiki panel in App**

In `src/App.jsx`, add:

```js
const CmoWikiPanel = lazy(() => import('./components/CmoWikiPanel'));
```

Replace the `encyclopedia` panel body with:

```jsx
<Suspense fallback={<div className="glass-panel preset-guide-loading">Loading CMO Lua encyclopedia...</div>}>
  <CmoWikiPanel
    onDraftQuestion={(text) => {
      setActiveTab('agent');
      setAgentMode('chat');
      window.dispatchEvent(new CustomEvent('cmo-ai-chat-draft-request', { detail: { text } }));
    }}
  />
</Suspense>
```

- [ ] **Step 6: Add chat draft event support if missing**

If `LuaAssistant.jsx` does not yet listen for `cmo-ai-chat-draft-request`, add a small effect that sets the AI prompt text and opens chat mode without sending. Keep this as the only `LuaAssistant.jsx` change in this task.

- [ ] **Step 7: Verify and commit**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
npm run lint
npm run build
```

Expected:

- all PASS;
- Main JS below `400 kB`;
- Main CSS below `60 kB`;
- no package-lock change.

Commit:

```powershell
git add src/App.jsx src/components/CmoWikiPanel.jsx src/components/CmoWikiPanel.css src/components/LuaAssistant.jsx tools/verify-cmo-wiki-code-assistant-contract.mjs
git commit -m "Add CMO Lua wiki panel"
```

## Task 4: Slice 2 Lua Editor Reference Helper

**Files:**

- Create: `src/components/LuaEditorReferenceHelper.jsx`
- Create: `src/components/LuaEditorReferenceHelper.css`
- Modify: `src/components/LuaAssistant.jsx`
- Modify: `tools/verify-cmo-wiki-code-assistant-contract.mjs`

- [ ] **Step 1: Extend smoke for deterministic editor helper**

Add:

```js
const editorHelperSource = readFileSync('src/components/LuaEditorReferenceHelper.jsx', 'utf8');
assert.ok(editorHelperSource.includes('Lua 참조 도우미'));
assert.ok(editorHelperSource.includes('알려진 패턴을 찾을 수 없습니다'));
assert.ok(editorHelperSource.includes('AI 채팅창에 검토 질문 넣기'));
assert.equal(/sendCmoAiPrompt|fetch\\(|ScenEdit_RunScript|writeFile|appendFile/.test(editorHelperSource), false);
```

- [ ] **Step 2: Run smoke and confirm RED**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
```

Expected: FAIL because `LuaEditorReferenceHelper.jsx` does not exist.

- [ ] **Step 3: Create `LuaEditorReferenceHelper.jsx`**

Create:

```jsx
import { useMemo } from 'react';
import { Search } from 'lucide-react';
import {
  formatWikiQuestionDraft,
  matchCmoWikiEntriesForLua,
} from '../lib/cmoWikiEntries';
import './LuaEditorReferenceHelper.css';

export default function LuaEditorReferenceHelper({ luaText, wikiEntries, onDraftQuestion }) {
  const matches = useMemo(() => matchCmoWikiEntriesForLua(luaText, wikiEntries, { limit: 4 }), [luaText, wikiEntries]);

  const draftQuestion = (entry) => {
    onDraftQuestion(formatWikiQuestionDraft(entry, { luaText }));
  };

  return (
    <aside className="lua-reference-helper">
      <div className="mini-title">
        <Search size={15} />
        Lua 참조 도우미
      </div>
      {matches.length ? (
        <div className="lua-reference-list">
          {matches.map((entry) => (
            <article key={entry.id} className="lua-reference-card">
              <strong>{entry.title}</strong>
              <p>{entry.useCase || entry.summary}</p>
              <small>{entry.sourceFile}</small>
              <button className="btn btn-mini btn-ghost" type="button" onClick={() => draftQuestion(entry)}>
                AI 채팅창에 검토 질문 넣기
              </button>
            </article>
          ))}
        </div>
      ) : (
        <div className="lua-reference-empty">
          <strong>알려진 패턴을 찾을 수 없습니다</strong>
          <p>붙여넣은 코드에서 알려진 CMO API나 템플릿 단서를 찾지 못했습니다. 백과사전에서 기능을 검색하거나 AI 에이전트에게 코드의 의미를 물어보세요.</p>
        </div>
      )}
    </aside>
  );
}
```

- [ ] **Step 4: Add minimal CSS**

Create:

```css
.lua-reference-helper {
  display: grid;
  gap: 0.75rem;
}

.lua-reference-list {
  display: grid;
  gap: 0.65rem;
}

.lua-reference-card,
.lua-reference-empty {
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 14px;
  padding: 0.8rem;
  background: rgba(8, 15, 26, 0.68);
}
```

- [ ] **Step 5: Wire beside Lua editor**

In `LuaAssistant.jsx`, import and render `LuaEditorReferenceHelper` only in the Lua editor mode. Pass current manual Lua text, normalized wiki entries, and the same text-only draft handler used by the wiki panel.

- [ ] **Step 6: Verify and commit**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
npm run lint
npm run build
```

Commit:

```powershell
git add src/components/LuaEditorReferenceHelper.jsx src/components/LuaEditorReferenceHelper.css src/components/LuaAssistant.jsx tools/verify-cmo-wiki-code-assistant-contract.mjs
git commit -m "Add Lua editor reference helper"
```

## Task 5: Release Verification and Kimi QA Directive

**Files:**

- Modify: `package.json`
- Create: `handoff/to-kimi/2026-05-13-cmo-wiki-code-assistant-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`

- [ ] **Step 1: Add smoke to verify:release**

In `package.json`, add `npm run smoke:cmo-wiki-code-assistant` before `smoke:ai-client-parser` in `verify:release`.

- [ ] **Step 2: Run full verification**

Run:

```powershell
npm run smoke:cmo-wiki-code-assistant
npm run smoke:ai-chat-entrypoint
npm run lint
npm run build
npm run verify:release
git diff --check
```

Expected:

- all PASS;
- Main JS < `400 kB`;
- Main CSS < `60 kB`;
- `aiContextPruning` < `9 kB`;
- AI adapter smoke has no raw Bearer / Authorization / sk- leakage.

- [ ] **Step 3: Create Kimi QA directive**

Create `handoff/to-kimi/2026-05-13-cmo-wiki-code-assistant-qa.md` with checkpoints:

```text
1. Helper builds 51 / 51 wiki entries.
2. TemplateLibrary utility copies moved to cmoWikiEntries helper.
3. LuaAssistant.jsx did not grow during helper-only slice.
4. Wiki panel labels include CMO Lua 백과사전, 언제 쓰나요?, CMO에서 직접 확인할 값.
5. Examples are described as 참고용 patterns, not final verified code.
6. Editor-side panel label avoids agent/AI wording and uses Lua 참조 도우미 or equivalent.
7. Text-only AI draft button does not call AI automatically.
8. Draft includes CMO engine verification wording.
9. Draft redacts Bearer/sk/local path-like strings.
10. No CMO file write, polling, watcher, live-state claim, or browser root introduced.
11. No dependency or lockfile drift.
12. Main JS/CSS/aiContextPruning watch lines remain green.
13. verify:release PASS.
```

- [ ] **Step 4: Update agent current-task files**

Set:

- Kimi active QA directive to the new QA file.
- Claude review completed / standby.
- Gemini review completed / standby.

- [ ] **Step 5: Commit QA directive**

Run:

```powershell
git add package.json handoff/to-kimi/2026-05-13-cmo-wiki-code-assistant-qa.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md
git commit -m "Open CMO wiki code assistant QA"
```

## Self-Review Checklist

- Spec coverage: helper-only, wiki UI, editor reference helper, text-only drafts, preset creation de-emphasis, and safety boundaries all have tasks.
- Placeholder scan: no implementation step relies on unspecified UI behavior.
- Type consistency: helper names are consistent across smoke, UI, and imports.
- Scope: no dependencies, no backend routes, no B2/B3/B4 behavior changes.
