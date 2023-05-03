-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local player, coords = nil, {}
Citizen.CreateThread(function()
    while true do
        player = PlayerPedId()
        coords = GetEntityCoords(player)
        Citizen.Wait(500)
    end
end)

local online_cops = 0
local curBank = 0
local doors = {}
local blips = {}
local powerBox_timer, powerBox_player = 0, false
local pacificSafe = {}
local interacting = false

Citizen.CreateThread(function()
    while true do 
        for i = 1, #Config.Banks do
            if #(coords - Config.Banks[i].blip.pos) < 100.0 then
                curBank = i
            end
        end
        Citizen.Wait(2000)
    end
end)

RegisterNetEvent('t1ger_bankrobbery:updateConfigCL')
AddEventHandler('t1ger_bankrobbery:updateConfigCL', function(id, data)
	Config.Banks[id] = data
end)

RegisterNetEvent('t1ger_bankrobbery:inUseCL')
AddEventHandler('t1ger_bankrobbery:inUseCL', function(id, state)
	Config.Banks[id].inUse = state
end)

RegisterNetEvent('t1ger_bankrobbery:keypadHackedCL')
AddEventHandler('t1ger_bankrobbery:keypadHackedCL', function(id, num, state)
	Config.Banks[id].keypads[num].hacked = state
end)

RegisterNetEvent('t1ger_bankrobbery:doorFreezeCL')
AddEventHandler('t1ger_bankrobbery:doorFreezeCL', function(id, num, state)
	Config.Banks[id].doors[num].freeze = state
end)

RegisterNetEvent('t1ger_bankrobbery:safeRobbedCL')
AddEventHandler('t1ger_bankrobbery:safeRobbedCL', function(id, num, state)
	Config.Banks[id].safes[num].robbed = state
end)

RegisterNetEvent('t1ger_bankrobbery:safeFailedCL')
AddEventHandler('t1ger_bankrobbery:safeFailedCL', function(id, num, state)
	Config.Banks[id].safes[num].failed = state
end)

RegisterNetEvent('t1ger_bankrobbery:powerBoxDisabledCL')
AddEventHandler('t1ger_bankrobbery:powerBoxDisabledCL', function(id, state)
	Config.Banks[id].powerBox.disabled = state
end)

RegisterNetEvent('t1ger_bankrobbery:pettyCashRobbedCL')
AddEventHandler('t1ger_bankrobbery:pettyCashRobbedCL', function(id, num, state)
    Config.Banks[id].pettyCash[num].robbed = state
end)

RegisterNetEvent('t1ger_bankrobbery:safeCrackedCL')
AddEventHandler('t1ger_bankrobbery:safeCrackedCL', function(id, state)
	Config.Banks[id].crackSafe.cracked = state
end)

RegisterNetEvent('t1ger_bankrobbery:updateOnlineCops')
AddEventHandler('t1ger_bankrobbery:updateOnlineCops', function(count)
	online_cops = count
    if Config.Debug == true then 
        online_cops = 5
    end
end)

