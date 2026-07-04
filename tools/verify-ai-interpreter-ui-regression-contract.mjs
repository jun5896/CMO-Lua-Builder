import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const indexCss = readFileSync('src/index.css', 'utf8');
const settingsSource = readFileSync('src/components/AiAdapterSettings.jsx', 'utf8');
const chatSource = readFileSync('src/components/AiInterpreterChatPanel.jsx', 'utf8');
const assistantSource = readFileSync('src/components/LuaAssistant.jsx', 'utf8');

const responsiveMatch = indexCss.match(/@media\s*\(\s*max-width:\s*(\d+)px\s*\)/);
assert.ok(responsiveMatch, 'responsive breakpoint media query should exist');
assert.ok(
  Number(responsiveMatch[1]) <= 1120,
  `desktop workspace should not collapse at 1280px; observed breakpoint ${responsiveMatch[1]}px`,
);
assert.doesNotMatch(
  indexCss,
  /\.ai-readiness-panel\s*{[^}]*grid-template-columns:\s*minmax\(0,\s*1fr\)\s+auto\s+auto/s,
  'AI adapter readiness card should not squeeze status text into a near-zero column',
);

assert.match(
  settingsSource,
  /API key 입력칸은 보안상 비웁니다/,
  'settings UI should explain why the API key field is cleared after apply',
);
assert.match(
  settingsSource,
  /adapter 메모리/,
  'settings UI should state that the applied key stays only in adapter memory',
);

assert.match(
  chatSource,
  /ai-chat-response-preview/,
  'AI chat panel should render a visible latest-response preview',
);
assert.match(
  chatSource,
  /최근 AI 응답 미리보기/,
  'AI chat panel should label the latest-response preview clearly',
);
assert.match(
  chatSource,
  /AI 응답 탭에서 전체 구조화 검토/,
  'AI chat panel should provide a clear review target for full response inspection',
);

assert.match(
  assistantSource,
  /const callAiAdapter = async \(promptOverride, statusLabel = '현재 요청문', nextPreviewTab = 'ai'\)/,
  'primary AI calls should route the response to the AI response tab by default',
);
assert.match(
  assistantSource,
  /setOutputPreviewTab\(nextPreviewTab\)/,
  'AI calls should switch to the target preview tab before the response arrives',
);

console.log('PASS - AI interpreter UI regression contract holds.');
