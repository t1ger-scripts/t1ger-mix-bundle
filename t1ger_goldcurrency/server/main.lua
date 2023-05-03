-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
ESX = exports['es_extended']:getSharedObject()

local exchange_cooldown = {}
local job_cooldown = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    TriggerClientEvent('t1ger_goldcurrency:createNPC', -1, Config.JobNPC)
end)

AddEventHandler('esx:playerLoaded', function(playerId)
	TriggerClientEvent('t1ger_goldcurrency:createNPC', playerId, Config.JobNPC)
end)

-- thread for syncing the cooldown timer
Citizen.CreateThread(function() -- do not touch this thread function!
	while true do
	Citizen.Wait(1000)
        -- exhange cooldown:
		for k,v in pairs(exchange_cooldown) do
			if v.timeExchange <= 0 then
				RemoveExchangeCooldown(v.identifier)
			else
				v.timeExchange = v.timeExchange - 1000
			end
		end
        -- job cooldown:
		for k,v in pairs(job_cooldown) do
			if v.timeJob <= 0 then
				RemoveJobCooldown(v.identifier)
			else
				v.timeJob = v.timeJob - 1000
			end
		end
	end
end)

-- Add Job Cooldown
RegisterServerEvent('t1ger_goldcurrency:addJobCooldown')
AddEventHandler('t1ger_goldcurrency:addJobCooldown',function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
	table.insert(job_cooldown, {
        identifier = xPlayer.identifier,
        timeJob = ((Config.JobNPC.cooldown * 60000))
    })
end)

-- Check Job Cooldown:
ESX.RegisterServerCallback('t1ger_goldcurrency:getJobCooldown',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not GetJobCooldown(xPlayer.identifier) then
		cb(false)
	else
        TriggerClientEvent('t1ger_goldcurrency:ShowNotifyESX', xPlayer.source, (Lang['job_timer']):format(GetJobTimer(xPlayer.identifier)))
		cb(true)
	end
end)

-- Get Job Fees:
ESX.RegisterServerCallback('t1ger_goldcurrency:getJobFees', function(source, cb, fees)
    local xPlayer = ESX.GetPlayerFromId(source)
	local money = 0
	if fees.dirty then money = xPlayer.getAccount('black_money').money else money = xPlayer.getMoney() end
	if money >= fees.amount then cb(true) else cb(false) end
end)

-- Prepare Gold Job:
RegisterServerEvent('t1ger_goldcurrency:prepareJobSV')
AddEventHandler('t1ger_goldcurrency:prepareJobSV', function(id, fees, veh_model)
	local xPlayer = ESX.GetPlayerFromId(source)
	-- Job Fees:
    if fees.dirty then xPlayer.removeAccountMoney('black_money', fees.amount) else xPlayer.removeMoney(fees.amount) end
	-- Add player cooldown:
	TriggerEvent('t1ger_goldcurrency:addJobCooldown', xPlayer.source)
	-- Start the job:
	TriggerClientEvent('t1ger_goldcurrency:startTheGoldJob', source, id, veh_model)
end)

-- Update Config SV:
RegisterServerEvent('t1ger_goldcurrency:updateConfigSV')
AddEventHandler('t1ger_goldcurrency:updateConfigSV', function(data)
	TriggerClientEvent('t1ger_goldcurrency:updateConfigCL', -1, data)
end)

-- Event for police alerts
RegisterServerEvent('t1ger_goldcurrency:PoliceNotifySV')
AddEventHandler('t1ger_goldcurrency:PoliceNotifySV', function(targetCoords, streetName, label)
	TriggerClientEvent('t1ger_goldcurrency:PoliceNotifyCL', -1, (label):format(streetName))
	TriggerClientEvent('t1ger_goldcurrency:PoliceNotifyBlip', -1, targetCoords)
end)

-- Smelting Reward:
RegisterServerEvent('t1ger_goldcurrency:giveJobReward')
AddEventHandler('t1ger_goldcurrency:giveJobReward', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	for k,v in pairs(Config.JobReward) do 
		math.randomseed(GetGameTimer())
		local chance = math.random(0,100)
		if chance <= v.chance then
			Citizen.Wait(250)
			math.randomseed(GetGameTimer())
			local count = math.random(v.amount.min, v.amount.max)
			-- add item:
			local invItem = xPlayer.getInventoryItem(v.item)
			local arr = {canCarry = false, limit = 0}
			if Config.ItemWeightSystem then
				if xPlayer.canCarryItem(v.item, count) then
					arr.canCarry = true
					arr.limit = invItem.weight
				end
			else
				if invItem ~= -1 and (invItem.count + count) <= invItem.limit then
					arr.canCarry = true
					arr.limit = invItem.limit
				end
			end
			if arr.canCarry then 
				xPlayer.addInventoryItem(v.item, count)
				TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['items_added']):format(count, invItem.label))
			else
				TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['item_limit_exceed']):format(invItem.label, arr.limit))
			end
		end
		Citizen.Wait(250)
	end
