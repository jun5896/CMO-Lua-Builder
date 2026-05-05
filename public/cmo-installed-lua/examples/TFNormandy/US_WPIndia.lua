--WP India
--Get unit that triggered event
local triggerUnit=ScenEdit_UnitX()

--Message to player
RadioMessageToPlayer('Eagle 6 this is ' .. triggerUnit.name .. ', on station at WP India. Transferring nav data to the attack birds; You should have the co-ordinates on the tac-map within 2 minutes, out.')

ChangeScore('playerside',25,triggerUnit.name..' provided navigation data from WP India.')

--Makes radar autodetectable
ScenEdit_SetUnit({guid='ede4c4c5-3087-4f62-84e1-ad893f8f394c',autodetectable='Yes'})