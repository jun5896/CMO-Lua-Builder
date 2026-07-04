local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.side == 'France' then
    local theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','ultra secreto','1. Acknowledge your report of detecting and engaging a submarine contrary to your written orders. <BR>2. You are relieved of command effective immediately. <BR>3. Return to Madrid at once for debriefing.')
    ScenEdit_SpecialMessage('playerside',theMessage)
    ChangeScore('Spain',-2000,'A French submarine was destroyed in direct contravention of orders.')
    ScenEdit_EndScenario()

else

    if theDestroyedUnit.type == 'Aircraft' then

        local fuelRemaining = theDestroyedUnit.fuel[2001].current
        local outOfFuel

        local function CivilianAircraftDestroyed()
            local civilianAircraftDestroyed = tonumber(ScenEdit_GetKeyValue('civilianAircraftDestroyed'))
            if civilianAircraftDestroyed == nil then civilianAircraftDestroyed = 0 end
            civilianAircraftDestroyed = civilianAircraftDestroyed + 1
            local theMessage
            if civilianAircraftDestroyed >= 2 then
                ChangeScore('Spain', -10000, 'After the shoot-down of two Civilian aircraft you were relieved of command.')
                ScenEdit_EndScenario()
                theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','ultra secreto','confirm civilian aircraft '..theDestroyedUnit.name..
                ' was destroyed. You are relieved of command effective immediately. <br>')
            else
                theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','ultra secreto','confirm civilian aircraft '..theDestroyedUnit.name..
                ' was destroyed partly due to negligence on your part. senior command is meeting to discuss your replacement as officer in charge. <BR><BR> take all measures to avoid further civilian casualties. <br>')
            end
            ScenEdit_SpecialMessage('playerside',theMessage)
            RegisterMessage(theMessage)
        end

        local function IncrementCivilianShootdownCounter()
            local civilianAircraftDestroyed = tonumber(ScenEdit_GetKeyValue('civilianAircraftDestroyed'))
            if civilianAircraftDestroyed == nil then civilianAircraftDestroyed = 0 end
            civilianAircraftDestroyed = tostring(civilianAircraftDestroyed + 1)
            ScenEdit_SetKeyValue('civilianAircraftDestroyed', civilianAircraftDestroyed)
            return tonumber(civilianAircraftDestroyed)
        end

        if fuelRemaining < 10 then outOfFuel = true end

        local debugMessage

        if outOfFuel then
            debugMessage = theDestroyedUnit.name..' (dbid='..theDestroyedUnit.dbid..') was destroyed, presumedly due to running out of fuel. No points deducted.'
        else
            debugMessage = theDestroyedUnit.name..' (dbid='..theDestroyedUnit.dbid..') was destroyed, presumedly due to hostile action. Points deducted.'
            ChangeScore('Spain', -2000, 'A civilian airliner was shot down.')
            CivilianAircraftDestroyed()
            IncrementCivilianShootdownCounter()
        end

        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside',debugMessage)
        end
    
    elseif theDestroyedUnit.type == 'Ship' then
        local function CivilianShipDestroyed()
            local civilianShipDestroyed = tonumber(ScenEdit_GetKeyValue('civilianShipDestroyed'))
            if civilianShipDestroyed == nil then civilianShipDestroyed = 0 end
            civilianShipDestroyed = civilianShipDestroyed + 1
            local theMessage
            if civilianShipDestroyed >= 2 then
                ChangeScore('Spain', -10000, 'After the sinking of two Civilian ships you were relieved of command.')
                ScenEdit_EndScenario()
                theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','ultra secreto','confirm civilian vessel '..theDestroyedUnit.name..
                ' was destroyed. You are relieved of command effective immediately. <br>')
            else
                theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','ultra secreto','confirm civilian vessel '..theDestroyedUnit.name..
                ' was destroyed partly due to negligence on your part. senior command is meeting to discuss your replacement as officer in charge. <BR><BR> take all measures to avoid further civilian casualties. <br>')
            end
            ScenEdit_SpecialMessage('playerside',theMessage)
            RegisterMessage(theMessage)
        end

        local function IncrementCivilianSinkingCounter()
            local civilianShipDestroyed = tonumber(ScenEdit_GetKeyValue('civilianShipDestroyed'))
            if civilianShipDestroyed == nil then civilianShipDestroyed = 0 end
            civilianShipDestroyed = tostring(civilianShipDestroyed + 1)
            ScenEdit_SetKeyValue('civilianShipDestroyed', civilianShipDestroyed)
            return tonumber(civilianShipDestroyed)
        end

        ChangeScore('Spain', -2000, 'A civilian ship was sunk.')
        CivilianShipDestroyed()
        IncrementCivilianSinkingCounter()   
    end
end