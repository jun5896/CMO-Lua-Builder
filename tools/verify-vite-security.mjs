import assert from 'node:assert/strict';
import { mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { createServer } from 'vite';

// Synthetic files only: never use the checkout's .env or provider settings.
// This checks Vite's file boundary, not the application's custom middleware.
const root = await mkdtemp(path.join(tmpdir(), 'cmo-vite-security-'));
const marker = 'CMO_SYNTHETIC_PRIVATE_FILE_MARKER';
await writeFile(path.join(root, '.env'), `SYNTHETIC_VALUE=${marker}\n`);
await writeFile(path.join(root, 'tls.pem'), `${marker}\n`);
await writeFile(path.join(root, 'allowed.txt'), 'CMO public fixture\n');
const server = await createServer({
  configFile: false,
  root,
  logLevel: 'silent',
  server: { host: '127.0.0.1', port: 0, fs: { allow: [root] } },
});
const checks = [];
try {
  await server.listen();
  const origin = `http://127.0.0.1:${server.httpServer.address().port}`;
  const request = (url, options) => fetch(`${origin}${url}`, {
    ...options, signal: AbortSignal.timeout(10_000),
  });
  const publicFile = await request('/allowed.txt?raw');
  assert.equal(publicFile.status, 200);
  assert((await publicFile.text()).includes('CMO public fixture'));
  const head = await request('/allowed.txt', { method: 'HEAD' });
  assert.equal(head.status, 200);
  assert.equal(await head.text(), '');
  checks.push('normal public GET/HEAD');

  // GHSA-fx2h-pf6j-xcff: Windows resolves the default NTFS data stream to
  // the original file. The old dependency returned both synthetic secrets.
  for (const url of [
    '/.env?raw', '/tls.pem?raw',
    '/.env::$DATA?raw', '/tls.pem::$DATA?raw',
    '/.env%3A%3A$DATA?raw',
  ]) {
    const response = await request(url);
    assert([403, 404].includes(response.status), `${url}: expected denial, got ${response.status}`);
    assert(!(await response.text()).includes(marker), `${url}: private fixture leaked`);
    checks.push(url);
  }
} finally {
  await server.close();
}
console.log(JSON.stringify({ ok: true, platform: process.platform, checks }));
