-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local ESX = exports['es_extended']:getSharedObject()
local deliveryCompanies = {}

Citizen.CreateThread(function ()
    while GetResourceState('mysql-async') ~= 'started' do Citizen.Wait(0) end
    while GetResourceState(GetCurrentResourceName()) ~= 'started' do Citizen.Wait(0) end
    if GetResourceState(GetCurrentResourceName()) == 'started' then InitializeDeliveries() end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Society) do
        TriggerEvent('esx_society:registerSociety', v.name, v.label, v.account, v.datastore, v.inventory, v.data)
    end
end)

function InitializeDeliveries()
	Citizen.Wait(1000)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_deliveries', {}, function(results)
		if next(results) then
			for i = 1, #results do
				local data = {
					identifier = results[i].identifier,
					id = results[i].id,
					name = results[i].name,
					level = results[i].level,
					certificate = results[i].certificate
				}
				deliveryCompanies[results[i].id] = data
				Config.Companies[results[i].id].owned = true
				Config.Companies[results[i].id].data = data
				Citizen.Wait(5)
			end
		end
	end)
	RconPrint('T1GER Deliveries Initialized\n')
end

AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	while not xPlayer do Citizen.Wait(100) end
    SetupDeliveryCompanies(xPlayer.source)
end)

RegisterServerEvent('t1ger_deliveries:debugSV')
AddEventHandler('t1ger_deliveries:debugSV', function()
    SetupDeliveryCompanies(source)
end)

function SetupDeliveryCompanies(src)
    local xPlayer = ESX.GetPlayerFromId(src)
	while not xPlayer do Citizen.Wait(100) end
    local isOwner, deliveryID = 0, 0
	if next(deliveryCompanies) then
		for k,v in pairs(deliveryCompanies) do
			if v.identifier == xPlayer.identifier then 
				isOwner = v.id
			end
            local currentJob = xPlayer.getJob()
            if currentJob.name == Config.Society[Config.Companies[v.id].society].name then
                deliveryID = v.id
            end
		end
	end
	TriggerClientEvent('t1ger_deliveries:loadCompanies', xPlayer.source, deliveryCompanies, Config.Companies, isOwner, towID)
end

-- Event:
RegisterServerEvent('t1ger_deliveries:updateCompanyDataSV')
AddEventHandler('t1ger_deliveries:updateCompanyDataSV', function(id, data)
	Config.Companies[id].data = data
	TriggerClientEvent('t1ger_deliveries:updateCompanyDataCL', -1, id, Config.Companies[id].data)
end)

