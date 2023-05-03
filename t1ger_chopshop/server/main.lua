-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function ()
    -- Check if mysql-async is started:
    while GetResourceState('mysql-async') ~= 'started' do
        Citizen.Wait(0)
    end
    while GetResourceState(GetCurrentResourceName()) ~= 'started' do 
        Citizen.Wait(0)
    end
    if GetResourceState(GetCurrentResourceName()) == 'started' then 
        InitializeChopShop()
    end
end)

local carList = {}
local scrap_cooldown = {}
local thief_cooldown = {}

-- Function to initialize the resource:
function InitializeChopShop()
	Citizen.Wait(1000)
	while true do
		local ready = false 
		local scrapList, ready = GenerateCarList()
		while not ready do Citizen.Wait(200) end
		TriggerClientEvent('t1ger_chopshop:intializeChopShop', -1, scrapList)
		Citizen.Wait(Config.ChopShop.Settings.newCarListTimer * 60000)
	end
end

-- Function to scramble & generate car list:
function GenerateCarList()
    carList = {}
    local scrambler = {}
    local totalCount = Config.ChopShop.Settings.carListAmount
    for i = 1, totalCount do 
        local val = math.random(1, #Config.ScrapVehicles)
        Citizen.Wait(1)
        math.randomseed(GetGameTimer())
        while scrambler[val] == val do
            val = math.random(1, #Config.ScrapVehicles)
        end
        scrambler[val] = val
        local car = Config.ScrapVehicles[val]
        table.insert(carList, {label = car.label, hash = car.hash, price = car.price})
    end
    return carList, true
end

-- Load CarList on playerLoaded
AddEventHandler('esx:playerLoaded', function(playerId)
	TriggerClientEvent('t1ger_chopshop:intializeChopShop', playerId, carList)
end)

-- Callback to check if vehicle is owned:
ESX.RegisterServerCallback('t1ger_chopshop:isVehicleOwned',function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate',{ ['@plate'] = plate}, function(result) 
        if result[1] then 
			cb(true)
        else
			cb(false)
        end

	end)
end)

-- Callback to get cops count:
ESX.RegisterServerCallback('t1ger_chopshop:getCopsCount',function(source, cb)
	local count = GetCopsCount()
	cb(count)
end)

-- Event to delete owned vehicle:
RegisterServerEvent('t1ger_chopshop:deleteOwnedVehicle')
AddEventHandler('t1ger_chopshop:deleteOwnedVehicle',function(plate)
    MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {['@plate'] = plate})
end)

-- Event for scrap vehicle payment:
RegisterServerEvent('t1ger_chopshop:getPayment')
AddEventHandler('t1ger_chopshop:getPayment',function(scrapCar, percent)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.ChopShop.Settings.scrap_rewards
	-- Money Reward:
	if cfg.cash.enable then
		local money = math.floor(scrapCar.price * (percent/100))
		if cfg.cash.dirty then xPlayer.addAccountMoney('black_money', money) else xPlayer.addMoney(money) end
		TriggerClientEvent('t1ger_chopshop:ShowNotifyESX',source, Lang['cash_reward']:format(money))
	end
	-- Item Reward:
	if cfg.items.enable then 
		local i = 0
		local maxItems = cfg.items.maxItems	
		for k,v in pairs(Config.Materials) do
			if i < maxItems then 
				math.randomseed(GetGameTimer())
				if math.random(0,100) <= v.chance then
					math.randomseed(GetGameTimer())
					local amount = math.random(v.amount.min,v.amount.max)
					xPlayer.addInventoryItem(v.item, amount)
					i = i + 1
				end
				Citizen.Wait(100)
			else
				break
			end
		end
	end
	-- cooldown:
	if Config.ChopShop.Settings.cooldown.scrap.enable then 
		TriggerEvent('t1ger_chopshop:addCooldown', xPlayer.source, 'scrap')
	end
end)

