-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

-- Get Inventory Item & Count:
ESX.RegisterServerCallback('t1ger_minerjob:getInventoryItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count >= amount then cb(true) else cb(false) end
end)

-- Remove x amount of item(s) from inventory:
ESX.RegisterServerCallback('t1ger_minerjob:removeItem',function(source, cb, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count >= amount then
		xPlayer.removeInventoryItem(item, amount)
		cb(true)
	else
		cb(false)
	end
end)

-- Mine Spot State:
RegisterServerEvent('t1ger_minerjob:mineSpotStateSV')
AddEventHandler('t1ger_minerjob:mineSpotStateSV', function(id, state)
	Config.Mining[id].inUse = state
    TriggerClientEvent('t1ger_minerjob:mineSpotStateCL', -1, id, state)
end)

-- Mining Reward:
RegisterServerEvent('t1ger_minerjob:miningReward')
AddEventHandler('t1ger_minerjob:miningReward', function(item, amount)
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
		TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['stone_mined']):format(amount, invItem.label))
	else
		TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['item_limit_exceed']):format(invItem.label, arr.limit))
	end
end)

-- Washing Reward:
RegisterServerEvent('t1ger_minerjob:washingReward')
AddEventHandler('t1ger_minerjob:washingReward', function(item, amount)
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
		TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['stone_washed']):format(amount, invItem.label))
	else
		TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['item_limit_exceed']):format(invItem.label, arr.limit))
	end
end)

-- Smelting Reward:
RegisterServerEvent('t1ger_minerjob:smeltingReward')
AddEventHandler('t1ger_minerjob:smeltingReward', function(table)
	local xPlayer = ESX.GetPlayerFromId(source)

	for k,v in pairs(Config.SmeltingSettings.reward) do 
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
				TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['smelt_reward']):format(count, invItem.label))
			else
				TriggerClientEvent('t1ger_minerjob:ShowNotifyESX', xPlayer.source, (Lang['item_limit_exceed']):format(invItem.label, arr.limit))
			end
		end
		Citizen.Wait(250)
	end
end)