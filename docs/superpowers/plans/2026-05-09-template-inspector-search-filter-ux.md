# Template Inspector Search Filter UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Template Inspector findability by searching annotation text, adding first-slice quick filters, adding requirement badges, and keeping all changes inside the Preset Guide lazy chunk.

**Architecture:** This is a Track A editor-automation slice. `TemplateLibrary.jsx` remains the single behavior owner for resource search, filter state, badge derivation, and rendering. `PresetGuide.css` owns the visual treatment. No AI adapter, parser, context pruning, sidecar, CMO filesystem, package, or server code changes are allowed.

**Tech Stack:** React 19, Vite, existing public JSON manifests, existing `public/template-annotations.json`, CSS in the lazy-loaded `PresetGuide.css` chunk.

---

## File Structure

- Modify: `src/components/TemplateLibrary.jsx`
  - Add taxonomy constants and pure helper functions.
  - Extend search to annotation text.
  - Add session-only quick filter state.
  - Add requirement badge rendering.
  - Add universal AI-draft footer in the selected resource card.
- Modify: `src/components/PresetGuide.css`
  - Add styles for quick filter chips, result count line, requirement badges, and universal draft footer.
- Create: `handoff/to-kimi/2026-05-09-template-inspector-search-filter-ux-qa.md`
  - Focused QA directive for Kimi after implementation.
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
  - Mark the A1 QA directive active.

Do not modify:

