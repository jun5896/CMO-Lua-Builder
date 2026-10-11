import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import { PassThrough, Writable } from 'node:stream';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { Workspace, buildMessages } from '../desktop/core/workspace.mjs';
import { OmpGateway } from '../desktop/core/omp-gateway.mjs';
import { validateObservation, exampleObservation } from '../desktop/core/observations.mjs';

const directory = await mkdtemp(path.join(tmpdir(), 'cmo-desktop-test-'));
const catalog = [{ id: 'mock/chat', kind: 'chat' }, { id: 'typesafe/jev-latest', kind: 'judge' }];
const captured = [];
let responder = async () => ({ content: 'Reviewed.\n```lua\nprint("draft")\n```', actualModel: 'mock/actual', usage: { prompt_tokens: 10, completion_tokens: 8 } });
const gateway = { models: async () => catalog, chat: async (request, options) => { captured.push(request); return responder(request, options); } };
const file = path.join(directory, 'workspace.json');
const workspace = new Workspace(file, () => gateway);
await workspace.load();
const make = (mode, sideId = '') => workspace.create({ name: sideId || mode, mode, scenarioId: 'scenario-one', sideId });
const blue = await make('advice', 'blue');
const red = await make('advice', 'red');
const author = await make('authoring');
const lua = await make('lua');
const observation = (session, marker) => ({ ...exampleObservation(session), missionNotes: [marker] });
await workspace.update(blue.id, { model: 'mock/chat', context: JSON.stringify(observation(blue, 'BLUE_PRIVATE_FACT')) });
await workspace.update(red.id, { model: 'mock/chat', context: JSON.stringify(observation(red, 'RED_PRIVATE_FACT')) });
await workspace.update(author.id, { model: 'mock/chat', context: 'AUTHOR_SECRET_EVENT' });
await workspace.update(lua.id, { model: 'mock/chat', draft: 'print("CURRENT_LUA")' });
await workspace.models();
await workspace.chat(blue.id, 'BLUE_PRIVATE_PROMPT');
await workspace.chat(red.id, 'RED_PRIVATE_PROMPT');
assert(JSON.stringify(captured[0]).includes('BLUE_PRIVATE_FACT'));
assert(!JSON.stringify(captured[0]).includes('RED_PRIVATE'));
assert(JSON.stringify(captured[1]).includes('RED_PRIVATE_FACT'));
assert(!JSON.stringify(captured[1]).includes('BLUE_PRIVATE'));
assert(!JSON.stringify(captured).includes('AUTHOR_SECRET_EVENT'));
assert.equal(workspace.session(blue.id).draft, '', 'advice never adopts executable output');
await workspace.chat(lua.id, 'Review my draft');
assert(JSON.stringify(captured.at(-1)).includes('CURRENT_LUA'));
assert(workspace.session(lua.id).draft.includes('print("draft")'));
assert.equal(workspace.session(lua.id).turns[1].actualModel, 'mock/actual');
await assert.rejects(workspace.update(blue.id, { sideId: 'red' }), /cannot be changed/);
assert.equal(workspace.session(blue.id).sideId, 'blue');
assert.throws(() => validateObservation(observation(red, 'x'), blue), /does not match/);
assert.throws(() => validateObservation({ ...observation(blue, 'x'), events: ['hidden'] }, blue), /unsupported fields/);
assert.throws(() => validateObservation({ ...observation(blue, 'x'), contacts: [{ id: 'c', label: 'c', lastKnown: 'unknown', confidence: 'low', actualUnitGuid: 'hidden' }] }, blue), /unsupported fields/);
await workspace.update(red.id, { context: JSON.stringify(observation(blue, 'x')) });
const countBefore = captured.length;
await assert.rejects(workspace.chat(red.id, 'Test mismatched data'), /does not match/);
assert.equal(captured.length, countBefore);
await workspace.update(red.id, { context: JSON.stringify(observation(red, 'RED_PRIVATE_FACT')) });
await workspace.update(author.id, { model: 'typesafe/jev-latest' });
await assert.rejects(workspace.chat(author.id, 'Chat with judge'), /chat model/);
await workspace.update(author.id, { model: 'mock/chat', requestLimit: 1 });
responder = async () => ({ content: '```lua\nos.execute("bad")\n```', actualModel: 'mock/chat', usage: {} });
const unsafe = await workspace.chat(author.id, 'Draft');
assert.equal(unsafe.inspection.ok, false);
assert.equal(workspace.session(author.id).draft, '');
await assert.rejects(workspace.chat(author.id, 'Over limit'), /limit reached/);
await workspace.clearHistory(author.id);
assert.equal(workspace.session(author.id).requests, 1, 'clearing history does not reset spend limit');