-- Callback to check money & purchase tow service:
ESX.RegisterServerCallback('t1ger_deliveries:buyCompany',function(source, cb, id, val, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = 0
    if Config.BuyWithBank then money = xPlayer.getAccount('bank').money else money = xPlayer.getMoney() end
	if money >= val.price then
		if Config.BuyWithBank then xPlayer.removeAccountMoney('bank', val.price) else xPlayer.removeMoney(val.price) end
        MySQL.Async.execute('INSERT INTO t1ger_deliveries (id, identifier, name) VALUES (@id, @identifier, @name)', {
            ['id'] = id,
			['identifier'] = xPlayer.identifier,
            ['name'] = name
        })
		xPlayer.setJob(Config.Society[val.society].name, Config.Society[val.society].boss_grade)
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('t1ger_deliveries:sellCompany')
AddEventHandler('t1ger_deliveries:sellCompany', function(id, val, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE FROM t1ger_deliveries WHERE id = @id', {['@id'] = id}) 
    if Config.BuyWithBank then xPlayer.addAccountMoney('bank', amount) else xPlayer.addMoney(amount) end
	xPlayer.setJob('unemployed', 0)
end)

-- Event to update selected tow service:
RegisterServerEvent('t1ger_deliveries:updateCompany')
AddEventHandler('t1ger_deliveries:updateCompany', function(num, val, state, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if state ~= nil then 
        -- add/remove service to/from table:
        if state then 
			deliveryCompanies[num] = { identifier = xPlayer.identifier, id = num, name = name, level = 0, certificate = false }
			Config.Companies[num].data = data
        else
			for i = 1, #deliveryCompanies do
				if deliveryCompanies[i].id == num then
					deliveryCompanies[i] = nil
					Config.Companies[num].data = nil
					break
				end
			end
        end
        Config.Companies[num].owned = state
    else
        if name ~= nil then 
            for k,v in pairs(deliveryCompanies) do
                if v.id == num then
                    v.name = name
                    MySQL.Async.execute('UPDATE t1ger_deliveries SET name = @name WHERE id = @id', {
                        ['@name'] = name,
                        ['@id'] = num
                    })
                    break
                end
            end
        end
    end
    TriggerClientEvent('t1ger_deliveries:syncServices', -1, deliveryCompanies, Config.Companies)
end)

-- Purchase Certificate:
ESX.RegisterServerCallback('t1ger_deliveries:buyCertifcate',function(source, cb, id)
    local xPlayer = ESX.GetPlayerFromId(source)
	local money = 0
	if Config.BuyWithBank then money = xPlayer.getAccount('bank').money else money = xPlayer.getMoney() end
	if money >= Config.CertificatePrice then
		if Config.BuyWithBank then xPlayer.removeAccountMoney('bank', Config.CertificatePrice) else xPlayer.removeMoney(Config.CertificatePrice) end
		MySQL.Async.execute('UPDATE t1ger_deliveries SET certificate = @certificate WHERE id = @id', {
			['@certificate'] = true,
			['@id'] = id
		})
        cb(true)
	else
        cb(false)
	end
end)

ESX.RegisterServerCallback('t1ger_deliveries:payVehicleDeposit',function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
	local money = 0
	if Config.DepositInBank then money = xPlayer.getAccount('bank').money else money = xPlayer.getMoney() end
    if money >= amount then
		if Config.DepositInBank then xPlayer.removeAccountMoney('bank', amount) else xPlayer.removeMoney(amount) end
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('t1ger_deliveries:retrievePaycheck')
AddEventHandler('t1ger_deliveries:retrievePaycheck', function(paycheck, vehDeposit, giveDeposit, id, val)
	local xPlayer = ESX.GetPlayerFromId(source)
    if giveDeposit then
        xPlayer.addMoney(vehDeposit)
        TriggerClientEvent('t1ger_deliveries:notify', xPlayer.source, (Lang['deposit_returned']:format(vehDeposit)))
    end
	-- add paycheck money to society account:
	TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
        TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
            account.addMoney(paycheck)
        end)
    end)
    TriggerClientEvent('t1ger_deliveries:notify', xPlayer.source, (Lang['paycheck_received']:format(paycheck)))

	local newLevel = val.data.level + Config.AddLevelAmount
	MySQL.Async.execute('UPDATE t1ger_deliveries SET level = @level WHERE id = @id', {
		['@level'] = newLevel,
		['@id'] = id
	})
	Config.Companies[id].data.level = newLevel
	TriggerClientEvent('t1ger_deliveries:updateCompanyDataCL', -1, id, Config.Companies[id].data)
end)

-- Orders from T1GER_Shops
ESX.RegisterServerCallback('t1ger_deliveries:getShopOrders',function(source, cb)
	local orders = exports['t1ger_shops']:GetShopOrders()
    cb(orders)
end)

-- Event to update taken state for shop orders
RegisterServerEvent('t1ger_deliveries:updateOrderState')
AddEventHandler('t1ger_deliveries:updateOrderState', function(data, state)
	exports['t1ger_shops']:UpdateOrderTakenStatus(data.id, data.shopID, state)
end)

-- Event to complete shop order delivery
RegisterServerEvent('t1ger_deliveries:orderDeliveryDone')
AddEventHandler('t1ger_deliveries:orderDeliveryDone', function(data)
	exports['t1ger_shops']:AddShopOrder(data)

end)

-- Callback to get inventory item:
ESX.RegisterServerCallback('t1ger_deliveries:getInventoryItem',function(source, cb, item, amount)
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
RegisterServerEvent('t1ger_deliveries:removeItem')
AddEventHandler('t1ger_deliveries:removeItem', function(item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, count)
end)

-- Callback to check if is owner:
ESX.RegisterServerCallback('t1ger_deliveries:hasCompany',function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_deliveries', {}, function(results)
		if next(results) then
			for i = 1, #results do
				if results[i].identifier == xPlayer.identifier then
					xPlayer.setJob(Config.Society[Config.Companies[results[i].id].society].name, 1)
					cb(true)
					break
				else
					if i == #results then
						cb(false)
					end
				end
				Citizen.Wait(2)
			end
		end
	end)
end)

-- Callback to get society vehicles:
ESX.RegisterServerCallback('t1ger_deliveries:getSocietyVehicles',function(source, cb, job_name)
    local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @job_name', {['@job_name'] = job_name}, function(results)
		cb(results)
	end)
end)

