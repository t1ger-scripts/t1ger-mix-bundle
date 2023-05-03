-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
ESX = exports['es_extended']:getSharedObject()

AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	while not xPlayer do Citizen.Wait(100) end
end)

-- ## HACKING DEVICE PREPARATION JOB ## --

RegisterServerEvent('t1ger_heistpreps:hacking:startDecryption')
AddEventHandler('t1ger_heistpreps:hacking:startDecryption', function(type, num, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    Config.Jobs[type][num].cache.decryption = {timer = Config.Jobs[type][num].decrypt.time * 60000, player = xPlayer.source, notifyPolice = false, done = false, collected = false}
	TriggerClientEvent('t1ger_heistpreps:sendCacheCL', -1, Config.Jobs[type][num].cache, type, num)
    local alertMSG = Lang['hack_police_alert']
    AlertCops(alertMSG, coords)
end)

RegisterServerEvent('t1ger_heistpreps:hacking:collected')
AddEventHandler('t1ger_heistpreps:hacking:collected', function(type, num)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Jobs[type][num].cache.decryption.collected == false then 
        Config.Jobs[type][num].cache.decryption.collected = true
        Citizen.Wait(1000)
        TriggerEvent('t1ger_heistpreps:giveItem', Config.Jobs[type][num].item[2].name, Config.Jobs[type][num].item[2].amount, xPlayer.source)
        TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['got_decrypted_device'])
        Config.Jobs[type][num].inUse = false
        Config.Jobs[type][num].cache = {}
        TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    else
        TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['device_already_collect'])
    end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1000)
        for k,v in pairs(Config.Jobs['hacking']) do
            if next(v.cache) and (v.cache.decryption ~= nil and next(v.cache.decryption)) then 
                if v.cache.decryption.done == false then
                    if v.cache.decryption.notifyPolice == false then
                        v.cache.decryption.notifyPolice = true
                    end
                    if v.cache.decryption.timer <= 0 then
                        DecryptionComplete('hacking', k)
                    else
                        v.cache.decryption.timer = v.cache.decryption.timer - 1000
                    end
                end
            end
        end
	end
end)

function DecryptionComplete(type, id)
    local xPlayer = ESX.GetPlayerFromId(Config.Jobs[type][id].cache.decryption.player)
    if xPlayer then
        local sender, subject = 'Decryption Software', '~r~3ncrypt3d m3ss4g3~s~'
        local msg = '~b~Decyption Software Completed!~s~\n\nGrab the ~y~device~s~ and yeet!'
        local textureDict, iconType = 'CHAR_LESTER_DEATHWISH', 7
        TriggerClientEvent('t1ger_heistpreps:notifyAdvanced', xPlayer.source, sender, subject, msg, textureDict, iconType)
        Config.Jobs[type][id].cache.decryption.done = true
        TriggerClientEvent('t1ger_heistpreps:sendCacheCL', -1, Config.Jobs[type][id].cache, type, id)
    end
end

function AlertCops(alertMSG, coords)
    local xPlayers = ESX.GetExtendedPlayers()
    local players  = {}
    for i=1, #(xPlayers) do
        local xPlayer = xPlayers[i]
        if CanReceiveAlerts(xPlayer.getJob().name) then
            TriggerClientEvent('t1ger_heistpreps:notifyCops', xPlayer.source, coords, alertMSG)
        end
    end
end

-- ## DRILLS PREPARATION JOB ## --

