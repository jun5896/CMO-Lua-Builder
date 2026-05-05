ScenEdit_DeleteReferencePoint({side='Soviet Union',guid='e87720a8-c82c-4daf-a88b-8bfac34c63de'})

ScenEdit_AddUnit({
    side='Soviet Union',
    type='Facility', 
    dbid=2973, --Inf Sec (Naval Spetsnaz OMRP Squad [Generic Laser Designator])
    name='152nd PDSS Det F', 
    latitude='44.5983161529611', 
    longitude='-63.4441014311682',
})

local DTG = DTGSoviet()

ScenEdit_SpecialMessage(
    'Soviet Union',
    DTG..'<BR>INCOMING UHF TRANSMISSION:<BR><BR>"Fantom this is Prizrak, we are in position."'
)