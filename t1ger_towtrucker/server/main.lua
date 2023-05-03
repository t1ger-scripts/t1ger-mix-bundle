-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

ESX = exports['es_extended']:getSharedObject()
towServices = {}

Citizen.CreateThread(function ()
    while GetResourceState('mysql-async') ~= 'started' do Citizen.Wait(0) end
    while GetResourceState(GetCurrentResourceName()) ~= 'started' do Citizen.Wait(0) end
    if GetResourceState(GetCurrentResourceName()) == 'started' then InitializeTowTrucker() end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Society) do
        TriggerEvent('esx_society:registerSociety', v.name, v.label, v.account, v.datastore, v.inventory, v.data)
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	while not xPlayer do Citizen.Wait(100) end
    SetupTowServices(xPlayer.source)
end)

function SetupTowServices(src)
    local xPlayer = ESX.GetPlayerFromId(src)
	while not xPlayer do Citizen.Wait(100) end
    local isOwner, towID = 0, 0
    if next(towServices) then 
        for k,v in pairs(towServices) do
            if xPlayer.identifier == v.identifier then
                isOwner = v.id
            end 
            local currentJob = xPlayer.getJob()
            if currentJob.name == Config.Society[Config.TowServices[v.id].society].name then
                towID = v.id
            end
        end
    end
	TriggerClientEvent('t1ger_towtrucker:loadTowServices', xPlayer.source, towServices, Config.TowServices, isOwner, towID)
end

-- Callback to check money & purchase tow service:
ESX.RegisterServerCallback('t1ger_towtrucker:buyTowService',function(source, cb, id, val, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = 0
    if Config.BuyWithBank then money = xPlayer.getAccount('bank').money else money = xPlayer.getMoney() end
	if money >= val.price then
		if Config.BuyWithBank then xPlayer.removeAccountMoney('bank', val.price) else xPlayer.removeMoney(val.price) end
        local impound = {}
        MySQL.Async.execute('INSERT INTO t1ger_towtrucker (id, identifier, name) VALUES (@id, @identifier, @name)', {
            ['id'] = id,
			['identifier'] = xPlayer.identifier,
            ['name'] = name,
            ['impound'] = json.encode(impound)
        })
		xPlayer.setJob(Config.Society[val.society].name, Config.Society[val.society].boss_grade)
        cb(true)
    else
        cb(false)
    end
end)

-- Event to update selected tow service:
RegisterServerEvent('t1ger_towtrucker:updateTowServices')
AddEventHandler('t1ger_towtrucker:updateTowServices', function(num, val, state, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    UpdateTowServices(num, val, state, name, identifier)
end)

RegisterServerEvent('t1ger_towtrucker:sellTowService')
AddEventHandler('t1ger_towtrucker:sellTowService', function(id, val, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE FROM t1ger_towtrucker WHERE id = @id', {['@id'] = id}) 
    if Config.BuyWithBank then xPlayer.addAccountMoney('bank', amount) else xPlayer.addMoney(amount) end
	xPlayer.setJob('unemployed', 0)
end)

-- Callback to get impounded vehicles:
ESX.RegisterServerCallback('t1ger_towtrucker:GetImpoundVehicles', function(source, cb, id)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_towtrucker WHERE id = @id', {['@id'] = id}, function(result)
        if result[1] then
            local list = {}
            local decoded = json.decode(result[1].impound)
            if decoded ~= nil then
                for k,v in pairs(decoded) do
                    table.insert(list, {
                        plate = v.plate,
                        owner = v.owner,
                        props = json.decode(v.props)
                    })
                end
                cb(decoded)
            else
                cb(nil)
            end
		else
			cb(nil)
		end
    end)
end)

-- Event to release impounded vehicle:
RegisterServerEvent('t1ger_towtrucker:releaseImpound')
AddEventHandler('t1ger_towtrucker:releaseImpound', function(id, plate, props, owner)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM t1ger_towtrucker WHERE id = @id', {['@id'] = id}, function(result)
        if result[1] then
            local decoded = json.decode(result[1].impound)
            if decoded ~= nil and next(decoded) then 
                for k,v in pairs(decoded) do 
                    if v.plate == plate then
                        table.remove(decoded, k)
                        MySQL.Async.execute('UPDATE t1ger_towtrucker SET impound = @impound WHERE id = @id', {
                            ['@impound'] = json.encode(decoded),
                            ['@id'] = id
                        })
                        MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle, tow_impound = @tow_impound WHERE plate = @plate AND owner = @owner', {
                            ['@owner'] = owner,
                            ['@plate'] = plate,
                            ['@tow_impound'] = 0,
                            ['@vehicle'] = json.encode(props),
                        })
                        TriggerClientEvent('t1ger_towtrucker:notify', xPlayer.source, (Lang['veh_impound_released']:format(plate)))
                        break
                    end
                end
            end
        end
	end)
