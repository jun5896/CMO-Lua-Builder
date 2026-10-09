// Session capability stays in memory, separate from saved provider/UI profiles.
export function createAdapterTransport(baseUrl, fetchImpl = (...args) => fetch(...args)) {
  let token = '';
  let pendingSession;

  async function session() {
    if (token) return token;
    if (!pendingSession) {
      pendingSession = (async () => {
        const response = await fetchImpl(`${baseUrl}/api/session`, {
          headers: { 'X-CMO-Bootstrap': '1' },
          cache: 'no-store',
        });
        if (!response.ok) throw new Error(`Adapter session failed (HTTP ${response.status})`);
        const body = await response.json();
        if (!/^[a-f0-9]{64}$/.test(body?.token || '')) throw new Error('Invalid adapter session response');
        token = body.token;
        return token;
      })().finally(() => { pendingSession = undefined; });
    }
    return pendingSession;
  }

  return async function adapterFetch(url, options = {}) {
    if (!url.startsWith(`${baseUrl}/`)) throw new Error('Invalid adapter request URL');
    for (let attempt = 0; attempt < 2; attempt += 1) {
      const usedToken = await session();
      const response = await fetchImpl(url, {
        ...options,
        headers: { ...options.headers, 'X-CMO-Session': usedToken },
      });
      if (attempt === 0 && response.status === 401
          && response.headers?.get('X-CMO-Auth-Required') === '1') {
        if (token === usedToken) token = '';
        await response.arrayBuffer();
        continue;
      }
      return response;
    }
  };
}
