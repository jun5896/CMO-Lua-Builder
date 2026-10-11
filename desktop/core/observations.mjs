function object(value, label) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${label} must be an object.`);
  return value;
}
function keys(value, allowed, label) {
  object(value, label);
  if (Object.keys(value).some((key) => !allowed.includes(key))) throw new Error(`${label} has unsupported fields. Full scenario or omniscient exports are not accepted for play advice.`);
}
function text(value, label, max = 2000) {
  if (typeof value !== 'string' || !value.trim() || value.length > max || value.includes('\0')) throw new Error(`${label} must be nonempty text, up to ${max} characters.`);
  return value.trim();
}

// This is a narrow import contract, not a filter capable of reconstructing fog
// of war from a full .scen export. The observer must supply side-visible facts.
export function validateObservation(value, session) {
  keys(value, ['schema', 'scenarioId', 'sideId', 'observedAt', 'ownUnits', 'contacts', 'missionNotes'], 'Observation');
  if (value.schema !== 'cmo-side-observation/v1') throw new Error('Expected cmo-side-observation/v1.');
  if (value.scenarioId !== session.scenarioId || value.sideId !== session.sideId) throw new Error('Observation scenario/side does not match this session.');
  if (!/^\d{4}-\d\d-\d\dT/.test(value.observedAt || '') || !Number.isFinite(Date.parse(value.observedAt))) throw new Error('observedAt must be an ISO timestamp.');
  for (const field of ['ownUnits', 'contacts', 'missionNotes']) {
    if (!Array.isArray(value[field]) || value[field].length > 500) throw new Error(`${field} must be an array with at most 500 entries.`);
  }
  const ownUnits = value.ownUnits.map((unit) => {
    keys(unit, ['id', 'name', 'status'], 'Own unit');
    return { id: text(unit.id, 'Unit id', 160), name: text(unit.name, 'Unit name', 160), status: text(unit.status, 'Unit status') };
  });
  const contacts = value.contacts.map((contact) => {
    keys(contact, ['id', 'label', 'lastKnown', 'confidence'], 'Contact');
    return { id: text(contact.id, 'Contact id', 160), label: text(contact.label, 'Contact label', 160), lastKnown: text(contact.lastKnown, 'Last-known observation'), confidence: text(contact.confidence, 'Confidence', 160) };
  });
  return {
    schema: value.schema, scenarioId: session.scenarioId, sideId: session.sideId,
    observedAt: value.observedAt, ownUnits, contacts,
    missionNotes: value.missionNotes.map((note) => text(note, 'Mission note')),
  };
}

export function exampleObservation(session) {
  return {
    schema: 'cmo-side-observation/v1', scenarioId: session.scenarioId, sideId: session.sideId,
    observedAt: new Date().toISOString(), ownUnits: [], contacts: [], missionNotes: [],
  };
}
