// PowerShell recognizes typographic single quotes too. Preserve filenames by
// doubling each recognized quote character, rather than changing their value.
export function quotePowerShellArgument(value) {
  return `'${String(value).replace(/['\u2018\u2019\u201a\u201b]/g, (quote) => quote + quote)}'`;
}

export function buildScenarioCommands(scenarioPath, outputSlug) {
  const source = quotePowerShellArgument(scenarioPath);
  const prepare = `node tools/prepare-cmo-scenario-sidecar.mjs ${source}`;
  if (!outputSlug) return { prepare };
  const slug = quotePowerShellArgument(outputSlug);
  const scan = quotePowerShellArgument(`scenario-sidecars\\${outputSlug}.json`);
  const xml = quotePowerShellArgument(`scenario-sidecars\\${outputSlug}.scenario.xml`);
  const summary = quotePowerShellArgument(`scenario-sidecars\\${outputSlug}.summary.json`);
  return {
    prepare: `${prepare} --slug ${slug}`,
    scan: `node tools/scan-cmo-scenario-folder.mjs ${source} --out ${scan}`,
    extractXml: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/extract-cmo-scenario-xml.ps1 ${source} --OutXml ${xml}`,
    summarize: `node tools/summarize-cmo-scenario-xml.mjs ${xml} --out ${summary}`,
  };
}

// Cached/imported command text is data, never a source of executable commands.
export function buildScenarioDecoderCommand(fileName, context = {}, knownPaths = {}) {
  const slug = String(fileName || 'scenario').replace(/\.[^.]+$/, '').normalize('NFKD')
    .replace(/[^A-Za-z0-9_. -]+/g, '').trim().replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-').replace(/^-+|-+$/g, '').toLowerCase() || 'scenario';
  const source = context?.sourcePath || knownPaths[slug] || `C:\\path\\to\\${fileName || 'Scenario.scen'}`;
  return buildScenarioCommands(source).prepare;
}
