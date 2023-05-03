-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function ()
    while GetResourceState('mysql-async') ~= 'started' do Citizen.Wait(0) end
    while GetResourceState(GetCurrentResourceName()) ~= 'started' do Citizen.Wait(0) end
    if GetResourceState(GetCurrentResourceName()) == 'started' then InitializeShops() end
end)

local jobGrades = {
	[1] = { name = 'apprentice', label = 'Apprentice', salary = 100},
	[2] = { name = 'clerk', label = 'Clerk', salary = 200},
	[3] = { name = 'boss', label = 'Owner', salary = 300},
}

Citizen.CreateThread(function()
    for k,v in pairs(Config.Society) do
		MySQL.Async.fetchAll("SELECT * FROM jobs WHERE name = @name", {['@name'] = v.name}, function(results)
			if not results[1] then 
				-- addon account:
				MySQL.Async.execute('INSERT IGNORE INTO addon_account (name, label, shared) VALUES (@name, @label, @shared)', { ['name'] = v.account, ['label'] = v.label, ['shared'] = 1 } )
				-- addon account data:
				MySQL.Async.execute('INSERT IGNORE INTO addon_account_data (account_name, money) VALUES (@account_name, @money)', { ['account_name'] = v.account, ['money'] = 0 } )
				-- jobs:
				MySQL.Async.execute('INSERT IGNORE INTO jobs (name, label) VALUES (@name, @label)', { ['name'] = v.name, ['label'] = v.label } )
				-- job grades:
				for i = 0, 2, 1 do
					MySQL.Async.execute('INSERT IGNORE INTO job_grades (job_name, grade, name, label, salary) VALUES (@job_name, @grade, @name, @label, @salary)', {
						['job_name'] = v.name,
						['grade'] = i,
						['name'] = jobGrades[i+1].name,
						['label'] = jobGrades[i+1].label,
						['salary'] = jobGrades[i+1].salary
					})
				end
				print("Job: "..v.name.." added to database, please restart server to load ESX.Jobs")
			end
		end)
        TriggerEvent('esx_society:registerSociety', v.name, v.label, v.account, v.datastore, v.inventory, v.data)
    end
end)

local shops = {}
function InitializeShops()
	Citizen.Wait(1000)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_shops', {}, function(results)
		if next(results) then
			for i = 1, #results do
				local data = {
					identifier = results[i].identifier,
					id = results[i].id,
					stock = nil or json.decode(results[i].stock),
					shelves = nil or json.decode(results[i].shelves)
				}
				shops[results[i].id] = data
				Config.Shops[results[i].id].owned = true
				Config.Shops[results[i].id].data = data
				Citizen.Wait(5)
			end
		end
	end)
	RconPrint('T1GER Shops Initialized\n')
end

AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	while not xPlayer do Citizen.Wait(100) end
    LoadShops(xPlayer.source)
end)

RegisterServerEvent('t1ger_shops:debugSV')
AddEventHandler('t1ger_shops:debugSV', function()
    LoadShops(source)
end)

function LoadShops(src)
    local xPlayer = ESX.GetPlayerFromId(src)
	while not xPlayer do Citizen.Wait(100) end
    local isOwner, shopID = 0, 0
    if next(shops) then 
        for k,v in pairs(shops) do
            if xPlayer.identifier == v.identifier then
                isOwner = v.id
            end 
            local currentJob = xPlayer.getJob()
            if currentJob.name == Config.Society[Config.Shops[v.id].society].name then
                shopID = v.id
            end
        end
    end
	TriggerClientEvent('t1ger_shops:loadShops', xPlayer.source, shops, Config.Shops, isOwner, shopID)
end

-- Callback to check money & purchase shop:
ESX.RegisterServerCallback('t1ger_shops:purchaseShop',function(source, cb, id, val)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = 0
    if Config.BuyShopWithBank then money = xPlayer.getAccount('bank').money else money = xPlayer.getMoney() end
	if money >= val.price then
		if Config.BuyShopWithBank then xPlayer.removeAccountMoney('bank', val.price) else xPlayer.removeMoney(val.price) end
        local employees, stock, shelves = {}, {}, {}
        MySQL.Async.execute('INSERT INTO t1ger_shops (identifier, id, stock, shelves) VALUES (@identifier, @id, @stock, @shelves)', {
            ['identifier'] = xPlayer.identifier,
            ['id'] = id,
            ['stock'] = json.encode(stock),
            ['shelves'] = json.encode(shelves),
        })
		xPlayer.setJob(Config.Society[val.society].name, Config.Society[val.society].boss_grade)
        cb(true)
    else
        cb(false)
    end
end)

