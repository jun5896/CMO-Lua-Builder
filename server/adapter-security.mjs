import { randomBytes, timingSafeEqual } from 'node:crypto';

export class RequestError extends Error {
  constructor(message, status = 400) {
    super(message);
    this.status = status;
  }
}

export function requireObject(value, label = 'Body') {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new RequestError(`${label} must be a JSON object`);
  }
  return value;
}

// A local capability, rotated on every start. It is never persisted or logged.
export function createAdapterSecurity(allowedOrigins) {
  const token = randomBytes(32).toString('hex');
  return {
    checkRequest(req, res, port) {
      res.setHeader('Cache-Control', 'no-store');
      res.setHeader('X-Content-Type-Options', 'nosniff');
      const host = String(req.headers.host || '').toLowerCase();
      if (host !== `127.0.0.1:${port}` && host !== `localhost:${port}`) {
        throw new RequestError('Loopback Host required', 403);
      }
      const origin = req.headers.origin;
      if (origin !== undefined && !allowedOrigins.has(origin)) {
        throw new RequestError('Origin not allowed', 403);
      }
      if (['navigate', 'no-cors'].includes(req.headers['sec-fetch-mode'])) {
        throw new RequestError('Navigation and no-cors requests are not allowed', 403);
      }
      if (origin) {
        res.setHeader('Access-Control-Allow-Origin', origin);
        res.setHeader('Vary', 'Origin');
      }
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-CMO-Scenario-File-Name, X-CMO-Bootstrap, X-CMO-Session');
      res.setHeader('Access-Control-Expose-Headers', 'X-CMO-Auth-Required');
    },
    bootstrap(req) {
      // Non-simple header forces a browser preflight. Originless local clients
      // must explicitly opt in too; navigation and HTML forms cannot obtain it.
      if (req.headers['x-cmo-bootstrap'] !== '1') {
        throw new RequestError('X-CMO-Bootstrap: 1 required', 403);
      }
      return token;
    },
    authorize(req, res) {
      const supplied = Buffer.from(String(req.headers['x-cmo-session'] || ''));
      const expected = Buffer.from(token);
      if (supplied.length !== expected.length || !timingSafeEqual(supplied, expected)) {
        // Client retries ONLY this pre-dispatch failure, never upstream 401s.
        res.setHeader('X-CMO-Auth-Required', '1');
        throw new RequestError('Adapter session required', 401);
      }
    },
  };
}