end)

-- Callback to Impound Vehicle:
ESX.RegisterServerCallback('t1ger_towtrucker:impoundVehicle', function(source, cb, id, plate, vehProps)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE (plate = @plate or plate = @plate2)', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate)
	}, function(data)
		if data[1] then
            -- update impound state of the vehicle:
            MySQL.Async.execute('UPDATE owned_vehicles SET tow_impound = @tow_impound WHERE plate = @plate', {
                ['@tow_impound'] = id,
                ['@plate'] = data[1].plate
            })
            -- put in impound of the tow service:
            MySQL.Async.fetchAll('SELECT * FROM t1ger_towtrucker WHERE id = @id', {['@id'] = id}, function(result)
                if result[1] then
                    local decoded = json.decode(result[1].impound)
                    if decoded ~= nil and next(decoded) then
                        for k,v in pairs(decoded) do
                            if v.plate == plate then
                                return cb(false, Lang['veh_already_in_impound']) 
                            else
                                if k == #decoded then
                                    table.insert(decoded, {plate = data[1].plate, owner = data[1].owner, props = json.encode(vehProps)})
                                    MySQL.Async.execute('UPDATE t1ger_towtrucker SET impound = @impound WHERE id = @id', {
                                        ['@impound'] = json.encode(decoded),
                                        ['@id'] = id
                                    })
                                    cb(true, Lang['vehicle_impounded2']) 
                                end
                            end
                        end
                    else
                        decoded = {}
                        table.insert(decoded, {plate = data[1].plate, owner = data[1].owner, props = json.encode(vehProps)})
                        MySQL.Async.execute('UPDATE t1ger_towtrucker SET impound = @impound WHERE id = @id', {
                            ['@impound'] = json.encode(decoded),
                            ['@id'] = id
                        })
                        cb(true, Lang['vehicle_impounded2']) 
                    end
                end
            end)
		else
			cb(false, Lang['impound_veh_not_owned'])
		end
	end)
end)

ESX.RegisterServerCallback('t1ger_towtrucker:isVehicleInTowImpound', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE (plate = @plate or plate = @plate2)', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate)
	}, function(result)
		if result[1] then
            if result[1].tow_impound > 0 then
                cb(true, result[1].tow_impound)
            else
                cb(false, 0)
            end
        else
            cb(false, 0)
        end
    end)
end)

-- Force Delete Object:
RegisterServerEvent('t1ger_towtrucker:forceDelete')
AddEventHandler('t1ger_towtrucker:forceDelete', function(ObjNet)
    TriggerClientEvent('t1ger_towtrucker:forceDeleteCL', -1, ObjNet)
end)

ESX.RegisterUsableItem(Config.RepairKit.itemName, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('t1ger_towtrucker:useRepairKit', xPlayer.source, Config.RepairKit)
end)

-- Job Data SV:
RegisterServerEvent('t1ger_towtrucker:JobDataSV')
AddEventHandler('t1ger_towtrucker:JobDataSV',function(type, num, data)
    TriggerClientEvent('t1ger_towtrucker:JobDataCL', -1, type, num, data)
end)

-- Job Reward
RegisterServerEvent('t1ger_towtrucker:getJobReward')
AddEventHandler('t1ger_towtrucker:getJobReward',function(payout)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cash = math.random(payout.min,payout.max)
    xPlayer.addMoney(cash)
    TriggerClientEvent('t1ger_towtrucker:notify', xPlayer.source, Lang['job_cash_reward']:format(cash))
end)

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
