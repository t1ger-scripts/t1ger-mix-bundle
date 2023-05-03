-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function ()
    while GetResourceState('mysql-async') ~= 'started' do Citizen.Wait(0) end
    while GetResourceState(GetCurrentResourceName()) ~= 'started' do Citizen.Wait(0) end
    if GetResourceState(GetCurrentResourceName()) == 'started' then InitializeGarage() end
end)

local pvt_garages = {}

function InitializeGarage()
	MySQL.Async.execute('UPDATE owned_vehicles SET state = @state WHERE NOT state', {['@state'] = true})
	-- private garages:
	if Config.EnablePrivateGarages == true then
		MySQL.Async.fetchAll('SELECT * FROM t1ger_garage', {}, function(results)
			if next(results) then
				for i = 1, #results do
					local decoded_vehicles = json.decode(results[i].vehicles)
					pvt_garages[results[i].id] = {identifier = results[i].identifier, id = results[i].id, vehicles = decoded_vehicles}
				end
				Wait(50)
				for i = 1, #Config.PrivateGarages do
					if pvt_garages[i] ~= nil then
						if pvt_garages[i].id == i then
							Config.PrivateGarages[i].owned = true
						end
					end
				end
			end
			RconPrint('T1GER GARAGE - INITIALIZED\n')
			if GetResourceState('garageShells') == 'started' then 
				RconPrint('K4MB1 GARAGE SHELLS - INITIALIZED\n')
			else
				RconPrint('^1[ERROR] K4MB1 GARAGE SHELLS - PLEASE DOWNLOAD & INSTALL THE SHELLS (LINK IN README)^0\n')
			end
		end)
	end
end

-- On Player Loaded:
AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	-- load owned garages here
	if Config.EnablePrivateGarages == true then 
		SetupPrivateGarages(xPlayer.source)
	end
end)

-- On Player Dropped:
AddEventHandler('esx:playerDropped', function(playerId, reason)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	MySQL.Async.execute('UPDATE owned_vehicles SET state = @state WHERE owner = @owner', {
		['@state'] = true,
		['@owner'] = xPlayer.identifier
	})
end)

-- Debug Thread:
Citizen.CreateThread(function()
	if Config.Debug then 
		Citizen.Wait(2000)
		if Config.EnablePrivateGarages == true then 
			if GetPlayers()[1] ~= nil then 
				SetupPrivateGarages(GetPlayers()[1])
			end
		end
	end
end)

