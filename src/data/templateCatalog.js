const commonDescription = {
  name: 'description',
  label: '설명',
  type: 'text',
  defaultValue: '',
  placeholder: 'CMO 이벤트 설명',
  hint: '비워두면 템플릿의 기본 설명을 사용합니다.',
};

export const EVENT_TEMPLATES = [
  {
    kind: 'iads_ambush',
    title: 'IADS Ambush',
    sourceFile: 'event_iads_ambush.tpl.lua',
    defaultName: 'IADS_Ambush_Check',
    summary: '지정한 SAM/레이더 유닛이 적 항공 접촉을 교전거리 안에서 포착하면 EMCON을 Passive에서 Active로 전환합니다.',
    notes: ['최신 템플릿은 VP_GetSide():contactsBy()를 먼저 쓰고, 실패하면 ScenEdit_GetContacts()로 되돌아갑니다.', '유닛은 GUID를 우선 조회하고, 실패하면 side+name으로 조회합니다.'],
    fields: [
      commonDescription,
      { name: 'side', label: '방어 측', type: 'text', defaultValue: 'RED', placeholder: 'RED' },
      { name: 'unit_id', label: 'SAM/레이더 GUID 또는 이름', type: 'text', defaultValue: '', placeholder: 'SA-21 Battery' },
      { name: 'target_type', label: '탐색 접촉 유형', type: 'select', defaultValue: 'Aircraft', options: ['Aircraft', 'Missile', 'Ship', 'Submarine', 'Facility'] },
      { name: 'engage_range', label: '교전거리 (nm)', type: 'number', defaultValue: 40 },
      { name: 'interval', label: '확인 주기 (초)', type: 'number', defaultValue: 5 },
    ],
  },
  {
    kind: 'contact_emcon',
    title: 'Contact EMCON',
    sourceFile: 'event_contact_emcon.tpl.lua',
    defaultName: 'Contact_EMCON_Update',
    summary: '특정 posture의 접촉이 감지되면 Side/Unit/Group EMCON 값을 바꿉니다.',
    notes: ['target_type이 있으면 contactsBy(target_type)를 우선 사용합니다.', 'emcon은 Lua table 그대로 입력합니다.'],
    fields: [
      commonDescription,
      { name: 'trigger', label: '트리거 옵션', type: 'lua', defaultValue: '{ name = "Contact EMCON Trigger", opts = { Interval = 15 } }', hint: 'event_contact_emcon.tpl.lua는 trigger.name과 trigger.opts를 사용합니다.' },
      { name: 'side', label: '접촉을 보유한 측', type: 'text', defaultValue: 'Blue' },
      { name: 'target_type', label: '접촉 유형', type: 'select', defaultValue: 'Aircraft', options: ['Aircraft', 'Missile', 'Ship', 'Submarine', 'Facility', ''] },
      { name: 'target_posture', label: '목표 posture', type: 'text', defaultValue: 'H', hint: 'H=Hostile. 비우면 posture와 무관하게 첫 접촉만으로 발동합니다.' },
      { name: 'emcon', label: 'EMCON 변경값', type: 'lua', defaultValue: '{ type = "Side", id = "Blue", value = "Radar=Active" }' },
      { name: 'message', label: '메시지 옵션', type: 'lua', defaultValue: '{ text = "Hostile contact detected. EMCON updated." }' },
    ],
  },
  {
    kind: 'cargo_drop',
    title: 'Cargo Drop',
    sourceFile: 'event_cargo_drop.tpl.lua',
    defaultName: 'Cargo_Drop_Zone',
    summary: '수송 유닛이 지정 Reference Point 영역에 들어오면 ScenEdit_UnloadCargo(unit.guid)를 호출합니다.',
    notes: ['최신 수정본은 ScenEdit_UnloadCargo({guid=...})가 아니라 unit.guid를 직접 전달합니다.'],
    fields: [
      commonDescription,
      { name: 'side', label: '수송 유닛 측', type: 'text', defaultValue: 'playerside' },
      { name: 'unit_id', label: '수송 유닛 GUID 또는 이름', type: 'text', defaultValue: '', placeholder: 'C-130 Cargo Flight' },
      { name: 'drop_zone', label: '강하 구역 RP 목록', type: 'lua', defaultValue: '{ "DZ-1", "DZ-2", "DZ-3", "DZ-4" }' },
    ],
  },
  {
    kind: 'victory_cond',
    title: 'Victory Condition',
    sourceFile: 'event_victory_cond.tpl.lua',
    defaultName: 'Victory_Check',
    summary: 'Lua 조건이 true가 되면 점수를 부여하고 선택적으로 시나리오를 종료합니다.',
    notes: ['check_logic은 함수 본문에 들어가므로 return true/false 형태로 작성합니다.'],
    fields: [
      commonDescription,
      { name: 'side', label: '점수 부여 측', type: 'text', defaultValue: 'playerside' },
      { name: 'points', label: '점수', type: 'number', defaultValue: 100 },
      { name: 'interval', label: '확인 주기 (초)', type: 'number', defaultValue: 15 },
      { name: 'check_logic', label: '승리 조건 Lua', type: 'lua', defaultValue: 'return (ScenEdit_GetScore("playerside") >= 1000)', rows: 4 },
      { name: 'message', label: '성공 메시지', type: 'text', defaultValue: 'Objective Achieved!' },
      { name: 'end_scenario', label: '조건 달성 시 시나리오 종료', type: 'checkbox', defaultValue: false },
    ],
  },
  {
    kind: 'teleport',
    title: 'Teleport / Relocate',
    sourceFile: 'event_teleport.tpl.lua',
    defaultName: 'Teleport_Units',
    summary: '대상 유닛들을 지정 위경도 박스 안의 임의 좌표로 이동시킵니다.',
    notes: ['target_guids는 Lua 배열로 입력합니다.', 'require_water/require_land 중 하나만 켜는 편이 안전합니다.'],
    fields: [
      commonDescription,
      { name: 'target_guids', label: '대상 GUID 목록', type: 'lua', defaultValue: '{ "unit-guid-1", "unit-guid-2" }' },
      { name: 'lat_min', label: '최소 위도', type: 'number', defaultValue: 37.0, mapImport: true },
      { name: 'lat_max', label: '최대 위도', type: 'number', defaultValue: 38.0, mapImport: true },
      { name: 'lon_min', label: '최소 경도', type: 'number', defaultValue: 125.0, mapImport: true },
      { name: 'lon_max', label: '최대 경도', type: 'number', defaultValue: 127.0, mapImport: true },
      { name: 'require_water', label: '수상 좌표만 허용', type: 'checkbox', defaultValue: false },
      { name: 'require_land', label: '육상 좌표만 허용', type: 'checkbox', defaultValue: false },
      { name: 'interval', label: '발동 주기 (초)', type: 'number', defaultValue: 60 },
    ],
  },
  {
    kind: 'csar',
    title: 'CSAR Auto-Spawner',
    sourceFile: 'event_csar.tpl.lua',
    defaultName: 'CSAR_Auto_Spawn',
    summary: '항공기 격추 시 생존 확률을 굴려 조종사/구명보트를 생성하고 구조 메시지를 보냅니다.',
    notes: ['격추 유닛이 Aircraft일 때만 작동합니다.', '템플릿 내부 DBID는 Stranded Person 2441, Life Raft 2553을 사용합니다.'],
    fields: [
      commonDescription,
      { name: 'target_side', label: '격추 감시 측', type: 'text', defaultValue: 'playerside' },
      { name: 'rescue_side', label: '구조 메시지 수신 측', type: 'text', defaultValue: 'playerside' },
    ],
  },
  {
    kind: 'logistics',
    title: 'Logistics Control',
    sourceFile: 'event_logistics.tpl.lua',
    defaultName: 'Logistics_Control',
    summary: '기지/항공모함 magazines를 비우거나 특정 weapon DBID를 보급합니다.',
    notes: ['base_id 또는 base_name 별칭을 지원합니다.', 'distribute 모드에서는 weapon_dbid와 quantity가 필요합니다.'],
    fields: [
      commonDescription,
      { name: 'side', label: '기지 측', type: 'text', defaultValue: 'playerside' },
      { name: 'base_id', label: '기지 GUID 또는 이름', type: 'text', defaultValue: '', placeholder: 'Blue Airbase' },
      { name: 'logistics_mode', label: '보급 모드', type: 'select', defaultValue: 'clear', options: ['clear', 'distribute'] },
      { name: 'weapon_dbid', label: 'Weapon DBID', type: 'number', defaultValue: 897, visibleWhen: (event) => event.logistics_mode === 'distribute', help: '현재 시나리오 DB의 Database Viewer에서 확인한 weapon DBID를 사용하세요.' },
      { name: 'quantity', label: '수량', type: 'number', defaultValue: 50, visibleWhen: (event) => event.logistics_mode === 'distribute' },
      { name: 'interval', label: '발동 주기 (초)', type: 'number', defaultValue: 3600 },
    ],
  },
  {
    kind: 'split_merge',
    title: 'Split / Merge Unit',
    sourceFile: 'event_split_merge.tpl.lua',
    defaultName: 'Split_Merge_Unit',
    summary: 'CMO v1265+ 공식 API ScenEdit_SplitUnit() / ScenEdit_MergeUnits()를 호출합니다.',
    notes: ['split은 지정 유닛을 mount/component 단위로 분리합니다.', 'merge는 현재 선택 유닛에 의존하는 API 특성이 있습니다.'],
    fields: [
      commonDescription,
      { name: 'side', label: '대상 측', type: 'text', defaultValue: 'RED' },
      { name: 'unit_id', label: '대상 GUID 또는 이름', type: 'text', defaultValue: '', placeholder: 'THAAD Battery' },
      { name: 'mode', label: '동작', type: 'select', defaultValue: 'split', options: ['split', 'merge'] },
      { name: 'interval', label: '발동 주기 (초)', type: 'number', defaultValue: 30 },
    ],
  },
  {
    kind: 'random_start_weather',
    title: 'Random Start Weather',
    sourceFile: 'event_random_start_weather.tpl.lua',
    defaultName: 'Random_Start_Weather',
    summary: '시나리오 시작 직후 1회만 날씨를 지정 범위 안에서 무작위 설정합니다.',
    notes: ['KeyValue guard로 중복 실행을 막습니다.', 'CMO API는 ScenEdit_SetWeather(temperature, rainfall, undercloud, seastate)를 사용합니다.'],
    fields: [
      commonDescription,
      { name: 'temp_min', label: '최소 기온', type: 'number', defaultValue: 15 },
      { name: 'temp_max', label: '최대 기온', type: 'number', defaultValue: 25 },
      { name: 'rain_min', label: '최소 강수', type: 'number', defaultValue: 0 },
      { name: 'rain_max', label: '최대 강수', type: 'number', defaultValue: 0 },
      { name: 'cloud_min', label: '최소 운량', type: 'number', defaultValue: 0.0 },
      { name: 'cloud_max', label: '최대 운량', type: 'number', defaultValue: 0.3 },
      { name: 'sea_min', label: '최소 해상상태', type: 'number', defaultValue: 0 },
      { name: 'sea_max', label: '최대 해상상태', type: 'number', defaultValue: 2 },
    ],
  },
  {
    kind: 'dynamic_weather',
    title: 'Dynamic Weather Drift',
    sourceFile: 'event_dynamic_weather.tpl.lua',
    defaultName: 'Dynamic_Weather_Drift',
    summary: '기준 날씨에서 정해진 변동폭 안으로 주기적으로 날씨를 흔듭니다.',
    notes: ['구름은 소수 난수로 처리하고, 강수/해상상태는 허용 범위로 clamp합니다.'],
    fields: [
      commonDescription,
      { name: 'base_temp', label: '기준 기온', type: 'number', defaultValue: 15 },
      { name: 'base_rain', label: '기준 강수', type: 'number', defaultValue: 0 },
      { name: 'base_cloud', label: '기준 운량', type: 'number', defaultValue: 0.1 },
      { name: 'base_sea', label: '기준 해상상태', type: 'number', defaultValue: 2 },
      { name: 'var_temp', label: '기온 변동폭', type: 'number', defaultValue: 2 },
      { name: 'var_rain', label: '강수 변동폭', type: 'number', defaultValue: 0 },
      { name: 'var_cloud', label: '운량 변동폭', type: 'number', defaultValue: 0.1 },
      { name: 'var_sea', label: '해상상태 변동폭', type: 'number', defaultValue: 1 },
      { name: 'interval', label: '발동 주기 (초)', type: 'number', defaultValue: 3600 },
    ],
  },
  {
    kind: 'ambient_traffic',
    title: 'Ambient Traffic',
    sourceFile: 'event_ambient_traffic.tpl.lua',
    defaultName: 'Ambient_Traffic_Spawn',
    summary: '지정 구역 안 수면 좌표에 민간 선박/항공 트래픽을 무작위 생성합니다.',
    notes: ['dbid_list는 Lua 배열로 입력합니다.', '현재 템플릿은 Civilian/Ship으로 생성하도록 구성되어 있습니다.'],
    fields: [
      commonDescription,
      { name: 'dbid_list', label: '생성 DBID 목록', type: 'lua', defaultValue: '{ 2024, 2696, 1475, 775, 2775, 1002 }' },
      { name: 'amount', label: '생성 수량', type: 'number', defaultValue: 5 },
      { name: 'lat_min', label: '최소 위도', type: 'number', defaultValue: 37.0, mapImport: true },
      { name: 'lat_max', label: '최대 위도', type: 'number', defaultValue: 38.0, mapImport: true },
      { name: 'lon_min', label: '최소 경도', type: 'number', defaultValue: 125.0, mapImport: true },
      { name: 'lon_max', label: '최대 경도', type: 'number', defaultValue: 127.0, mapImport: true },
      { name: 'interval', label: '발동 주기 (초)', type: 'number', defaultValue: 600 },
    ],
  },
  {
    kind: 'radio_message',
    title: 'Radio / Telex Message',
    sourceFile: 'event_radio_message.tpl.lua',
    defaultName: 'Radio_Message',
    summary: '일반 무전 또는 ACP126 스타일 전문 메시지를 플레이어 측에 출력합니다.',
    notes: ['telex 모드에서는 rec_station, snd_station, precedence, from, to, classification 필드를 함께 씁니다.'],
    fields: [
      commonDescription,
      { name: 'msg_type', label: '메시지 유형', type: 'select', defaultValue: 'radio', options: ['radio', 'telex'] },
      { name: 'side', label: '수신 측', type: 'text', defaultValue: 'playerside' },
      { name: 'body', label: '본문', type: 'textarea', defaultValue: 'INTELLIGENCE INDICATES RED IADS IS ACTIVE.', rows: 4 },
      { name: 'band', label: '무전 밴드', type: 'text', defaultValue: 'VHF', visibleWhen: (event) => event.msg_type !== 'telex' },
      { name: 'freq', label: '주파수', type: 'text', defaultValue: '121.5 MHz', visibleWhen: (event) => event.msg_type !== 'telex' },
      { name: 'rec_station', label: '수신국', type: 'text', defaultValue: 'ALL', visibleWhen: (event) => event.msg_type === 'telex' },
      { name: 'snd_station', label: '발신국', type: 'text', defaultValue: 'HQ', visibleWhen: (event) => event.msg_type === 'telex' },
      { name: 'precedence', label: '전문 우선순위', type: 'text', defaultValue: 'R', visibleWhen: (event) => event.msg_type === 'telex' },
      { name: 'from', label: 'From', type: 'text', defaultValue: 'COMMAND', visibleWhen: (event) => event.msg_type === 'telex' },
      { name: 'to', label: 'To', type: 'text', defaultValue: 'ALL STATIONS', visibleWhen: (event) => event.msg_type === 'telex' },
      { name: 'classification', label: '분류', type: 'text', defaultValue: 'UNCLASS', visibleWhen: (event) => event.msg_type === 'telex' },
      { name: 'interval', label: '발동 주기 (초)', type: 'number', defaultValue: 60 },
    ],
  },
  {
    kind: 'dbid_score',
    title: 'DBID Scoreboard',
    sourceFile: 'event_dbid_score.tpl.lua',
    defaultName: 'DBID_Scoreboard',
    summary: '격파된 유닛의 type + DBID 조합을 기준으로 점수를 부여합니다.',
    notes: ['최신 템플릿은 scores[u.dbid] 단독 조회가 아니라 scores[unit_type][dbid] 형태를 사용합니다.'],
    fields: [
      commonDescription,
      { name: 'target_side', label: '격파 대상 측', type: 'text', defaultValue: 'Any' },
      { name: 'side', label: '점수 부여 측', type: 'text', defaultValue: 'Blue' },
      { name: 'scores', label: '타입별 DBID 점수표', type: 'lua', defaultValue: '{ Facility = { [123] = 100 }, Aircraft = { [316] = 50 } }', rows: 4 },
    ],
  },
  {
    kind: 'scramble',
    title: 'Emergency Scramble',
    sourceFile: 'event_scramble.tpl.lua',
    defaultName: 'Emergency_Scramble',
    summary: '특정 트리거 발생 시 대기 유닛의 loadout을 교체하고 TimeToReady_Minutes를 즉시 준비 상태로 설정합니다.',
    notes: ['최신 템플릿은 unitName = u.guid와 TimeToReady_Minutes를 사용합니다.', 'units, trigger, message는 Lua table로 입력합니다.'],
    fields: [
      commonDescription,
      { name: 'trigger', label: '트리거', type: 'lua', defaultValue: '{ type = "RegularTime", name = "Scramble Trigger", opts = { interval = 10 } }', rows: 3 },
      { name: 'side', label: '유닛 측', type: 'text', defaultValue: 'Blue' },
      { name: 'units', label: '출격 유닛 GUID/이름 목록', type: 'lua', defaultValue: '{ "Viper 1", "Viper 2" }', help: '이미 배치된 유닛은 우클릭 > Scenario Editor > Copy unit ID to clipboard로 복사한 GUID를 우선 사용하세요.' },
      { name: 'loadout_dbid', label: 'Loadout ID', type: 'number', defaultValue: 33136, help: 'Database Viewer에서 해당 플랫폼의 loadout 항목으로 확인한 ID입니다. 플랫폼 DBID와 같은 DB 버전 기준이어야 합니다.' },
      { name: 'mission', label: '배정할 미션명', type: 'text', defaultValue: 'CAP Station' },
      { name: 'time_to_ready', label: '준비 시간 (분)', type: 'number', defaultValue: 0 },
      { name: 'message', label: '출격 메시지', type: 'lua', defaultValue: '{ side = "Blue", text = "QRA scramble launched." }' },
    ],
  },
];

