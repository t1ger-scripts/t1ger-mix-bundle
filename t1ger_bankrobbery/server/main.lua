-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function ()
    while GetResourceState('mysql-async') ~= 'started' do Citizen.Wait(0) end
    while GetResourceState(GetCurrentResourceName()) ~= 'started' do Citizen.Wait(0) end
    if GetResourceState(GetCurrentResourceName()) == 'started' then InitializeBankRobbey() end
end)

local online_cops = 0
local alertTime = 0

function InitializeBankRobbey()
	Citizen.Wait(1000)
	TriggerClientEvent('t1ger_bankrobbery:updateOnlineCops', -1, online_cops)
	RconPrint('T1GER Bank Robbery Initialized\n')
end

AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	while not xPlayer do Citizen.Wait(100) end
	TriggerClientEvent('t1ger_bankrobbery:updateOnlineCops', xPlayer.source, online_cops)
end)

-- Get Online Police Count:
Citizen.CreateThread(function()
    while true do
        online_cops = GetOnlinePoliceCount()
        TriggerClientEvent('t1ger_bankrobbery:updateOnlineCops', -1, online_cops)
        Citizen.Wait(Config.FetchJobs * 1000)
    end
end)

-- Update Pacific Config:
RegisterServerEvent('t1ger_bankrobbery:updateConfigSV')
AddEventHandler('t1ger_bankrobbery:updateConfigSV', function(id, data)
	Config.Banks[id] = data
	TriggerClientEvent('t1ger_bankrobbery:updateConfigCL', -1, id, Config.Banks[id])
end)

RegisterServerEvent('t1ger_bankrobbery:inUseSV')
AddEventHandler('t1ger_bankrobbery:inUseSV', function(id, state)
	Config.Banks[id].inUse = state
	TriggerClientEvent('t1ger_bankrobbery:inUseCL', -1, id, state)
end)

RegisterServerEvent('t1ger_bankrobbery:keypadHackedSV')
AddEventHandler('t1ger_bankrobbery:keypadHackedSV', function(id, num, state)
	Config.Banks[id].keypads[num].hacked = state
	TriggerClientEvent('t1ger_bankrobbery:keypadHackedCL', -1, id, num, state)
end)

RegisterServerEvent('t1ger_bankrobbery:doorFreezeSV')
AddEventHandler('t1ger_bankrobbery:doorFreezeSV', function(id, num, state)
	Config.Banks[id].doors[num].freeze = state
	TriggerClientEvent('t1ger_bankrobbery:doorFreezeCL', -1, id, num, state)
end)

RegisterServerEvent('t1ger_bankrobbery:safeRobbedSV')
AddEventHandler('t1ger_bankrobbery:safeRobbedSV', function(id, num, state)
	Config.Banks[id].safes[num].robbed = state
	TriggerClientEvent('t1ger_bankrobbery:safeRobbedCL', -1, id, num, state)
end)

RegisterServerEvent('t1ger_bankrobbery:safeFailedSV')
AddEventHandler('t1ger_bankrobbery:safeFailedSV', function(id, num, state)
	Config.Banks[id].safes[num].failed = state
	TriggerClientEvent('t1ger_bankrobbery:safeFailedCL', -1, id, num, state)
end)

RegisterServerEvent('t1ger_bankrobbery:powerBoxDisabledSV')
AddEventHandler('t1ger_bankrobbery:powerBoxDisabledSV', function(id, state)
	Config.Banks[id].powerBox.disabled = state
	TriggerClientEvent('t1ger_bankrobbery:powerBoxDisabledCL', -1, id, state)
end)

RegisterServerEvent('t1ger_bankrobbery:pettyCashRobbedSV')
AddEventHandler('t1ger_bankrobbery:pettyCashRobbedSV', function(id, num, state)
    Config.Banks[id].pettyCash[num].robbed = state
	TriggerClientEvent('t1ger_bankrobbery:pettyCashRobbedCL', -1, id, num, state)
end)

RegisterServerEvent('t1ger_bankrobbery:safeCrackedSV')
AddEventHandler('t1ger_bankrobbery:safeCrackedSV', function(id, state)
	Config.Banks[id].crackSafe.cracked = state
	TriggerClientEvent('t1ger_bankrobbery:safeCrackedCL', -1, id, state)
end)