RegisterServerEvent('t1ger_heistpreps:drills:spawnCrates')
AddEventHandler('t1ger_heistpreps:drills:spawnCrates', function(type, num)
    local cfg = Config.Jobs[type][num]

    local scrambler, got = GetScrambledStuff(cfg.crates, cfg.lootableCrates)
    while not got do 
        Citizen.Wait(100)
    end

    for k,v in pairs(cfg.crates) do
        local crate, netId = T1GER_CreateServerObject(cfg.model, v.pos[1], v.pos[2], v.pos[3], 10000.0, true)
        Config.Jobs[type][num].crates[k].netId = netId
        Config.Jobs[type][num].crates[k].searched = false
        if scrambler[k] == k then
            Config.Jobs[type][num].crates[k].loot = true
        end
        for i = 1, #v.npc do
            local weapon = {name = v.npc[i].weapon, ammo = 255}
            local NPC, networkID = T1GER_CreateServerPed(4, v.npc[i].model, v.npc[i].pos[1], v.npc[i].pos[2], v.npc[i].pos[3], v.npc[i].pos[4], 10000.0, weapon)
            Config.Jobs[type][num].crates[k].npc[i].netId = networkID
        end
    end
    Config.Jobs[type][num].inUse = true
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

RegisterServerEvent('t1ger_heistpreps:drills:searched')
AddEventHandler('t1ger_heistpreps:drills:searched', function(type, num, index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Jobs[type][num].crates[index].searched == true then 
        return TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['drills_alrdy_searched'])
    end
    Config.Jobs[type][num].crates[index].searched = true
    if Config.Jobs[type][num].crates[index].loot == true then
        xPlayer.addInventoryItem(Config.Jobs[type][num].item.name, Config.Jobs[type][num].item.amount)
        TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['you_found_a_drill'])
        local trueCounts = 0
        for k,v in pairs(Config.Jobs[type][num].crates) do
            if v.loot ~= nil and v.searched == true and v.loot == true then
                trueCounts = trueCounts + 1
            end
        end
        if trueCounts == Config.Jobs[type][num].lootableCrates then 
            -- reset if got all drills: 
            Config.Jobs[type][num].inUse = false
            for k,v in pairs(Config.Jobs[type][num].crates) do
                local entity = NetworkGetEntityFromNetworkId(v.netId)
                if DoesEntityExist(entity) then 
                    DeleteEntity(entity)
                end
                v.netId = nil
                v.searched = false
                v.loot = false
                for i = 1, #Config.Jobs[type][num].crates[k].npc do
                    local NPC = NetworkGetEntityFromNetworkId(Config.Jobs[type][num].crates[k].npc[i].netId)
                    if DoesEntityExist(NPC) then 
                        DeleteEntity(NPC)
                    end
                    Config.Jobs[type][num].crates[k].npc[i] = nil
                end
            end
            TriggerClientEvent('t1ger_heistpreps:drills:resetCurJob', xPlayer.source, type, num)
            TriggerClientEvent('t1ger_heistpreps:drills:resetCurJob2', -1, num)
        end
    else
        TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['you_found_nothing'])
    end
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

-- ## THERMAL CHARGES PREPARATION JOB ## --

RegisterServerEvent('t1ger_heistpreps:thermite:spawnConvoy')
AddEventHandler('t1ger_heistpreps:thermite:spawnConvoy', function(type, num)
    local cfg = Config.Jobs[type][num]
    local vehicle, netId = T1GER_CreateServerVehicle(cfg.vehicle, cfg.location.x, cfg.location.y, cfg.location.z, cfg.location.w, 100000.0, 'THERMITE', false, nil)
    Config.Jobs[type][num].inUse = true
    Config.Jobs[type][num].cache.type = type
    Config.Jobs[type][num].cache.num = num
    Config.Jobs[type][num].cache.started = true
    Config.Jobs[type][num].cache.netId = netId
    Config.Jobs[type][num].cache.agents = {}
    for i = 1, #cfg.agents do
        local agent, networkId = T1GER_CreateServerVehiclePed(vehicle, 6, cfg.agents[i].model, cfg.agents[i].seat, 100000.0)
        Config.Jobs[type][num].cache.agents[i] = networkId
    end
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

RegisterServerEvent('t1ger_heistpreps:thermite:searching')
AddEventHandler('t1ger_heistpreps:thermite:searching', function(type, num)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Jobs[type][num].cache.searching == true then 
        return TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['convoy_alrdy_searched'])
    else
        Config.Jobs[type][num].cache.searching = true
        TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    end
end)

-- ## EXPLOSIVES PREPARATION JOB ## --

