
RegisterServerEvent('t1ger_heistpreps:hacking:spawnDevice')
AddEventHandler('t1ger_heistpreps:hacking:spawnDevice', function(type, num)
    local cfg = Config.Jobs[type][num]
    math.randomseed(GetGameTimer())
    local coords = cfg.spawn[math.random(1, #cfg.spawn)]
    local h_device, netId = T1GER_CreateServerObject(cfg.model, coords[1], coords[2], coords[3], 10000.0, true)
    Config.Jobs[type][num].inUse = true
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    Config.Jobs[type][num].cache.netId = netId
    Config.Jobs[type][num].cache.type = type
    Config.Jobs[type][num].cache.num = num
    Config.Jobs[type][num].cache.started = true
    TriggerClientEvent('t1ger_heistpreps:sendCacheCL', -1, Config.Jobs[type][num].cache, type, num)
end)


RegisterServerEvent('t1ger_heistpreps:hacking:pickUp')
AddEventHandler('t1ger_heistpreps:hacking:pickUp', function(type, num)
    Config.Jobs[type][num].cache.pickedUp = true
	TriggerClientEvent('t1ger_heistpreps:sendCacheCL', -1, Config.Jobs[type][num].cache, type, num)
end)

RegisterServerEvent('t1ger_heistpreps:hacking:decrypting')
AddEventHandler('t1ger_heistpreps:hacking:decrypting', function(type, num)
    Config.Jobs[type][num].cache.decrypting = true
	TriggerClientEvent('t1ger_heistpreps:sendCacheCL', -1, Config.Jobs[type][num].cache, type, num)
end)

RegisterServerEvent('t1ger_heistpreps:thermite:reset')
AddEventHandler('t1ger_heistpreps:thermite:reset', function(type, num)
    Config.Jobs[type][num].inUse = false
    Config.Jobs[type][num].cache = {}
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    TriggerClientEvent('t1ger_heistpreps:thermite:resetCL', -1, type, num)
end)

RegisterServerEvent('t1ger_heistpreps:explosives:placed')
AddEventHandler('t1ger_heistpreps:explosives:placed', function(type, num)
    Config.Jobs[type][num].cache.placed = true
    Config.Jobs[type][num].cache.lockpicking = false
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

RegisterServerEvent('t1ger_heistpreps:keycard:spawnPed')
AddEventHandler('t1ger_heistpreps:keycard:spawnPed', function(type, num)
    local cfg = Config.Jobs[type][num]
    local NPC, netId = T1GER_CreateServerPed(6, cfg.model, cfg.npc.x, cfg.npc.y, cfg.npc.z, cfg.npc.w, 15000.0, nil)
    Config.Jobs[type][num].inUse = true
    Config.Jobs[type][num].cache.netId = netId
    Config.Jobs[type][num].cache.type = type
    Config.Jobs[type][num].cache.num = num
    Config.Jobs[type][num].cache.started = true
    Config.Jobs[type][num].cache.searchedKeys = false
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

RegisterServerEvent('t1ger_heistpreps:keycard:createTrucks')
AddEventHandler('t1ger_heistpreps:keycard:createTrucks', function(type, num, source)
    local cfg = Config.Jobs[type][num]
    local scrambler, got = GetScrambledStuff(cfg.spawns, cfg.keycards)
    while not got do 
        Citizen.Wait(100)
    end
    for k,v in pairs(cfg.spawns) do
        local truck, netId = T1GER_CreateServerVehicle(cfg.vehicle, v.pos.x, v.pos.y, v.pos.z, v.pos.w, 100000.0, 'TRUCK007', false, 2)
        Config.Jobs[type][num].spawns[k].netId = netId
        Config.Jobs[type][num].spawns[k].searched = false
        if scrambler[k] == k then
            Config.Jobs[type][num].spawns[k].loot = true
        end
    end
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

function T1GER_CreateServerObject(model, x, y, z, cullingRadius, freeze)
    local obj = CreateObject(model, x, y, z, true, true, true)
    while not DoesEntityExist(obj) do
        Citizen.Wait(50)
    end
    if DoesEntityExist(obj) then
        local netId = NetworkGetNetworkIdFromEntity(obj)
        SetEntityDistanceCullingRadius(obj, cullingRadius)
        if freeze == true then 
            FreezeEntityPosition(obj, true)
        end
        return obj, netId
    end
    return nil, nil
end

function T1GER_CreateServerVehicle(model, x, y, z, h, cullingRadius, plate, freeze, lock)
    local vehicle = CreateVehicle(model, x, y, z, h, true, false)
    while not DoesEntityExist(vehicle) do
        Citizen.Wait(50)
    end
    if DoesEntityExist(vehicle) then
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        SetEntityDistanceCullingRadius(vehicle, cullingRadius)
        SetVehicleNumberPlateText(vehicle, plate)
        if freeze == true then FreezeEntityPosition(vehicle, true) end
        if lock ~= nil then SetVehicleDoorsLocked(vehicle, lock) end
        return vehicle, netId
    end
    return nil, nil
end

function T1GER_CreateServerPed(type, model, x, y, z, h, cullingRadius, weapon)
    local ped = CreatePed(type, model, x, y, z, h, true, false)
    while not DoesEntityExist(ped) do
        Citizen.Wait(50)
    end
    if DoesEntityExist(ped) then
        local netId = NetworkGetNetworkIdFromEntity(ped)
        SetEntityDistanceCullingRadius(ped, cullingRadius)
        if weapon ~= nil and next(weapon) then 
            GiveWeaponToPed(ped, weapon.name, weapon.ammo, false, false)
        end
        return ped, netId
    end
    return nil, nil
end

function T1GER_CreateServerVehiclePed(vehicle, type, model, seat, cullingRadius)
    local ped = CreatePedInsideVehicle(vehicle, type, model, seat, true, false)
    while not DoesEntityExist(ped) do
        Citizen.Wait(50)
    end
    if DoesEntityExist(ped) then
        local netId = NetworkGetNetworkIdFromEntity(ped)
        SetEntityDistanceCullingRadius(ped, cullingRadius)
        return ped, netId
    end
    return nil, nil
end



function GetScrambledStuff(t, count)
    local scrambler = {}
    for i = 1, count do 
        math.randomseed(GetGameTimer())
        local num = math.random(1, #t)
        Citizen.Wait(1)
        while scrambler[num] == num do
            math.randomseed(GetGameTimer())
            num = math.random(1, #t)
        end
        scrambler[num] = num
    end
    return scrambler, true
end

function CanReceiveAlerts(job)
	if not job then return false end
	for k,v in pairs(Config.AlertJobs) do
		if job == v then
			return true
		end
	end
	return false
end