-- Event to sell shop:
RegisterServerEvent('t1ger_shops:sellShop')
AddEventHandler('t1ger_shops:sellShop', function(id, val, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE FROM t1ger_shops WHERE id = @id', {['@id'] = id}) 
    if Config.BuyShopWithBank then xPlayer.addAccountMoney('bank', amount) else xPlayer.addMoney(amount) end
	xPlayer.setJob('unemployed', 0)
end)

-- Update & Sync Shops:
RegisterServerEvent('t1ger_shops:updateShops')
AddEventHandler('t1ger_shops:updateShops', function(num, val, state)
	local xPlayer = ESX.GetPlayerFromId(source)
	local data = nil
	if state == true then
		local d1, d2 = json.decode('[]'), json.decode('[]')
		data = {identifier = xPlayer.identifier, id = num, stock = d1, shelves = d2}
		shops[num] = data
	else
		shops[num] = nil
	end
	Config.Shops[num].owned = state
	Config.Shops[num].data = data
	TriggerClientEvent('t1ger_shops:syncShops', -1, shops, Config.Shops)
end)

-- Get player money:
ESX.RegisterServerCallback('t1ger_shops:getPlayerMoney',function(source, cb, price, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = 0
    if type == 'button_cash' then money = xPlayer.getMoney() elseif type == 'button_card' then money = xPlayer.getAccount('bank').money end
    if price < 0 then
		print('t1ger_shops: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
		return
    end
	if money >= price then cb(true) else cb(false) end
end)

-- Get player inventory limit:
ESX.RegisterServerCallback('t1ger_shops:getPlayerInvLimit',function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local limitExceed, DataFetched = false, false
	if #data > 0 then 
		for k,v in pairs(data) do
            local invItem = xPlayer.getInventoryItem(v.item)
			if invItem ~= nil then 
                if v.str_match == nil then 
					if Config.ItemWeightSystem == true then
						if not xPlayer.canCarryItem(v.item, v.count) then 
							limitExceed = true
							TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_limit_exceed']:format(v.label,invItem.weight))
						end
					else
						if (invItem.count + v.count) > invItem.limit then
							limitExceed = true
							TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_limit_exceed']:format(v.label,invItem.limit))
						end
					end
				end
			else
				return print('ITEM '..data.item..' DOES NOT EXIST IN DATABASE')
			end
            if k == #data then
				DataFetched = true
			end
		end
	else
        local invItem = xPlayer.getInventoryItem(data.item)
		if invItem ~= nil then 
			if Config.ItemWeightSystem == true then
				if not xPlayer.canCarryItem(data.item, data.value) then 
					TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_limit_exceed']:format(data.name,invItem.weight))
					limitExceed = true
				end
			else
				if (invItem.count + data.value) > invItem.limit then
					TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_limit_exceed']:format(data.name,invItem.limit))
					limitExceed = true
				end
			end
			DataFetched = true
		else
			return print('ITEM '..data.item..' DOES NOT EXIST IN DATABASE')
		end
	end
    while not DataFetched do
		Citizen.Wait(10)
	end
	if limitExceed then 
		cb(true) 
	else 
		cb(false) 
	end
end)

-- function to purchase selected item:
RegisterServerEvent('t1ger_shops:purchaseItem')
AddEventHandler('t1ger_shops:purchaseItem', function(item, price, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if type == 'button_cash' then xPlayer.removeMoney(price) elseif type == 'button_card' then xPlayer.removeAccountMoney('bank', price) end
    xPlayer.addInventoryItem(item.item, item.value)
    TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_purchased']:format(item.value,item.name,price))
end)


-- function to purchase basket items:
RegisterServerEvent('t1ger_shops:checkoutBasket')
AddEventHandler('t1ger_shops:checkoutBasket', function(basket, type, id)
    local xPlayer = ESX.GetPlayerFromId(source)
	-- Remove Money:
    if type == 'button_cash' then xPlayer.removeMoney(basket.bill) elseif type == 'button_card' then xPlayer.removeAccountMoney('bank', basket.bill) end
	-- Add Items / Weapons:
    for k,v in pairs(basket.items) do 
        if v.str_match ~= nil then
            if v.str_match == "weapon" then
                xPlayer.addWeapon(v.item, v.count)
            elseif v.str_match == "ammo" then
                TriggerClientEvent('t1ger_shops:addAmmoClient', xPlayer.source, v.weapon, v.count)
            end
        else
            xPlayer.addInventoryItem(v.item, v.count)
        end
    end
	-- Update Shop Stock:
	if next(shops[id].stock) then
		for k,v in pairs(shops[id].stock) do
			if v.qty == 0 or v.qty <= 0 then
				table.remove(shops[id].stock, k)
			end
		end
	end
	-- Update Society Account:
	TriggerEvent('esx_addonaccount:getSharedAccount', Config.Society[Config.Shops[id].society].account, function(account)
		account.addMoney(basket.bill)
	end)
	-- Sync to Database and Clients:
	MySQL.Async.execute("UPDATE t1ger_shops SET stock = @stock WHERE id = @id", { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
	Config.Shops[id].data = shops[id]
	TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
    TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['basket_paid']:format(basket.bill))
end)

-- Empty Shop Basket:
RegisterServerEvent('t1ger_shops:emptyShopBasket')
AddEventHandler('t1ger_shops:emptyShopBasket', function(id, shopBasket)
    local LoopDone = false
	if next(shops[id].stock) then 
		for k,v in pairs(shops[id].stock) do 
			for _,y in pairs(shopBasket) do 
				if y.item == v.item then
					v.qty = (v.qty + y.count)
				end
			end
			if k == #shops[id].stock then 
				LoopDone = true
			end
		end
		while not LoopDone do 
			Citizen.Wait(10)
		end
		-- Update Database:
		MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
		-- Sync:
		Config.Shops[id].data = shops[id]
		TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
	end
end)

-- Remove Item from Shop Basket:
RegisterServerEvent('t1ger_shops:removeBasketItem')
AddEventHandler('t1ger_shops:removeBasketItem', function(id, item)
	if next(shops[id].stock) then 
		for k,v in pairs(shops[id].stock) do 
			if item.item == v.item then 
				v.qty = (v.qty + item.count)
				-- Update Database:
				MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
				-- Sync:
				Config.Shops[id].data = shops[id]
				TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
				break
			end
		end
	end
end)

-- Update shelves (add / remove):
RegisterServerEvent('t1ger_shops:updateShelves')
AddEventHandler('t1ger_shops:updateShelves', function(id, data, addBoolean)
    local xPlayer = ESX.GetPlayerFromId(source)
	if next(shops[id].shelves) then 
		if addBoolean then 
			table.insert(shops[id].shelves, data)
		else
			for k,v in pairs(shops[id].shelves) do
				if data.type == v.type and data.drawText == v.drawText then
					table.remove(shops[id].shelves, k)
				end
			end
		end
	else
		table.insert(shops[id].shelves, data)
	end

    -- Update Database:
    MySQL.Async.execute('UPDATE t1ger_shops SET shelves = @shelves WHERE id = @id', { ['@shelves'] = json.encode(shops[id].shelves), ['@id'] = id })
	-- Sync:
	Config.Shops[id].data = shops[id]
	TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
end)

-- Fetch shelves from ply shop:
ESX.RegisterServerCallback('t1ger_shops:fetchShelves',function(source, cb, id)
	cb(shops[id].shelves)
end)


-- Get User Inventory:
ESX.RegisterServerCallback('t1ger_shops:getUserInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventoryItems = xPlayer.inventory
    cb(inventoryItems)
end)

ESX.RegisterServerCallback('t1ger_shops:doesItemExists', function(source, cb, id, item, shelf_type)
    local xPlayer = ESX.GetPlayerFromId(source)
	if next(shops[id].stock) then
		for k,v in pairs(shops[id].stock) do
			if item == v.item then
				cb(true)
				break
			end
			if k == #shops[id].stock then 
				cb(false)
			end
		end
	else
		cb(nil)
	end
end)

-- Fetch Shelf Item Stock:
ESX.RegisterServerCallback('t1ger_shops:getItemStock', function(source, cb, id)
    cb(shops[id].stock)
end)

-- Update item price in shelf:
RegisterServerEvent('t1ger_shops:updateItemPrice')
AddEventHandler('t1ger_shops:updateItemPrice', function(id, shelf, item, price)
	if next(shops[id].stock) then 
		for k,v in pairs(shops[id].stock) do 
			if item == v.item and shelf == v.type then
				v.price = price
				-- Update Database:
				MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
				-- Sync:
				Config.Shops[id].data = shops[id]
				TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
				break
			end
		end
	end
end)

-- Restock items in shelf:
RegisterServerEvent('t1ger_shops:itemDeposit')
AddEventHandler('t1ger_shops:itemDeposit', function(item, amount, price, id, shelf)
    local xPlayer = ESX.GetPlayerFromId(source)
    local restock_item, itemAdded, itemMatch, itemName = item, false, false, ''

	local invItem = xPlayer.getInventoryItem(restock_item)
	if invItem ~= nil then 
		if invItem.count >= amount then
			if next(shops[id].stock) then
				for i = 1, #shops[id].stock do
					if restock_item == shops[id].stock[i].item and shelf.type == shops[id].stock[i].type then
						shops[id].stock[i].qty = (shops[id].stock[i].qty + amount)
						itemAdded = true
						itemMatch = true
						break
					else
						if i == #shops[id].stock then 
							itemAdded = true
							break
						end
					end
				end
			else
				itemAdded = true
			end
			while not itemAdded do
				Citizen.Wait(10)
			end

			if not itemMatch then
				table.insert(shops[id].stock, {item = restock_item, qty = amount, label = invItem.label, price = price, type = shelf.type}) 
			end

			-- Update Database:
			MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
			-- Sync:
			Config.Shops[id].data = shops[id]
			TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
			-- Remove Inv Item:
			xPlayer.removeInventoryItem(restock_item, amount)
			TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['shelf_item_deposit']:format(amount, itemName))
		else
			TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['not_enough_items'])
		end
	else
		return print('ITEM '..data.item..' DOES NOT EXIST IN DATABASE')
	end
end)

-- Remove items from shelf:
RegisterServerEvent('t1ger_shops:itemWithdraw')
AddEventHandler('t1ger_shops:itemWithdraw', function(item, label, amount, id, type)
    local xPlayer = ESX.GetPlayerFromId(source)
	if next(shops[id].stock) then
		for k,v in pairs(shops[id].stock) do
			if item == v.item and type == v.type then
				if tonumber(v.qty) == tonumber(amount) then
					table.remove(shops[id].stock, k)
				else
					v.qty = (v.qty - amount)
				end
				-- Update Database:
				MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
				-- Sync:
				Config.Shops[id].data = shops[id]
				TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
				-- Add item:
				xPlayer.addInventoryItem(item, amount)
				TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['shelf_item_withdraw']:format(amount, label))
			end
		end
	end
end)

-- Update item stock when added to basket:
ESX.RegisterServerCallback('t1ger_shops:updateItemStock', function(source, cb, id, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
	if next(shops[id].stock) then
		for k,v in pairs(shops[id].stock) do
			if item == v.item then
				if amount <= v.qty then
					v.qty = (v.qty - amount)
					-- Update Database:
					MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
					-- Sync:
					Config.Shops[id].data = shops[id]
					TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
					cb(true)
				else
					cb(false)
				end
				break
			end
		end
	end
end)

-- Pay for stock order
ESX.RegisterServerCallback('t1ger_shops:payStockOrder',function(source, cb, id, orderPrice)
	TriggerEvent('esx_addonaccount:getSharedAccount', Config.Society[Config.Shops[id].society].account, function(account)
		if account.money >= orderPrice then
			account.removeMoney(orderPrice)
			cb(true)
		else
			cb(false)
		end
	end)
end)

-- Create Order:
RegisterServerEvent('t1ger_shops:createOrder')
AddEventHandler('t1ger_shops:createOrder', function(id, itemLabel, orderItem, orderStrMatch, orderAmount, orderItemPrice, orderCost, shelf_type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local order = {}
	local data = {item = orderItem, qty = orderAmount, label = itemLabel, price = orderItemPrice, str_match = orderStrMatch, type = shelf_type}
	local done = false
	MySQL.Async.fetchAll("SELECT * FROM t1ger_orders WHERE shopID = @shopID AND taken = @taken", {['@shopID'] = id, ['@taken'] = false}, function(results)
		if results[1] then
			order = json.decode(results[1].data)
			if next(order) then
				for k,v in pairs(order) do
					if v.item == data.item and v.type == data.type then
						v.qty = (v.qty + data.qty)
						break
					else
						if k == #order then 
							table.insert(order, data)
							break
						end
					end
				end
			else
				table.insert(order, data)
			end
			MySQL.Async.execute('UPDATE t1ger_orders SET data = @data, cost = @cost WHERE shopID = @shopID AND id = @id', {
				['id'] = results[1].id,
				['shopID'] = results[1].shopID,
				['data'] = json.encode(order),
				['cost'] = (results[1].cost + orderCost),
			})
		else
			table.insert(order, data)
			MySQL.Async.execute('INSERT INTO t1ger_orders (shopID, data, taken, cost, pos) VALUES (@shopID, @data, @taken, @cost, @pos)', {
				['shopID'] = id,
				['data'] = json.encode(order),
				['taken'] = false,
				['cost'] = tonumber(orderCost),
				['pos'] = json.encode(Config.Shops[id].delivery)
			})
		end
		return TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['stock_order_placed']:format(data.qty, data.label, orderCost))
	end)
end)

RegisterServerEvent('t1ger_shops:deliverOrder')
AddEventHandler('t1ger_shops:deliverOrder', function(data)
	for k,v in pairs(data.order) do
		local itemAdded, itemMatch = false, false
		if next(shops[data.shopID].stock) then
			for i = 1, #shops[data.shopID].stock do
				if v.item == shops[data.shopID].stock[i].item and v.type == shops[data.shopID].stock[i].type then
					shops[data.shopID].stock[i].qty = (shops[data.shopID].stock[i].qty + v.qty)
					itemAdded = true
					itemMatch = true
					break
				else
					if i == #shops[data.shopID].stock then 
						itemAdded = true
						break
					end
				end
			end
		else
			itemAdded = true
		end

		while not itemAdded do
			Citizen.Wait(10)
		end

		if not itemMatch then
			if v.str_match ~= nil then 
				table.insert(shops[data.shopID].stock, {item = v.item , qty = v.qty, label = v.label, price = v.price, str_match = v.str_match, type = v.type})
			else
				table.insert(shops[data.shopID].stock, {item = v.item , qty = v.qty, label = v.label, price = v.price, type = v.type})
			end
		end

		MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[data.shopID].stock), ['@id'] = data.shopID })
		Config.Shops[data.shopID].data = shops[data.shopID]
		TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, data.shopID, Config.Shops[data.shopID].data, shops)
	end
