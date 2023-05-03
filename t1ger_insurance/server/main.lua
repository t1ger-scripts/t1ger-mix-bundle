-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()
TriggerEvent('esx_society:registerSociety', Config.Insurance.job.name, 'Insurance', 'society_insurance', 'society_insurance', 'society_insurance', {type = 'private'})

local brokers = 0

-- Get Online Insurance Brokers:
Citizen.CreateThread(function()
    while true do
        brokers = GetOnlineBrokers()
        TriggerClientEvent('t1ger_insurance:updateBrokerCount', -1, brokers)
        Citizen.Wait(Config.Insurance.job.sync_time * 60 * 1000)
    end
end)

-- Load Broker Count:
AddEventHandler('esx:playerLoaded', function(playerId)
	Citizen.Wait(1000)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if xPlayer then
		TriggerClientEvent('t1ger_insurance:updateBrokerCount', xPlayer.source, brokers)
	end
end)

-- Callback to fetch owned vehicles:
ESX.RegisterServerCallback('t1ger_insurance:fetchVehicles', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local vehicles = {}
	if xPlayer then
		MySQL.Async.fetchAll('SELECT * FROM '..Config.VehiclesTable..' WHERE owner = @identifier', {['@identifier'] = xPlayer.identifier}, function(results) 
			if #results > 0 then
				for k,v in pairs(results) do
					local veh_props = json.decode(v.vehicle)
					table.insert(vehicles, {props = veh_props, plate = v.plate, insurance = v.insurance})
					if Config.HasModelNameInTable then
						vehicles[k].model = v.model
						if v.model ~= nil then 
							vehicles[k].price = MySQL.Sync.fetchScalar('SELECT price FROM vehicles WHERE model = @model', {['@model'] = v.model})
						end
					end
				end
				cb(vehicles)
			else
				cb(nil)
			end
		end)
	end
end)

-- Event to buy insurance:
RegisterServerEvent('t1ger_insurance:buyInsurance')
AddEventHandler('t1ger_insurance:buyInsurance', function(data, upfront, sub)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		if xPlayer.getAccount('bank').money >= upfront then
			xPlayer.removeAccountMoney('bank', upfront)
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_insurance', function(account)
				account.addMoney(upfront)
			end)
			TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['insurance_established']:format(upfront))
			UpdateInsuranceState(data.plate, true)
		end
	end
end)

-- Event to cancel insurance:
RegisterServerEvent('t1ger_insurance:cancelInsurance')
AddEventHandler('t1ger_insurance:cancelInsurance', function(data, upfront, sub)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		UpdateInsuranceState(data.plate, false)
		TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['insurance_cancelled']:format(data.plate))
	end
end)

-- function to update insurance state:
function UpdateInsuranceState(plate, state)
	MySQL.Async.execute('UPDATE '..Config.VehiclesTable..' SET insurance = @insurance WHERE plate = @plate', {
		['@plate'] = plate,
		['@insurance'] = state
	})
end

-- Server event to pay insurance bills:
RegisterServerEvent('t1ger_insurance:payInsuranceBill')
AddEventHandler('t1ger_insurance:payInsuranceBill', function(bill)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		--if xPlayer.getAccount('bank').money >= bill then
			xPlayer.removeAccountMoney('bank', bill)
			TriggerClientEvent('t1ger_insurance:ShowAdvancedNotifyESX', xPlayer.source, Lang['bank'], Lang['received_bill'], (Lang['paid_ins_bil']):format(bill), 'CHAR_BANK_MAZE', 9)
		--end
	end
end)

-- Callback to get vehicle data based on plate
ESX.RegisterServerCallback('t1ger_insurance:getVehiclePlate', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM '..Config.VehiclesTable..' WHERE plate = @plate', {['@plate'] = plate}, function(result) 
		if result[1] then
			cb(result[1])
		else
			TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['plate_not_exist'])
		end
	end)
end)

-- Get Vehicle Price:
ESX.RegisterServerCallback('t1ger_insurance:getVehiclePrice', function(source, cb, model)
	local xPlayer = ESX.GetPlayerFromId(source)
	local vehicle_price = MySQL.Sync.fetchScalar('SELECT price FROM vehicles WHERE model = @model', {['@model'] = model})
	cb(vehicle_price)
end)