-- Manage & Freeze Doors:
Citizen.CreateThread(function()
    while true do 
        if curBank ~= 0 then
            -- Closest Door:
            for k,v in pairs(Config.Banks[curBank].doors) do  
                if doors[k] ~= nil and DoesEntityExist(doors[k].entity) then
                    if v.freeze == true then
                        SetEntityHeading(doors[k].entity, v.setHeading)
                        FreezeEntityPosition(doors[k].entity, true)
                    else
                        if k == 'cell' or k == 'cell2' or 'terminal' then
                            FreezeEntityPosition(doors[k].entity, false)
                        end
                        if k == 'desk' then 
                            if (curBank ~= 1 and curBank ~= 2) then 
                                SetEntityHeading(doors[k].entity, v.setHeading - 100.0)
                            else
                                FreezeEntityPosition(doors[k].entity, false)
                            end
                        end
                    end
                else
                    local obj = GetClosestObjectOfType(v.pos.x, v.pos.y, v.pos.z, 2.0, v.model)
                    doors[k] = {entity = obj, pos = v.pos, type = k, heading = v.heading, setHeading = v.setHeading, freeze = v.freeze}
                end
            end
            -- Crack Safe Pacific:
            if curBank == 1 and Config.Banks[curBank].crackSafe ~= nil and #(coords - Config.Banks[curBank].crackSafe.pos) < 20.0 then 
                if pacificSafe ~= nil and pacificSafe.entity ~= nil and DoesEntityExist(pacificSafe.entity) then
                    pacificSafe.coords = GetEntityCoords(pacificSafe.entity)
                else
                    pacificSafe.entity = GetClosestObjectOfType(Config.Banks[curBank].crackSafe.pos.x, Config.Banks[curBank].crackSafe.pos.y, Config.Banks[curBank].crackSafe.pos.z, 2.0, Config.Banks[curBank].crackSafe.model)
                    if pacificSafe.entity == 0 then
                        TriggerEvent('t1ger_bankrobbery:createSafe')
                        Citizen.Wait(2000)
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

-- Bank Thread:
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1)
        local sleep = true
        if curBank ~= 0 then

            -- keypads:
            for k,v in pairs(Config.Banks[curBank].keypads) do
                local distance = #(coords - v.pos)
                if distance <= 1.5 and not interacting then
                    if k == 'start' then
                        if IsPlayerCop == false then 
                            if Config.Banks[curBank].keypads[k].hacked == false then
                                if (Config.Banks[curBank].inUse == false) or (Config.Banks[curBank].inUse == true and Config.Banks[curBank].powerBox.disabled == true) then  
                                    sleep = false
                                    local text = v.text
                                    if curBank == 1 and Config.Banks[curBank].crackSafe.cracked == true then
                                        text = v.text[1]..' | '..v.text[2]
                                    elseif curBank == 1 and Config.Banks[curBank].crackSafe.cracked == false then
                                        text = v.text[1]
                                    end
                                    T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, text)
                                    if IsControlJustPressed(0, Config.KeyControls['hack_terminal']) then
                                        if online_cops >= Config.Banks[curBank].police then
                                            if IsAnyBankBeingRobbed() == false or (IsAnyBankBeingRobbed() == true and Config.Banks[curBank].inUse == true) then 
                                                HackingKeypad(k,v)
                                            else
                                                TriggerEvent('t1ger_bankrobbery:notify', Lang['bank_rob_in_progress'])
                                            end
                                        else
                                            TriggerEvent('t1ger_bankrobbery:notify', Lang['not_enough_police'])
                                        end
                                    end
                                    if IsControlJustPressed(0, Config.KeyControls['use_accesscard']) and curBank == 1 and Config.Banks[curBank].crackSafe.cracked then
                                        UseAccesscard(k,v)
                                    end
                                end
                            end
                        elseif IsPlayerCop == true then
                            local text = Lang['draw_bank_secured']
                            if Config.Banks[curBank].inUse == true then 
                                text = Lang['draw_secure_bank']
                            end
                            sleep = false
                            T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, text)
                            if IsControlJustPressed(0, Config.KeyControls['reset_bank']) then
                                if Config.Banks[curBank].inUse == true then 
                                    local ped = IsAnyPedsInVaultArea(Config.Banks[curBank].doors['vault'].pos, Config.Banks[curBank].safes[3].pos)
                                    if ped == 0 then 
                                        ResetCurrentBank(k,v)
                                    else
                                        TriggerEvent('t1ger_bankrobbery:notify', Lang['reset_evacuate_players'])
                                    end
                                end
                            end
                        end
                    elseif k == 'vault' and Config.Banks[curBank].keypads[k].hacked == false then 
                        if Config.Banks[curBank].inUse == true and Config.Banks[curBank].keypads['start'].hacked == true then
                            sleep = false
                            local text = v.text
                            if curBank == 1 and Config.Banks[curBank].crackSafe.cracked == true then
                                text = v.text[1]..' | '..v.text[2]
                            elseif curBank == 1 and Config.Banks[curBank].crackSafe.cracked == false then
                                text = v.text[1]
                            end
                            T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, text)
                            if IsControlJustPressed(0, Config.KeyControls['hack_vault']) then
                                HackingKeypad(k,v)
                            end
                            if IsControlJustPressed(0, Config.KeyControls['use_accesscard']) and curBank == 1 and Config.Banks[curBank].crackSafe.cracked then
                                UseAccesscard(k,v)
                            end
                        end
                    end
                end
            end

            -- doors & petty cash:
            for k,v in pairs(Config.Banks[curBank].doors) do
                if Config.Banks[curBank].inUse == true and (k == 'desk' or k == 'cell' or k == 'cell2') then 
                    -- door actions:
                    if (v.freeze == true and Config.Banks[curBank].keypads['start'].hacked == true and Config.Banks[curBank].keypads['vault'].hacked == true) or (curBank == 1 and v.freeze == true and Config.Banks[curBank].inUse and Config.Banks[curBank].powerBox.disabled == true and k == 'desk') then
                        local distance = #(coords - v.pos)
                        local offset = GetOffsetFromEntityInWorldCoords(doors[k].entity, v.offset.x, v.offset.y, v.offset.z)
                        if distance <= 2.0 and not interacting then
                            sleep = false
                            local text = Lang['draw_place_thermite']
                            if v.action == 'lockpick' then
                                text = Lang['draw_lockpick_door']
                            end
                            T1GER_DrawTxt(offset.x, offset.y, offset.z, text)
                            if IsControlJustPressed(0, Config.KeyControls['door_action']) then
                                DoorAction(k,v,offset)
                            end
                        end
                    end
                    -- petty cash:
                    if v.freeze == false then
                        for i = 1, #Config.Banks[curBank].pettyCash do
                            local distance = #(coords - Config.Banks[curBank].pettyCash[i].pos)
                            if distance <= 2.0 and not interacting then
                                sleep = false
                                if distance <= 1.0 then 
                                    local text = Lang['draw_rob_petty_cash']
                                    if Config.Banks[curBank].pettyCash[i].robbed then
                                        text = Lang['draw_petty_cash_robbed']
                                    end
                                    T1GER_DrawTxt(Config.Banks[curBank].pettyCash[i].pos.x, Config.Banks[curBank].pettyCash[i].pos.y, Config.Banks[curBank].pettyCash[i].pos.z, text)
                                    if IsControlJustPressed(0, Config.KeyControls['petty_cash']) and not Config.Banks[curBank].pettyCash[i].robbed then
                                        GrabCash(i, Config.Banks[curBank].pettyCash[i].pos)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- safes:
            for k,v in pairs(Config.Banks[curBank].safes) do
                if Config.Banks[curBank].inUse == true then 
                    if (curBank ~= 1 and Config.Banks[curBank].keypads[v.requireHack].hacked == true) or (curBank == 1 and Config.Banks[curBank].doors[v.requireDoor].freeze == false) then
                        local distance = #(coords - v.pos)
                        if distance <= 2.0 then
                            sleep = false
                            if distance <= 1.0 and not interacting then
                                local text = Lang['draw_drill_safe']
                                if v.robbed then
                                    text = Lang['draw_safe_drilled']
                                elseif v.failed then
                                    text = Lang['draw_safe_destroyed']
                                end
                                T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, text)
                                if IsControlJustPressed(0, Config.KeyControls['drill_start']) and not v.robbed and not v.failed then
                                    DrillSafe(k,v)
                                end
                            end
                            if IsControlJustPressed(2, Config.KeyControls['drill_stop']) then
                                TriggerEvent('t1ger_bankrobbery:drilling:stop')
                            end
                        end
                    end
                end
            end

            -- power box:
            if Config.Banks[curBank].powerBox ~= nil and Config.Banks[curBank].inUse == false then
                local distance = #(coords - Config.Banks[curBank].powerBox.pos)
                if distance <= 2.0 and not interacting then
                    sleep = false
                    if distance <= 1.0 then
                        if Config.Banks[curBank].powerBox.disabled == false then 
                            T1GER_DrawTxt(Config.Banks[curBank].powerBox.pos.x, Config.Banks[curBank].powerBox.pos.y, Config.Banks[curBank].powerBox.pos.z, Lang['draw_disable_powerbox'])
                            if IsControlJustPressed(0, Config.KeyControls['powerbox']) then
                                if online_cops >= Config.Banks[curBank].police then
                                    DisablePowerBox()
                                else
                                    TriggerEvent('t1ger_bankrobbery:notify', Lang['not_enough_police'])
                                end
                            end
                        else
                            T1GER_DrawTxt(Config.Banks[curBank].powerBox.pos.x, Config.Banks[curBank].powerBox.pos.y, Config.Banks[curBank].powerBox.pos.z, Lang['draw_powerbox_disabled'])
                        end
                    end
                end
            end

            -- crack safe (only for pacific):
            if curBank == 1 and next(pacificSafe) and (pacificSafe.entity ~= nil and DoesEntityExist(pacificSafe.entity)) and pacificSafe.coords ~= nil then
                if Config.Banks[curBank].inUse and Config.Banks[curBank].powerBox.disabled == true and Config.Banks[curBank].doors['desk'].freeze == false then 
                    local distance = #(coords - pacificSafe.coords)
                    if distance <= 2.0 and not interacting then
                        local text = Lang['draw_crack_safe']
                        if Config.Banks[curBank].crackSafe.cracked == true then
                            text = Lang['draw_safe_cracked']
                        end
                        sleep = false
                        if distance <= 1.0 then
                            T1GER_DrawTxt(pacificSafe.coords.x, pacificSafe.coords.y, pacificSafe.coords.z, text)
                            if IsControlJustPressed(0, Config.KeyControls['crack_safe']) and Config.Banks[curBank].crackSafe.cracked == false then
                                CrackPacificSafe() 
                            end
                        end
                    end
                end
            end
            
        end

        if sleep then 
            Citizen.Wait(1000)
        end
    end