end)

function GetShopOrders()
	local done, orders = false, {}
	MySQL.Async.fetchAll('SELECT * FROM t1ger_orders WHERE taken = @taken', {['@taken'] = false}, function(results)
		if next(results) then 
			for i = 1, #results do
				local t = {id = results[i].id, shopID = results[i].shopID, taken = results[i].taken, cost = results[i].cost, pos = json.decode(results[i].pos), order = json.decode(results[i].data)}
				table.insert(orders, t)
				Citizen.Wait(5)
				if i == #results then 
					done = true
				end
			end
		else
			done = true
		end
	end)

	while not done do 
		Citizen.Wait(10)
	end

	return orders
end

function UpdateOrderTakenStatus(id, shopID, state)
	MySQL.Async.execute('UPDATE t1ger_orders SET taken = @taken WHERE id = @id and shopID = @shopID', {
		['@taken'] = state,
		['@shopID'] = shopID,
		['@id'] = id
	})
end

function AddShopOrder(data)
	MySQL.Async.fetchAll("SELECT * FROM t1ger_orders WHERE shopID = @shopID AND id = @id", {['@shopID'] = data.shopID, ['@id'] = data.id}, function(results)
		if results[1] then
			local data = json.decode(results[1].data)
			local t = {id = results[1].id, shopID = results[1].shopID, taken = results[1].taken, cost = results[1].cost, pos = results[1].pos, order = data}
			TriggerEvent('t1ger_shops:deliverOrder', t)
			MySQL.Sync.execute('DELETE FROM t1ger_orders WHERE id = @id and shopID = @shopID', {
				['@id'] = results[1].id,
				['@shopID'] = results[1].shopID
			})
		end
	end)