end)

-- Get Inventory Item & Count:
ESX.RegisterServerCallback('t1ger_goldcurrency:checkCops',function(source, cb)
    local xPlayers = ESX.GetExtendedPlayers()
	PoliceOnline = 0
	for i=1, #(xPlayers) 1 do
		local xPlayer = xPlayers[i]
		for k,v in pairs(Config.PoliceSettings.jobs) do
			if xPlayer.job.name == v then
				PoliceOnline = PoliceOnline + 1
			end
		end
	end
    if PoliceOnline >= Config.PoliceSettings.requiredCops then 
        cb(true)
    else
        cb(false)
    end
end)

-- Get Inventory Item & Count:
ESX.RegisterServerCallback('t1ger_goldcurrency:getInventoryItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count >= amount then cb(true) else cb(false) end
end)

-- Remove x amount of item(s) from inventory:
ESX.RegisterServerCallback('t1ger_goldcurrency:removeItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count >= amount then
		xPlayer.removeInventoryItem(item, amount)
		cb(true)
	else
		cb(false)
	end
end)

-- Remove x amount of item(s) from inventory:
ESX.RegisterServerCallback('t1ger_goldcurrency:addItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
    local invItem = xPlayer.getInventoryItem(item)
    local arr = {canCarry = false, limit = 0}
	if Config.ItemWeightSystem then
		if xPlayer.canCarryItem(item, amount) then
			arr.canCarry = true
			arr.limit = invItem.weight
		end
	else
		if invItem ~= -1 and (invItem.count + amount) <= invItem.limit then
			arr.canCarry = true
			arr.limit = invItem.limit
		end
	end
	if arr.canCarry then 
		xPlayer.addInventoryItem(item, amount)
		TriggerClientEvent('t1ger_goldcurrency:ShowNotifyESX', xPlayer.source, (Lang['items_added']):format(amount, invItem.label))
        cb(true)
	else
		TriggerClientEvent('t1ger_goldcurrency:ShowNotifyESX', xPlayer.source, (Lang['item_limit_exceed']):format(invItem.label, arr.limit))
        cb(false)
	end
end)

-- Force Give Item:
RegisterServerEvent('t1ger_goldcurrency:giveItem')
AddEventHandler('t1ger_goldcurrency:giveItem', function(item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)

-- Exhange Reward:
RegisterServerEvent('t1ger_goldcurrency:giveExchangeReward')
AddEventHandler('t1ger_goldcurrency:giveExchangeReward', function(amount, dirty)
	local xPlayer = ESX.GetPlayerFromId(source)
    if dirty then
        xPlayer.addAccountMoney('black_money', amount)
    else
        xPlayer.addMoney(amount)
    end
    TriggerClientEvent('t1ger_goldcurrency:ShowNotifyESX', xPlayer.source, (Lang['money_received']):format(amount))
end)

RegisterServerEvent('t1ger_goldcurrency:addExchangeCooldown')
AddEventHandler('t1ger_goldcurrency:addExchangeCooldown',function()
    local xPlayer = ESX.GetPlayerFromId(source)
	table.insert(exchange_cooldown, {
        identifier = xPlayer.identifier,
        timeExchange = ((Config.ExchangeSettings.cooldown * 60000))
    })
end)

-- Check Exchange Cooldown:
ESX.RegisterServerCallback('t1ger_goldcurrency:getExchangeCooldown',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not GetExchangeCooldown(xPlayer.identifier) then
		cb(false)
	else
        TriggerClientEvent('t1ger_goldcurrency:ShowNotifyESX', xPlayer.source, (Lang['exchange_timer']):format(GetExchangeTimer(xPlayer.identifier)))
		cb(true)
	end
end)

-- DO NOT TOUCH!!
function RemoveExchangeCooldown(source)
	for k,v in pairs(exchange_cooldown) do
		if v.identifier == source then
			table.remove(exchange_cooldown, k)
		end
	end
end
function GetExchangeTimer(source)
	for k,v in pairs(exchange_cooldown) do
		if v.identifier == source then
			return math.ceil(v.timeExchange/60000)
		end
	end
end
function GetExchangeCooldown(source)
	for k,v in pairs(exchange_cooldown) do
		if v.identifier == source then
			return true
		end
	end
	return false
end
-- DO NOT TOUCH!!
function RemoveJobCooldown(source)
	for k,v in pairs(job_cooldown) do
		if v.identifier == source then
			table.remove(job_cooldown, k)
		end
	end
end
function GetJobTimer(source)
	for k,v in pairs(job_cooldown) do
		if v.identifier == source then
			return math.ceil(v.timeJob/60000)
		end
	end
end
function GetJobCooldown(source)
	for k,v in pairs(job_cooldown) do
		if v.identifier == source then
			return true
		end
	end
	return false
end