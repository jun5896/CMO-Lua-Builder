import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { getSidecarReadRoots, LEGACY_PUBLIC_SIDECAR_ROOT } from './tools/sidecar-paths.mjs';

const projectRoot = path.dirname(fileURLToPath(import.meta.url));
const publicRoot = path.join(projectRoot, 'public');
const sidecarUrlPrefixes = ['/scenario-scan-samples', '/scenario-sidecars'];
const excludedPublicDirs = new Set(['scenario-scan-samples']);

const contentTypes = new Map([
  ['.css', 'text/css; charset=utf-8'],
  ['.html', 'text/html; charset=utf-8'],
  ['.js', 'text/javascript; charset=utf-8'],
  ['.json', 'application/json; charset=utf-8'],
  ['.map', 'application/json; charset=utf-8'],
  ['.svg', 'image/svg+xml; charset=utf-8'],
  ['.txt', 'text/plain; charset=utf-8'],
  ['.xml', 'application/xml; charset=utf-8'],
]);

function decodeUrlPath(urlPath) {
  try {
    return decodeURIComponent(urlPath);
  } catch {
    return '';
  }
}

function safeJoin(root, requestPath) {
  const normalized = path.normalize(requestPath).replace(/^([/\\])+/, '');
  const target = path.resolve(root, normalized);
  const relative = path.relative(root, target);

  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    return null;
  }

  return target;
}

function sendStaticFile(filePath, response, method) {
  const type = contentTypes.get(path.extname(filePath).toLowerCase()) || 'application/octet-stream';
  response.setHeader('Content-Type', type);

  if (method === 'HEAD') {
    response.statusCode = 200;
    response.end();
    return;
  }

  fs.createReadStream(filePath)
    .on('error', () => {
      if (!response.headersSent) response.statusCode = 500;
      response.end();
    })
    .pipe(response);
}

async function tryServeFile(root, requestPath, request, response) {
  const filePath = safeJoin(root, requestPath);
  if (!filePath) return false;

  try {
    const stat = await fsp.stat(filePath);
    if (!stat.isFile()) return false;
    response.setHeader('Content-Length', stat.size);
    sendStaticFile(filePath, response, request.method);
    return true;
  } catch {
    return false;
  }
}

function createSidecarMiddleware() {
  const roots = getSidecarReadRoots();

  return (request, response, next) => {
    if (!['GET', 'HEAD'].includes(request.method || '')) {
      next();
      return;
    }

    void (async () => {
      const url = new URL(request.url || '/', 'http://127.0.0.1');
      const pathname = decodeUrlPath(url.pathname);
      const matchedPrefix = sidecarUrlPrefixes.find((prefix) => pathname.startsWith(`${prefix}/`));
      if (!matchedPrefix) {
        next();
        return;
      }

      const relativePath = pathname.slice(matchedPrefix.length + 1);
      for (const root of roots) {
        if (await tryServeFile(root, relativePath, request, response)) return;
      }

      next();
    })().catch(next);
  };
}

function createFilteredPublicMiddleware() {
  return (request, response, next) => {
    if (!['GET', 'HEAD'].includes(request.method || '')) {
      next();
      return;
    }

    void (async () => {
      const url = new URL(request.url || '/', 'http://127.0.0.1');
      const pathname = decodeUrlPath(url.pathname);
      const firstSegment = pathname.split('/').filter(Boolean)[0] || '';
      if (!firstSegment || excludedPublicDirs.has(firstSegment)) {
        next();
        return;
      }

      const relativePath = pathname.slice(1);
      if (await tryServeFile(publicRoot, relativePath, request, response)) return;

      next();
    })().catch(next);
  };
}

async function copyPublicExceptExcluded(sourceDir, targetDir) {
  let entries;
  try {
    entries = await fsp.readdir(sourceDir, { withFileTypes: true });
  } catch {
    return;
  }

  await fsp.mkdir(targetDir, { recursive: true });

  await Promise.all(entries.map(async (entry) => {
    if (excludedPublicDirs.has(entry.name)) return;

    const sourcePath = path.join(sourceDir, entry.name);
    const targetPath = path.join(targetDir, entry.name);

    if (entry.isDirectory()) {
      await fsp.cp(sourcePath, targetPath, { recursive: true });
      return;
    }

    if (entry.isFile()) {
      await fsp.copyFile(sourcePath, targetPath);
    }
  }));
}

function localSidecarPublicPlugin() {
  return {
    name: 'cmo-local-sidecar-public',
    configureServer(server) {
      server.middlewares.use(createSidecarMiddleware());
      server.middlewares.use(createFilteredPublicMiddleware());
    },
    configurePreviewServer(server) {
      server.middlewares.use(createSidecarMiddleware());
    },
    async closeBundle() {
      await copyPublicExceptExcluded(publicRoot, path.join(projectRoot, 'dist'));
      // Legacy public sidecars may exist on older workspaces; keep them out of dist.
      await fsp.rm(path.join(projectRoot, 'dist', path.relative(publicRoot, LEGACY_PUBLIC_SIDECAR_ROOT)), { recursive: true, force: true });
    },
  };
}

// Vite publicDir would copy the 10GB scenario sidecar cache into dist.
// Keep public assets available through middleware and copy only small assets.
export default defineConfig({
  publicDir: false,
  plugins: [react(), localSidecarPublicPlugin()],
});
