local TheDestroyedUnit = ScenEdit_UnitX()

if TheDestroyedUnit.dbid == 1325 then
	ChangeScore('USN', 10, 'Iranian Su-24MK Fencer D destroyed.')
	ScenEdit_SetEvent('US_SubWithdraws', {isactive=true})
else
	ChangeScore('USN', 5, TheDestroyedUnit.name .. ' destroyed.')
end