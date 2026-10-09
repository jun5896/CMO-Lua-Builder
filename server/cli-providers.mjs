/**
 * cli-providers.mjs — subscription-CLI provider implementations.
 *
 * Runs a locally installed coding-agent CLI in one-shot headless mode and
 * adapts the result to the same response shape as providers.mjs, so the UI
 * and bridge consume it exactly like an HTTP provider:
 *
 *   - claude-cli : Claude Code (`claude -p`), profile via CLAUDE_CONFIG_DIR
 *   - codex-cli  : OpenAI Codex (`codex exec`), account via CODEX_HOME
 *   - cursor-cli : Cursor Agent (`cursor-agent -p`), Composer via subscription
 *                  (Cursor blocks BYOK HTTP access to Composer; the CLI is the
 *                  only supported headless path)
 *   - grok-cli   : Grok Build CLI (`grok -p/--single`), subscription auth in
 *                  ~/.grok. The prompt must travel as an argv value (the CLI
 *                  has no stdin prompt mode), so grok-cli prompts are length-
 *                  capped below the Windows command-line limit.
 *
 * Safety posture:
 *   - Prompts are passed via stdin where the CLI supports it (no shell
 *     injection surface, no Windows command-line length limit); grok-cli is
 *     the argv exception and is length-guarded instead.
 *   - CLIs run in the OS temp directory so they cannot pick up repo context
 *     or edit project files, and codex runs with --sandbox read-only.
 *   - cfg.cliHome must be an existing directory; model ids are validated.
 */

