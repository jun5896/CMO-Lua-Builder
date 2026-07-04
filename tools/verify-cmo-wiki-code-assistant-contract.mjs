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

function readJson(path) {
  return JSON.parse(readFileSync(path, 'utf8').replace(/^\uFEFF/, ''));
}

const annotationsPayload = readJson('public/template-annotations.json');
const builderManifest = readJson('public/cmo-dev-work/manifest.json');
const installedManifest = readJson('public/cmo-installed-lua/manifest.json');
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
assert.equal(/sendCmoAiPrompt|fetch\(|writeFile|appendFile|unlink|rm\(|watch\(/.test(helperSource), false);

const templateLibrarySource = readFileSync('src/components/TemplateLibrary.jsx', 'utf8');
assert.ok(templateLibrarySource.includes("from '../lib/cmoWikiEntries'"));
assert.equal(/function annotationTextParts|function normalizeSearchText|function annotationText|function buildResourceBadges/.test(templateLibrarySource), false);

const appSource = readFileSync('src/App.jsx', 'utf8');
assert.ok(
  appSource.includes("lazy(() => import('./components/CmoWikiPanel'))"),
  'encyclopedia tab should lazy-load the new CMO wiki panel',
);
assert.ok(
  appSource.includes('cmo-ai-chat-draft-request'),
  'wiki question drafts should route to AI chat input through a text-only event',
);

const wikiPanelSource = readFileSync('src/components/CmoWikiPanel.jsx', 'utf8');
assert.ok(wikiPanelSource.includes('CMO Lua 백과사전'));
assert.ok(wikiPanelSource.includes('언제 쓰나요?'));
assert.ok(wikiPanelSource.includes('CMO에서 직접 확인할 값'));
assert.ok(wikiPanelSource.includes('참고용 템플릿 예제'));
assert.ok(wikiPanelSource.includes('AI 채팅창에 질문 초안 넣기'));
assert.ok(wikiPanelSource.includes('자동 전송되지 않습니다'));
assert.equal(/onAddTemplate|템플릿 추가|제작 폼에 추가/.test(wikiPanelSource), false);
assert.equal(/sendCmoAiPrompt|saveCmoLuaSidecar|fetchCmoLogFeedback|importCmoStateSnapshot/.test(wikiPanelSource), false);

const editorHelperSource = readFileSync('src/components/LuaEditorReferenceHelper.jsx', 'utf8');
assert.ok(editorHelperSource.includes('Lua 참조 도우미'));
assert.ok(editorHelperSource.includes('알려진 패턴을 찾을 수 없습니다'));
assert.ok(editorHelperSource.includes('AI 채팅창에 검토 질문 넣기'));
assert.ok(editorHelperSource.includes('자동 전송되지 않습니다'));
assert.equal(/sendCmoAiPrompt|fetch\(|ScenEdit_RunScript|writeFile|appendFile/.test(editorHelperSource), false);

const assistantSource = readFileSync('src/components/LuaAssistant.jsx', 'utf8');
assert.ok(assistantSource.includes("lazy(() => import('./LuaEditorReferenceHelper'))"));
assert.ok(assistantSource.includes('<LuaEditorReferenceHelper'));

console.log('PASS - CMO wiki code assistant helper contract holds.');