export const TEMPLATE_BY_KIND = Object.fromEntries(EVENT_TEMPLATES.map((template) => [template.kind, template]));
export const TEMPLATE_BY_SOURCE = Object.fromEntries(EVENT_TEMPLATES.map((template) => [template.sourceFile, template]));

export function getTemplateDefinition(kind) {
  return TEMPLATE_BY_KIND[kind] || EVENT_TEMPLATES[0];
}

export function getTemplateForSource(fileName) {
  return TEMPLATE_BY_SOURCE[fileName];
}

export function createEventFromTemplate(kind = EVENT_TEMPLATES[0].kind, overrides = {}) {
  const definition = getTemplateDefinition(kind);
  const values = {};

  definition.fields.forEach((field) => {
    if (Object.hasOwn(field, 'defaultValue')) {
      values[field.name] = field.defaultValue;
    }
  });

  return {
    id: overrides.id ?? Date.now() + Math.random(),
    ...values,
    ...overrides,
    kind: definition.kind,
    name: overrides.name ?? definition.defaultName,
  };
}

const iadsAmbushTemplate = TEMPLATE_BY_KIND.iads_ambush;
if (iadsAmbushTemplate) {
  iadsAmbushTemplate.summary = '여러 SAM/레이더 유닛을 동시에 감시하고, Aircraft/Missile 등 여러 접촉 유형 중 하나라도 교전거리 안에 들어오면 각 유닛의 레이더 EMCON을 Active로 전환합니다.';
  iadsAmbushTemplate.notes = [
    'unit_ids와 target_types는 Lua 배열로 입력합니다. 예: { "SA-21 Battery", "EW Radar" }, { "Aircraft", "Missile" }',
    '기존 preset 호환을 위해 unit_id/unit_name/target_type 단수 입력도 계속 인식합니다.',
    'VP_GetSide():contactsBy(type)를 접촉 유형별로 먼저 조회하고, 실패하면 ScenEdit_GetContacts(side)로 되돌아갑니다.',
  ];
  iadsAmbushTemplate.fields = [
    {
      ...commonDescription,
      help: 'CMO 이벤트 창에서 보일 설명입니다. 비워두면 템플릿 기본 설명인 IADS Ambush Event를 사용합니다.',
    },
    {
      name: 'side',
      label: '방어 측',
      type: 'text',
      defaultValue: 'RED',
      placeholder: 'RED',
      hint: '이 측이 보유한 접촉 정보와 SAM/레이더 유닛을 기준으로 판단합니다.',
      help: 'CMO의 Side 이름입니다. 예를 들어 적 방공망이 RED 측이면 RED를 입력합니다.',
    },
    {
      name: 'unit_ids',
      label: 'SAM/레이더 GUID 또는 이름 목록',
      type: 'lua',
      defaultValue: '{ "SA-21 Battery", "Early Warning Radar" }',
      rows: 3,
      hint: '복수 입력 가능: { "SAM-1", "SAM-2", "Radar-1" }',
      help: '레이더를 켜고 끌 대상 유닛들입니다. GUID가 가장 정확하고, 이름을 쓸 경우 side 안에서 고유한 이름이어야 합니다.',
    },
    {
      name: 'target_types',
      label: '탐색 접촉유형 목록',
      type: 'lua',
      defaultValue: '{ "Aircraft", "Missile" }',
      rows: 2,
      hint: '복수 입력 가능: { "Aircraft", "Missile", "Ship" }',
      help: '이 목록 중 하나라도 감지되면 위협 접촉으로 봅니다. Aircraft는 항공기, Missile은 미사일, Ship은 함정, Submarine은 잠수함, Facility는 고정시설 접촉입니다.',
    },
    {
      name: 'engage_range',
      label: '교전거리 (nm)',
      type: 'number',
      defaultValue: 40,
      hint: '접촉이 이 거리 안으로 들어오면 레이더를 Active로 전환합니다.',
      help: '해리 nautical mile 단위입니다. 40이면 감시 대상 SAM/레이더로부터 40nm 안에 위협 접촉이 있을 때 반응합니다.',
    },
    {
      name: 'interval',
      label: '확인 주기 (초)',
      type: 'number',
      defaultValue: 5,
      hint: '너무 짧으면 반응은 빠르지만 이벤트 스크립트가 자주 실행됩니다.',
      help: 'CMO RegularTime trigger 주기입니다. 5초면 5초마다 접촉 거리와 EMCON 상태를 다시 확인합니다.',
    },
  ];
}

