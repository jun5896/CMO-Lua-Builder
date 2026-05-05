import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { Info, MapPin, Trash2 } from 'lucide-react';
import { EVENT_TEMPLATES, createEventFromTemplate, getTemplateDefinition } from '../data/templateCatalog';

function FormField({ field, event, onChange, activeCoordinate }) {
  if (field.visibleWhen && !field.visibleWhen(event)) {
    return null;
  }

  const value = event[field.name] ?? '';

  const importCoordinate = () => {
    if (!activeCoordinate) {
      window.alert('먼저 지도에서 좌표를 클릭해 주세요.');
      return;
    }

    if (field.name.startsWith('lat')) {
      onChange(field.name, Number(activeCoordinate.lat));
    } else if (field.name.startsWith('lon')) {
      onChange(field.name, Number(activeCoordinate.lon));
    }
  };

  const commonProps = {
    value,
    placeholder: field.placeholder || '',
    onChange: (eventTarget) => onChange(field.name, eventTarget.target.value),
  };

  let control;

  if (field.type === 'select') {
    control = (
      <select value={value} onChange={(eventTarget) => onChange(field.name, eventTarget.target.value)}>
        {(field.options || []).map((option) => (
          <option key={option} value={option}>{option === '' ? '(비움)' : option}</option>
        ))}
      </select>
    );
  } else if (field.type === 'checkbox') {
    control = (
      <label className="checkbox-line">
        <input
          type="checkbox"
          checked={Boolean(value)}
          onChange={(eventTarget) => onChange(field.name, eventTarget.target.checked)}
        />
        <span>{field.label}</span>
      </label>
    );
  } else if (field.type === 'textarea' || field.type === 'lua') {
    control = (
      <textarea
        {...commonProps}
        rows={field.rows || (field.type === 'lua' ? 3 : 2)}
        spellCheck={false}
        className={field.type === 'lua' ? 'mono-input' : undefined}
      />
    );
  } else {
    control = <input {...commonProps} type={field.type === 'number' ? 'number' : 'text'} step={field.step || 'any'} />;
  }

  if (field.type === 'checkbox') {
    return (
      <div className="form-field">
        <div className="checkbox-help-line">
          {control}
          <HelpHint text={field.help || field.hint} />
        </div>
        {field.hint && <p className="field-hint">{field.hint}</p>}
      </div>
    );
  }

  return (
    <div className="form-field">
      <div className="field-label-row">
        <label>
          <span>{field.label}</span>
          <HelpHint text={field.help || field.hint} />
        </label>
        {field.mapImport && activeCoordinate && (
          <button className="btn btn-ghost btn-mini" type="button" onClick={importCoordinate}>
            <MapPin size={13} />
            지도값
          </button>
        )}
      </div>
      {control}
      {field.hint && <p className="field-hint">{field.hint}</p>}
    </div>
  );
}

