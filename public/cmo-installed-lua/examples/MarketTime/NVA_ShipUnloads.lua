local playerScore = ChangeScore('MACV',-50,'A North Vietnamese cargo ship was able to unload cargo at its destination.')

if playerScore <= -250 then
    ScenEdit_SpecialMessage('MACV',"You've allowed too many NVA ships to slip through and unload their cargo.<BR><BR> Mission failed!")
    ScenEdit_EndScenario()
end