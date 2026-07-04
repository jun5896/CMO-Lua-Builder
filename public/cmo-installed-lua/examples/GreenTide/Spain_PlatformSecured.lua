local theUnit = ScenEdit_UnitX()

if theUnit.dbid == 3127 then

    local theRig = ReturnNearestOilRigToUnit(theUnit.guid)

    if not OilRigHasBeenSecured(theRig.guid) then
        ChangeScore('Spain',200,theRig.name..' secured by '..theUnit.name)
        local theMessage = 'This is '..theUnit.name..', we have secured '..theRig.name..'. Out.'
        theMessage = GenerateRadioMessageBody(theMessage,theUnit.name)
        RadioMessage('VHF','132.25 MHz',theMessage)
        OilRigHasBeenSecured(theRig.guid,true)
        ScenEdit_DeleteUnit({guid=theUnit.guid})
        ScenEdit_SetUnitSide({side='Civilian',name=theRig.guid,newside='Spain'})
    end
    
end