- `src/lib/aiAdapterClient.js`
- `src/lib/aiContextPruning.js`
- `src/components/LuaAssistant.jsx`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiResponseReviewPanel.jsx`
- `server/**`
- `tools/**`
- `package.json`
- `package-lock.json`
- `public/template-annotations.json`
- CMO install, scenario, sidecar, or `dist/` folders

---

### Task 1: Add Taxonomy Helpers

**Files:**
- Modify: `src/components/TemplateLibrary.jsx`

- [ ] **Step 1: Insert taxonomy constants below `TEMPLATE_ANNOTATIONS_URL`**

Add this block near the top of `TemplateLibrary.jsx`, immediately after:

```js
const TEMPLATE_ANNOTATIONS_URL = '/template-annotations.json';
```

```js
const QUICK_FILTERS = [
  { id: 'event', label: 'Event' },
  { id: 'mission', label: 'Mission' },
  { id: 'unit', label: 'Unit' },
  { id: 'dbidLoadout', label: 'DBID / Loadout' },
  { id: 'rpZone', label: 'RP / Zone' },
  { id: 'doctrineEmcon', label: 'Doctrine / EMCON' },
  { id: 'keyvalue', label: 'KeyValue' },
];

const BADGE_DEFINITIONS = [
  { id: 'engineTest', label: 'engine test required', tone: 'warning' },
  { id: 'needsSide', label: 'needs Side', tone: 'info' },
  { id: 'needsMission', label: 'needs Mission', tone: 'info' },
  { id: 'needsUnitGuid', label: 'needs Unit GUID', tone: 'info' },
  { id: 'needsDbid', label: 'needs DBID', tone: 'info' },
  { id: 'needsLoadout', label: 'needs Loadout', tone: 'info' },
  { id: 'needsRpZone', label: 'needs RP / Zone', tone: 'info' },
  { id: 'affectsSideWide', label: 'affects Side-wide', tone: 'caution' },
];
```

- [ ] **Step 2: Replace `resourceSearchText(resource)` with annotation-aware helpers**

Replace the existing function:

```js
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
```

with:

```js
function annotationTextParts(annotation) {
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

function normalizeSearchText(values) {
  return values.filter(Boolean).join(' ').toLowerCase();
}

function resourceSearchText(resource, annotation) {
  return normalizeSearchText([
    resource.file,
    resource.relativePath,
    resource.scenario,
    resource.category,
    resource.type,
    ...(resource.features || []),
    ...(resource.apis || []),
    ...annotationTextParts(annotation),
  ]);
}
```

- [ ] **Step 3: Add filter and badge helper functions below `resourceSearchText()`**

```js
function includesAny(text, needles) {
  return needles.some((needle) => text.includes(needle));
}

function annotationText(annotation, field = 'all') {
  if (!annotation) return '';
  if (field === 'prerequisites') return normalizeSearchText(annotation.prerequisites || []);
  if (field === 'checks') return normalizeSearchText(annotation.checks || []);
  return normalizeSearchText(annotationTextParts(annotation));
}

function matchesQuickFilter(resource, annotation, filterId) {
  if (resource.type === 'preset') return false;

  const category = String(resource.category || '').toLowerCase();
  const allText = annotationText(annotation);

  if (filterId === 'event') return category === 'event';
  if (filterId === 'mission') return category === 'mission';
  if (filterId === 'unit') return category === 'unit' || includesAny(allText, ['unit spawn', 'unit edit', 'unit lifecycle']);
  if (filterId === 'dbidLoadout') return category === 'loadout' || includesAny(allText, ['dbid', 'loadout']);
  if (filterId === 'rpZone') return ['reference', 'zone'].includes(category) || includesAny(allText, [' rp ', 'reference point', 'zone']);
  if (filterId === 'doctrineEmcon') return category === 'doctrine' || includesAny(allText, ['doctrine', 'emcon', 'posture']);
  if (filterId === 'keyvalue') return category === 'kvstore' || includesAny(allText, ['keyvalue', 'kvstore', ' key value ']);

  return false;
}

function buildResourceBadges(resource, annotation) {
  const prerequisiteText = annotationText(annotation, 'prerequisites');
  const checkText = annotationText(annotation, 'checks');
  const allText = annotationText(annotation);
  const badges = [];

  const addBadge = (id) => {
    const badge = BADGE_DEFINITIONS.find((item) => item.id === id);
    if (badge && !badges.some((item) => item.id === id)) badges.push(badge);
  };

  if (includesAny(allText, ['engine test', 'engine verification', 'lua console', 'event editor', 'cmo engine'])) addBadge('engineTest');
  if (includesAny(prerequisiteText, ['side name', 'actual side', 'source side', 'target side'])) addBadge('needsSide');
  if (includesAny(prerequisiteText, ['mission name', 'actual mission'])) addBadge('needsMission');
  if (includesAny(prerequisiteText, ['unit guid', 'unit id', 'guid first', 'copy unit id'])) addBadge('needsUnitGuid');
  if (includesAny(prerequisiteText, ['dbid', 'database viewer'])) addBadge('needsDbid');
  if (includesAny(prerequisiteText, ['loadout id', 'loadout'])) addBadge('needsLoadout');
  if (includesAny(prerequisiteText, ['rp name', 'rp 이름', 'reference point', 'zone name', 'zone 이름'])) addBadge('needsRpZone');
  if (includesAny(allText, ['side-wide', 'side level', 'posture', 'doctrine', 'emcon'])) addBadge('affectsSideWide');

  if (!badges.some((badge) => badge.id === 'engineTest') && includesAny(checkText, ['test', 'verify', 'verification', 'check'])) {
    addBadge('engineTest');
  }

  return badges;
}
```

- [ ] **Step 4: Run lint to catch syntax issues**

```powershell
npm run lint
```

Expected: PASS. If it fails, fix only `TemplateLibrary.jsx` syntax or lint issues introduced by this task.

---

### Task 2: Add Filter State and Filtering Behavior

**Files:**
- Modify: `src/components/TemplateLibrary.jsx`

- [ ] **Step 1: Add active filter state inside `TemplateLibrary`**

After:

```js
const [query, setQuery] = useState('');
const [deferredQuery, setDeferredQuery] = useState('');
```

add:

```js
const [activeFilters, setActiveFilters] = useState([]);
```

- [ ] **Step 2: Add a filter toggle handler near `handleQuery`**

After `handleQuery`, add:

```js
const toggleFilter = (filterId) => {
  setActiveFilters((current) => (
    current.includes(filterId)
      ? current.filter((item) => item !== filterId)
      : [...current, filterId]
  ));
};

const clearFilters = () => {
  setActiveFilters([]);
};
```

- [ ] **Step 3: Replace `visibleResources` memo with query + OR filter logic**

Replace:

```js
const visibleResources = useMemo(() => {
  if (!deferredQuery) return resources;
  return resources.filter((resource) => resourceSearchText(resource).includes(deferredQuery));
}, [deferredQuery, resources]);
```

with:

```js
const visibleResources = useMemo(() => {
  return resources.filter((resource) => {
    const annotation = templateAnnotations?.[resource.file] || null;
    const matchesQuery = !deferredQuery || resourceSearchText(resource, annotation).includes(deferredQuery);
    const matchesFilters = !activeFilters.length
      || activeFilters.some((filterId) => matchesQuickFilter(resource, annotation, filterId));
    return matchesQuery && matchesFilters;
  });
}, [activeFilters, deferredQuery, resources, templateAnnotations]);
```

- [ ] **Step 4: Add an empty-state reset helper**

Near `clearFilters`, add:

```js
const resetSearchAndFilters = () => {
  setQuery('');
  setDeferredQuery('');
  clearFilters();
};
```

- [ ] **Step 5: Run lint**

```powershell
npm run lint
```

Expected: PASS.

---

### Task 3: Render Quick Filters, Counts, and Badges

**Files:**
- Modify: `src/components/TemplateLibrary.jsx`

- [ ] **Step 1: Add selected badges before JSX return**

After:

```js
const linkedTemplate = selected?.type === 'template' ? getTemplateForSource(selected.file) : null;
const sourceRoot = activeSource === 'installed' ? installedManifest?.sourceRoot : builderManifest?.sourceRoot;
```

add:

```js
const selectedAnnotation = selected ? templateAnnotations?.[selected.file] || null : null;
const selectedBadges = selected ? buildResourceBadges(selected, selectedAnnotation) : [];
```

- [ ] **Step 2: Render quick filters below the search box**

Immediately after the search box closing `</div>` around the query input, insert:

```jsx
      <div className="template-filter-bar" aria-label="Template quick filters">
        {QUICK_FILTERS.map((filter) => {
          const active = activeFilters.includes(filter.id);
          return (
            <button
              key={filter.id}
              className={`template-filter-chip ${active ? 'active' : ''}`}
              type="button"
              aria-pressed={active}
              onClick={() => toggleFilter(filter.id)}
            >
              {filter.label}
            </button>
          );
        })}
        {activeFilters.length > 0 && (
          <button className="template-filter-clear" type="button" onClick={clearFilters}>
            Clear filters
          </button>
        )}
      </div>

      <p className="template-result-count">
        {visibleResources.length} / {resources.length} resources shown
      </p>
```

- [ ] **Step 3: Render compact badges on each resource row**

Inside the `visibleResources.map((resource) => (` block, replace the current row content:

```jsx
                <span>{resourceLabel(resource)}</span>
                <small>{resource.lines} lines</small>
```

with:

```jsx
                <span>{resourceLabel(resource)}</span>
                <small>{resource.lines} lines</small>
                <span className="resource-row-badges">
                  {buildResourceBadges(resource, templateAnnotations?.[resource.file] || null).slice(0, 2).map((badge) => (
                    <em key={badge.id} className={`template-badge ${badge.tone}`}>{badge.label}</em>
                  ))}
                </span>
```

- [ ] **Step 4: Update the empty state to reset filters too**

Inside the `.resource-list-empty` block, keep the existing `<strong>` heading and replace the explanatory paragraph with this paragraph and reset button:

```jsx
              <p>Reduce the search text or clear filters, then try again.</p>
              <button className="btn btn-mini btn-ghost" type="button" onClick={resetSearchAndFilters}>
                Reset search / filters
              </button>
```

- [ ] **Step 5: Render full badges and universal draft footer in the selected card**

In the selected source card, after `<ResourceMeta selected={selected} />`, insert:

```jsx
                {selectedBadges.length > 0 && (
                  <div className="template-badge-row">
                    {selectedBadges.map((badge) => (
                      <span key={badge.id} className={`template-badge ${badge.tone}`}>{badge.label}</span>
                    ))}
                  </div>
                )}
```

After `<TemplateGuideNotes ... />` and before `<pre className="source-code">{source}</pre>`, insert:

```jsx
            <p className="template-draft-footer">
              AI draft. CMO engine verification is still required before execution.
            </p>
```

- [ ] **Step 6: Run lint**

```powershell
npm run lint
```

Expected: PASS.

---

### Task 4: Style Filters and Badges

**Files:**
- Modify: `src/components/PresetGuide.css`

- [ ] **Step 1: Add CSS near existing Template Inspector styles**

Append this block near the existing `.resource-list-empty` / Template Inspector styles:

```css
.template-filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 0.42rem;
  margin: 0.65rem 0 0;
}

.template-filter-chip,
.template-filter-clear {
  border: 1px solid rgba(164, 214, 207, 0.22);
  border-radius: 999px;
  background: rgba(0, 0, 0, 0.18);
  color: #cfe9e4;
  cursor: pointer;
  font-size: 0.72rem;
  font-weight: 700;
  padding: 0.34rem 0.58rem;
  transition: border-color 160ms ease, background 160ms ease, color 160ms ease;
}

.template-filter-chip:hover,
.template-filter-clear:hover,
.template-filter-chip.active {
  border-color: rgba(120, 219, 203, 0.58);
  background: rgba(87, 210, 190, 0.16);
  color: #f1fffc;
}

.template-filter-clear {
  color: #f6c989;
}

.template-result-count {
  margin: 0.42rem 0 0;
  color: var(--muted);
  font-size: 0.72rem;
}

.resource-row-badges,
.template-badge-row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.32rem;
}

.resource-row-badges {
  margin-top: 0.3rem;
}

.template-badge-row {
  margin-top: 0.45rem;
}

.template-badge {
  border: 1px solid rgba(164, 214, 207, 0.2);
  border-radius: 999px;
  color: #d9efeb;
  font-size: 0.66rem;
  font-style: normal;
  font-weight: 800;
  letter-spacing: 0.01em;
  padding: 0.16rem 0.42rem;
  text-transform: none;
}

.template-badge.info {
  background: rgba(96, 171, 255, 0.13);
  border-color: rgba(96, 171, 255, 0.3);
}

.template-badge.caution {
  background: rgba(246, 201, 137, 0.13);
  border-color: rgba(246, 201, 137, 0.42);
  color: #ffe1ab;
}

.template-badge.warning {
  background: rgba(255, 132, 102, 0.14);
  border-color: rgba(255, 132, 102, 0.46);
  color: #ffc4b4;
}

.template-draft-footer {
  border: 1px solid rgba(246, 201, 137, 0.26);
  border-radius: 14px;
  background: rgba(246, 201, 137, 0.1);
  color: #ffe1ab;
  font-size: 0.76rem;
  font-weight: 700;
  line-height: 1.45;
  margin: 0.7rem 0;
  padding: 0.58rem 0.72rem;
}
```

- [ ] **Step 2: Run lint**

```powershell
npm run lint
```

Expected: PASS.

- [ ] **Step 3: Run build**

```powershell
npm run build
```

Expected: PASS. Main JS remains under `400 kB`, Main CSS remains under `60 kB`, and `aiContextPruning` remains under `9 kB`. PresetGuide lazy chunk may grow, but target is at or below about `33 kB JS / 7 kB CSS`.

---

### Task 5: Manual Static Verification

**Files:**
- Read: `src/components/TemplateLibrary.jsx`
- Read: `src/components/PresetGuide.css`

- [ ] **Step 1: Verify no forbidden files changed**

```powershell
git diff --name-only
```

Expected product changes only:

```text
src/components/TemplateLibrary.jsx
src/components/PresetGuide.css
```

Handoff changes are allowed only after Task 6.

- [ ] **Step 2: Verify no forbidden runtime strings were introduced**

```powershell
rg -n "apiKey|Authorization|Bearer|sk-|localStorage|sessionStorage|CMO_SCENARIO_SIDECAR_ROOT|writeFile|unlink|rm|Remove-Item" src/components/TemplateLibrary.jsx src/components/PresetGuide.css
```

Expected: no matches, except none are expected for this slice.

- [ ] **Step 3: Verify quick filter labels are exactly the first-slice taxonomy**

```powershell
rg -n "Event|Mission|Unit|DBID / Loadout|RP / Zone|Doctrine / EMCON|KeyValue" src/components/TemplateLibrary.jsx
```

Expected: all seven labels present.

- [ ] **Step 4: Verify removed noisy filters are absent**

```powershell
rg -n "GUID filter|Side / Posture|Engine Test Required" src/components/TemplateLibrary.jsx
```

Expected: no matches. `needs Unit GUID` and `engine test required` may appear as badge labels, but there must be no quick filter with those labels.

- [ ] **Step 5: Verify universal draft footer exists**

```powershell
rg -n "AI draft|CMO engine verification" src/components/TemplateLibrary.jsx
```

Expected: one footer string in the selected resource card.

---

### Task 6: Create Kimi QA Directive

**Files:**
- Create: `handoff/to-kimi/2026-05-09-template-inspector-search-filter-ux-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`

- [ ] **Step 1: Create the QA directive**

The directive must ask Kimi to verify:

```markdown
# Kimi QA Directive - Template Inspector Search Filter UX

## Status

Active QA request.

## Target

Track A1 Template Inspector Search and Filter UX.

## Scope To Verify

- Product files should be limited to `src/components/TemplateLibrary.jsx` and `src/components/PresetGuide.css`.
- No AI adapter, parser, context pruning, server, tools, package, public JSON, sidecar, or CMO folder changes.
- Annotation text is searchable.
- Quick filters are exactly Event, Mission, Unit, DBID / Loadout, RP / Zone, Doctrine / EMCON, and KeyValue.
- Multiple active filters use OR semantics.
- GUID, Side standalone, and Engine Test are not quick filters.
- Badges include engine test required, needs Side, needs Mission, needs Unit GUID, needs DBID, needs Loadout, needs RP / Zone, and affects Side-wide when applicable.
- Universal AI draft footer is visible on selected cards.
- Empty result state offers search/filter reset.

## Pipeline

Run:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
npm run smoke:ai-client-parser
```

Report:

- Main JS under `400 kB`
- Main CSS under `60 kB`
- PresetGuide lazy chunk delta from `30.05 kB JS / 5.86 kB CSS`
- `aiContextPruning` under `9 kB`
- no raw `Bearer`, `Authorization`, or `sk-` leakage

## Static Negative Checks

- No `apiKey`, `localStorage`, or `sessionStorage` introduced in `TemplateLibrary.jsx`.
- No generated sidecar data appears in `public/`, `dist/`, or project-local sidecar folders.
- Prompt-copy fallback and `isPasteReady` apply gate remain unchanged.

## Verdict

Approve only if all pipeline and static checks pass.
```

- [ ] **Step 2: Update Kimi `CURRENT_TASK.md`**

Set active state to the new directive. Preserve existing baseline sections and only add a compact top-level active directive note.

- [ ] **Step 3: Commit implementation + QA directive**

```powershell
git status --short
git add src/components/TemplateLibrary.jsx src/components/PresetGuide.css handoff/to-kimi/2026-05-09-template-inspector-search-filter-ux-qa.md handoff/to-kimi/CURRENT_TASK.md
git commit -m "Add template inspector search filter UX"
```

Expected: commit succeeds.

---

### Task 7: Final Verification Before Handoff

**Files:**
- No source edits.

- [ ] **Step 1: Run focused pipeline**

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
npm run smoke:ai-client-parser
```

Expected: all PASS.

- [ ] **Step 2: Confirm git state**

```powershell
git status --short --branch
```

Expected: clean except no untracked files.

- [ ] **Step 3: Push**

```powershell
git push
```

Expected: `main -> origin/main`.

- [ ] **Step 4: Report to user**

Include:

- Commit hash.
- Files changed.
- Bundle sizes.
- Smoke status.
- Kimi QA directive path.

Do not create a release tag yet. The release tag is a separate branch point after Kimi approves.