-- Event to send buy confirmation:
RegisterServerEvent('t1ger_insurance:sendSellConfirmation')
AddEventHandler('t1ger_insurance:sendSellConfirmation', function(upfront, subscription, plate, target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	TriggerClientEvent('t1ger_insurance:buyInsuranceConfirmation', xTarget.source, plate, upfront, subscription, xPlayer.source)
end)

-- Event to sell insurance:
RegisterServerEvent('t1ger_insurance:sellInsurance')
AddEventHandler('t1ger_insurance:sellInsurance', function(plate, target, upfront, status)
	local xPlayer = ESX.GetPlayerFromId(target)
	local xTarget = ESX.GetPlayerFromId(source)
	if xTarget then
		if status == 'confirm' then
			if xTarget.getAccount('bank').money >= upfront then
				xTarget.removeAccountMoney('bank', upfront)
				TriggerEvent('esx_addonaccount:getSharedAccount', 'society_insurance', function(account)
					account.addMoney(upfront)
				end)
				TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xTarget.source, Lang['insurance_established']:format(upfront))
				TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['u_sold_insurance'])
				UpdateInsuranceState(plate, true)
			end
		else
			TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['target_denied_ins'])
		end
	end
end)

-- Event to send cancel confirmation:
RegisterServerEvent('t1ger_insurance:sendCancelConfirmation')
AddEventHandler('t1ger_insurance:sendCancelConfirmation', function(plate, target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	TriggerClientEvent('t1ger_insurance:cancelInsuranceConfirmation', xTarget.source, plate, xPlayer.source)
end)

-- Event to cancel insurance:
RegisterServerEvent('t1ger_insurance:deleteInsurance')
AddEventHandler('t1ger_insurance:deleteInsurance', function(plate, target, status)
	local xPlayer = ESX.GetPlayerFromId(target)
	local xTarget = ESX.GetPlayerFromId(source)
	if xTarget then
		if status == 'cancel_insurance' then
			UpdateInsuranceState(plate, false)
			TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xTarget.source, Lang['insurance_cancelled']:format(plate))
			TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['u_cancelled_insurance'])
		else
			TriggerClientEvent('t1ger_insurance:ShowNotifyESX', xPlayer.source, Lang['target_denied_ins'])
		end
	end
end)

-- Function to get online brokers:
function GetOnlineBrokers()
    local xPlayers = ESX.GetExtendedPlayers()
	local brokers = 0
	for i=1, #(xPlayers) do
        local xPlayer = xPlayers[i]
        if xPlayer.job.name == Config.Insurance.job.name then
            brokers = brokers + 1
        end
    end
    return brokers
end

-- Open Insurance Paper
RegisterServerEvent('t1ger_insurance:openInsurancePaperSV')
AddEventHandler('t1ger_insurance:openInsurancePaperSV', function(player, target, plate)
	local xPlayer = ESX.GetPlayerFromId(player)
	local xTarget = ESX.GetPlayerFromId(target)

	MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier}, function (user)
		if user[1] then
			MySQL.Async.fetchAll('SELECT * FROM '..Config.VehiclesTable..' WHERE owner = @identifier', {['@identifier'] = xPlayer.identifier}, function(results)
				if results then
					for k,v in pairs(results) do
						if plate == v.plate then
							local props = json.decode(v.vehicle)
							local ins_text = 'No'; if v.insurance then ins_text = 'Yes' end
							local info = { user = user, plate = v.plate, insurance = ins_text, hash = props.model }
							if v.model ~= nil then info.model = v.model end
							TriggerClientEvent('t1ger_insurance:openInsurancePaperCL', xTarget.source, info, plate)
							break
						end
					end
				else
					TriggerClientEvent('t1ger_carinsurance:ShowNotifyESX', xPlayer.source, Lang['plate_not_exists'])
				end
			end)
		end
	end)
end)

-- Open Insurance Paper
RegisterServerEvent('t1ger_carinsurance:openSV')
AddEventHandler('t1ger_carinsurance:openSV', function(player, target, plate)
	local identifier = ESX.GetPlayerFromId(player).identifier
	local _source 	 = ESX.GetPlayerFromId(target).source
	local vehFound   = false

	MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {['@identifier'] = identifier}, function (user)
		local vehPlate = nil
		local vehIns = 0
		local vehHash = nil
		if (user[1] ~= nil) then
			MySQL.Async.fetchAll('SELECT * FROM '..Config.OwnedVehicles..' WHERE owner=@identifier',{['@identifier'] = identifier}, function(vehData) 
				for k,v in pairs(vehData) do
					if plate == v.plate then
						local vehicle = json.decode(v.vehicle)
						vehHash = vehicle.model
						vehIns = v.insurance
						vehPlate = v.plate
						vehFound = true
					end
				end
				if vehFound then
					local label
					if vehIns == 0 then
						label = "No"
					elseif vehIns == 1 then
						label = "Yes"
					end
					local info = {
						user = user,
						carPlate = vehPlate,
						carIns = label,
						carHash = vehHash,
					}
					TriggerClientEvent('t1ger_carinsurance:openCL', _source, info, plate)
				else
					TriggerClientEvent('t1ger_carinsurance:ShowNotifyESX', _source, Lang['plate_not_exists'])
				end
			end)
		end
	end)
end)

