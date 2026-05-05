if not AshevilleOnStation() or not MiamiOnStation() then
	ChangeScore('playerside', -50, 'At least one subamrine is not within its launch zone.')
end

ScenEdit_SetSpecialAction({actionnameorid='Request Reconaissance Data', isactive=true})