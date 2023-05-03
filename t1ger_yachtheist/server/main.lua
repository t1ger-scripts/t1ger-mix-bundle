-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

local cooldown = {active = false, duration = (Config.CooldownTimer * 60000), timer = 0}

-- Police Notify
RegisterServerEvent('t1ger_yachtheist:PoliceNotifySV')
AddEventHandler('t1ger_yachtheist:PoliceNotifySV', function(type)
    if type == "alert" then 
        TriggerClientEvent('t1ger_yachtheist:PoliceNotifyCL', -1, Lang['police_notify'])
    elseif type == "secure" then 
        TriggerClientEvent('t1ger_yachtheist:PoliceNotifyCL', -1, Lang['police_notify_2'])
    end
end)

-- Remove x amount of item(s) from inventory:
ESX.RegisterServerCallback('t1ger_yachtheist:removeItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count >= amount then
		xPlayer.removeInventoryItem(item, amount)
		cb(true)
	else
		cb(false)
	end
end)

-- Check Item in Inventory:
ESX.RegisterServerCallback('t1ger_yachtheist:getItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count >= amount then
		cb(true)
	else
		cb(false)
	end
end)

-- Event to update safe state:
RegisterServerEvent('t1ger_yachtheist:SafeDataSV')
AddEventHandler('t1ger_yachtheist:SafeDataSV', function(type, id, state)
    local xPlayer = ESX.GetPlayerFromId(source)
    if type == "robbed" then
        Config.Safes[id].robbed = state
    elseif type == "failed" then
        Config.Safes[id].failed = state
    end
    TriggerClientEvent('t1ger_yachtheist:SafeDataCL', -1, type, id, state)
end)

-- Vault Reward:
RegisterServerEvent('t1ger_yachtheist:vaultReward')
AddEventHandler('t1ger_yachtheist:vaultReward', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.VaultRewards
	-- Chance to keep drill:
	math.randomseed(GetGameTimer())
	if math.random(0,100) <= Config.ChanceToKeepDrill then 
		xPlayer.addInventoryItem(Config.DatabaseItems['drill'], 1)
	end
	-- Money:
	local amount = ((math.random(cfg.money.min, cfg.money.max)) * 1000)
	if cfg.money.dirtyCash then xPlayer.addAccountMoney('black_money', amount) else xPlayer.addMoney(amount) end
	-- items:
	for k,v in pairs(cfg.items) do
		local invItem = xPlayer.getInventoryItem(v.item)
		math.randomseed(GetGameTimer())
		if math.random(0,100) <= v.chance then
			Citizen.Wait(250)
			math.randomseed(GetGameTimer())
			local amount = math.random(v.min, v.max)
			xPlayer.addInventoryItem(v.item, amount)
			TriggerClientEvent('t1ger_yachtheist:ShowNotifyESX', xPlayer.source, (Lang['safe_item_reward']:format(amount, invItem.label)))
		end
		Citizen.Wait(250)
	end
end)

-- Add Grabbed Cash:
ESX.RegisterServerCallback('t1ger_yachtheist:addGrabbedCash',function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.VaultRewards.trolley
	math.randomseed(GetGameTimer())
    local amount = (math.random(cfg.min, cfg.max))
	if cfg.dirtyCash then xPlayer.addAccountMoney('black_money', amount) else xPlayer.addMoney(amount) end
    cb(amount)
end)

-- Check Police:
ESX.RegisterServerCallback('t1ger_yachtheist:checkPolice',function(source, cb)
    local xPlayers = ESX.GetExtendedPlayers()
	PoliceOnline = 0
	for i=1, #(xPlayers) do
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

-- Force Give Item:
RegisterServerEvent('t1ger_yachtheist:giveItem')
AddEventHandler('t1ger_yachtheist:giveItem', function(item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)

RegisterServerEvent('t1ger_yachtheist:resetHeistSV')
AddEventHandler('t1ger_yachtheist:resetHeistSV', function()
    local xPlayer = ESX.GetPlayerFromId(source)

	Config.Yacht.terminal.activated = false
	Config.Yacht.keypad.hacked = false
	Config.Yacht.trolley.grabbing = false
	Config.Yacht.trolley.taken = false

	for i = 1, #Config.Safes do 
		Config.Safes[i].robbed = false
		Config.Safes[i].failed = false
	end

	-- enable cooldown:
	Config.Yacht.cooldown = true
	cooldown.active = true
	cooldown.timer = cooldown.duration

	Wait(400)
    TriggerClientEvent('t1ger_yachtheist:resetHeistCL', -1)
end)

-- Force Delete Object:
RegisterServerEvent('t1ger_yachtheist:forceDeleteSV')
AddEventHandler('t1ger_yachtheist:forceDeleteSV', function(ObjNet)
    TriggerClientEvent('t1ger_yachtheist:forceDeleteCL', -1, ObjNet)
end)

-- Update Config SV:
RegisterServerEvent('t1ger_yachtheist:updateConfigSV')
AddEventHandler('t1ger_yachtheist:updateConfigSV', function(data)
	TriggerClientEvent('t1ger_yachtheist:updateConfigCL', -1, data)
end)

-- thread for syncing the cooldown timer
Citizen.CreateThread(function() -- do not touch this thread function!
	while true do
		Citizen.Wait(1000)
		if cooldown.active then 
			if cooldown.timer <= 0 then
				Config.Yacht.cooldown = false
				cooldown.active = false 
			else
				cooldown.timer = cooldown.timer - 1000
			end
		else
			Citizen.Wait(5000)
		end
	end
end)