const WEATHER_HELP = {
  temperature:
    '섭씨 온도입니다. CMO SetWeather의 temperature 값으로 들어가며 음수도 사용할 수 있습니다. 예: -5는 영하 5도, 15는 온화한 날씨, 30은 더운 날씨입니다.',
  rainfall:
    '강수 강도입니다. CMO 템플릿 기준 허용 범위는 0-50입니다. 0은 비 없음, 5-10은 약한 비, 20-30은 강한 비, 50은 매우 강한 강수로 보면 됩니다.',
  undercloud:
    '구름/운량 값입니다. CMO SetWeather의 undercloud 값으로 0.0-1.0 범위를 씁니다. 0.0은 맑음, 0.3은 부분적으로 흐림, 0.7은 많이 흐림, 1.0은 전면 흐림에 가깝습니다.',
  seastate:
    '해상상태 값입니다. CMO 템플릿 기준 허용 범위는 0-9입니다. 0은 매우 잔잔함, 2는 약한 파고, 4는 보통 이상, 6은 매우 거친 바다, 9는 극심한 해상상태로 이해하면 됩니다.',
};

const randomStartWeatherTemplate = TEMPLATE_BY_KIND.random_start_weather;
if (randomStartWeatherTemplate) {
  randomStartWeatherTemplate.notes = [
    'CMO API는 ScenEdit_SetWeather(temperature, rainfall, undercloud, seastate)를 사용합니다.',
    '기온은 섭씨, 강수는 0-50, 운량은 0.0-1.0, 해상상태는 0-9 범위로 입력합니다.',
    '시작 직후 KeyValue guard로 한 번만 실행되며, min/max 사이에서 무작위 값을 뽑습니다.',
  ];
  randomStartWeatherTemplate.fields = [
    {
      ...commonDescription,
      help: 'CMO 이벤트 설명입니다. 비워두면 Random Starting Weather Setup 설명을 사용합니다.',
    },
    {
      name: 'temp_min',
      label: '최소 기온 (°C)',
      type: 'number',
      defaultValue: 15,
      hint: '무작위 시작 기온의 하한입니다.',
      help: WEATHER_HELP.temperature,
    },
    {
      name: 'temp_max',
      label: '최대 기온 (°C)',
      type: 'number',
      defaultValue: 25,
      hint: '무작위 시작 기온의 상한입니다.',
      help: `${WEATHER_HELP.temperature} 최소값보다 크거나 같게 두는 것이 안전합니다.`,
    },
    {
      name: 'rain_min',
      label: '최소 강수 (0-50)',
      type: 'number',
      defaultValue: 0,
      hint: '무작위 강수 강도의 하한입니다.',
      help: WEATHER_HELP.rainfall,
    },
    {
      name: 'rain_max',
      label: '최대 강수 (0-50)',
      type: 'number',
      defaultValue: 0,
      hint: '무작위 강수 강도의 상한입니다.',
      help: `${WEATHER_HELP.rainfall} 폭우를 원하지 않으면 10 이하로 두는 편이 무난합니다.`,
    },
    {
      name: 'cloud_min',
      label: '최소 운량 (0.0-1.0)',
      type: 'number',
      defaultValue: 0.0,
      step: 0.1,
      hint: '무작위 구름값의 하한입니다.',
      help: WEATHER_HELP.undercloud,
    },
    {
      name: 'cloud_max',
      label: '최대 운량 (0.0-1.0)',
      type: 'number',
      defaultValue: 0.3,
      step: 0.1,
      hint: '무작위 구름값의 상한입니다.',
      help: `${WEATHER_HELP.undercloud} 0.8 이상은 시야/센서 운용에 체감 영향을 줄 수 있습니다.`,
    },
    {
      name: 'sea_min',
      label: '최소 해상상태 (0-9)',
      type: 'number',
      defaultValue: 0,
      hint: '무작위 해상상태의 하한입니다.',
      help: WEATHER_HELP.seastate,
    },
    {
      name: 'sea_max',
      label: '최대 해상상태 (0-9)',
      type: 'number',
      defaultValue: 2,
      hint: '무작위 해상상태의 상한입니다.',
      help: `${WEATHER_HELP.seastate} 상륙/소형 선박 운용을 고려하면 너무 높은 값을 피하는 편이 좋습니다.`,
    },
  ];
}