end)

-- Function to hack keypads:
function HackingKeypad(id,val)
    interacting = true
    local has_item = HasRequiredItems('hacking')
    if has_item then
        RemoveRequiredItems('hacking')
        SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
        Citizen.Wait(250)
        FreezeEntityPosition(player, true)
        TaskStartScenarioInPlace(player, 'WORLD_HUMAN_STAND_MOBILE', -1, true)
        if Config.ProgressBars then
            exports['progressBars']:startUI(3000, Lang['progBar_prep_hack'])
        end
        Citizen.Wait(3000)
        local busy, hacked = true, false
        if id == 'start' then 
            TriggerEvent('mhacking:show')
            TriggerEvent('mhacking:start', 4, 30, function(success)
                TriggerEvent('mhacking:hide')
                hacked = success
                busy = false
            end)
        elseif id == 'vault' then
            TriggerEvent("utk_fingerprint:Start", 3, 3, 2, function(success, reason)
                hacked = success
                busy = false
            end)
        end
        while busy do 
            Citizen.Wait(100)
        end
        ClearPedTasks(player)
        FreezeEntityPosition(player, false)
        Citizen.Wait(2000)
        if hacked then
            TriggerServerEvent('t1ger_bankrobbery:keypadHackedSV', curBank, id, true)
            local openVault = false
            if id == 'start' then 
                if Config.Banks[curBank].inUse == false then
                    TriggerServerEvent('t1ger_bankrobbery:inUseSV', curBank, true)
                end
                if curBank == 1 then
                    TriggerServerEvent('t1ger_bankrobbery:doorFreezeSV', curBank, 'terminal', false)
                else
                    openVault = true
                end
            elseif id == 'vault' then
                if curBank == 1 then 
                    openVault = true
                else
                    TriggerServerEvent('t1ger_bankrobbery:doorFreezeSV', curBank, 'terminal', false)
                end
            end
            if Config.Banks[curBank].powerBox.disabled and powerBox_timer ~= 0 then
                if Config.Banks[curBank].powerBox.hackAdd.enable then
                    local newTime = powerBox_timer + (Config.Banks[curBank].powerBox.hackAdd.time * 1000)
                    TriggerServerEvent('t1ger_bankrobbery:syncPowerBoxSV', newTime)
                    TriggerEvent('t1ger_bankrobbery_notify', Lang['extra_free_time_added']:format(tonumber(newTime/1000)))
                end
            else
                BankRobberyAlert(Config.Banks[curBank].name)
            end
            if openVault then
                TriggerServerEvent('t1ger_bankrobbery:openVaultSV', true, curBank) 
            end
        else
            TriggerEvent('t1ger_bankrobbery:notify', Lang['hacking_failed'])
            if Config.Banks[curBank].powerBox.disabled and powerBox_timer ~= 0 then
                TriggerServerEvent('t1ger_bankrobbery:syncPowerBoxSV', 2000)
            else
                BankRobberyAlert(Config.Banks[curBank].name)
            end
            Citizen.Wait(1000)
        end
    end
    interacting = false