end

-- Get player loadout:
ESX.RegisterServerCallback('t1ger_shops:getLoadout',function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getLoadout())
end)

-- function to purchase selected ammo:
RegisterServerEvent('t1ger_shops:purchaseAmmo')
AddEventHandler('t1ger_shops:purchaseAmmo', function(item, price, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if type == 'button_cash' then xPlayer.removeMoney(price) elseif type == 'button_card' then xPlayer.removeAccountMoney('bank', price) end
    TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_purchased']:format(item.value,item.name,price))
end)

-- function to purchase weapon:
RegisterServerEvent('t1ger_shops:purchaseWeapon')
AddEventHandler('t1ger_shops:purchaseWeapon', function(item, price, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if type == 'button_cash' then xPlayer.removeMoney(price) elseif type == 'button_card' then xPlayer.removeAccountMoney('bank', price) end
    xPlayer.addWeapon(item.item, 0)
    TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['item_purchased']:format(item.value,item.name,price))
end)

-- Add Loadout Stock in shelf:
RegisterServerEvent('t1ger_shops:loadoutDeposit')
AddEventHandler('t1ger_shops:loadoutDeposit', function(item, amount, price, id, shelf)
    local xPlayer = ESX.GetPlayerFromId(source)
    local add_item, updated, itemMatch, itemName = item.value, false, false, item.name
	if next(shops[id].stock) then
		for i = 1, #shops[id].stock do
			if add_item == shops[id].stock[i].item and shelf.type == shops[id].stock[i].type then
				shops[id].stock[i].qty = (shops[id].stock[i].qty + amount)
				updated = true
				itemMatch = true
				break
			else
				if i == #shops[id].stock then
					updated = true
					break
				end
			end
		end
	else
		updated = true
	end
	while not updated do
		Citizen.Wait(10)
	end
	if not itemMatch then
		table.insert(shops[id].stock, {item = add_item, qty = amount, label = itemName, price = price, type = shelf.type, str_match = item.type})
	end
	-- Update Database:
	MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
	-- Sync:
	Config.Shops[id].data = shops[id]
	TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
	-- Remove Inv Item:
    if item.type == "weapon" then
        xPlayer.removeWeapon(add_item, 0)
    end
	TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['shelf_item_deposit']:format(amount, itemName))
end)