function HelpHint({ text }) {
  const anchorRef = useRef(null);
  const [tooltip, setTooltip] = useState(null);

  useEffect(() => {
    if (!tooltip) return undefined;

    const close = () => setTooltip(null);
    window.addEventListener('resize', close);
    window.addEventListener('scroll', close, true);
    return () => {
      window.removeEventListener('resize', close);
      window.removeEventListener('scroll', close, true);
    };
  }, [tooltip]);

  if (!text) return null;

  const showTooltip = () => {
    if (!anchorRef.current) return;

    const rect = anchorRef.current.getBoundingClientRect();
    const edge = 12;
    const width = Math.min(320, window.innerWidth - edge * 2);
    const half = width / 2;
    const unclampedLeft = rect.left + rect.width / 2;
    const left = Math.min(Math.max(unclampedLeft, edge + half), window.innerWidth - edge - half);
    const showBelow = rect.top < 132;
    const top = showBelow ? rect.bottom + 10 : rect.top - 10;

    setTooltip({
      left,
      top,
      width,
      placement: showBelow ? 'bottom' : 'top',
    });
  };

  const toggleTooltip = (event) => {
    event.preventDefault();
    event.stopPropagation();
    if (tooltip) {
      setTooltip(null);
    } else {
      showTooltip();
    }
  };

  return (
    <>
      <span
        ref={anchorRef}
        className="help-hint"
        tabIndex={0}
        role="button"
        aria-label={text}
        onClick={toggleTooltip}
        onMouseEnter={showTooltip}
        onMouseLeave={() => setTooltip(null)}
        onFocus={showTooltip}
        onBlur={() => setTooltip(null)}
        onKeyDown={(event) => {
          if (event.key === 'Enter' || event.key === ' ') {
            toggleTooltip(event);
          }
          if (event.key === 'Escape') {
            setTooltip(null);
          }
        }}
      >
        ?
      </span>
      {tooltip && createPortal(
        <span
          className={`help-popover placement-${tooltip.placement}`}
          role="tooltip"
          style={{
            left: `${tooltip.left}px`,
            top: `${tooltip.top}px`,
            width: `${tooltip.width}px`,
          }}
        >
          {text}
        </span>,
        document.body,
      )}
    </>
  );
}

function isKnownTemplateKind(kind) {
  return EVENT_TEMPLATES.some((template) => template.kind === kind);
}

function normalizeEventForEditor(event) {
  const source = event && typeof event === 'object' ? event : {};
  const fallbackKind = EVENT_TEMPLATES[0]?.kind || 'iads_ambush';
  const kind = isKnownTemplateKind(source.kind) ? source.kind : fallbackKind;
  const id = source.id ?? `recovered-${kind}`;
  const defaults = createEventFromTemplate(kind, { id });

  return {
    ...defaults,
    ...source,
    id,
    kind,
    name: source.name ?? defaults.name,
  };
}

function EventEditor({ event, updateEvent, replaceEvent, removeEvent, activeCoordinate }) {
  const safeEvent = normalizeEventForEditor(event);
  const definition = getTemplateDefinition(safeEvent.kind);
  const notes = Array.isArray(definition.notes) ? definition.notes : [];
  const fields = Array.isArray(definition.fields) ? definition.fields : [];

  const handleChange = (field, value) => {
    updateEvent(safeEvent.id, { [field]: value });
  };

  const handleKindChange = (kind) => {
    replaceEvent(safeEvent.id, createEventFromTemplate(kind, { id: safeEvent.id }));
  };

  return (
    <article className="event-card">
      <div className="event-card-header">
        <div className="form-field">
          <label>템플릿 유형</label>
          <select value={safeEvent.kind} onChange={(target) => handleKindChange(target.target.value)}>
            {EVENT_TEMPLATES.map((template) => (
              <option key={template.kind} value={template.kind}>{template.title}</option>
            ))}
          </select>
        </div>
        <button className="btn btn-icon danger" type="button" onClick={() => removeEvent(safeEvent.id)} aria-label="이벤트 삭제">
          <Trash2 size={18} />
        </button>
      </div>

      <div className="form-field">
        <label>제목</label>
        <input
          type="text"
          value={safeEvent.name}
          onChange={(target) => handleChange('name', target.target.value)}
          className="event-title-input"
          placeholder="이벤트 이름"
        />
      </div>

      <div className="template-summary">
        <div className="summary-title">
          <Info size={16} />
          <span>{definition.sourceFile}</span>
        </div>
        <p>{definition.summary}</p>
        {notes.map((note) => (
          <div className="note-pill" key={note}>{note}</div>
        ))}
      </div>

      <div className="field-grid">
        {fields.map((field) => (
          <FormField
            key={field.name}
            field={field}
            event={safeEvent}
            onChange={handleChange}
            activeCoordinate={activeCoordinate}
          />
        ))}
      </div>
    </article>
  );
}

export default EventEditor;