-- Setup Garages:
function SetupPrivateGarages(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	local garage_id = 0
	for k,v in pairs(pvt_garages) do
		if xPlayer.identifier == v.identifier then
			garage_id = v.id
			break
		end
	end
	TriggerClientEvent('t1ger_garage:loadPrivateGarages', xPlayer.source, pvt_garages, garage_id, Config.PrivateGarages)
end

-- Event to update private garage:
RegisterServerEvent('t1ger_garage:updatePrivateGarage')
AddEventHandler('t1ger_garage:updatePrivateGarage', function(num, val, state)
	local xPlayer = ESX.GetPlayerFromId(source)
	if state then
		pvt_garages[num] = {identifier = xPlayer.identifier, id = num, vehicles = nil}
	else
		for k,v in pairs(pvt_garages) do
			if v.id == num then
				pvt_garages[k] = nil
				break
			end
		end
	end
	Config.PrivateGarages[num].owned = state
	TriggerClientEvent('t1ger_garage:syncPrivateGarages', -1, pvt_garages, Config.PrivateGarages)
end)

-- Callback to purchase garage:
ESX.RegisterServerCallback('t1ger_garage:buyPrivateGarage',function(source, cb, id, val)
	local xPlayer = ESX.GetPlayerFromId(source)
	local paid = false
	if Config.BuyGarageWithBank then 
		if xPlayer.getAccount('bank').money >= val.price then
			xPlayer.removeAccountMoney('bank', val.price)
			paid = true
		end
	else
		if xPlayer.getMoney() >= val.price then 
			xPlayer.removeMoney(val.price)
			paid = true
		end
	end
	if paid then
		local vehicles = {}
		for i = 1, #Config.Offsets[val.prop].veh do
			vehicles[i] = {id = i, plate = false}
		end
		MySQL.Async.execute('INSERT INTO t1ger_garage (identifier, id, vehicles) VALUES (@identifier, @id, @vehicles)', {
			['@identifier'] = xPlayer.identifier,
			['@id'] = id,
			['@vehicles'] = json.encode(vehicles)
		})
		cb(true)
	else
		cb(false)
	end
end)

-- Event to sell private garage:
RegisterServerEvent('t1ger_garage:sellGarage')
AddEventHandler('t1ger_garage:sellGarage', function(id, val, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE FROM t1ger_garage WHERE id = @id', {['@id'] = id}) 
    if Config.BuyGarageWithBank then xPlayer.addAccountMoney('bank', amount) else xPlayer.addMoney(amount) end
end)

RegisterServerEvent('t1ger_garage:sendCacheSV')
AddEventHandler('t1ger_garage:sendCacheSV',function(id, data)
	Config.PrivateGarages[id].cache = data
	TriggerClientEvent('t1ger_garage:sendCacheCL', -1, Config.PrivateGarages[id].cache, id)
end)

-- Get Private Garage Vehicles:
ESX.RegisterServerCallback('t1ger_garage:getPrivateGarageVehicles',function(source, cb, id, val)
	local xPlayer = ESX.GetPlayerFromId(source)
	local fetched, owned_vehicles = false, {}
	MySQL.Async.fetchAll('(SELECT plate, vehicle, state, garage, fuel, type from owned_vehicles t1 INNER JOIN t1ger_garage t2 ON t1.owner = t2.identifier WHERE t2.id = @id AND t2.identifier = @identifier AND t1.type = @type AND t1.garage = @garage)', {
		['@id'] = id,
		['@identifier'] = xPlayer.identifier,
		['@type'] = 'car',
		['@garage'] = 'private'
	}, function(results)
        if results[1] then
			for k,v in pairs(results) do
				owned_vehicles[v.plate] = v
			end
			fetched = true 
        else
			fetched = true
        end
	end)
	while not fetched do 
		Citizen.Wait(10)
	end
	local gotData, pvt_vehicles = false, {}
	MySQL.Async.fetchAll('SELECT vehicles FROM t1ger_garage WHERE identifier = @identifier AND id = @id', {
		['@identifier'] = xPlayer.identifier,
		['@id'] = id
	}, function(results)
		if results[1] then 
			local decoded = json.decode(results[1].vehicles)
			if decoded ~= nil and next(decoded) ~= nil then
				for i = 1, #decoded do
					if decoded[i].plate then
						local plate = decoded[i].plate
						if owned_vehicles[plate] ~= nil then
							if owned_vehicles[plate].state then 
								table.insert(pvt_vehicles, {id = i, plate = plate, props = json.decode(owned_vehicles[plate].vehicle), fuel = owned_vehicles[plate].fuel})
							end
						end
					end
				end
				gotData = true
			else
				return print("[t1ger_garage:getPrivateGarageVehicles] ERROR | #224652")
			end
		else
			return print("[t1ger_garage:getPrivateGarageVehicles] ERROR | #884821")
		end
	end)
	while not gotData do 
		Citizen.Wait(10)
	end
	cb(pvt_vehicles)
end)

-- Get Private Garage Vehicles:
ESX.RegisterServerCallback('t1ger_garage:checkPrivateGarage',function(source, cb, id, plate, props, fuel)
	local xPlayer = ESX.GetPlayerFromId(source)
	local has_space = false
	MySQL.Async.fetchAll('SELECT vehicles FROM t1ger_garage WHERE identifier = @identifier AND id = @id', {
		['@identifier'] = xPlayer.identifier,
		['@id'] = id
	}, function(results)
		if results[1] then 
			local decoded = json.decode(results[1].vehicles)
			if decoded ~= nil and next(decoded) ~= nil then
				local slot = GetGarageSlot(decoded, plate)
				if not slot then
					cb(false, Lang['pvt_plate_exists'])
				else
					if slot == 0 then
						cb(false, Lang['pvt_no_empty_slots'])
					else
						MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle, state = @state, garage = @garage, fuel = @fuel WHERE owner = @owner AND (plate = @plate or plate = @plate2)', {
							['@owner'] = xPlayer.identifier,
							['@plate'] = plate,
							['@plate2'] = T1GER_Trim(plate),
							['@vehicle'] = json.encode(props),
							['@state'] = true,
							['@garage'] = 'private',
							['@fuel'] = fuel,
						}, function(rowsChanged)
							if rowsChanged then 
								cb(true, slot)
							end
						end)
					end
				end
			else
				return print("[t1ger_garage:checkPrivateGarage] ERROR | #224652")
			end
		else
			return print("[t1ger_garage:checkPrivateGarage] ERROR | #884821")
		end
	end)
end)

