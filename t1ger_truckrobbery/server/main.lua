-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

local jobCooldown = {} 

RegisterServerEvent('t1ger_truckrobbery:jobCooldown')
AddEventHandler('t1ger_truckrobbery:jobCooldown',function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	table.insert(jobCooldown,{cooldown = xPlayer.identifier, time = (Config.TruckRobbery.cooldown * 60000)}) -- cooldown timer for doing missions
end)

Citizen.CreateThread(function() -- do not touch this thread function!
	while true do
	Citizen.Wait(1000)
		for k,v in pairs(jobCooldown) do
			if v.time <= 0 then
				RemoveCooldownTimer(v.cooldown)
			else
				v.time = v.time - 1000
			end
		end
	end
end)

-- Callback to get cops count:
ESX.RegisterServerCallback('t1ger_truckrobbery:copCount',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetExtendedPlayers()
	local CopsOnline = 0
	for i=1, #(xPlayers) do
		local xPlayer = xPlayers[i]
		if xPlayer.job.name == 'police' then
			CopsOnline = CopsOnline + 1
		end
	end
	cb(CopsOnline)
end)

-- Callback to get cooldown:
ESX.RegisterServerCallback('t1ger_truckrobbery:getCooldown',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not CheckCooldownTimer(xPlayer.identifier) then
		cb(nil)
	else
		cb(GetCooldownTimer(xPlayer.identifier))
	end
end)

-- Callback to check if ply has job fees:
ESX.RegisterServerCallback('t1ger_truckrobbery:getJobFees',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local money = 0
	if Config.TruckRobbery.computer.fees.bankMoney then 
		money = xPlayer.getAccount('bank').money
	else
		money = xPlayer.getMoney()
	end
	if money >= Config.TruckRobbery.computer.fees.amount then
        cb(true)
    else
        cb(false)
    end
end)

-- server side function to accept the mission
RegisterServerEvent('t1ger_truckrobbery:startJobSV')
AddEventHandler('t1ger_truckrobbery:startJobSV', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('t1ger_truckrobbery:jobCooldown', source)
	if Config.TruckRobbery.computer.fees.bankMoney then 
		xPlayer.removeAccountMoney('bank', Config.TruckRobbery.computer.fees.amount)
	else
		xPlayer.removeMoney(Config.TruckRobbery.computer.fees.amount)
	end
	TriggerClientEvent('t1ger_truckrobbery:startJobCL', source)
end)

-- Event to trigger job reward:
RegisterServerEvent('t1ger_truckrobbery:jobReward')
AddEventHandler('t1ger_truckrobbery:jobReward',function()
	local cfg = Config.TruckRobbery.reward
	local xPlayer = ESX.GetPlayerFromId(source)
	local reward = math.random(cfg.money.min, cfg.money.max)
	
	if cfg.money.dirty then
		xPlayer.addAccountMoney('black_money', tonumber(reward))
	else
		xPlayer.addMoney(reward)
	end
	TriggerClientEvent('t1ger_truckrobbery:ShowNotifyESX', xPlayer.source, (Lang['reward_notify']:format(reward)))
	
	if cfg.items.enable then
		for k,v in pairs(cfg.items.list) do
			if math.random(0,100) <= v.chance then 
				local amount = math.random(v.min, v.max)
				local name = tostring(v.item)
				if Config.HasItemLabel then
					name = ESX.GetItemLabel(v.item)
				end
				xPlayer.addInventoryItem(v.item, amount)
				TriggerClientEvent('t1ger_truckrobbery:ShowNotifyESX', xPlayer.source, (Lang['you_received_item']:format(amount,name)))
			end
		end
	end
end)

-- Event to trigger police notifications:
RegisterServerEvent('t1ger_truckrobbery:PoliceNotifySV')
AddEventHandler('t1ger_truckrobbery:PoliceNotifySV', function(targetCoords, streetName)
	TriggerClientEvent('t1ger_truckrobbery:PoliceNotifyCL', -1, (Lang['police_notify']):format(streetName))
	TriggerClientEvent('t1ger_truckrobbery:PoliceNotifyBlip', -1, targetCoords)
end)

-- Event to update config.lua across all clients:
RegisterServerEvent('t1ger_truckrobbery:SyncDataSV')
AddEventHandler('t1ger_truckrobbery:SyncDataSV',function(data)
    TriggerClientEvent('t1ger_truckrobbery:SyncDataCL', -1, data)
end)

-- Do not touch these 3 functions:
function RemoveCooldownTimer(source)
    for k,v in pairs(jobCooldown) do
        if v.cooldown == source then
            table.remove(jobCooldown,k)
        end
    end
end
function GetCooldownTimer(source)
    for k,v in pairs(jobCooldown) do
        if v.cooldown == source then
            return math.ceil(v.time/60000)
        end
    end
end
function CheckCooldownTimer(source)
    for k,v in pairs(jobCooldown) do
        if v.cooldown == source then
            return true
        end
    end
    return false
end