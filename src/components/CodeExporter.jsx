import { useState } from 'react';
import { Check, Copy } from 'lucide-react';
import { generatePresetLua } from '../lib/presetLua';

function CodeExporter({ events, settings }) {
  const [copied, setCopied] = useState(false);
  const output = generatePresetLua(events, settings);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(output);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1800);
  };

  return (
    <section className="code-exporter">
      <div className="section-header compact">
        <div>
          <p className="eyebrow">Builder Preset</p>
          <h3>Lua preset output</h3>
        </div>
        <button className="btn btn-primary" type="button" onClick={handleCopy}>
          {copied ? <Check size={16} /> : <Copy size={16} />}
          {copied ? 'Copied' : 'Copy'}
        </button>
      </div>
      <pre className="code-block">{output}</pre>
    </section>
  );
}

export default CodeExporter;