function GetGarageSlot(table, plate)
	local slot = 0
	-- get empty garage slot:
	for i = 1, #table do
		if not table[i].plate then
			slot = i
			break
		end
	end
	-- check if plate exists in private garage:
	for k,v in pairs(table) do if v.plate == plate or v.plate == ESX.Math.Trim(plate) then return false end end
	return slot
end

RegisterServerEvent('t1ger_garage:enterPrivateGarage')
AddEventHandler('t1ger_garage:enterPrivateGarage',function(id, plate, slot)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('(SELECT plate, vehicle, fuel, vehicles from owned_vehicles t1 INNER JOIN t1ger_garage t2 ON t1.owner = t2.identifier WHERE t2.id = @id AND t2.identifier = @identifier AND t1.plate = @plate OR t1.plate = @plate2)', {
		['@id'] = id,
		['@identifier'] = xPlayer.identifier,
		['@plate'] = plate,
		['@plate2'] = ESX.Math.Trim(plate)
	}, function(results)
        if results[1] then
			local decoded = json.decode(results[1].vehicles)
			if decoded ~= nil and next(decoded) ~= nil then
				decoded[slot].plate = results[1].plate
				MySQL.Sync.execute('UPDATE t1ger_garage SET vehicles = @vehicles WHERE id = @id AND identifier = @identifier', {
					['@identifier'] = xPlayer.identifier,
					['@id'] = id,
					['@vehicles'] = json.encode(decoded)
				})
			else
				return print("[t1ger_garage:enterPrivateGarage] ERROR | #224652")
			end
		else
			return print("[t1ger_garage:enterPrivateGarage] ERROR | #884821")
        end
	end)
end)

RegisterServerEvent('t1ger_garage:leavePrivateGarage')
AddEventHandler('t1ger_garage:leavePrivateGarage',function(id, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_garage WHERE identifier = @identifier AND id = @id', {
		['@identifier'] = xPlayer.identifier,
		['@id'] = id
	}, function(results)
		if results[1] then 
			local decoded = json.decode(results[1].vehicles)
			if decoded ~= nil and next(decoded) ~= nil then
				for i = 1, #decoded do
					if decoded[i].plate == plate or decoded[i].plate == ESX.Math.Trim(plate) then
						decoded[i].plate = false
						MySQL.Sync.execute('UPDATE t1ger_garage SET vehicles = @vehicles WHERE id = @id AND identifier = @identifier', {
							['@identifier'] = xPlayer.identifier,
							['@id'] = id,
							['@vehicles'] = json.encode(decoded)
						})
						MySQL.Sync.execute('UPDATE owned_vehicles SET garage = @garage, state = @state WHERE (plate = @plate OR plate = @plate2) AND owner = @owner', {
							['@owner'] = xPlayer.identifier,
							['@plate'] = plate,
							['@plate2'] = ESX.Math.Trim(plate),
							['@garage'] = nil,
							['@state'] = false
						})
						break
					end
				end
			else
				return print("[t1ger_garage:leavePrivateGarage] ERROR | #224652")
			end
		else
			return print("[t1ger_garage:leavePrivateGarage] ERROR | #884821")
		end
	end)
end)

-- Is Vehicle Plate Valid:
ESX.RegisterServerCallback('t1ger_garage:isVehiclePlateValid',function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE (plate = @plate or plate = @plate2)', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
	}, function(results) 
		if results[1] then 
			cb(true)
		else
			cb(false)
		end
	end)
end)

-- Is Vehicle Owned:
ESX.RegisterServerCallback('t1ger_garage:isVehicleOwned',function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND (plate = @plate or plate = @plate2)', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
		['@owner'] = xPlayer.identifier,
	}, function(results) 
		if results[1] then 
			cb(true)
		else
			cb(false)
		end
	end)
