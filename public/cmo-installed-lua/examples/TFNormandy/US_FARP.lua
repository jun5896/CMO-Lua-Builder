RadioMessageToPlayer("Eagle 6 this is Green 1 Actual; X-ray is go, out.")
ChangeScore('playerside',25,'FARP X-ray was established.')

local FARP = ScenEdit_AddUnit({type = 'Facility', side = 'United States', dbid = '248', name = 'FARP X-ray', latitude='31.0078243299548', longitude='41.5106026485656'})
ScenEdit_FillMagsForLoadout ({guid=FARP.guid,loadoutid=1638,quantity=8})

ScenEdit_DeleteUnit({side='United States',type='Aircraft',name='Green 1'})
ScenEdit_DeleteUnit({side='United States',type='Aircraft',name='Green 2'})

for i = 1,4 do
    ScenEdit_DeleteReferencePoint({side='United States',name='FARP X-'..i})
end