import { Plus, Sparkles } from 'lucide-react';
import { FEATURE_FORM_GROUPS, getTemplateDefinition } from '../data/templateCatalog';

function FeaturePalette({ onAddTemplate }) {
  return (
    <section className="feature-palette">
      <div className="mini-title">
        <Sparkles size={16} />
        폼 추가 / Builder Forms
      </div>
      <p className="palette-intro">
        그룹을 펼쳐 버튼을 누르면 프리셋 제작 폼에 바로 추가됩니다.
      </p>
      <div className="palette-groups">
        {FEATURE_FORM_GROUPS.map((group) => (
          <details key={group.name} className="palette-group">
            <summary>
              <span>{group.name}</span>
              <small>{group.forms.length}</small>
            </summary>
            <p>{group.description}</p>
            <div className="palette-buttons">
              {group.forms.map((kind) => {
                const template = getTemplateDefinition(kind);
                return (
                  <button key={kind} className="palette-button" type="button" onClick={() => onAddTemplate(kind)}>
                    <Plus size={13} />
                    {template.title}
                  </button>
                );
              })}
            </div>
          </details>
        ))}
      </div>
    </section>
  );
}

export default FeaturePalette;