const dynamicWeatherTemplate = TEMPLATE_BY_KIND.dynamic_weather;
if (dynamicWeatherTemplate) {
  dynamicWeatherTemplate.notes = [
    '기준값(base_*)에서 변동폭(var_*)만큼 매 주기 흔들고, 강수/운량/해상상태는 허용 범위로 clamp합니다.',
    '기온은 섭씨, 강수는 0-50, 운량은 0.0-1.0, 해상상태는 0-9 범위입니다.',
    '변동폭은 절대값이 아니라 ±범위입니다. 예: 기준 기온 15, 변동폭 2면 13-17도 사이로 움직입니다.',
  ];
  dynamicWeatherTemplate.fields = [
    {
      ...commonDescription,
      help: 'CMO 이벤트 설명입니다. 비워두면 Dynamic Weather Event 설명을 사용합니다.',
    },
    {
      name: 'base_temp',
      label: '기준 기온 (°C)',
      type: 'number',
      defaultValue: 15,
      hint: '동적 날씨가 출발하는 중심 기온입니다.',
      help: `${WEATHER_HELP.temperature} Dynamic Weather에서는 이 값을 중심으로 var_temp만큼 위아래로 움직입니다.`,
    },
    {
      name: 'base_rain',
      label: '기준 강수 (0-50)',
      type: 'number',
      defaultValue: 0,
      hint: '동적 날씨가 출발하는 중심 강수 강도입니다.',
      help: `${WEATHER_HELP.rainfall} Dynamic Weather에서는 이 값을 중심으로 var_rain만큼 변동합니다.`,
    },
    {
      name: 'base_cloud',
      label: '기준 운량 (0.0-1.0)',
      type: 'number',
      defaultValue: 0.1,
      step: 0.1,
      hint: '동적 날씨가 출발하는 중심 운량입니다.',
      help: `${WEATHER_HELP.undercloud} Dynamic Weather에서는 이 값을 중심으로 var_cloud만큼 변동합니다.`,
    },
    {
      name: 'base_sea',
      label: '기준 해상상태 (0-9)',
      type: 'number',
      defaultValue: 2,
      hint: '동적 날씨가 출발하는 중심 해상상태입니다.',
      help: `${WEATHER_HELP.seastate} Dynamic Weather에서는 이 값을 중심으로 var_sea만큼 변동합니다.`,
    },
    {
      name: 'var_temp',
      label: '기온 변동폭 (±°C)',
      type: 'number',
      defaultValue: 2,
      hint: '기준 기온에서 위아래로 흔들릴 최대 폭입니다.',
      help: '±섭씨 단위입니다. 기준 기온 15, 변동폭 2면 실행 때마다 13-17도 범위 안에서 새 기온을 만듭니다.',
    },
    {
      name: 'var_rain',
      label: '강수 변동폭 (±, 0-50)',
      type: 'number',
      defaultValue: 0,
      hint: '기준 강수에서 위아래로 흔들릴 최대 폭입니다.',
      help: '강수 강도 변동폭입니다. 기준 강수 10, 변동폭 5면 5-15 사이가 되며, 최종값은 0-50 범위로 제한됩니다.',
    },
    {
      name: 'var_cloud',
      label: '운량 변동폭 (±, 0.0-1.0)',
      type: 'number',
      defaultValue: 0.1,
      step: 0.1,
      hint: '기준 운량에서 위아래로 흔들릴 최대 폭입니다.',
      help: '운량 변동폭입니다. 기준 운량 0.4, 변동폭 0.1이면 0.3-0.5 사이가 되며, 최종값은 0.0-1.0 범위로 제한됩니다.',
    },
    {
      name: 'var_sea',
      label: '해상상태 변동폭 (±, 0-9)',
      type: 'number',
      defaultValue: 1,
      hint: '기준 해상상태에서 위아래로 흔들릴 최대 폭입니다.',
      help: '해상상태 변동폭입니다. 기준 2, 변동폭 1이면 1-3 사이가 되며, 최종값은 0-9 범위로 제한됩니다.',
    },
    {
      name: 'interval',
      label: '변경 주기 (초)',
      type: 'number',
      defaultValue: 3600,
      hint: '날씨를 다시 계산하는 간격입니다. 3600초는 1시간입니다.',
      help: 'CMO RegularTime trigger 주기입니다. 너무 짧으면 날씨가 자주 튀고, 너무 길면 변화가 둔하게 느껴집니다. 1800-3600초 정도가 자연스러운 편입니다.',
    },
  ];
}