end)

-- Is Type Allowed:
ESX.RegisterServerCallback('t1ger_garage:isTypeAllowed',function(source, cb, plate, type)
	MySQL.Async.fetchAll('SELECT type FROM owned_vehicles WHERE (plate = @plate or plate = @plate2)', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
	}, function(results) 
		if results[1] then
			if results[1].type == type then 
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)

-- Event to update vehicle state:
RegisterServerEvent('t1ger_garage:updateState')
AddEventHandler('t1ger_garage:updateState', function(plate, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local query, garage = 'UPDATE owned_vehicles SET state = @state WHERE plate = @plate or plate = @plate2', nil
	if type == 'impound' or type == 'job' then
		query = 'UPDATE owned_vehicles SET state = @state, garage = @garage WHERE plate = @plate or plate = @plate2'
	end
	if type == 'private' then 
		query = 'UPDATE owned_vehicles SET state = @state, garage = @garage WHERE plate = @plate or plate = @plate2'
	end
	MySQL.Async.execute(query, { ['@plate'] = plate, ['@plate2'] = T1GER_Trim(plate), ['@garage'] = garage, ['@state'] = false }, function(rowsChanged)
		if rowsChanged then
			if type == 'impound' then 
				TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_paid_impound_fees']:format(Config.Impound.Fees, plate))
			elseif type == 'job' then
				TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_took_out_job_veh']:format(plate))
			elseif type == 'garage' then 
				TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_took_out_vehicle']:format(plate))
			elseif type == 'private' then 
				TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_took_out_vehicle']:format(plate))
			end
		else
			print("[t1ger_garage:updateState] - ERROR #376593")
		end
	end)
end)

-- Store Owned Vehicles
RegisterServerEvent('t1ger_garage:setVehicleStored')
AddEventHandler('t1ger_garage:setVehicleStored', function(plate, props, fuel, garage)
	local query = 'UPDATE owned_vehicles SET vehicle = @vehicle, state = @state, garage = @garage, fuel = @fuel WHERE owner = @owner AND (plate = @plate or plate = @plate2)'
	if Config.StoreAnotherVehicle then
		query = 'UPDATE owned_vehicles SET vehicle = @vehicle, state = @state, garage = @garage, fuel = @fuel WHERE plate = @plate or plate = @plate2'
	end
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute(query, {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
		['@vehicle'] = json.encode(props),
		['@state'] = true,
		['@garage'] = garage,
		['@fuel'] = fuel,
		['@owner'] = xPlayer.identifier,
	}, function(rowsChanged)
		if rowsChanged then
			TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_stored_vehicle']:format(plate))
		else
			print("[t1ger_garage:setVehicleStored] - ERROR #245722")
		end
	end)
end)

-- Get Owned Vehicles:
ESX.RegisterServerCallback('t1ger_garage:getOwnedVehicles',function(source, cb, garage, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner and (garage = @garage OR garage IS NULL) and type = @type', {
		['@owner'] = xPlayer.identifier,
		['@garage'] = garage,
		['@type'] = type
	}, function(results) 
		if results[1] then 
			cb(results)
		else
			cb(false)
		end
	end)
end)

-- Get ALL Owned Vehicles:
ESX.RegisterServerCallback('t1ger_garage:getAllOwnedVehicles',function(source, cb, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier,
	}, function(results) 
		if results[1] then 
			cb(results)
		else
			cb(false)
		end
	end)
end)

-- Transfer owned vehicles:
RegisterServerEvent('t1ger_garage:transferVehicle')
AddEventHandler('t1ger_garage:transferVehicle', function(plate, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE owned_vehicles SET garage = @garage WHERE plate = @plate or plate = @plate2', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
		['@garage'] = garage
	}, function(rowsChanged)
		if rowsChanged then
			TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_transferred_vehicle'])
		end
	end)
end)