-- Open Vault Door:
RegisterServerEvent('t1ger_bankrobbery:openVaultSV')
AddEventHandler('t1ger_bankrobbery:openVaultSV', function(open, id)
	TriggerClientEvent('t1ger_bankrobbery:openVaultCL', -1, open, id)
end)

-- Sync Vault Doors:
RegisterServerEvent('t1ger_bankrobbery:setHeadingSV')
AddEventHandler('t1ger_bankrobbery:setHeadingSV', function(id, type, heading)
	Config.Banks[id].doors[type].setHeading = heading
	TriggerClientEvent('t1ger_bankrobbery:setHeadingCL', -1, id, type, heading)
end)

-- Event to apply particle FX:
RegisterServerEvent('t1ger_bankrobbery:particleFxSV')
AddEventHandler('t1ger_bankrobbery:particleFxSV', function(pos, dict, lib)
	TriggerClientEvent('t1ger_bankrobbery:particleFxCL', -1, pos, dict, lib)
end)

-- Event to swap models:
RegisterServerEvent('t1ger_bankrobbery:modelSwapSV')
AddEventHandler('t1ger_bankrobbery:modelSwapSV', function(pos, radius, old_model, new_model)
	TriggerClientEvent('t1ger_bankrobbery:modelSwapCL', -1, pos, radius, old_model, new_model)
end)

-- Callback to get inventory item:
ESX.RegisterServerCallback('t1ger_bankrobbery:getInventoryItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local invItem = xPlayer.getInventoryItem(item)
	if invItem ~= nil then
		if invItem.count >= amount then
			cb(true, invItem)
		else
			cb(false, invItem)
		end 
	else
		return print("^1[ITEM ERROR] - ["..string.upper(item).."] DOES NOT EXIST IN DATABASE!^0")
	end
end)

-- Event to remove inventory item:
RegisterServerEvent('t1ger_bankrobbery:removeItem')
AddEventHandler('t1ger_bankrobbery:removeItem', function(item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, count)
end)

-- Event to give safe rewards:
RegisterServerEvent('t1ger_bankrobbery:safeReward')
AddEventHandler('t1ger_bankrobbery:safeReward', function(id, num)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.Banks[id].safes[num]
	-- Money:
	math.randomseed(GetGameTimer())
	local amount = math.random(cfg.cash.min, cfg.cash.max)
	if cfg.cash.enable then
		if Config.CashInDirty then
			xPlayer.addAccountMoney('black_money', amount)
		else
			xPlayer.addMoney(amount)
		end
		TriggerClientEvent('t1ger_bankrobbery:notify', xPlayer.source, Lang['cash_reward']:format(amount))
	end
	-- Items:
	math.randomseed(GetGameTimer())
	for k,v in pairs(cfg.items) do
		if math.random(0,100) <= v.chance then
			local invItem = xPlayer.getInventoryItem(v.name)
			if invItem ~= nil then
				math.randomseed(GetGameTimer())
				local amount = math.random(v.amount.min,v.amount.max)
				xPlayer.addInventoryItem(invItem.name, amount)
				TriggerClientEvent('t1ger_bankrobbery:notify', xPlayer.source, Lang['item_reward']:format(amount, invItem.label))
			else
				print("^1[ITEM ERROR] - ["..string.upper(item).."] DOES NOT EXIST IN DATABASE!^0")
			end
		end
		Citizen.Wait(10)
	end
end)