-- Server Event for selecting risk grade:
RegisterServerEvent('t1ger_chopshop:selectRiskGrade')
AddEventHandler('t1ger_chopshop:selectRiskGrade', function(label, grade, job_fees, cops, vehicles)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.ChopShop.Settings
	local money = 0
	if cfg.jobFeesDirty then money = xPlayer.getAccount('black_money').money else money = xPlayer.getMoney() end
	if money >= job_fees then
		local police = GetCopsCount()
		if police >= cops then
			if cfg.jobFeesDirty then xPlayer.removeAccountMoney('black_money', job_fees) else xPlayer.removeMoney(job_fees) end
			local num = math.random(1, #vehicles)
			local veh = vehicles[num]
			TriggerClientEvent('t1ger_chopshop:BrowseAvailableJobs', xPlayer.source, 0, grade, veh)
			TriggerClientEvent('t1ger_chopshop:ShowNotifyESX', xPlayer.source, ((Lang['paid_for_job']):format(job_fees, label)))
		else
			TriggerClientEvent('t1ger_chopshop:ShowNotifyESX', xPlayer.source, Lang['not_enough_police'])
		end
	else
		TriggerClientEvent('t1ger_chopshop:ShowNotifyESX', xPlayer.source, Lang['not_enough_money'])
	end
end)

-- Function to get cops count
function GetCopsCount()
	local cops = 0 
	local xPlayers = ESX.GetExtendedPlayers()
	local cops = 0
	for i=1, #(xPlayers) do 
		local xPlayer = xPlayers[i]
		for k,v in pairs(Config.ChopShop.Police.jobs) do
			if xPlayer['job']['name'] == v then cops = cops + 1 end
		end
	end
	return cops
end

-- Sync Config accross all players:
RegisterServerEvent('t1ger_chopshop:syncDataSV')
AddEventHandler('t1ger_chopshop:syncDataSV',function(data)
    TriggerClientEvent('t1ger_chopshop:syncDataCL', -1, data)
end)

-- Server Event for Job Reward:
RegisterServerEvent('t1ger_chopshop:JobCompleteSV')
AddEventHandler('t1ger_chopshop:JobCompleteSV',function(payout, percent)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.ChopShop.Settings.thiefjob
	-- Money Reward:
	local money =  math.floor(payout*(percent/100))
	if cfg.dirty then xPlayer.addAccountMoney('black_money', money) else xPlayer.addMoney(money) end
	-- Item Reward:
	if cfg.items.enable then 
		local i = 0
		local maxItems = cfg.items.maxItems	
		for k,v in pairs(Config.Materials) do
			if i < maxItems then 
				math.randomseed(GetGameTimer())
				if math.random(0,100) <= v.chance then
					math.randomseed(GetGameTimer())
					local amount = math.random(v.amount.min,v.amount.max)
					xPlayer.addInventoryItem(v.item, amount)
					i = i + 1
				end
				Citizen.Wait(100)
			else
				break
			end
		end
	end
	if Config.ChopShop.Settings.cooldown.thiefjob.enable then 
		TriggerEvent('t1ger_chopshop:addCooldown', xPlayer.source, 'thief')
	end
	TriggerClientEvent('t1ger_chopshop:ShowNotifyESX', xPlayer.source, ((Lang['reward_msg']):format(money)))
end)

-- Event to trigger police notifications:
RegisterServerEvent('t1ger_chopshop:PoliceNotifySV')
AddEventHandler('t1ger_chopshop:PoliceNotifySV', function(targetCoords, streetName)
	TriggerClientEvent('t1ger_chopshop:PoliceNotifyCL', -1, (Lang['police_notify']):format(streetName))
	TriggerClientEvent('t1ger_chopshop:PoliceNotifyBlip', -1, targetCoords)
end)

-- Thread for cooldown management:
Citizen.CreateThread(function() -- do not touch this thread function!
	while true do
	Citizen.Wait(1000)
		for k,v in pairs(scrap_cooldown) do
			if v.time <= 0 then
				ResetCooldown(v.identifier, 'scrap')
			else
				v.time = v.time - 1000
			end
		end
		for k,v in pairs(thief_cooldown) do
			if v.time <= 0 then
				ResetCooldown(v.identifier, 'thief')
			else
				v.time = v.time - 1000
			end
		end
	end
end)

-- Server event to add cooldown:
RegisterServerEvent('t1ger_chopshop:addCooldown')
AddEventHandler('t1ger_chopshop:addCooldown',function(source, type)
    local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.ChopShop.Settings.cooldown
	if type == 'thief' then 
		table.insert(thief_cooldown, {identifier = xPlayer.identifier, time = (cfg.thiefjob.time * 60000)})
	elseif type == 'scrap' then 
		table.insert(scrap_cooldown, {identifier = xPlayer.identifier, time = (cfg.scrap.time * 60000)})
	end
end)

-- Callback to get cooldown timer:
ESX.RegisterServerCallback('t1ger_chopshop:hasCooldown', function(source, cb, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not CheckCooldownTimer(xPlayer.identifier, type) then
		cb(false)
	else
		local msg = Lang['job_cooldown']; if type == 'scrap' then msg = Lang['scrap_cooldown'] end
		TriggerClientEvent('t1ger_chopshop:ShowNotifyESX', xPlayer.source, msg:format(GetCooldownTimer(xPlayer.identifier), type))
		cb(true)
	end
end)

-- Functions for Cooldown:
function ResetCooldown(source, type)
	if type == 'thief' then 
		for k,v in pairs(thief_cooldown) do
			if v.identifier == source then
				table.remove(thief_cooldown, k)
			end
		end
	elseif type == 'scrap' then
		for k,v in pairs(scrap_cooldown) do
			if v.identifier == source then
				table.remove(scrap_cooldown, k)
			end
		end
	end
end
function GetCooldownTimer(source, type)
	if type == 'thief' then 
		for k,v in pairs(thief_cooldown) do
			if v.identifier == source then
				return math.ceil(v.time/60000)
			end
		end
	elseif type == 'scrap' then
		for k,v in pairs(scrap_cooldown) do
			if v.identifier == source then
				return math.ceil(v.time/60000)
			end
		end
	end
end
function CheckCooldownTimer(source, type)
	if type == 'thief' then 
		for k,v in pairs(thief_cooldown) do
			if v.identifier == source then
				return true
			end
		end
		return false
	elseif type == 'scrap' then
		for k,v in pairs(scrap_cooldown) do
			if v.identifier == source then
				return true
			end
		end
		return false
	end
end
