-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local anpr_enabled = false

-- Thread to run ANPR::
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(100)
		local sleep = true
		if anpr_enabled then 
			sleep = false
			if ply_veh ~= nil then
				local entityHit = GetVehicleMarkedForANPR()
                local ready, plate = isVehicleReadyForANPR(entityHit)
                if ready then 
                    CheckForHits(plate, entityHit)
                    Citizen.Wait(200)
                end
                -- Break ANPR thread if not in veh:
                if not IsPedInAnyVehicle(player, false) then
                    anpr_enabled = false
                    ANPR_StateNotify(anpr_enabled)
                end
                -- Break ANPR thread if not in veh:
                if not IsPedInAnyVehicle(player, false) then
                    anpr_enabled = false
                    ANPR_StateNotify(anpr_enabled)
                end
            end
		end
		if sleep then Citizen.Wait(2000) end
	end
end)

-- Get Vehicle to ANPR Scan:
function GetVehicleMarkedForANPR()
    local coordA = GetOffsetFromEntityInWorldCoords(ply_veh, 0.0, 1.0, 1.0)
    local coordB = GetOffsetFromEntityInWorldCoords(ply_veh, 0.0, Config.ANPR.range, 0.0)
    local targetVeh = StartShapeTestCapsule(coordA, coordB, Config.ANPR.radius, 10, ply_veh, 7)
    local a, b, c, d, entityHit = GetShapeTestResult(targetVeh)
    return entityHit
end

-- Check if vehicle has driver:
function isVehicleReadyForANPR(entity)
    if IsEntityAVehicle(entity) then
        local driver = GetPedInVehicleSeat(entity, -1)
        if driver ~= 0 and IsPedAPlayer(driver) then
            local plate = GetVehicleNumberPlateText(entity):gsub("^%s*(.-)%s*$", "%1")
            return true, plate
        end
    end
end

-- Function to check vehicle hits:
function CheckForHits(plate, entity)
    local color1, color2 = GetVehColorName(entity)
    local vehName = GetVehName(entity)
    if anpr_table[plate] ~= nil then
        -- Play Front End Sound:
        for i = 1, Config.ANPR.hitSound.count, 1 do 
            PlaySoundFrontend(-1, Config.ANPR.hitSound.dict, Config.ANPR.hitSound.lib, true)
            Citizen.Wait(Config.ANPR.hitSound.delay)
        end
        -- Add Hits to an array:
        local strings = {}
        if anpr_table[plate].stolen then table.insert(strings, Config.ANPR.labels.stolen) end
        if anpr_table[plate].bolo then table.insert(strings, Config.ANPR.labels.bolo) end
        if Config.T1GER_Insurance then 
            if anpr_table[plate].insurance == false then
                table.insert(strings, Config.ANPR.labels.uninsured)
            end
        end
        -- Get the owner:
        local decoded = json.decode(anpr_table[plate].owner)
        local owner = decoded.firstname..' '..decoded.lastname
        -- Create Message String:
        local notifyString = 'None'
        if #strings > 0 then
            notifyString = table.concat(strings,"\n- ")
        end
        -- Advanced Notification:
        RequestStreamedTextureDict(Config.ANPR.notify.textureDict)
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName((Lang['anpr_hit_msg']):format(plate,owner,notifyString))
        local subtitle = color1..' '..vehName
        EndTextCommandThefeedPostMessagetext(Config.ANPR.notify.textureDict, Config.ANPR.notify.textureName, false, Config.ANPR.notify.iconType, Config.ANPR.notify.title, subtitle)
        EndTextCommandThefeedPostTicker(false, Config.ANPR.notify.showInBrief)
        Wait(500)
        anpr_enabled = false
        ANPR_StateNotify(anpr_enabled)
    end
end

-- Command to add stolen state:
RegisterCommand(Config.ANPR.command.str, function(source, args)
    if Config.ANPR.command.enable then 
        if IsPlayerJobCop() then 
            if #args > 0 then 
                -- stolen/bolo commands:
                if args[1] and args[2] and args[3] then
                    local state = false; if args[3] == 'true' then state = true elseif args[3] == 'false' then state = false end
                    TriggerServerEvent('t1ger_trafficpolicer:updateANPR', args[1], args[2], state)
                else
                    TriggerEvent('chatMessage', 'ANPR ERROR', {255, 0, 0}, Lang['anpr_cmd_error'])
                end
            else
                -- enable/disable anpr in-game:
                if HasVehicleANPR(ply_veh) then 
                    anpr_enabled = not anpr_enabled
                    ANPR_StateNotify(anpr_enabled)
                end
            end
        end
    end
end, false)

-- Thread to handle hotkey for Traffic Policer Menu:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
        local sleep = true
        if Config.ANPR.keybind.enable then 
            sleep = false
            if IsControlJustPressed(0, Config.ANPR.keybind.key) then
                if IsPlayerJobCop() then
                    if HasVehicleANPR(ply_veh) then 
                        anpr_enabled = not anpr_enabled
                        ANPR_StateNotify(anpr_enabled)
                    end
                end
            end
        end
        if sleep then Citizen.Wait(2000) end
	end
end)

-- Check if Vehicle is ANPR whitelisted:
function HasVehicleANPR(entity)
    if IsPedInAnyVehicle(player, false) then
        for k,v in pairs(Config.ANPR.whitelist) do
            local hash_key = GetHashKey(v)
            if GetEntityModel(entity) == hash_key then
                return true
            end
        end
        TriggerEvent('t1ger_trafficpolicer:notify', Lang['veh_no_anpr'])
    end
    return false
end

-- Notify Active State of ANPR:
function ANPR_StateNotify(state)
    if state then 
        PlaySoundFrontend(-1, Config.ANPR.sound.activate.dict, Config.ANPR.sound.activate.lib, true)
        TriggerEvent('t1ger_trafficpolicer:notify', Lang['anpr_activated'])
    else
        PlaySoundFrontend(-1, Config.ANPR.sound.deactivate.dict, Config.ANPR.sound.deactivate.lib, true)
        TriggerEvent('t1ger_trafficpolicer:notify', Lang['anpr_deactivated'])
    end
end

-- Load ANPR:
RegisterNetEvent('t1ger_trafficpolicer:loadANPR')
AddEventHandler('t1ger_trafficpolicer:loadANPR', function(data)
	anpr_table = data
end)
