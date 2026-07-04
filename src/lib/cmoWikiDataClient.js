import { EVENT_TEMPLATES } from '../data/templateCatalog';
import { buildCmoWikiEntries } from './cmoWikiEntries';

const TEMPLATE_ANNOTATIONS_URL = '/template-annotations.json';
const BUILDER_MANIFEST_URL = '/cmo-dev-work/manifest.json';
const INSTALLED_MANIFEST_URL = '/cmo-installed-lua/manifest.json';

let wikiEntriesPromise = null;

function loadJson(url) {
  return fetch(url).then((response) => {
    if (!response.ok) {
      throw new Error(`${url}: ${response.status}`);
    }
    return response.json();
  });
}

export function loadCmoWikiEntries() {
  if (!wikiEntriesPromise) {
    wikiEntriesPromise = Promise.all([
      loadJson(TEMPLATE_ANNOTATIONS_URL),
      loadJson(BUILDER_MANIFEST_URL),
      loadJson(INSTALLED_MANIFEST_URL).catch(() => ({})),
    ]).then(([annotationsPayload, builderManifest, installedManifest]) => buildCmoWikiEntries({
      annotationsPayload,
      templates: EVENT_TEMPLATES,
      builderManifest,
      installedManifest,
    }));
  }

  return wikiEntriesPromise;
}