RegisterServerEvent('t1ger_heistpreps:explosives:spawnCase')
AddEventHandler('t1ger_heistpreps:explosives:spawnCase', function(type, num)
    local cfg = Config.Jobs[type][num]
    math.randomseed(GetGameTimer())
    local coords = cfg.spawn[math.random(1, #cfg.spawn)]
    local case, netId = T1GER_CreateServerObject(cfg.model, coords.x, coords.y, coords.z, 10000.0, false)
    print("case coords: ", coords)
    Config.Jobs[type][num].inUse = true
    Config.Jobs[type][num].cache.netId = netId
    Config.Jobs[type][num].cache.type = type
    Config.Jobs[type][num].cache.num = num
    Config.Jobs[type][num].cache.started = true
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
end)

RegisterServerEvent('t1ger_heistpreps:explosives:collected')
AddEventHandler('t1ger_heistpreps:explosives:collected', function(type, num)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Jobs[type][num].cache.collected == true then 
        return TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['case_already_collected'])
    else
        Config.Jobs[type][num].cache.collected = true
        TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    end
end)

RegisterServerEvent('t1ger_heistpreps:explosives:lockpicking')
AddEventHandler('t1ger_heistpreps:explosives:lockpicking', function(type, num, state)
    local xPlayer = ESX.GetPlayerFromId(source)
    if state == true and Config.Jobs[type][num].cache.lockpicking == true then 
        return TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['case_being_unlocked'])
    else
        Config.Jobs[type][num].cache.lockpicking = state
        TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    end
end)

RegisterServerEvent('t1ger_heistpreps:explosives:unlocked')
AddEventHandler('t1ger_heistpreps:explosives:unlocked', function(type, num)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('t1ger_heistpreps:giveItem', Config.Jobs[type][num].item.name, Config.Jobs[type][num].item.amount, xPlayer.source)
    Config.Jobs[type][num].inUse = false
    Config.Jobs[type][num].cache = {}
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    TriggerClientEvent('t1ger_heistpreps:explosives:reset', -1, type, num)
end)

-- ## KEYCARD PREPARATION JOB ## --

RegisterServerEvent('t1ger_heistpreps:keycard:searchedKeys')
AddEventHandler('t1ger_heistpreps:keycard:searchedKeys', function(type, num)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('t1ger_heistpreps:giveItem', Config.Jobs[type][num].item[1].name, Config.Jobs[type][num].item[1].amount, xPlayer.source)
    Config.Jobs[type][num].cache.searchedKeys = true
    TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    TriggerEvent('t1ger_heistpreps:keycard:createTrucks', type, num, xPlayer.source)
end)

RegisterServerEvent('t1ger_heistpreps:keycard:truckSearched')
AddEventHandler('t1ger_heistpreps:keycard:truckSearched', function(type, num, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Jobs[type][num].spawns[id].searched == true then
        return TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['truck_already_searched'])
    else
        Config.Jobs[type][num].spawns[id].searched = true
        if Config.Jobs[type][num].spawns[id].loot == true then 
            TriggerEvent('t1ger_heistpreps:giveItem', Config.Jobs[type][num].item[2].name, Config.Jobs[type][num].item[2].amount, xPlayer.source)
            TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['found_keycard_in_truck'])
            -- check if got all keycards:
            local trueCounts = 0
            for k,v in pairs(Config.Jobs[type][num].spawns) do
                if (v.loot ~= nil and v.loot == true) and v.searched == true then
                    trueCounts = trueCounts + 1
                end
            end
            if trueCounts == Config.Jobs[type][num].keycards then 
                -- reset: 
                Config.Jobs[type][num].inUse = false
                for k,v in pairs(Config.Jobs[type][num].spawns) do
                    local entity = NetworkGetEntityFromNetworkId(v.netId)
                    if DoesEntityExist(entity) then 
                        DeleteEntity(entity)
                    end
                    v.netId = nil
                    v.searched = false
                    v.loot = false
                end
                Config.Jobs[type][num].cache = {}
                TriggerClientEvent('t1ger_heistpreps:keycard:resetCurJob', xPlayer.source, type, num)
                TriggerClientEvent('t1ger_heistpreps:keycard:resetCurJob2', -1, num)
                
            end
        else
            TriggerClientEvent('t1ger_heistpreps:notify', xPlayer.source, Lang['found_nothing_in_truck'])
        end
        TriggerClientEvent('t1ger_heistpreps:sendConfigCL', -1, type, num, Config.Jobs[type][num])
    end
end)

RegisterServerEvent('t1ger_heistpreps:giveItem')
AddEventHandler('t1ger_heistpreps:giveItem', function(item, amount, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        xPlayer = ESX.GetPlayerFromId(target)
    end
    xPlayer.addInventoryItem(item, amount)
end)

RegisterServerEvent('t1ger_heistpreps:removeItem')
AddEventHandler('t1ger_heistpreps:removeItem', function(item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, amount)
end)

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