end

-- Function to use access card:
function UseAccesscard(id,val)
    if curBank == 1 then 
        interacting = true
        local has_item = HasRequiredItems('accesscard')
        if has_item then
            RemoveRequiredItems('accesscard')
            local keypad = GetClosestObjectOfType(coords, 4.0, GetHashKey('hei_prop_hei_securitypanel'))
            T1GER_LoadModel('p_ld_id_card_01')
            local card = CreateObject(GetHashKey('p_ld_id_card_01'), coords, true, true, false)
            AttachEntityToEntity(card, player, GetPedBoneIndex(player, 28422), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
            TaskStartScenarioInPlace(player, 'PROP_HUMAN_ATM', 0, true)
            if Config.ProgressBars then 
                exports['progressBars']:startUI(2000, Lang['progBar_ins_accesscard'])
            end
            Citizen.Wait(1700)
            AttachEntityToEntity(card, keypad, GetPedBoneIndex(player, 28422), -0.09, -0.02, -0.08, 270.0, 0.0, 270.0, true, true, false, true, 1, true)
            FreezeEntityPosition(card)
            Citizen.Wait(300)
            TriggerServerEvent('t1ger_bankrobbery:keypadHackedSV', curBank, id, true)
            if id == 'start' then 
                if Config.Banks[curBank].inUse == false then 
                    TriggerServerEvent('t1ger_bankrobbery:inUseSV', curBank, true)
                end
                TriggerServerEvent('t1ger_bankrobbery:doorFreezeSV', curBank, 'terminal', false)
            end
            PlaySoundFrontend(-1, 'ATM_WINDOW', 'HUD_FRONTEND_DEFAULT_SOUNDSET')
            ClearPedTasksImmediately(player)
            if id == 'vault' then 
                Citizen.Wait(500)
                TriggerServerEvent('t1ger_bankrobbery:openVaultSV', true, curBank)
            end
            DeleteEntity(card)
        end
        interacting = false
    end
end

-- Function to interact with cell doors:
function DoorAction(id,val,offset)
    interacting = true
    local has_item = HasRequiredItems(val.action)
    if has_item then
        RemoveRequiredItems(val.action)
        local success = false
        if val.action == 'thermite' then
            local scene_pos, scene_rot = offset, vector3(0.0,0.0,val.heading)
            local anim = {dict = 'anim@heists@ornate_bank@thermal_charge', name = 'thermal_charge'}
            local objHash = GetHashKey('hei_prop_heist_thermite')
            -- Load Anim:
            T1GER_LoadAnim(anim.dict)
            -- Scene:
            local scene = NetworkCreateSynchronisedScene(scene_pos, scene_rot, 2, false, false, 1065353216, 0, 1.3)
            -- Add Ped to scene:
            NetworkAddPedToSynchronisedScene(player, scene, anim.dict, anim.name, 1.5, -4.0, 1, 16, 1148846080, 0)
            -- Start Scene:
            NetworkStartSynchronisedScene(scene)
            if Config.ProgressBars then 
                exports['progressBars']:startUI(4000, Lang['progBar_thermite'])
            end
            Citizen.Wait(1000)
            T1GER_LoadModel(objHash)
            local object = CreateObject(objHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
            SetEntityCollision(object, false, false)
            AttachEntityToEntity(object, player, GetPedBoneIndex(player, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
            Citizen.Wait(3500)
            DetachEntity(object, true, true)
            FreezeEntityPosition(object, true)
            -- Particle Effects:
            TriggerServerEvent('t1ger_bankrobbery:particleFxSV', GetEntityCoords(object), 'scr_ornate_heist', 'scr_heist_ornate_thermal_burn')
            -- Stop Scene:
            NetworkStopSynchronisedScene(scene)
            -- Play Anim:
            TaskPlayAnim(player, anim.dict, 'cover_eyes_loop', 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
            Citizen.Wait(3000)
            DeleteObject(object)
            -- Replace Model:
            TriggerServerEvent('t1ger_bankrobbery:modelSwapSV', val.pos, 5.0, val.model, GetHashKey('hei_v_ilev_bk_safegate_molten'))
            ClearPedTasks(player)
            success = true
        elseif val.action == 'lockpick' then
			local anim = {dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', name = 'machinic_loop_mechandplayer'}
			T1GER_LoadAnim(anim.dict)
            SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
            TaskTurnPedToFaceCoord(player, offset.x, offset.y, offset.z, -1)
            Citizen.Wait(1000)
            local offset = val.offset
            local anim_pos = GetOffsetFromEntityInWorldCoords(doors[id].entity, offset.x, offset.y-0.8, offset.z)
            if curBank == 1 and id == 'desk' then 
                anim_pos = GetOffsetFromEntityInWorldCoords(doors[id].entity, offset.x, offset.y+0.8, offset.z)
            end
            if curBank == 1 and id == 'desk' then
                TaskPlayAnimAdvanced(player, anim.dict, anim.name, anim_pos.x, anim_pos.y, anim_pos.z, 0.0, 0.0, 250.0, 3.0, 1.0, -1, 31, 0, 0, 0 ) 
            else
                TaskPlayAnimAdvanced(player, anim.dict, anim.name, anim_pos.x, anim_pos.y, anim_pos.z, 0.0, 0.0, val.heading, 3.0, 1.0, -1, 31, 0, 0, 0 )
            end
            if Config.ProgressBars then 
                exports['progressBars']:startUI(3000, Lang['progBar_lockpicking'])
            end
            Citizen.Wait(3000)
            ClearPedTasks(player)
            success = true
        end
        if success then
            TriggerServerEvent('t1ger_bankrobbery:doorFreezeSV', curBank, id, false)
            Citizen.Wait(1000)
            interacting = false
        end
    else
        interacting = false
    end
end

-- Function to drill closest safe:
function DrillSafe(id,val)
    local anim = {dict = 'anim@heists@fleeca_bank@drilling', lib = 'drill_straight_idle'}
    local closestPlayer, dist = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and dist <= 1.0 then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.lib, 3) then
            return TriggerEvent('t1ger_bankrobbery:notify', Lang['safe_drilled_by_ply'])
        end
    end
    interacting = true
    local has_item = HasRequiredItems('drilling')
    if has_item then
        RemoveRequiredItems('drilling')
        FreezeEntityPosition(player, true)
        SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
        Citizen.Wait(250)
        local objHash = GetHashKey('hei_prop_heist_drill')
        -- Load Anim:
        T1GER_LoadAnim(anim.dict)
        -- Load Model:
        T1GER_LoadModel(objHash)
        -- Set Pos & Heading:
        SetEntityCoords(player, val.anim.x, val.anim.y, val.anim.z-0.95)
        SetEntityHeading(player, val.anim.w)
        -- Anim:
        TaskPlayAnimAdvanced(player, anim.dict, anim.lib, val.anim.x, val.anim.y, val.anim.z, 0.0, 0.0, val.anim.w, 3.0, -4.0, -1, 2, 0, 0, 0 )
        -- Object:
        local object = CreateObject(objHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
        AttachEntityToEntity(object, player, GetPedBoneIndex(player, 28422), 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
        SetEntityAsMissionEntity(object, true, true)
        -- Sound:
        RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
        RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
        RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
        local soundID = GetSoundId()
        Citizen.Wait(100)
        PlaySoundFromEntity(soundID, "Drill", object, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
        Citizen.Wait(100)
        -- Particle FX:
        local ptfx = {dict = 'core', name = 'ent_anim_pneumatic_drill'}
        T1GER_LoadPtfxAsset(ptfx.dict)
        SetPtfxAssetNextCall(ptfx.dict)
        ptfx.effect = StartParticleFxLoopedOnEntity(ptfx.name, object, 0.0, -0.5, 0.0, 0.0, 0.0, 0.0, 0.9, 0, 0, 0)
        ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.0)
        Citizen.Wait(100)
        -- Drilling Minigame:
        TriggerEvent('t1ger_bankrobbery:drilling:start',function(status)
            if status == 1 then
                -- success
                TriggerServerEvent('t1ger_bankrobbery:safeRobbedSV', curBank, id, true)
                TriggerServerEvent('t1ger_bankrobbery:safeReward', curBank, id)
            elseif status == 2 then
                -- fail
                TriggerServerEvent('t1ger_bankrobbery:safeFailedSV', curBank, id, true)
                TriggerEvent('t1ger_bankrobbery:notify', Lang['you_destroyed_safe'])
            elseif status == 3 then
                -- pause
                TriggerEvent('t1ger_bankrobbery:notify', Lang['drilling_paused'])
            end
            ClearPedTasksImmediately(player)
            StopSound(soundID)
            ReleaseSoundId(soundID)
            DeleteObject(object)
            DeleteEntity(object)
            FreezeEntityPosition(player, false)
            StopParticleFxLooped(ptfx.effect, 0)
            StopGameplayCamShaking(true)
            Citizen.Wait(1000)
            interacting = false
        end)
    else
        interacting = false
    end
end

-- function to disable power box:
function DisablePowerBox()
    interacting = true
    if IsAnyBankBeingRobbed() == false then 
        local has_item = HasRequiredItems('powerbox')
        if has_item then
            RemoveRequiredItems('powerbox')
            local cfg = Config.Banks[curBank].powerBox
            SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
            Citizen.Wait(250)
            SetEntityCoords(player, cfg.anim.x, cfg.anim.y, cfg.anim.z-0.975, false, false, false, false)
            SetEntityHeading(player, cfg.anim.w)
            TaskStartScenarioInPlace(player, 'WORLD_HUMAN_HAMMERING', 0, true)
            if Config.ProgressBars then 
                exports['progressBars']:startUI(2000, Lang['progBar_open_powerbox'])
            end
            Citizen.Wait(2250)
            TaskStartScenarioInPlace(player, 'prop_human_parking_meter', 0, true)
            if Config.ProgressBars then 
                exports['progressBars']:startUI(2000, Lang['progBar_cut_wires'])
            end
            Citizen.Wait(2000)
            TriggerServerEvent('t1ger_bankrobbery:powerBoxDisabledSV', curBank, true)
            TriggerServerEvent('t1ger_bankrobbery:inUseSV', curBank, true)
            powerBox_player = true
            TriggerServerEvent('t1ger_bankrobbery:syncPowerBoxSV', (cfg.freeTime * 1000))
            TriggerEvent('t1ger_bankrobbery:notify', Lang['notify_free_time']:format(tonumber(cfg.freeTime)))
            ClearPedTasks(player)
        end
    else
        TriggerEvent('t1ger_bankrobbery:notify', Lang['bank_rob_in_progress'])
    end
    interacting = false
end

-- Thread to handle free robbing time:
Citizen.CreateThread(function()
	while true do
		if powerBox_timer ~= 0 and powerBox_player then
			sleep = false
			if Config.Banks[curBank].powerBox.disabled then
                powerBox_timer = (powerBox_timer - 1000)
                if Config.Debug then 
                    print("free rob time left: "..powerBox_timer)
                end
				if powerBox_timer <= 0 then
					BankRobberyAlert(Config.Banks[curBank].name)
					powerBox_timer = 0
					powerBox_player = false
                end
                TriggerServerEvent('t1ger_bankrobbery:syncPowerBoxSV', powerBox_timer)
			end
		end
		Citizen.Wait(1000)
	end
end)

-- Function to rob petty cash:
function GrabCash(id,pos)
    local anim = { dict = 'anim@scripted@heist@ig1_table_grab@cash@male@', name = 'grab' }
    local closestPlayer, dist = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and dist <= 1.0 then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.lib, 3) then
            return TriggerEvent('t1ger_bankrobbery:notify', 'Petty cash already being taken by someone else.')
        end
    end
    interacting = true 
    T1GER_LoadAnim(anim.dict)
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(250)
	T1GER_LoadModel('h4_prop_h4_cash_stack_02a')
    local cash_stack = CreateObject(GetHashKey('h4_prop_h4_cash_stack_02a'), pos.x, pos.y, pos.z, true, true, true)
    TaskTurnPedToFaceEntity(player, cash_stack, -1)
    Citizen.Wait(1000)
    if Config.ProgressBars then 
        exports['progressBars']:startUI(2000, Lang['progBar_petty_cash_grab'])
    end
    TaskPlayAnim(player, anim.dict, anim.name, 4.0, -1.0, -1, 2, 0, 0, 0, 0)
    Citizen.Wait(2000)
	ClearPedTasks(player)
    DeleteObject(cash_stack)
    TriggerServerEvent('t1ger_bankrobbery:pettyCashRobbedSV', curBank, id, true)
    TriggerServerEvent('t1ger_bankrobbery:pettyCashReward', curBank, id)
    Citizen.Wait(1000)
    interacting = false
end

-- function to crack pacific safe:
function CrackPacificSafe()
    interacting = true 
    local anim = {dict = 'mini@safe_cracking', name = 'dial_turn_anti_fast_3'}
    T1GER_LoadAnim(anim.dict)
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(250)
	SetEntityCoords(player, Config.Banks[curBank].crackSafe.anim.x, Config.Banks[curBank].crackSafe.anim.y, Config.Banks[curBank].crackSafe.anim.z - 0.95)
	Wait(100)
	FreezeEntityPosition(player, true)
	SetEntityHeading(player, GetEntityHeading(pacificSafe.entity))
	TaskPlayAnim(player, anim.dict, anim.name, 1.0, 1.0, -1, 2, 0, 0, 0)
    if Config.ProgressBars then
        exports['progressBars']:startUI(1000, Lang['progBar_cracking']) 
    end
    Citizen.Wait(1000)
    local combinations = {}
    for i = 1, #Config.Banks[curBank].crackSafe.combinations do
        math.randomseed(GetGameTimer()) 
        local pin_number = math.random(Config.Banks[curBank].crackSafe.combinations[i].min, Config.Banks[curBank].crackSafe.combinations[i].max)+1
        if Config.Debug then 
            print("pin: ", pin_number)
        end
        table.insert(combinations, pin_number)
    end
    SafeCracking.Start(function(result)
        if result then
            TriggerServerEvent('t1ger_bankrobbery:safeCrackedSV', curBank, true)
            TriggerServerEvent('t1ger_bankrobbery:crackSafeReward', curBank)
        else
            TriggerEvent('t1ger_bankrobbery:notify', Lang['safe_cracking_failed'])
        end
    end, combinations)
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
    Citizen.Wait(1000)
    interacting = false 
end

-- Alert Police Function:
function BankRobberyAlert(name)
    TriggerEvent('t1ger_bankrobbery:police_notify', name)
end

-- function to get peds in vault room
function IsAnyPedsInVaultArea(pos1, pos2)
    local ped = StartShapeTestCapsule(pos1, pos2, 3.0, 12, player, 7)
    local a, b, c, d, entityHit = GetShapeTestResult(ped)
    for i = 0, 3 do
        if GetPedType(entityHit) == i then 
            return entityHit
        end
    end
    return 0
end

function CreateBankBlips()
    Citizen.CreateThread(function()
        for i = 1, #Config.Banks do
            blips[i] = CreateBlip(Config.Banks[i].blip)
        end
    end)
end

-- Function to reset heist:
function ResetCurrentBank(id,val)
    interacting = true
	TriggerServerEvent('t1ger_bankrobbery:ResetCurrentBankSV', curBank)
    Citizen.Wait(1000)
    interacting = false 
end

-- Function to check if ply has required items:
function HasRequiredItems(action)
    local checked, has_item = false, false
    if Config.Banks[curBank].reqItems[action] ~= nil then
        for k,v in pairs(Config.Banks[curBank].reqItems[action]) do
            ESX.TriggerServerCallback('t1ger_bankrobbery:getInventoryItem', function(cb, item) 
                has_item = cb
                if not has_item then
                    TriggerEvent('t1ger_bankrobbery:notify', Lang['need_item_for_task']:format(item.label))
                    checked = true
                end
                if k == #Config.Banks[curBank].reqItems[action] then
                    checked = true
                end
            end, v.name, v.amount)
            if checked then
                break
            end
        end
    else
        checked = true
        has_item = true
    end
    while not checked do
        Citizen.Wait(100)
    end
    return has_item
end

-- Function to remove required items:
function RemoveRequiredItems(action)
    if Config.Banks[curBank].reqItems[action] ~= nil then
        for k,v in pairs(Config.Banks[curBank].reqItems[action]) do
            if v.remove == true then
                math.randomseed(GetGameTimer())
                if math.random(0,100) <= v.chance then
                    TriggerServerEvent('t1ger_bankrobbery:removeItem', v.name, v.amount)
                end
            end
        end
    end
end

-- Function to check if robbery in progress:
function IsAnyBankBeingRobbed()
    for i = 1, #Config.Banks do
        if Config.Banks[i].inUse == true then 
            return true
        end
    end
    return false
end

-- Blips:
function CreateBlip(data)
    local blip = nil
    if data.enable then 
        blip = AddBlipForCoord(data.pos.x, data.pos.y, data.pos.z)
		SetBlipSprite (blip, data.sprite)
		SetBlipDisplay(blip, data.display)
		SetBlipScale  (blip, data.scale)
		SetBlipColour (blip, data.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(data.name)
		EndTextCommandSetBlipName(blip)
    end
    return blip
end

-- Event to apply ptfx:
RegisterNetEvent('t1ger_bankrobbery:particleFxCL')
AddEventHandler('t1ger_bankrobbery:particleFxCL', function(pos, dict, name)
    T1GER_LoadPtfxAsset(dict)
    SetPtfxAssetNextCall(dict)
    local offset = vector3(pos.x, pos.y+1.0, pos.z-0.07)
    local ptfx = StartParticleFxLoopedAtCoord(name, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Citizen.Wait(3000)
    StopParticleFxLooped(ptfx, 0)
end)

-- Event to model swap:
RegisterNetEvent('t1ger_bankrobbery:modelSwapCL')
AddEventHandler('t1ger_bankrobbery:modelSwapCL', function(pos, radius, old_model, new_model)
    CreateModelSwap(pos, radius, old_model, new_model, 1)
end)

-- Event to open vault:
RegisterNetEvent('t1ger_bankrobbery:openVaultCL')
AddEventHandler('t1ger_bankrobbery:openVaultCL', function(open, id)
    local setHeading = 0
    TriggerEvent('t1ger_bankrobbery:vaultSound', Config.Banks[id].doors['vault'].pos, Config.Banks[id].doors['vault'].count)
    if DoesEntityExist(doors['vault'].entity) then 
        for i = 1, Config.Banks[id].doors['vault'].count do
            Citizen.Wait(10)
            local heading = GetEntityHeading(doors['vault'].entity)
            if open then
                if id == 2 then 
                    setHeading = (round(heading, 1) + 0.4)
                else
                    setHeading = (round(heading, 1) - 0.4)
                end
            else
                if id == 2 then 
                    setHeading = (round(heading, 1) - 0.4)
                else
                    setHeading = (round(heading, 1) + 0.4)
                end
            end
            SetEntityHeading(doors['vault'].entity, setHeading)
            -- Sync:
            Config.Banks[id].doors['vault'].setHeading = setHeading
        end
        TriggerServerEvent('t1ger_bankrobbery:setHeadingSV', id, 'vault', setHeading)
    end
end)

RegisterNetEvent('t1ger_bankrobbery:vaultSound')
AddEventHandler('t1ger_bankrobbery:vaultSound', function(pos, count)
    if #(coords - pos) <= 10.0 then
        local newCount = count*0.015
        for i = 1, newCount, 1 do 
            PlaySoundFrontend(-1, "OPENING", "MP_PROPERTIES_ELEVATOR_DOORS" , 1)
            Citizen.Wait(800)
        end
    end
end)

-- Event to sync vault heading:
RegisterNetEvent('t1ger_bankrobbery:setHeadingCL')
AddEventHandler('t1ger_bankrobbery:setHeadingCL', function(id, type, heading)
	Config.Banks[id].doors[type].setHeading = heading
end)

-- Event to update powerbox timer:
RegisterNetEvent('t1ger_bankrobbery:syncPowerBoxCL')
AddEventHandler('t1ger_bankrobbery:syncPowerBoxCL', function(timer)
	powerBox_timer = timer
end)

-- Create Pacific Crack Safe:
RegisterNetEvent('t1ger_bankrobbery:createSafe')
AddEventHandler('t1ger_bankrobbery:createSafe', function()
    local cfg = Config.Banks[curBank].crackSafe
    local hashkey = GetHashKey(cfg.model) % 0x100000000
    T1GER_LoadModel(hashkey)
	pacificSafe.entity = CreateObject(hashkey, cfg.pos.x, cfg.pos.y, cfg.pos.z, true, true, true)
	SetEntityAsMissionEntity(pacificSafe.entity, true)
	FreezeEntityPosition(pacificSafe.entity, true)
	SetEntityHeading(pacificSafe.entity, cfg.heading)
	if HasModelLoaded(hashkey) then
		SetModelAsNoLongerNeeded(hashkey)
	end
end)

-- ## CAMERA SECTION ## --
local usingCamera = false
local cameraID = 0
local tablet = nil

RegisterCommand('camera', function(source, args, rawCommand)
	local cameraNum = tonumber(args[1])
    if cameraNum then 
        if IsPlayerCop then
            TriggerEvent('t1ger_bankrobbery:camera', cameraNum)
        else
            TriggerEvent('t1ger_bankrobbery:notify', Lang['no_access_to_cam'])
        end
    else
        return TriggerEvent('t1ger_bankrobbery:notify', 'Camera ID must be a number')
    end
end, false)

RegisterNetEvent('t1ger_bankrobbery:camera')
AddEventHandler('t1ger_bankrobbery:camera', function(cameraNum)
	local player = GetPlayerPed(-1)
	if usingCamera then
		usingCamera = false
		ClearPedTasks(player)
        DeleteObject(tablet)
        SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'), true)
	else
		if cameraNum > 0 and cameraNum <= #Config.Camera then
			-- tablet emote:
			if not IsEntityPlayingAnim(player, 'amb@world_human_seat_wall_tablet@female@base', 'base', 3) then
				RequestAnimDict('amb@world_human_seat_wall_tablet@female@base')
				while not HasAnimDictLoaded('amb@world_human_seat_wall_tablet@female@base') do
					Citizen.Wait(10)
				end
				TaskPlayAnim(player, 'amb@world_human_seat_wall_tablet@female@base', 'base', 2.0, -2, -1, 49, 0, 0, 0, 0) 
				object = CreateObject(GetHashKey('prop_cs_tablet'), 0, 0, 0, true, true, true)
				AttachEntityToEntity(object, player, GetPedBoneIndex(player, 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
				tablet = object
				Wait(500)
			end
			Wait(500)
			TriggerEvent('t1ger_bankrobbery:openCameraView', cameraNum)
		else
            TriggerEvent('t1ger_bankrobbery:notify', Lang['camera_not_exist'])
		end
	end
end)

-- Camera VIew:
RegisterNetEvent('t1ger_bankrobbery:openCameraView')
AddEventHandler('t1ger_bankrobbery:openCameraView', function(cameraNum)
	local player = GetPlayerPed(-1)
	local curCam = Config.Camera[cameraNum]
	local x,y,z,heading = curCam.pos[1],curCam.pos[2],curCam.pos[3],curCam.heading
	usingCamera = true
	SetTimecycleModifier('heliGunCam')
	SetTimecycleModifierStrength(1.0)
	local scaleForm = RequestScaleformMovie('TRAFFIC_CAM')
	while not HasScaleformMovieLoaded(scaleForm) do
		Citizen.Wait(0)
	end
	cameraID = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
	SetCamCoord(cameraID, x, y, (z+1.25))						
	SetCamRot(cameraID, -13.0, 0.0, heading)
	SetCamFov(cameraID, 105.0)
	RenderScriptCams(true, false, 0, 1, 0)
	PushScaleformMovieFunction(scaleForm, 'PLAY_CAM_MOVIE')
	SetFocusArea(x, y, z, 0.0, 0.0, 0.0)
	PopScaleformMovieFunctionVoid()
	while usingCamera do
		SetCamCoord(cameraID, x, y, (z+1.25))
		PushScaleformMovieFunction(scaleForm, 'SET_ALT_FOV_HEADING')
		PushScaleformMovieFunctionParameterFloat(GetEntityCoords(heading).z)
		PushScaleformMovieFunctionParameterFloat(1.0)
		PushScaleformMovieFunctionParameterFloat(GetCamRot(cameraID, 2).z)
		PopScaleformMovieFunctionVoid()
		DrawScaleformMovieFullscreen(scaleForm, 255, 255, 255, 255)
		Citizen.Wait(1)
	end
	ClearFocus()
	ClearTimecycleModifier()
	RenderScriptCams(false, false, 0, 1, 0) -- Return to gameplay camera
	SetScaleformMovieAsNoLongerNeeded(scaleForm) -- Cleanly release the scaleform
	DestroyCam(cameraID, false)
	SetNightvision(false)
	SetSeethrough(false)
end)


-- Camera Buttons:
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(1)
		local sleep = true
		if usingCamera then
			sleep = false
			local camForm = InstructionalButtonsCamera("instructional_buttons")
			local camRotation = GetCamRot(cameraID, 2)
			DrawScaleformMovieFullscreen(camForm, 255, 255, 255, 255, 0)
			if IsControlPressed(0, Config.CamLeft) then -- arrow left
				SetCamRot(cameraID, camRotation.x, 0.0, (camRotation.z+0.25), 2)
			end
			if IsControlPressed(0, Config.CamRight) then -- arrow right
				SetCamRot(cameraID, camRotation.x, 0.0, (camRotation.z-0.25), 2)
			end
			if IsControlPressed(0, Config.CamUp) then -- arrow up
				SetCamRot(cameraID, (camRotation.x+0.25), 0.0, camRotation.z, 2)
			end
			if IsControlPressed(0, Config.CamDown) then -- arrow down
				SetCamRot(cameraID, (camRotation.x-0.25), 0.0, camRotation.z, 2)
			end
			if IsControlPressed(0, Config.CamExit) then -- backspace
				usingCamera = false
				Wait(500)
				ClearPedTasks(player)
				DeleteObject(tablet)
				SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- Instructional Buttons:
local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

-- Button:
local function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionalButtonsCamera(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 174, true))
    ButtonMessage("LEFT")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 175, true))
    ButtonMessage("RIGHT")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 172, true))
    ButtonMessage("UP")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 173, true))
    ButtonMessage("DOWN")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, 178, true)) -- The button to display
    ButtonMessage("EXIT") -- the message to display next to it
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end


-- Debug:
RegisterCommand('door', function(source, args)
    if Config.Debug == true then 
        local id = tonumber(args[1])
        TriggerServerEvent('t1ger_bankrobbery:openVaultSV', true, id)
    end
end, false)