import { spawn, spawnSync } from 'node:child_process';
import { existsSync, mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';

export const CLI_PROVIDER_TYPES = new Set(['claude-cli', 'codex-cli', 'cursor-cli', 'grok-cli']);

const MODEL_RE = /^[A-Za-z0-9._:\/-]{1,64}$/;
const DEFAULT_CLI_TIMEOUT_MS = 300_000;
// Windows CreateProcess command lines cap at ~32K chars; leave headroom.
const GROK_ARGV_PROMPT_LIMIT = 28_000;
// Sentinel model meaning "let the CLI use its configured default model".
const AUTO_MODEL = new Set(['', 'auto', 'default']);

export function isCliProviderType(providerType) {
  return CLI_PROVIDER_TYPES.has(providerType);
}

export function flattenMessagesToPrompt(messages = []) {
  const system = [];
  const turns = [];

  for (const message of messages) {
    const content = String(message?.content || '').trim();
    if (!content) continue;
    if (message.role === 'system') {
      system.push(content);
    } else {
      turns.push(`[${message.role || 'user'}]\n${content}`);
    }
  }

  const parts = [];
  if (system.length) parts.push(`[system]\n${system.join('\n\n')}`);
  parts.push(...turns);
  parts.push('[assistant]\nRespond with the assistant message only.');
  return parts.join('\n\n');
}

/**
 * Pure builder — returns the spawn plan without any I/O, so contracts can
 * verify argv/env shape offline.
 */
export function buildCliInvocation(cfg) {
  const rawModel = String(cfg.model || '').trim();
  if (rawModel && !MODEL_RE.test(rawModel)) {
    throw new Error('Invalid CLI model id');
  }
  // 'auto'/'default' → omit the model flag and use the CLI's configured default.
  const model = AUTO_MODEL.has(rawModel.toLowerCase()) ? '' : rawModel;

  const envOverrides = {};
  const home = String(cfg.cliHome || '').trim();

  switch (cfg.providerType) {
    case 'claude-cli': {
      if (home) envOverrides.CLAUDE_CONFIG_DIR = home;
      return {
        command: 'claude',
        args: ['-p', '--output-format', 'text', '--max-turns', '1', ...(model ? ['--model', model] : [])],
        envOverrides,
        promptViaStdin: true,
        readsLastMessageFile: false,
      };
    }
    case 'grok-cli': {
      const prompt = String(cfg.prompt || '');
      if (!prompt) throw new Error('grok-cli requires the prompt at invocation-build time');
      if (prompt.length > GROK_ARGV_PROMPT_LIMIT) {
        throw new Error(`grok-cli prompt exceeds argv limit (${prompt.length} > ${GROK_ARGV_PROMPT_LIMIT} chars) — shrink the context or use another backend`);
      }
      return {
        command: 'grok',
        args: ['-p', prompt, '--output-format', 'plain', ...(model ? ['-m', model] : [])],
        envOverrides,
        promptViaStdin: false,
        readsLastMessageFile: false,
      };
    }
    case 'codex-cli': {
      if (home) envOverrides.CODEX_HOME = home;
      return {
        command: 'codex',
        args: [
          'exec',
          '--sandbox', 'read-only',
          '--skip-git-repo-check',
          ...(model ? ['--model', model] : []),
          ...(cfg.lastMessageFile ? ['--output-last-message', cfg.lastMessageFile] : []),
          '-',
        ],
        envOverrides,
        promptViaStdin: true,
        readsLastMessageFile: Boolean(cfg.lastMessageFile),
      };
    }
    case 'cursor-cli': {
      if (home) envOverrides.CURSOR_CONFIG_DIR = home;
      return {
        command: 'cursor-agent',
        // --trust: headless runs require directory trust; we always run in an
        // empty OS temp directory, so trusting it grants access to nothing.
        args: ['-p', '--trust', '--output-format', 'text', ...(model ? ['--model', model] : [])],
        envOverrides,
        promptViaStdin: true,
        readsLastMessageFile: false,
      };
    }
    default:
      throw new Error(`Unknown CLI providerType: ${cfg.providerType}`);
  }
}

export function resolveCliExecutable(command) {
  const probe = process.platform === 'win32'
    ? spawnSync('where', [command], { encoding: 'utf8' })
    : spawnSync('which', [command], { encoding: 'utf8' });

  if (probe.status !== 0) return '';
  const lines = String(probe.stdout || '').split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  if (!lines.length) return '';

  // Prefer a real executable over shell shims so we can spawn without a shell.
  const exe = lines.find((line) => /\.(exe|com)$/i.test(line));
  return exe || lines[0];
}

function cliFailure(cfg, message) {
  return {
    status: 502,
    body: {
      ok: false,
      providerType: cfg.providerType,
      baseUrl: '',
      model: cfg.model,
      status: 502,
      errorCode: null,
      errorMessage: message,
    },
  };
}

export function cliShellMode(executable, plan) {
  const shell = /\.(cmd|bat)$/i.test(executable);
  if (shell && !plan.promptViaStdin) {
    throw new Error('grok-cli requires a native executable; .cmd/.bat shims cannot safely receive prompt arguments');
  }
  return shell;
}

export async function callCliProvider(cfg, { resolveExecutable = resolveCliExecutable, spawnProcess = spawn } = {}) {
  const timeoutMs = Number.isFinite(cfg.timeoutMs) ? cfg.timeoutMs : DEFAULT_CLI_TIMEOUT_MS;
  const home = String(cfg.cliHome || '').trim();
  if (home && !existsSync(home)) {
    return cliFailure(cfg, `cliHome does not exist: ${path.basename(home)}`);
  }

  let workDir = '';
  let lastMessageFile = '';
  if (cfg.providerType === 'codex-cli') {
    workDir = mkdtempSync(path.join(tmpdir(), 'cmo-cli-'));
    lastMessageFile = path.join(workDir, 'last-message.txt');
  }

  const prompt = flattenMessagesToPrompt(cfg.messages);

  let plan;
  try {
    plan = buildCliInvocation({ ...cfg, lastMessageFile, prompt });
  } catch (error) {
    if (workDir) rmSync(workDir, { recursive: true, force: true });
    return cliFailure(cfg, error.message);
  }

  const executable = resolveExecutable(plan.command);
  if (!executable) {
    if (workDir) rmSync(workDir, { recursive: true, force: true });
    return cliFailure(cfg, `${plan.command} CLI not found on PATH`);
  }

  let useShell;
  try {
    useShell = cliShellMode(executable, plan);
  } catch (error) {
    if (workDir) rmSync(workDir, { recursive: true, force: true });
    return cliFailure(cfg, error.message);
  }

  const result = await new Promise((resolve) => {
    const child = spawnProcess(executable, plan.args, {
      cwd: tmpdir(),
      env: { ...process.env, ...plan.envOverrides },
      shell: useShell,
      windowsHide: true,
    });

    let stdout = '';
    let stderr = '';
    let settled = false;

    const timer = setTimeout(() => {
      if (settled) return;
      settled = true;
      child.kill('SIGKILL');
      resolve({ timedOut: true, exitCode: null, stdout, stderr });
    }, timeoutMs);

    child.stdout.on('data', (chunk) => { stdout += chunk; });
    child.stderr.on('data', (chunk) => { stderr += chunk; });
    child.on('error', (error) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      resolve({ spawnError: error.message, exitCode: null, stdout, stderr });
    });
    child.on('close', (code) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      resolve({ exitCode: code, stdout, stderr });
    });

    child.stdin.on('error', () => {});
    if (plan.promptViaStdin) {
      child.stdin.end(prompt, 'utf8');
    } else {
      child.stdin.end();
    }
  });

  let text = String(result.stdout || '').trim();
  if (plan.readsLastMessageFile && lastMessageFile) {
    try {
      const fromFile = readFileSync(lastMessageFile, 'utf8').trim();
      if (fromFile) text = fromFile;
    } catch {
      // fall back to stdout
    }
  }
  if (workDir) rmSync(workDir, { recursive: true, force: true });

  if (result.timedOut) return cliFailure(cfg, `${plan.command} timed out after ${timeoutMs}ms`);
  if (result.spawnError) return cliFailure(cfg, `${plan.command} spawn failed: ${result.spawnError}`);
  if (result.exitCode !== 0) {
    const stderrTail = String(result.stderr || '').trim().split(/\r?\n/).slice(-3).join(' | ').slice(0, 400);
    return cliFailure(cfg, `${plan.command} exited ${result.exitCode}${stderrTail ? `: ${stderrTail}` : ''}`);
  }
  if (!text) return cliFailure(cfg, `${plan.command} produced no output`);

  return {
    status: 200,
    body: {
      ok: true,
      providerType: cfg.providerType,
      baseUrl: '',
      model: cfg.model,
      response: {
        model: cfg.model,
        choices: [{
          index: 0,
          message: { role: 'assistant', content: text },
          finish_reason: 'stop',
        }],
      },
    },
  };
}