function registerBuilderForm(template) {
  if (TEMPLATE_BY_KIND[template.kind]) {
    Object.assign(TEMPLATE_BY_KIND[template.kind], template);
    return TEMPLATE_BY_KIND[template.kind];
  }

  EVENT_TEMPLATES.push(template);
  TEMPLATE_BY_KIND[template.kind] = template;
  if (template.sourceFile) {
    TEMPLATE_BY_SOURCE[template.sourceFile] = template;
  }
  return template;
}

const sideField = {
  name: 'side',
  label: 'Side',
  type: 'text',
  defaultValue: 'Blue',
  help: 'CMO 시나리오의 진영 이름입니다. 예: Blue, Red, playerside',
};

const rpListHelp = 'Reference Point 이름 배열입니다. 예: { "RP-1", "RP-2", "RP-3", "RP-4" }';

registerBuilderForm({
  kind: 'reference_point_add',
  title: 'Reference Point',
  sourceFile: 'reference_point_add.tpl.lua',
  defaultName: 'RP-1',
  presetSection: 'reference_points',
  featureGroup: 'Reference Points / Zones',
  summary: '지도 좌표에 CMO Reference Point를 생성합니다.',
  notes: ['지도에서 좌표를 클릭한 뒤 위도/경도 필드의 지도값 버튼으로 입력할 수 있습니다.'],
  fields: [
    sideField,
    { name: 'lat', label: '위도', type: 'number', defaultValue: 37.5, mapImport: true, help: 'Reference Point의 latitude 값입니다.' },
    { name: 'lon', label: '경도', type: 'number', defaultValue: 126.5, mapImport: true, help: 'Reference Point의 longitude 값입니다.' },
    { name: 'highlighted', label: '강조 표시', type: 'checkbox', defaultValue: false },
    { name: 'locked', label: '잠금', type: 'checkbox', defaultValue: false },
  ],
});

