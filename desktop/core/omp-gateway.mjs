import { spawn } from 'node:child_process';
import { homedir } from 'node:os';
import path from 'node:path';
import { existsSync } from 'node:fs';
import { randomUUID } from 'node:crypto';

export function defaultOmpExecutable() {
  const local = path.join(homedir(), '.local', 'bin', process.platform === 'win32' ? 'omp.exe' : 'omp');
  return existsSync(local) ? local : process.platform === 'win32' ? 'omp.exe' : 'omp';
}

export function validateExecutable(value) {
  if (typeof value !== 'string' || !value.trim() || /[\r\n\0]/.test(value)) throw new Error('Select an OMP executable.');
  const executable = value.trim();
  if (process.platform === 'win32' && !/\.exe$/i.test(executable)) throw new Error('OMP must be a native .exe, not a shell command or .cmd shim.');
  return executable;
}

// A child belongs to one request. Cancellation never kills another side's call.
// No shell, HTTP listener, credential snapshots, or provider configuration writes.
export class OmpGateway {
  constructor({ executable = defaultOmpExecutable(), spawnImpl = spawn, timeoutMs = 180_000 } = {}) {
    this.executable = validateExecutable(executable);
    this.spawnImpl = spawnImpl;
    this.timeoutMs = timeoutMs;
  }

  request(route, body, { signal } = {}) {
    if (!['/v1/models', '/v1/chat/completions'].includes(route)) throw new Error('Unsupported OMP route.');
    return new Promise((resolve, reject) => {
      if (signal?.aborted) return reject(new Error('Request cancelled. Provider billing may already have occurred.'));
      const id = randomUUID();
      let child;
      let pending = '';
      let size = 0;
      let settled = false;
      let timer;
      const finish = (error, value) => {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        signal?.removeEventListener('abort', abort);
        child?.stdin.destroy();
        child?.kill();
        if (error) reject(error); else resolve(value);
      };
      const abort = () => finish(new Error('Request cancelled. Provider billing may already have occurred.'));
      try {
        child = this.spawnImpl(this.executable, ['auth-gateway', 'stdio'], {
          shell: false, windowsHide: true, cwd: homedir(), stdio: ['pipe', 'pipe', 'pipe'],
        });
      } catch { finish(new Error('Could not start OMP. Check the executable path.')); return; }
      signal?.addEventListener('abort', abort, { once: true });
      timer = setTimeout(() => finish(new Error('OMP timed out. No automatic retry was sent.')), this.timeoutMs);
      child.on('error', () => finish(new Error('Could not start OMP. Check the executable path.')));
      child.on('close', () => finish(new Error('OMP exited without a response. Check OMP login and configuration.')));
      child.stdin.on('error', () => finish(new Error('OMP input connection closed.')));
      // Discard diagnostics: they can contain credential/configuration details.
      child.stderr.on('data', () => {});
      child.stdout.setEncoding('utf8');
      child.stdout.on('data', (chunk) => {
        size += Buffer.byteLength(chunk);
        if (size > 24 * 1024 * 1024) return finish(new Error('OMP response exceeded the local size limit.'));
        pending += chunk;
        let end;
        while ((end = pending.indexOf('\n')) >= 0 && !settled) {
          const line = pending.slice(0, end);
          pending = pending.slice(end + 1);
          let frame;
          try { frame = JSON.parse(line); } catch { continue; }
          if (frame?.id !== id) continue;
          if (!Number.isInteger(frame.status) || frame.status < 200 || frame.status >= 300) {
            finish(new Error(`OMP returned HTTP ${Number(frame.status) || 'error'}. Check model access in OMP; no automatic retry was sent.`));
          } else finish(null, frame.body);
        }
      });
      child.stdin.end(`${JSON.stringify({ id, path: route, ...(body === undefined ? {} : { body }) })}\n`);
    });
  }

  async models(options) {
    const result = await this.request('/v1/models', undefined, options);
    if (!Array.isArray(result?.data)) throw new Error('OMP returned an invalid model catalog.');
    return result.data.filter((m) => typeof m.id === 'string').map((m) => ({
      id: m.id, name: typeof m.display_name === 'string' ? m.display_name : m.id,
      kind: m.kind || 'chat', provider: m.owned_by || m.id.split('/')[0],
    })).sort((a, b) => a.id.localeCompare(b.id));
  }

  async chat({ model, messages, maxTokens }, options) {
    const result = await this.request('/v1/chat/completions', {
      model, messages, stream: false, max_tokens: maxTokens,
    }, options);
    const content = result?.choices?.[0]?.message?.content;
    if (typeof content !== 'string' || !content.trim()) throw new Error('The selected model returned no text response.');
    if (content.length > 320_000) throw new Error('Model output exceeded the local draft limit.');
    const usage = {};
    for (const key of ['prompt_tokens', 'completion_tokens', 'total_tokens']) {
      if (Number.isFinite(result?.usage?.[key]) && result.usage[key] >= 0) usage[key] = result.usage[key];
    }
    return { content, actualModel: typeof result.model === 'string' ? result.model : model, usage };
  }
}
