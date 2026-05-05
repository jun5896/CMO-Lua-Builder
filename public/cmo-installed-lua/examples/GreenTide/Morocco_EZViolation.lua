local theUnit = ScenEdit_UnitX()

if theUnit.type == 'Aircraft' or theUnit.type == 'Ship' then
    local positionDescription = ConvertDecimalPositionToDegrees(theUnit.latitude,theUnit.longitude)
    local unitDescription = theUnit.type
    if unitDescription == 'Ship' then unitDescription = 'Vessel' end
    unitDescription = string.lower(unitDescription)
    local theMessage = 'Unidentified '..unitDescription..' in position '..positionDescription..', you are violating Moroccan sovereign territory and your intentions are unclear. Leave the area immediately or we will be forced to defend ourselves.'

    theMessage = GenerateRadioMessageBody(theMessage,'Unknown')
    RadioMessage('VHF','121.50 MHz',theMessage,{latitude=theUnit.latitude,longitude=theUnit.longitude})

    ScenEdit_SetSidePosture ('Morocco', 'Spain', 'H')

    local offensiveMissions = {
        "Ground Strike",
        "Lanzarote Strike",
    }

    for k,v in ipairs (offensiveMissions) do
        ScenEdit_SetMission('Morocco',v,{isactive=true})
    end

    ScenEdit_SetEvent('Morocco_EZViolation',{isactive=false})
end