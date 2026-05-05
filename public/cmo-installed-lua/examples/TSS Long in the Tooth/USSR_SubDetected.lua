ScenEdit_SetEMCON('Side','United States','Sonar=Active')
ScenEdit_SetEvent('US_ActiveSonar',{isactive=false})
unit = ScenEdit_GetUnit({guid='08b01150-677c-498d-ad35-deeda64f71e2'})
if unit then
	ScenEdit_SetEMCON('Unit',unit.guid,'Sonar=Passive')
end