registerBuilderForm({
  kind: 'zone_add',
  title: 'No-Nav / Exclusion Zone',
  sourceFile: 'zone_add.tpl.lua',
  defaultName: 'Restricted_Zone',
  presetSection: 'zones',
  featureGroup: 'Reference Points / Zones',
  summary: 'Reference Point 목록을 사용해 No-Nav 또는 Exclusion Zone을 생성합니다.',
  notes: ['구역을 만들려면 먼저 Reference Point들이 시나리오에 존재해야 합니다.'],
  fields: [
    sideField,
    { name: 'zone_kind', outputName: 'kind', label: 'Zone 종류', type: 'select', defaultValue: 'nonav', options: ['nonav', 'exclusion'] },
    { name: 'area', label: '구역 RP 목록', type: 'lua', defaultValue: '{ "RP-1", "RP-2", "RP-3", "RP-4" }', rows: 3, help: rpListHelp },
    { name: 'isactive', label: '활성화', type: 'checkbox', defaultValue: true },
  ],
});

registerBuilderForm({
  kind: 'unit_spawn',
  title: 'Spawn Unit',
  sourceFile: 'unit_spawn.tpl.lua',
  defaultName: 'New Unit',
  presetSection: 'units',
  featureGroup: 'Unit Spawn / Edit',
  summary: '지정 좌표에 DBID 기반 유닛을 생성합니다.',
  notes: ['DBID는 현재 시나리오가 쓰는 DB3K/CWDB 버전과 맞아야 합니다.', 'Aircraft, Ship, Facility, Submarine 같은 CMO unit type을 사용합니다.', 'DBID와 Loadout ID는 Game > Database Viewer 또는 Editor > Database 메뉴에서 확인합니다.'],
  fields: [
    sideField,
    { name: 'type', label: 'Unit type', type: 'select', defaultValue: 'Aircraft', options: ['Aircraft', 'Ship', 'Facility', 'Submarine', 'Satellite'] },
    { name: 'dbid', label: 'Platform DBID', type: 'number', defaultValue: 211, help: 'Database Viewer에서 현재 DB 버전 기준으로 확인한 생성 플랫폼 DBID입니다.' },
    { name: 'lat', label: '위도', type: 'number', defaultValue: 37.5, mapImport: true },
    { name: 'lon', label: '경도', type: 'number', defaultValue: 126.5, mapImport: true },
    { name: 'alt', label: '고도', type: 'number', defaultValue: 0 },
    { name: 'heading', label: '방위', type: 'number', defaultValue: 0 },
    { name: 'speed', label: '속도', type: 'number', defaultValue: 0 },
    { name: 'loadout', label: 'Loadout ID', type: 'number', defaultValue: '', help: '항공기 생성 시 사용할 loadout ID입니다. 플랫폼 DBID와 같은 DB 버전에서 확인해야 합니다.' },
  ],
});

registerBuilderForm({
  kind: 'unit_spawn_random',
  title: 'Random Spawn Unit',
  sourceFile: 'unit_spawn_random.tpl.lua',
  defaultName: 'Random Unit',
  presetSection: 'units',
  staticFields: { is_random: true },
  featureGroup: 'Geometry / Map',
  summary: '지정 bounding box 안에서 육상/해상 조건을 만족하는 좌표를 찾아 유닛을 생성합니다.',
  notes: ['지도 입력이 필요한 템플릿입니다.', 'terrain=sea면 해상 좌표를, terrain=land면 육상 좌표를 찾습니다.'],
  fields: [
    sideField,
    { name: 'type', label: 'Unit type', type: 'select', defaultValue: 'Ship', options: ['Aircraft', 'Ship', 'Facility', 'Submarine'] },
    { name: 'dbid', label: 'Platform DBID', type: 'number', defaultValue: 87, help: 'Database Viewer에서 현재 DB 버전 기준으로 확인한 플랫폼 DBID입니다.' },
    { name: 'terrain', label: '지형 조건', type: 'select', defaultValue: 'sea', options: ['sea', 'land'] },
    { name: 'lat_min', label: '최소 위도', type: 'number', defaultValue: 37.0, mapImport: true },
    { name: 'lat_max', label: '최대 위도', type: 'number', defaultValue: 38.0, mapImport: true },
    { name: 'lon_min', label: '최소 경도', type: 'number', defaultValue: 125.0, mapImport: true },
    { name: 'lon_max', label: '최대 경도', type: 'number', defaultValue: 127.0, mapImport: true },
    { name: 'max_attempts', label: '최대 시도 횟수', type: 'number', defaultValue: 500 },
  ],
});