-- Event to give crack safe rewards:
RegisterServerEvent('t1ger_bankrobbery:crackSafeReward')
AddEventHandler('t1ger_bankrobbery:crackSafeReward', function(id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.Banks[id].crackSafe.reward
	-- Money:
	math.randomseed(GetGameTimer())
	local amount = math.random(cfg.cash.min, cfg.cash.max)
	if cfg.cash.enable then
		if Config.CashInDirty then
			xPlayer.addAccountMoney('black_money', amount)
		else
			xPlayer.addMoney(amount)
		end
		TriggerClientEvent('t1ger_bankrobbery:notify', xPlayer.source, Lang['cash_reward']:format(amount))
	end
	-- Items:
	math.randomseed(GetGameTimer())
	for k,v in pairs(cfg.items) do
		if math.random(0,100) <= v.chance then
			local invItem = xPlayer.getInventoryItem(v.name)
			if invItem ~= nil then
				math.randomseed(GetGameTimer())
				local amount = math.random(v.amount.min,v.amount.max)
				xPlayer.addInventoryItem(invItem.name, amount)
				TriggerClientEvent('t1ger_bankrobbery:notify', xPlayer.source, Lang['item_reward']:format(amount, invItem.label))
			else
				print("^1[ITEM ERROR] - ["..string.upper(item).."] DOES NOT EXIST IN DATABASE!^0")
			end
		end
		Citizen.Wait(10)
	end
end)

-- Event to give petty cash rewards:
RegisterServerEvent('t1ger_bankrobbery:pettyCashReward')
AddEventHandler('t1ger_bankrobbery:pettyCashReward', function(id, num)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cfg = Config.Banks[id].pettyCash[num].reward
	-- Money:
	math.randomseed(GetGameTimer())
	local amount = math.random(cfg.min, cfg.max)
	if cfg.dirty then
		xPlayer.addAccountMoney('black_money', amount)
	else
		xPlayer.addMoney(amount)
	end
	TriggerClientEvent('t1ger_bankrobbery:notify', xPlayer.source, Lang['cash_reward']:format(amount))
end)

-- Event to sync powerbox:
RegisterServerEvent('t1ger_bankrobbery:syncPowerBoxSV')
AddEventHandler('t1ger_bankrobbery:syncPowerBoxSV', function(timer)
	local xPlayer = ESX.GetPlayerFromId(source)
	alertTime = timer
	TriggerClientEvent('t1ger_bankrobbery:syncPowerBoxCL', -1, alertTime)
end)

-- Event to send police alert
RegisterServerEvent('t1ger_bankrobbery:sendPoliceAlertSV')
AddEventHandler('t1ger_bankrobbery:sendPoliceAlertSV', function(coords, msg)
	TriggerClientEvent('t1ger_bankrobbery:sendPoliceAlertCL', -1, coords, msg)
end)

-- Event to reset bank robbery:
RegisterServerEvent('t1ger_bankrobbery:ResetCurrentBankSV')
AddEventHandler('t1ger_bankrobbery:ResetCurrentBankSV', function(id)
	Config.Banks[id].inUse = false
	for k,v in pairs(Config.Banks[id].keypads) do
		v.hacked = false
	end
	for k,v in pairs(Config.Banks[id].doors) do
		v.freeze = true
		v.setHeading = v.heading
		if k == 'cell' or k == 'cell2' then
			TriggerClientEvent('t1ger_bankrobbery:modelSwapCL', -1, v.pos, 5.0, GetHashKey('hei_v_ilev_bk_safegate_molten'), v.model)
		end
	end
	for i = 1, #Config.Banks[id].safes do
		Config.Banks[id].safes[i].robbed = false
		Config.Banks[id].safes[i].failed = false
	end
	for k,v in pairs(Config.Banks[id].pettyCash) do
		Config.Banks[id].pettyCash[k].robbed = false
	end
	Config.Banks[id].powerBox.disabled = false
	if Config.Banks[id].crackSafe ~= nil then
		Config.Banks[id].crackSafe.cracked = false
	end
	alertTime = 0
	Wait(100)
	TriggerClientEvent('t1ger_bankrobbery:updateConfigCL', -1, id, Config.Banks[id])
	-- Secure News:
	local xPlayers = ESX.GetExtendedPlayers()
	for i=1, #(xPlayers) do 
		local xPlayer = xPlayers[i]
		for k,v in pairs(Config.PoliceJobs) do
			if xPlayer.job.name == v then
				TriggerClientEvent('chatMessage', xPlayers[i], "^2News: | ^7", { 128, 128, 128 }, string.sub('The bank has been secured. All banks are now open again!',0))
			end
		end
	end
end)


-- Function to Get Online Police:
function GetOnlinePoliceCount()
	local xPlayers = ESX.GetExtendedPlayers()
	local count = 0
	for i=1, #(xPlayers) do 
		local xPlayer = xPlayers[i]
        for k,v in pairs(Config.PoliceJobs) do
            if xPlayer.job.name == v then
				count = count + 1
				break
            end
        end
    end
    return count
end



