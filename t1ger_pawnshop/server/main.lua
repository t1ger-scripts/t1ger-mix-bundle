-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

-- Server Event for Buying:
RegisterServerEvent('t1ger_pawnshop:buyItem')
AddEventHandler('t1ger_pawnshop:buyItem', function(amount, total_price, item, label)
	local xPlayer = ESX.GetPlayerFromId(source)
	local money = 0
	if Config.BuyWithCash then money = xPlayer.getMoney() else money = xPlayer.getAccount('bank').money end
	if money >= total_price then
		-- weight/limit check
		local arr = {canCarry = false, limit = 0}
		local invItem = xPlayer.getInventoryItem(item)
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
		-- 
		if arr.canCarry then 
			if Config.BuyWithCash then xPlayer.removeMoney(total_price) else xPlayer.removeAccountMoney('bank', total_price) end
			xPlayer.addInventoryItem(item, amount)
			TriggerClientEvent('t1ger_pawnshop:ShowNotifyESX', xPlayer.source, (Lang['item_bought']):format(amount, label, total_price))
		else
			TriggerClientEvent('t1ger_pawnshop:ShowNotifyESX', xPlayer.source, (Lang['item_limit_exceed']):format(label, arr.limit))
		end
	else
		TriggerClientEvent('t1ger_pawnshop:ShowNotifyESX', xPlayer.source, Lang['not_enough_money'])
	end
end)

-- Server Event for Selling:
RegisterServerEvent('t1ger_pawnshop:sellItem')
AddEventHandler('t1ger_pawnshop:sellItem', function(amount, total_price, item, label)
	local xPlayer = ESX.GetPlayerFromId(source)
	local invItem = xPlayer.getInventoryItem(item)
	if invItem.count >= amount then
		xPlayer.removeInventoryItem(item, amount)
		if Config.ReceiveCash then 
			xPlayer.addMoney(total_price)
		else
			xPlayer.addAccountMoney('bank', total_price)
		end
		TriggerClientEvent('t1ger_pawnshop:ShowNotifyESX', xPlayer.source, (Lang['item_sold']):format(amount, label, total_price))
	else
		TriggerClientEvent('t1ger_pawnshop:ShowNotifyESX', xPlayer.source, Lang['not_enough_items'])
	end
end)
