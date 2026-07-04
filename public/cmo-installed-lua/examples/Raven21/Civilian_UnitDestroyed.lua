ChangeScore('United States',-500,'A civilian vessel was sunk.')
local civScore = ChangeScore('Civilian',500,'A civilian vessel was sunk.')
if civScore >= 1000 then
    TelexMessageToPlayer(
        'ntbi',
        'COMIDEASTFOR',
        'z',
        'Commander Middle east force',
        'commanding officer cv 34 oriskany',
        'top secret',
        '1. your wanton disregard for rules of engagement and subsequent civilian casualties has compromised the mission.<BR> 2. you are relieved of command effective immediately. <br> 3. expect to face a court martial on your return to port.'
    )
    ChangeScore('United States',-500,'You were relieved of command.')
    ScenEdit_EndScenario()
else
    TelexMessageToPlayer(
        'ntbi',
        'COMIDEASTFOR',
        'z',
        'Commander Middle east force',
        'commanding officer cv 34 oriskany',
        'top secret',
        '1. immediately cease fire.<BR> 2. positively identify any further contacts before engaging.'
    )
end