registerBuilderForm({
  kind: 'loadout_set',
  title: 'Set Unit Loadout',
  sourceFile: 'loadout_set.tpl.lua',
  defaultName: 'Set_Loadout',
  presetSection: 'loadouts',
  includeName: false,
  featureGroup: 'Unit Spawn / Edit',
  summary: '기존 항공기/유닛의 loadout을 교체하고 준비 시간을 설정합니다.',
  notes: ['unit은 가능하면 CMO 우클릭 메뉴의 Copy unit ID to clipboard로 얻은 GUID를 사용하세요.', 'Loadout ID는 현재 시나리오 DB의 Database Viewer에서 확인한 값이어야 합니다.'],
  fields: [
    sideField,
    { name: 'unit', label: '유닛 GUID 또는 이름', type: 'text', defaultValue: 'Viper 1', help: '배치된 유닛은 이름보다 GUID가 안전합니다. CMO에서 우클릭 > Scenario Editor > Copy unit ID to clipboard를 사용하세요.' },
    { name: 'dbid', label: 'Loadout ID', type: 'number', defaultValue: 33136, help: 'Database Viewer에서 해당 플랫폼의 loadout 항목으로 확인한 ID입니다.' },
    { name: 'time_to_ready', label: '준비 시간 (분)', type: 'number', defaultValue: 0 },
  ],
});

[
  ['mission_patrol', 'Patrol Mission', 'mission_patrol.tpl.lua', 'patrol', [
    { name: 'patrol_type', label: 'Patrol type', type: 'select', defaultValue: 'AAW', options: ['AAW', 'ASW', 'ASuW', 'SEAD', 'Sea Control', 'Naval', 'Land'] },
    { name: 'patrol_zone_rps', label: 'Patrol zone RPs', type: 'lua', defaultValue: '{ "CAP-1", "CAP-2", "CAP-3", "CAP-4" }', rows: 3, help: rpListHelp },
    { name: 'oneThirdRule', label: '1/3 rule', type: 'checkbox', defaultValue: true },
    { name: 'checkOPA', label: 'OPA 확인', type: 'checkbox', defaultValue: true },
    { name: 'active_em', label: 'Active EM 허용', type: 'checkbox', defaultValue: false },
  ]],
  ['mission_support', 'Support Mission', 'mission_support.tpl.lua', 'support', [
    { name: 'support_type', label: 'Support type', type: 'text', defaultValue: 'air' },
    { name: 'support_area_rps', label: 'Support zone RPs', type: 'lua', defaultValue: '{ "SUP-1", "SUP-2", "SUP-3", "SUP-4" }', rows: 3, help: rpListHelp },
    { name: 'one_third_rule', label: '1/3 rule', type: 'checkbox', defaultValue: true },
    { name: 'station_altitude', label: 'Station altitude', type: 'number', defaultValue: '' },
  ]],
  ['mission_strike', 'Strike Mission', 'mission_strike.tpl.lua', 'strike', [
    { name: 'strike_type', label: 'Strike type', type: 'select', defaultValue: 'Land', options: ['Land', 'Naval', 'Sub', 'Air Intercept'] },
    { name: 'targets', label: 'Target names', type: 'lua', defaultValue: '{ "Target-1" }', rows: 2 },
    { name: 'target_side', label: 'Target side', type: 'text', defaultValue: 'Red' },
    { name: 'flight_size', label: 'Flight size', type: 'number', defaultValue: 2 },
  ]],
  ['mission_cargo', 'Cargo Mission', 'mission_cargo.tpl.lua', 'cargo', [
    { name: 'cargo_type', label: 'Cargo type', type: 'text', defaultValue: 'air' },
    { name: 'pickup_rp', label: 'Pickup RP', type: 'text', defaultValue: 'Pickup RP' },
    { name: 'dropoff_rp', label: 'Dropoff RP', type: 'text', defaultValue: 'Dropoff RP' },
    { name: 'minimum_number', label: 'Minimum units', type: 'number', defaultValue: 1 },
    { name: 'cargo_items', label: 'Cargo items', type: 'lua', defaultValue: '{}', rows: 2 },
  ]],
  ['mission_ferry', 'Ferry Mission', 'mission_ferry.tpl.lua', 'ferry', [
    { name: 'ferry_type', label: 'Ferry type', type: 'text', defaultValue: 'air' },
    { name: 'embarkation_rp', label: 'Embarkation RP', type: 'text', defaultValue: 'Start RP' },
    { name: 'destination_rp', label: 'Destination RP', type: 'text', defaultValue: 'Destination RP' },
    { name: 'one_way', label: 'One way', type: 'checkbox', defaultValue: false },
  ]],
  ['mission_mine', 'Mine Mission', 'mission_mine.tpl.lua', 'mine', [
    { name: 'mine_type', label: 'Mine type', type: 'text', defaultValue: 'naval' },
    { name: 'minefield_area_rps', label: 'Minefield RPs', type: 'lua', defaultValue: '{ "MINE-1", "MINE-2", "MINE-3", "MINE-4" }', rows: 3, help: rpListHelp },
    { name: 'density', label: 'Density', type: 'text', defaultValue: 'Medium' },
    { name: 'number_of_mines', label: 'Number of mines', type: 'number', defaultValue: 12 },
  ]],
].forEach(([kind, title, sourceFile, outputKind, fields]) => {
  registerBuilderForm({
    kind,
    title,
    sourceFile,
    defaultName: title.replace(/\s+/g, '_'),
    presetSection: 'missions',
    outputKind,
    featureGroup: 'Mission Control',
    summary: `${title}을 생성합니다.`,
    fields: [sideField, ...fields],
  });
});

registerBuilderForm({
  kind: 'doctrine_set',
  title: 'Doctrine Settings',
  sourceFile: 'doctrine_set.tpl.lua',
  defaultName: 'Set_Doctrine',
  presetSection: 'doctrines',
  includeName: false,
  featureGroup: 'Doctrine / EMCON',
  summary: 'Side 또는 특정 유닛의 doctrine 설정을 Lua table로 적용합니다.',
  fields: [
    sideField,
    { name: 'unit', label: '유닛 이름 (선택)', type: 'text', defaultValue: '' },
    { name: 'settings', label: 'Doctrine table', type: 'lua', defaultValue: '{ weapon_control_status_air = 0 }', rows: 3 },
  ],
});

