ChangeScore('Soviet Union',500,'B-402 reached the safe zone transiting to open ocean.')

local theMessage = Signal(
    'b-402',
    'north fleet hq severomorsk',
    'mission accomplished',
    'air',
    'congratulations on a successful mission.'
)

ScenEdit_SpecialMessage('Soviet Union',theMessage)

ScenEdit_EndScenario()