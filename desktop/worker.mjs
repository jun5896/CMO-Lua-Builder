import path from 'node:path';
import { homedir } from 'node:os';
import { Workspace } from './core/workspace.mjs';
import { OmpGateway } from './core/omp-gateway.mjs';
import { inspectLuaSafety } from '../src/lib/luaSafety.js';

const directoryArgument = process.argv.indexOf('--data-dir');
const dataDirectory = directoryArgument >= 0 ? process.argv[directoryArgument + 1]
  : path.join(process.env.LOCALAPPDATA || path.join(homedir(), '.local', 'share'), 'CMO Lua Builder', 'Desktop');
if (!dataDirectory) throw new Error('Missing data directory.');
const workspace = new Workspace(path.join(path.resolve(dataDirectory), 'workspace.json'), (executable) => new OmpGateway({ executable }));
const write = (value) => process.stdout.write(`${JSON.stringify(value)}\n`);
let bootError;
try { await workspace.load(); } catch (error) { bootError = error.message; }
write({ ready: true });

async function dispatch(request) {
  if (bootError) throw new Error(bootError);
  switch (request.method) {
    case 'state': return workspace.snapshot();
    case 'create': return workspace.create(request.input || {});
    case 'update': return workspace.update(request.sessionId, request.input || {});
    case 'configure': return workspace.configure(request.executable);
    case 'models': return workspace.models();
    case 'chat': return workspace.chat(request.sessionId, request.prompt);
    case 'cancel': return workspace.cancel(request.sessionId);
    case 'clearHistory': return workspace.clearHistory(request.sessionId);
    case 'inspectLua': return inspectLuaSafety(request.content);
    default: throw new Error('Unsupported desktop command.');
  }
}
const inFlight = new Set();
function lineReceived(line) {
  let request;
  try {
    request = JSON.parse(line);
    if (!request || typeof request !== 'object' || typeof request.id !== 'string' || request.id.length > 100) throw new Error();
  } catch { write({ id: null, ok: false, error: 'Invalid desktop request.' }); return; }
  if (inFlight.has(request.id) || inFlight.size >= 12) {
    write({ id: request.id, ok: false, error: 'Too many or duplicate pending requests.' }); return;
  }
  inFlight.add(request.id);
  dispatch(request).then(
    (result) => write({ id: request.id, ok: true, result }),
    (error) => write({ id: request.id, ok: false, error: error.message || 'Desktop request failed.' }),
  ).finally(() => inFlight.delete(request.id));
}
let buffer = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  buffer += chunk;
  let newline;
  while ((newline = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, newline);
    buffer = buffer.slice(newline + 1);
    if (Buffer.byteLength(line) > 4 * 1024 * 1024) {
      write({ id: null, ok: false, error: 'Desktop request is too large.' });
    } else if (line.trim()) lineReceived(line);
  }
  if (Buffer.byteLength(buffer) > 4 * 1024 * 1024) {
    workspace.close();
    process.exitCode = 1;
    process.stdin.destroy();
  }
});
process.stdin.on('end', () => workspace.close());
process.on('SIGTERM', () => { workspace.close(); process.exit(0); });