registerBuilderForm({
  kind: 'doctrine_emcon',
  title: 'EMCON Settings',
  sourceFile: 'doctrine_emcon.tpl.lua',
  defaultName: 'Set_EMCON',
  presetSection: 'emcon',
  includeName: false,
  featureGroup: 'Doctrine / EMCON',
  summary: 'Side 또는 특정 유닛의 EMCON 값을 설정합니다.',
  fields: [
    sideField,
    { name: 'unit', label: '유닛 이름 (선택)', type: 'text', defaultValue: '' },
    { name: 'value', label: 'EMCON value', type: 'text', defaultValue: 'Radar=Active' },
  ],
});

registerBuilderForm({
  kind: 'side_posture',
  title: 'Side Posture',
  sourceFile: 'side_posture.tpl.lua',
  defaultName: 'Set_Posture',
  presetSection: 'sides',
  includeName: false,
  featureGroup: 'Doctrine / EMCON',
  summary: 'Side 간 posture를 Friendly/Neutral/Unfriendly/Hostile 등으로 설정합니다.',
  fields: [
    sideField,
    { name: 'postures', label: 'Posture table', type: 'lua', defaultValue: '{ { other_side = "Red", posture = "H" } }', rows: 3 },
  ],
});

registerBuilderForm({
  kind: 'kvstore_set',
  title: 'KeyValue State',
  sourceFile: 'kvstore_set.tpl.lua',
  defaultName: 'Set_KeyValue',
  presetSection: 'kvstore',
  includeName: false,
  featureGroup: 'KeyValue State',
  summary: 'Scenario KeyValue 저장소에 상태 플래그를 기록합니다.',
  fields: [
    { name: 'entries', label: 'KeyValue entries', type: 'lua', defaultValue: '{ { key = "mission_started", value = "1" } }', rows: 3 },
  ],
});

registerBuilderForm({
  kind: 'event_simple',
  title: 'Simple Lua Event',
  sourceFile: 'event_simple.tpl.lua',
  defaultName: 'Simple_Lua_Event',
  presetSection: 'events',
  outputKind: 'simple',
  featureGroup: 'Event Automation',
  summary: '트리거 하나와 LuaScript 액션 하나로 구성된 기본 이벤트입니다.',
  fields: [
    commonDescription,
    { name: 'trigger', label: 'Trigger table', type: 'lua', defaultValue: '{ type = "RegularTime", name = "Simple Trigger", opts = { Interval = 60 } }', rows: 3 },
    { name: 'lua_script', label: 'Lua script', type: 'lua', defaultValue: 'print("Simple event fired")', rows: 4 },
    { name: 'isrepeatable', label: '반복 가능', type: 'checkbox', defaultValue: false },
  ],
});

registerBuilderForm({
  kind: 'event_regular_time',
  title: 'Regular Time Event',
  sourceFile: 'event_regular_time.tpl.lua',
  defaultName: 'Hourly_Action',
  presetSection: 'events',
  outputKind: 'regular_time',
  featureGroup: 'Event Automation',
  summary: '정해진 초 간격마다 LuaScript를 실행합니다.',
  fields: [
    { name: 'interval', label: '실행 주기 (초)', type: 'number', defaultValue: 3600 },
    { name: 'lua_script', label: 'Lua script', type: 'lua', defaultValue: 'print("hourly action")', rows: 4 },
  ],
});

registerBuilderForm({
  kind: 'event_kv_flag',
  title: 'One-Shot KeyValue Event',
  sourceFile: 'event_kv_flag.tpl.lua',
  defaultName: 'OneShot_KeyValue_Event',
  presetSection: 'events',
  outputKind: 'kv_flag',
  featureGroup: 'KeyValue State',
  summary: 'KeyValue 플래그로 중복 실행을 막는 1회성 이벤트입니다.',
  fields: [
    commonDescription,
    { name: 'trigger', label: 'Trigger table', type: 'lua', defaultValue: '{ type = "RegularTime", name = "OneShot Trigger", opts = { Interval = 10 } }', rows: 3 },
    { name: 'kv_key', label: 'KeyValue key', type: 'text', defaultValue: 'oneshot_done' },
    { name: 'lua_script', label: 'Lua script', type: 'lua', defaultValue: 'print("one-shot action")', rows: 4 },
  ],
});

export const FEATURE_FORM_GROUPS = [
  {
    name: 'Mission Control',
    description: 'Patrol, support, strike, cargo, ferry, mine mission 생성 폼입니다.',
    forms: ['mission_patrol', 'mission_support', 'mission_strike', 'mission_cargo', 'mission_ferry', 'mission_mine'],
  },
  {
    name: 'Unit Spawn / Edit',
    description: '유닛 생성, 무작위 배치, loadout 교체, scramble 계열 폼입니다.',
    forms: ['unit_spawn', 'unit_spawn_random', 'loadout_set', 'scramble', 'split_merge'],
  },
  {
    name: 'Reference Points / Zones',
    description: '지도 좌표와 RP 배열을 사용하는 구역 구성 폼입니다.',
    forms: ['reference_point_add', 'zone_add', 'teleport', 'ambient_traffic'],
  },
  {
    name: 'Contacts / Detection',
    description: '접촉 탐지, IADS ambush, 탐지 기반 EMCON 전환 폼입니다.',
    forms: ['iads_ambush', 'contact_emcon'],
  },
  {
    name: 'Doctrine / EMCON',
    description: 'Doctrine, EMCON, side posture 설정 폼입니다.',
    forms: ['doctrine_set', 'doctrine_emcon', 'side_posture'],
  },
  {
    name: 'Weather',
    description: '시작 날씨 무작위화와 동적 날씨 변화 폼입니다.',
    forms: ['random_start_weather', 'dynamic_weather'],
  },
  {
    name: 'Scoring / Victory',
    description: '점수판, DBID 기반 점수, 승리 조건 폼입니다.',
    forms: ['victory_cond', 'dbid_score'],
  },
  {
    name: 'Event Automation',
    description: '주기 실행, 단순 Lua 이벤트, KeyValue 1회성 이벤트 폼입니다.',
    forms: ['event_simple', 'event_regular_time', 'event_kv_flag'],
  },
  {
    name: 'Cargo / Logistics',
    description: '화물 하역, 보급, cargo mission 계열 폼입니다.',
    forms: ['cargo_drop', 'logistics', 'mission_cargo'],
  },
  {
    name: 'Messaging / Briefing',
    description: '라디오/전문 메시지 출력 폼입니다.',
    forms: ['radio_message'],
  },
];
