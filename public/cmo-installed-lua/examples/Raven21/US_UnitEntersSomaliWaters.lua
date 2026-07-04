local theUnit = ScenEdit_UnitX()

local positionDesc = ConvertDecimalPositionToDegrees(theUnit.latitude,theUnit.longitude)

if theUnit.type == 'Ship' then
    local theMessage = GenerateRadioMessageBody('Unidentified vessel at position '..positionDesc..'; you are violating sovereign Somalian waters.</p> <p>Turn back immediately or you will be fired upon.',
    'Unknown Station')

    RadioMessage("VHF", "121.5 MHz", theMessage, {latitude = theUnit.latitude, longitude = theUnit.longitude})

elseif theUnit.type == 'Aircraft' then

    local theMessage = GenerateRadioMessageBody('Unidentified aircraft at position '..positionDesc..'; you are violating sovereign Somalian airspace.</p> <p>Turn back immediately or you will be fired upon.',
    'Unknown Station')

    RadioMessage("VHF", "121.5 MHz", theMessage, {latitude = theUnit.latitude, longitude = theUnit.longitude})
end

ScenEdit_SetSidePosture('Somalia','United States','H')