-- Store Job Vehicles
RegisterServerEvent('t1ger_garage:setJobVehicleStored')
AddEventHandler('t1ger_garage:setJobVehicleStored', function(plate, props, fuel)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle, fuel = @fuel, state = @state WHERE plate = @plate or plate = @plate2', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
		['@vehicle'] = json.encode(props),
		['@fuel'] = fuel,
		['@state'] = true
	}, function(rowsChanged)
		if rowsChanged then
			TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_stored_vehicle']:format(plate))
		else
			print("[t1ger_garage:setJobVehicleStored] - ERROR #753722")
		end
	end)
end)

-- Get Society Vehicles:
ESX.RegisterServerCallback('t1ger_garage:getSocietyVehicles',function(source, cb, type, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner and type = @type', {
		['@owner'] = society,
		['@type'] = type
	}, function(results) 
		if results[1] then 
			cb(results)
		else
			cb(false)
		end
	end)
end)

-- Event to get impounded vehicles by type:
ESX.RegisterServerCallback('t1ger_garage:getImpoundedVehicles',function(source, cb, cfg)
	local xPlayer = ESX.GetPlayerFromId(source)
	local query = 'SELECT * FROM owned_vehicles WHERE owner = @owner and garage = @garage and type = @type'
	MySQL.Async.fetchAll(query, {['@owner'] = xPlayer.identifier, ['@garage'] = 'impound', ['@type'] = cfg.type}, function(results) 
		if results[1] then 
			cb(results)
		else
			cb(false)
		end
	end)
end)

-- Event to get impounded vehicles by type:
ESX.RegisterServerCallback('t1ger_garage:getImpoundedJobVehicles',function(source, cb, cfg)
	local xPlayer = ESX.GetPlayerFromId(source)
	local query = 'SELECT * FROM owned_vehicles WHERE owner = @job and garage = @garage and type = @type'
	MySQL.Async.fetchAll(query, {['@job'] = xPlayer.job.name, ['@garage'] = 'impound', ['@type'] = cfg.type}, function(results) 
		if results[1] then 
			cb(results)
		else
			cb(false)
		end
	end)
end)

-- Callback to get vehicles in specific garage:
ESX.RegisterServerCallback('t1ger_garage:getSeizedVehicles',function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE garage = @garage AND seized = @seized', {
		['@garage'] = 'impound',
		['@seized'] = true
	}, function(results) 
		if results[1] then 
			cb(results)
		else
			cb(false)
		end
	end)
end)

-- Callback to get impound fees
ESX.RegisterServerCallback('t1ger_garage:getImpoundFees',function(source, cb, fees)
	local xPlayer = ESX.GetPlayerFromId(source)
	local paid = false
	if Config.Impound.Bank then
		if xPlayer.getAccount('bank').money >= fees then xPlayer.removeAccountMoney('bank', fees); paid = true end
	else
		if xPlayer.getMoney() >= fees then xPlayer.removeMoney(fees); paid = true end
	end
	if paid then cb(true) else cb(false) end
end)

-- Event to update vehicle seized status:
RegisterServerEvent('t1ger_garage:updateSeized')
AddEventHandler('t1ger_garage:updateSeized', function(plate, state)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE owned_vehicles SET seized = @seized WHERE plate = @plate or plate = @plate2', {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
		['@seized'] = state
	}, function(rowsChanged)
		if rowsChanged then
			TriggerClientEvent('t1ger_garage:notify', xPlayer.source, Lang['u_released_vehicle']:format(plate))
		else
			print("[t1ger_garage:updateSeized] - ERROR #167593")
		end
	end)
end)

-- Set Vehicle Impounded:
RegisterServerEvent('t1ger_garage:setVehicleImpounded')
AddEventHandler('t1ger_garage:setVehicleImpounded', function(plate, props, fuel, garage, seized)
	local query = 'UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, fuel = @fuel, state = @state WHERE plate = @plate or plate = @plate2'
	if seized then
		query = 'UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, fuel = @fuel, state = @state, seized = @seized WHERE plate = @plate or plate = @plate2'
	end
	local plate, vehicle = props.plate, json.encode(props)
	MySQL.Sync.execute(query, {
		['@plate'] = plate,
		['@plate2'] = T1GER_Trim(plate),
		['@vehicle'] = json.encode(props),
		['@garage'] = garage,
		['@fuel'] = fuel,
		['@state'] = true,
		['@seized'] = seized
	})
end)

-- Function to trim plates:
function T1GER_Trim(value)
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end
