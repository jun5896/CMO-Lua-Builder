import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const appSource = readFileSync('src/App.jsx', 'utf8');
const assistantSource = readFileSync('src/components/LuaAssistant.jsx', 'utf8');
const indexCss = readFileSync('src/index.css', 'utf8');
const chatSource = readFileSync('src/components/AiInterpreterChatPanel.jsx', 'utf8');

assert.match(
  appSource,
  /const WORKSPACE_TABS = \[\s*{ id: 'agent', label: 'Lua 편집 에이전트'/s,
  'Lua editing agent should be the leftmost top-level workspace tab',
);
assert.match(
  appSource,
  /{ id: 'encyclopedia', label: '백과사전'/,
  'Encyclopedia should be the second top-level workspace tab',
);
assert.match(
  appSource,
  /{ id: 'settings', label: '설정'/,
  'Settings should be the third top-level workspace tab',
);
assert.match(
  appSource,
  /const AGENT_MODE_TABS = \[/,
  'Lua editing agent should define a two-item sub menu',
);
assert.match(
  appSource,
  /{ id: 'chat', label: 'AI 에이전트 대화'/,
  'Agent sub menu should include AI agent chat',
);
assert.match(
  appSource,
  /{ id: 'editor', label: 'Lua 편집기'/,
  'Agent sub menu should include Lua editor',
);
assert.match(
  appSource,
  /activeTab: 'agent'/,
  'new workspaces should open on the Lua editing agent by default',
);
assert.match(
  appSource,
  /agentMode: 'chat'/,
  'Lua editing agent should default to AI agent chat mode',
);
assert.match(
  indexCss,
  /grid-template-columns:\s*repeat\(3,\s*minmax\(0,\s*1fr\)\)/,
  'top workspace nav should allocate three columns',
);
assert.match(
  indexCss,
  /\.workspace-tab\.primary-agent-tab/,
  'Lua editing agent top-level tab should receive distinct visual styling',
);
assert.match(
  appSource,
  /activeTab !== 'agent'/,
  'LuaAssistant should be mounted only for the Lua editing agent tab',
);
assert.match(
  appSource,
  /focusOutputPreviewTab={agentMode === 'chat' \? 'chat' : ''}/,
  'AI agent chat sub menu should focus the simple chat entrypoint',
);
assert.match(
  appSource,
  /const LuaAssistant = lazy\(\(\) => import\('\.\/components\/LuaAssistant'\)\)/,
  'LuaAssistant should be lazy-loaded so the heavy assistant does not stay in the main bundle',
);
assert.doesNotMatch(
  appSource,
  /import LuaAssistant from '\.\/components\/LuaAssistant'/,
  'LuaAssistant should not be statically imported by App.jsx',
);

assert.match(
  assistantSource,
  /function LuaAssistant\(\{\s*focusOutputPreviewTab = ''/,
  'LuaAssistant should accept a top-level preview focus prop',
);
assert.match(
  assistantSource,
  /renderSimpleAiChatPane/,
  'AI Chat entrypoint should render a dedicated simple chat pane',
);
assert.match(
  assistantSource,
  /simple-ai-chat-pane/,
  'AI Chat pane should not reuse the full Output & Validation layout',
);
assert.match(
  assistantSource,
  /!\s*focusOutputPreviewTab && \(\s*<div className="assistant-section-actions">/s,
  'AI Chat pane should hide the expert file action toolbar',
);
assert.match(
  assistantSource,
  /!\s*focusOutputPreviewTab && \(\s*<div className="assistant-file-strip">/s,
  'AI Chat pane should hide the expert file status strip',
);
assert.match(
  assistantSource,
  /AI Chat \/ Lua Assistant/,
  'chat entrypoint should make the panel title match the chat-first mode',
);
assert.match(
  assistantSource,
  /chatScenarioFileInputRef/,
  'simple AI Chat should have a scenario attachment input',
);
assert.match(
  assistantSource,
  /chatAttachmentInputRef/,
  'simple AI Chat should support Lua/background file attachments',
);
assert.match(
  assistantSource,
  /chatAttachmentFolderInputRef/,
  'simple AI Chat should support folder scan attachments',
);
assert.match(
  assistantSource,
  /SCENARIO_SCEN_METADATA_READ_LIMIT/,
  'simple AI Chat should disclose the .scen browser metadata read limit',
);
assert.match(
  assistantSource,
  /SCENARIO_XML_SIDECAR_CHAR_LIMIT/,
  'simple AI Chat should disclose the XML/JSON summary read limit',
);
assert.match(
  assistantSource,
  /CHAT_ATTACHMENT_TEXT_READ_LIMIT/,
  'simple AI Chat should have a bounded text attachment read limit',
);
assert.match(
  assistantSource,
  /preserveEditors:\s*true/,
  'AI Chat scenario attachment should not overwrite the manual editors',
);
assert.match(
  assistantSource,
  /Do not overwrite the manual editor draft from attachments/,
  'attached files should be prompt context instead of automatic editor replacement',
);

assert.match(
  chatSource,
  /simpleMode = false/,
  'AI chat panel should support a simplified mode',
);
assert.match(
  chatSource,
  /simpleMode \? 'CMO AI Chat' : 'AI Interpreter Chat'/,
  'simple mode should present a plain chat title',
);
assert.match(
  chatSource,
  /!simpleMode && \(/,
  'simple mode should hide advanced review controls',
);
assert.match(
  chatSource,
  /hidden={simpleMode}/,
  'simple mode should hide advanced status and prompt preview panels',
);
assert.match(
  chatSource,
  /const hasAiResponse = Boolean\(responsePreview\)/,
  'AI chat panel should distinguish idle state from parsed non-ready responses',
);
assert.match(
  chatSource,
  /const blockerCount = hasAiResponse \? parsedResponse\?\.blockers\?\.length \|\| 0 : 0/,
  'AI chat panel should not show parser blockers before any AI response exists',
);
assert.match(
  chatSource,
  /!hasAiResponse\s*\?\s*'응답 대기/,
  'AI chat panel idle state should say response pending instead of Lua missing',
);

console.log('PASS - AI chat entrypoint contract holds.');
