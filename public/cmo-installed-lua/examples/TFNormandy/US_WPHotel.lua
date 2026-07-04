--WP Hotel
--Get unit that triggered event
local triggerUnit=ScenEdit_UnitX()

--Message to player
RadioMessageToPlayer('Eagle 6 this is ' .. triggerUnit.name .. ', on station at WP Hotel. Transferring nav data to the attack birds; You should have the co-ordinates on the tac-map within 2 minutes, out.')

ChangeScore('playerside',25,triggerUnit.name..' provided navigation data from WP Hotel.')

--Makes radar autodetectable
ScenEdit_SetUnit({guid='ca802a6d-ef31-4da2-a2c8-94af204e5693',autodetectable='Yes'})