-- Remove items from shelf:
RegisterServerEvent('t1ger_shops:loadoutWithdraw')
AddEventHandler('t1ger_shops:loadoutWithdraw', function(item, label, amount, id, type, str_match)
    local xPlayer = ESX.GetPlayerFromId(source)
	if next(shops[id].stock) then
		for k,v in pairs(shops[id].stock) do
			if item == v.item and type == v.type then
				if tonumber(v.qty) == tonumber(amount) then
					table.remove(shops[id].stock, k)
				else
					v.qty = (v.qty - amount)
				end
				-- Update Database:
				MySQL.Async.execute('UPDATE t1ger_shops SET stock = @stock WHERE id = @id', { ['@stock'] = json.encode(shops[id].stock), ['@id'] = id })
				-- Sync:
				Config.Shops[id].data = shops[id]
				TriggerClientEvent('t1ger_shops:updateShopsDataCL', -1, id, Config.Shops[id].data, shops)
				-- Add Weapon:
				if str_match == "weapon" then xPlayer.addWeapon(item, 1) end
				TriggerClientEvent('t1ger_shops:notify', xPlayer.source, Lang['shelf_item_withdraw']:format(amount, label))
				break
			end
		end
	end
end)

-- Function to get online players:
function GetOnlinePlayers()
    local xPlayers = ESX.GetExtendedPlayers()
    local players  = {}
	for i=1, #(xPlayers) do
		local xPlayer = xPlayers[i]
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name
		})
	end
    return players
end