// A request for one side may finish after another without mixing persistence.
const deferred = new Map();
responder = (request, { signal }) => new Promise((resolve, reject) => {
  const side = request.messages[0].content.includes('"sideId":"blue"') ? 'blue' : 'red';
  deferred.set(side, resolve);
  signal.addEventListener('abort', () => reject(new Error('Request cancelled.')), { once: true });
});
const blueRun = workspace.chat(blue.id, 'blue pending');
const redRun = workspace.chat(red.id, 'red pending');
const blueFailure = assert.rejects(blueRun, /cancelled/);
while (deferred.size < 2) await new Promise(resolve => setTimeout(resolve, 5));
await assert.rejects(workspace.chat(lua.id, 'third'), /Two requests/);
await assert.rejects(workspace.update(blue.id, { context: 'changed' }), /in progress/);
workspace.cancel(blue.id);
deferred.get('red')({ content: 'RED_ONLY_RESULT', actualModel: 'mock/chat', usage: {} });
await blueFailure;
await redRun;
assert(!JSON.stringify(workspace.session(blue.id)).includes('RED_ONLY_RESULT'));
assert(workspace.session(red.id).turns.at(-1).content.includes('RED_ONLY_RESULT'));
assert.equal(workspace.active.size, 0);
const restored = new Workspace(file, () => gateway);
await restored.load();
assert.deepEqual(restored.snapshot().sessions, workspace.snapshot().sessions);
const oversized = structuredClone(workspace.session(lua.id));
oversized.turns = [{ role: 'user', content: 'x'.repeat(250_000) }];
assert.throws(() => buildMessages(oversized, 'next'), /nothing was silently truncated/);

// Transport: argv boundaries, opaque ids, credential-error redaction, cancel.
let spawnArgs;
let transportMode = 'success';
function spawnFake(...args) {
  spawnArgs = args;
  const child = new EventEmitter();
  child.stdout = new PassThrough(); child.stderr = new PassThrough(); child.killed = false;
  child.kill = () => { child.killed = true; return true; };
  child.stdin = new Writable({ write(chunk, _encoding, done) {
    const frame = JSON.parse(chunk.toString());
    queueMicrotask(() => {
      child.stderr.write('Authorization: Bearer SYNTHETIC_SECRET');
      if (transportMode === 'hang') return;
      child.stdout.write(JSON.stringify({ ready: true }) + '\n');
      child.stdout.write(JSON.stringify({ id: 'other-id', status: 200, body: { data: [] } }) + '\n');
      child.stdout.write(JSON.stringify({ id: frame.id, status: transportMode === 'error' ? 401 : 200, body: transportMode === 'error' ? { secret: 'SYNTHETIC_SECRET' } : { data: [{ id: 'mock/chat' }, { id: 'mock/judge', kind: 'judge' }] } }) + '\n');
    });
    done();
  } });
  return child;
}
const transport = new OmpGateway({ executable: process.platform === 'win32' ? 'C:\\path with spaces\\omp.exe' : '/path with spaces/omp', spawnImpl: spawnFake, timeoutMs: 1000 });
assert.equal((await transport.models())[0].kind, 'chat');
assert.deepEqual(spawnArgs[1], ['auth-gateway', 'stdio']);
assert.equal(spawnArgs[2].shell, false);
assert.equal(spawnArgs[2].windowsHide, true);
transportMode = 'error';
await assert.rejects(transport.models(), (error) => error.message.includes('401') && !error.message.includes('SYNTHETIC_SECRET'));
transportMode = 'hang';
const cancellation = new AbortController();
const cancelled = transport.models({ signal: cancellation.signal });
cancellation.abort(); await assert.rejects(cancelled, /cancelled/);
const quickTimeout = new OmpGateway({ spawnImpl: spawnFake, timeoutMs: 10 });
await assert.rejects(quickTimeout.models(), /timed out/);

// Exercise the actual worker process protocol without launching OMP.
const worker = spawn(process.execPath, [fileURLToPath(new URL('../desktop/worker.mjs', import.meta.url)), '--data-dir', path.join(directory, 'stdio')], { stdio: ['pipe', 'pipe', 'pipe'], windowsHide: true });
let output = '';
worker.stdout.setEncoding('utf8'); worker.stdout.on('data', chunk => { output += chunk; });
const responses = () => output.split('\n').filter(Boolean).map(line => JSON.parse(line));
async function rpc(id, method, input) {
  worker.stdin.write(JSON.stringify({ id, method, input }) + '\n');
  for (let i = 0; i < 500; i++) {
    const result = responses().find(item => item.id === id);
    if (result) return result;
    await new Promise(resolve => setTimeout(resolve, 10));
  }
  throw new Error('Worker RPC timed out');
}
try {
  assert.equal((await rpc('state', 'state')).result.sessions.length, 0);
  const createResult = await rpc('create', 'create', { name: 'Native client', mode: 'lua', scenarioId: 's', sideId: '' });
  assert.equal(createResult.ok, true);
  assert.equal((await rpc('unknown', 'executeLua')).ok, false, 'no game execution surface');
  assert.equal((await rpc('state2', 'state')).result.sessions.length, 1);
} finally { worker.stdin.end(); worker.kill(); }
await writeFile(path.join(directory, 'corrupt.json'), '{broken');
const corrupt = new Workspace(path.join(directory, 'corrupt.json'), () => gateway);
await assert.rejects(corrupt.load(), /Original file was preserved/);
assert.equal(await readFile(path.join(directory, 'corrupt.json'), 'utf8'), '{broken');
console.log(JSON.stringify({ ok: true, checks: ['side isolation', 'immutable binding', 'observation contract', 'OMP chat/judge split', 'Lua screening', 'budget', 'parallel cancellation', 'restart persistence', 'bounded context', 'stdio transport/redaction/timeout', 'worker protocol', 'corrupt-file preservation'] }));
