local theShip = ScenEdit_UnitX()

TelexMessageToPlayer(
    "CSG77",
    'CENTCOM',
    'i',
    'US central command',
    'carrier strike group 77',
    'secret',
    '1. acknowledge reports that '..theShip.name..' has entered the Persian gulf <BR>2. centcom considers this a powerful demonstration of freedom of navigation through the straits of hormuz <BR>3. mission accomplished, bravo zulu',
    nil
)

ChangeScore('United States',5000,'Blockade broken.')

ScenEdit_EndScenario()