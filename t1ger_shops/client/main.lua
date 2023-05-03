-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local player, coords = nil, {}
Citizen.CreateThread(function()
    while true do
        player = PlayerPedId()
        coords = GetEntityCoords(player)
        Citizen.Wait(500)
    end
end)

local shops = {}
local shopBlips = {}
local isOwner = 0
local shopID = 0
local cashier_menu = nil
local basket = {bill = 0, items = {}, shopID = 0}

RegisterNetEvent('t1ger_shops:loadShops')
AddEventHandler('t1ger_shops:loadShops', function(results, cfg, num, id)
	Config.Shops = cfg
	shops = results
	isOwner = num
	TriggerEvent('t1ger_shops:setShopID', id)
	Citizen.Wait(200)
	UpdateShopBlips()
end)

RegisterNetEvent('t1ger_shops:syncShops')
AddEventHandler('t1ger_shops:syncShops', function(results, cfg)
	Config.Shops = cfg
	shops = results
	Citizen.Wait(200)
	UpdateShopBlips()
end)

RegisterNetEvent('t1ger_shops:setShopID')
AddEventHandler('t1ger_shops:setShopID', function(id)
	shopID = id
end)

function UpdateShopBlips()
	for k,v in pairs(shopBlips) do RemoveBlip(v) end
	for i = 1, #Config.Shops do
		if Config.Shops[i].owned then
			if isOwner == Config.Shops[i].data.id then
				CreateShopBlip(Config.Shops[i], 'Your ') 
			else
				CreateShopBlip(Config.Shops[i], '')
			end
		else
			CreateShopBlip(Config.Shops[i], '')
		end
	end
end

function CreateShopBlip(cfg, label)
	local mk = Config.BlipSettings[cfg.type]
	if mk.enable then
		local blip = AddBlipForCoord(cfg.b_menu[1], cfg.b_menu[2], cfg.b_menu[3])
		SetBlipSprite(blip, mk.sprite)
		SetBlipDisplay(blip, mk.display)
		SetBlipScale(blip, mk.scale)
		SetBlipColour(blip, mk.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(label..mk.name)
		EndTextCommandSetBlipName(blip)
		table.insert(shopBlips, blip)
	end
end

local bossMenu = nil
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true 
		for k,v in pairs(Config.Shops) do
			local boss_pos = vector3(v.b_menu[1], v.b_menu[2], v.b_menu[3])
			local distance = #(coords - boss_pos)
			if bossMenu ~= nil then
				distance = #(coords - vector3(bossMenu.b_menu[1], bossMenu.b_menu[2], bossMenu.b_menu[3]))
				while bossMenu ~= nil and distance > 1.5 do
					bossMenu = nil
					Citizen.Wait(1)
				end
				if bossMenu == nil then
					ESX.UI.Menu.CloseAll()
				end
			else
				local mk = Config.MarkerSettings['boss']
				if distance <= mk.drawDist then
					sleep = false
					-- Draw Marker:
					if mk.enable and distance >= 2.0 then
						DrawMarker(mk.type, v.b_menu[1], v.b_menu[2], v.b_menu[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
					end
					-- Draw Text & Interaction:
					if distance < 2.0 and v.buyable == true then
						if v.owned == true then
							if (T1GER_isJob(Config.Society[v.society].name)) or (isOwner == k) then
								T1GER_DrawTxt(v.b_menu[1], v.b_menu[2], v.b_menu[3], Lang['draw_manage_shop'])
								if IsControlJustPressed(0, Config.KeyControls['boss_menu']) then
									bossMenu = v
									ManageShopMenu(k,v)
								end
							else
								T1GER_DrawTxt(v.b_menu[1], v.b_menu[2], v.b_menu[3], 'NO ACCESS TO MENU')
							end
						else
							if (T1GER_isJob(Config.Society[v.society].name) and PlayerData.job.grade_name ~= 'boss') or (isOwner == 0) then
								T1GER_DrawTxt(v.b_menu[1], v.b_menu[2], v.b_menu[3], Lang['draw_buy_shop']:format(comma_value(math.floor(v.price))))
								if IsControlJustPressed(0, Config.KeyControls['buy_shop']) then
									bossMenu = v
									PurchaseShop(k,v)
								end
							else
								T1GER_DrawTxt(v.b_menu[1], v.b_menu[2], v.b_menu[3], 'SHOP OWNED')
							end
						end
					end
				end
			end
		end
		if sleep then Citizen.Wait(1500) end
	end
end)

function PurchaseShop(id,val)
	local elements = {
		{ label = 'No', value = 'no' },
		{ label = 'Yes', value = 'yes' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_purchase_confirmation',
		{
			title    = 'Confirm | Price: $'..comma_value(val.price),
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value ~= 'no' then
			ESX.TriggerServerCallback('t1ger_shops:purchaseShop', function(purchased)
				if purchased then
					TriggerEvent('t1ger_shops:notify', Lang['shop_purchased']:format(comma_value(val.price)))
					isOwner = tonumber(id)
					TriggerServerEvent('t1ger_shops:updateShops', id, val, true)
				else
					TriggerEvent('t1ger_shops:notify', Lang['not_enough_money'])
				end
			end, id, val)
		end
		menu.close()
		bossMenu = nil
	end, function(data, menu)
		menu.close()
		bossMenu = nil
	end)
end

function SellShop(id,val)
	local sell_price = (val.price * Config.SalePercentage)
	local elements = {
		{ label = 'No', value = 'no' },
		{ label = 'Yes', value = 'yes' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_sell_confirmation',
		{
			title    = 'Confirm Sale | Price: $'..comma_value(math.floor(sell_price)),
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'yes' then
			TriggerServerEvent('t1ger_shops:sellShop', id, val, math.floor(sell_price))
			isOwner = 0
			TriggerServerEvent('t1ger_shops:updateShops', id, val, false)
			TriggerEvent('t1ger_shops:notify', Lang['shop_sold']:format(comma_value(math.floor(sell_price))))
			menu.close()
			bossMenu = nil
			ESX.UI.Menu.CloseAll()
		else
			menu.close()
			ManageShopMenu(id,val)
		end
	end, function(data, menu)
		menu.close()
		ManageShopMenu(id,val)
	end)
end

function ManageShopMenu(id,val)
	ESX.UI.Menu.CloseAll()
	local elements = {}
	if (T1GER_isJob(Config.Society[val.society].name) and PlayerData.job.grade_name == 'boss') or isOwner == id then
		table.insert(elements, {label = 'Sell Shop', value = 'sell_shop'})
		table.insert(elements, {label = 'Boss Menu', value = 'boss_menu'})
	end
	if #elements > 0 then 
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_shop_menu',
			{
				title    = 'Shop ['..tostring(id)..']',
				align    = 'center',
				elements = elements
			},
		function(data, menu)
			local action = data.current.value
			if action == 'sell_shop' then
				SellShop(id,val)
			elseif action == 'boss_menu' then
				BossMenu(id,val)
			end
		end, function(data, menu)
			menu.close()
			bossMenu = nil
		end)
	else
		TriggerEvent('t1ger_shops:notify', Lang['boss_menu_no_access'])
		bossMenu = nil
	end
end

function BossMenu(id,val)
	local cfg, cfg2 = Config.SocietySettings, Config.Society[val.society]
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_main_menu',
		{
			title    = cfg2.label,
			align    = 'center',
			elements = {
				{ label = 'Boss Actions', value = 'boss_actions', job = cfg2.name },
				{ label = 'Account Balance', value = 'get_balance', job = cfg2.name}
			}
		},
	function(data, menu)
		if data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', data.current.job, function(data, menu)
				menu.close()
			end, {withdraw = cfg.withdraw, deposit = cfg.deposit, wash = cfg.wash, employees = cfg.employees, grades = cfg.grades})
		elseif data.current.value == 'get_balance' then
			ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(amount)
				TriggerEvent('t1ger_shops:notify', Lang['get_account_balance']:format(comma_value(amount)))
			end, data.current.job)
		end
	end, function(data, menu)
		menu.close()
		ManageShopMenu(id,val)
	end)
end

-- ## CASHIER ## -- 

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Shops) do
			local distance = #(coords - vector3(v.cashier[1], v.cashier[2], v.cashier[3]))
			if cashier_menu ~= nil then
				distance = #(coords - vector3(cashier_menu.cashier[1], cashier_menu.cashier[2], cashier_menu.cashier[3]))
				while cashier_menu ~= nil and distance > 1.5 do
					cashier_menu = nil
					Citizen.Wait(1)
				end
				if cashier_menu == nil then
					ESX.UI.Menu.CloseAll()
				end
			else
				local mk = Config.MarkerSettings['cashier']
				if distance < 20.0 then 
					sleep = false
					if distance > mk.drawDist and basket.bill > 0 then 
						EmptyShopBasket(Lang['basket_emptied'])
					elseif distance < mk.drawDist then
						if mk.enable and distance > 1.5 then 
							DrawMarker(mk.type, v.cashier[1], v.cashier[2], v.cashier[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
						end
						if distance < 1.5 then
							T1GER_DrawTxt(v.cashier[1], v.cashier[2], v.cashier[3], Lang['draw_cashier'])
							if IsControlJustPressed(0, Config.KeyControls['cashier']) then
								cashier_menu = v
								OpenCashierMenu(k,v)
							end 
						end
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

function OpenCashierMenu(id,val)
	local elements = {}
	if val.owned then 
		if basket.bill > 0 and #basket.items then
			elements = {{label = '<span style="color:MediumSeaGreen;">Confirm Basket</span>', value = 'confirm_basket'}}
			for k,v in pairs(basket.items) do
				local listLabel = ('<span style="color:GoldenRod;">%sx</span> %s <span style="color:MediumSeaGreen;">[ $%s ]</span>'):format(v.count,v.label,v.price)
				table.insert(elements, {label = listLabel, v.count, v.price, value = 'item_data', num = k, str_match = v.str_match})
			end
			ESX.UI.Menu.CloseAll()
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_basket_confirm_items',
				{
					title    = ('Basket Bill <span style="color:MediumSeaGreen;"> [ $%s ]</span>'):format(basket.bill),
					align    = 'center',
					elements = elements
				},
			function(data, menu)
				if data.current.value == 'confirm_basket' then
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_basket_select_payment_type', {
						title    = 'Select Payment Type',
						align    = 'center',
						elements = {
							{label = 'Pay w/ Cash', value = 'button_cash'},
							{label = 'Pay w/ Card', value = 'button_card'},
							{label = 'No',  value = 'button_no'},
						}
					}, function(data2, menu2)
						if data2.current.value ~= 'button_no' then 
							menu.close()
							cashier_menu = nil
							ESX.TriggerServerCallback('t1ger_shops:getPlayerMoney', function(hasMoney)
								if hasMoney then
									ESX.TriggerServerCallback('t1ger_shops:getPlayerInvLimit', function(limitExceeded)
										if not limitExceeded then
											TriggerServerEvent('t1ger_shops:checkoutBasket', basket, data2.current.value, id)
											EmptyShopBasket(nil)
										end
									end, basket.items)
								end
							end, basket.bill, data2.current.value)
						end
						menu2.close()
					end, function(data2, menu2)
						menu2.close()
					end)
				end 
			end, function(data, menu)
				menu.close()
				cashier_menu = nil
			end)
		else
			TriggerEvent('t1ger_shops:notify', Lang['basket_is_empty'])
			cashier_menu = nil
		end
	else
		for k,v in pairs(Config.Items) do
			for i = 1, #v.type do
				if val.type == v.type[i] then
					local max_count = 100
					if v.str_match ~= nil and Config.WeaponLoadout and v.str_match == "weapon" then max_count = 1 end
					if v.str_match ~= nil and Config.WeaponLoadout and v.str_match == "ammo" then max_count = 250 end
					table.insert(elements, {label = (('%s <span style="color:MediumSeaGreen;">[ $%s ]</span>'):format(v.label,v.price)), name = v.label, item = v.item, ammo_type = v.ammo_type, str_match = v.str_match, price = v.price, type = 'slider', value = 1, min = 1, max = max_count})
				end
			end
		end
		ESX.UI.Menu.CloseAll()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_item_list_menu',
			{
				title    = 'Shop',
				align    = 'center',
				elements = elements
			},
		function(data, menu)
			local item = data.current
			local price = (item.value * item.price)
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_item_confirm_purchase', {
				title    = 'Buy '..item.value..'x '..item.name..' for $'..price..'?',
				align    = 'center',
				elements = {
					{label = 'Pay w/ Cash', value = 'button_cash'},
					{label = 'Pay w/ Card', value = 'button_card'},
					{label = 'No',  value = 'button_no'},
				}
			}, function(data2, menu2)
				if data2.current.value ~= 'button_no' then 
					ESX.TriggerServerCallback('t1ger_shops:getPlayerMoney', function(hasMoney)
						if hasMoney then
							if Config.WeaponLoadout then
								if item.str_match ~= nil then
									if (string.match(item.str_match, "ammo")) then
										menu2.close()
										AddAmmoToLoadout(item, price, data2.current.value)
									elseif (string.match(item.str_match, "weapon")) then
										AddWeaponToLoadout(item, price, data2.current.value)
									end
								else
									ESX.TriggerServerCallback('t1ger_shops:getPlayerInvLimit', function(limitExceeded)
										if not limitExceeded then
											TriggerServerEvent('t1ger_shops:purchaseItem', item, price, data2.current.value)
										end
									end, item)
								end
							else
								ESX.TriggerServerCallback('t1ger_shops:getPlayerInvLimit', function(limitExceeded)
									if not limitExceeded then
										TriggerServerEvent('t1ger_shops:purchaseItem', item, price, data2.current.value)
									end
								end, item)
							end
						else
							TriggerEvent('t1ger_shops:notify', Lang['not_enough_money'])
						end
					end, price, data2.current.value)
				end
				menu2.close()
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
			cashier_menu = nil
		end)
	end
end

-- ## BASKET ## --

RegisterCommand(Config.BasketCommand, function(source, args)
	OpenShopBasket()
end, false)

function OpenShopBasket()
	if basket.bill > 0 and #basket.items then
		local elements = {}
		for k,v in pairs(basket.items) do
			local listLabel = ('<span style="color:GoldenRod;">%sx</span> %s <span style="color:MediumSeaGreen;">[ $%s ]</span>'):format(v.count,v.label,v.price)
			table.insert(elements, {label = listLabel, name = v.label, v.count, v.price, value = 'item_data', num = k})
		end
		table.insert(elements, {label = '<span style="color:IndianRed;">Empty Basket</span>', value = 'empty_basket'})
		ESX.UI.Menu.CloseAll()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_basket_overview', {
			title    = ('Basket Bill <span style="color:MediumSeaGreen;">[ $%s</span>'):format(basket.bill),
			align    = 'center',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'empty_basket' then
				menu.close()
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_basket_confirm_empty', {
					title    = 'Confirm to Empty Basket',
					align    = 'center',
					elements = {
						{label = 'No',  value = 'button_no'},
						{label = 'Yes', value = 'button_yes'},
					}
				}, function(data2, menu2)
					menu2.close()
					if data2.current.value == 'button_yes' then
						EmptyShopBasket(Lang['you_emptied_basket'])
					else
						OpenShopBasket()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
			if data.current.value == 'item_data' then
				menu.close()
				local i = data.current.num
				local item = basket.items[i]
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_basket_item_data', {
					title    = item.label,
					align    = 'center',
					elements = {
						{label = ('Price <span style="color:MediumSeaGreen;">[ $%s ]</span>'):format(item.price)},
						{label = ('Count <span style="color:GoldenRod;">[ %sx ]</span>'):format(item.count)},
						{label = '<span style="color:IndianRed;">Remove Item</span>', value = 'remove_item'},
					}
				}, function(data2, menu2)
					if data2.current.value == 'remove_item' then
						basket.bill = basket.bill - item.price
						TriggerServerEvent('t1ger_shops:removeBasketItem', basket.shopID, item)
						table.remove(basket.items, i)
						TriggerEvent('t1ger_shops:notify', Lang['basket_item_removed']:format(item.count,item.label))
						OpenShopBasket()
					end
				end, function(data2, menu2)
					menu2.close()
					OpenShopBasket()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	else
		TriggerEvent('t1ger_shops:notify', Lang['basket_is_empty'])
		ESX.UI.Menu.CloseAll()
	end
end

-- ## SHELVES & STOCK ## --

local shelf_menu = nil
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Shops) do
			local distance = #(coords - vector3(v.cashier[1], v.cashier[2], v.cashier[3]))
			if distance < 15.0 then
				if v.data then 
					if v.data.shelves ~= nil then
						if next(v.data.shelves) then 
							for num,shelf in pairs(v.data.shelves) do
								local shelfDist = #(coords - vector3(shelf.pos[1], shelf.pos[2], shelf.pos[3]))
								if shelf_menu ~= nil then 
									shelfDist = #(coords - vector3(shelf_menu.pos[1], shelf_menu.pos[2], shelf_menu.pos[3]))
									while shelf_menu ~= nil and shelfDist > 1.5 do
										shelf_menu = nil
										Citizen.Wait(1)
									end
									if shelf_menu == nil then
										ESX.UI.Menu.CloseAll()
									end
								else 
									local mk = Config.MarkerSettings['shelves']
									if shelfDist < mk.drawDist then
										sleep = false
										if mk.enable and shelfDist > 1.5 then
											DrawMarker(mk.type, shelf.pos[1], shelf.pos[2], shelf.pos[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
										end
										if shelfDist <= 1.5 then
											if (T1GER_isJob(Config.Society[v.society].name)) or (isOwner == k) then
												T1GER_DrawTxt(shelf.pos[1], shelf.pos[2], shelf.pos[3], "~r~[E]~s~ "..shelf.drawText.." | ~y~[G]~s~ "..Lang['draw_manage_stock'])
												if IsControlJustPressed(0, Config.KeyControls['stock']) then 
													shelf_menu = shelf
													OpenStockManageMenu(k,v,num,shelf)
												end
											else
												T1GER_DrawTxt(shelf.pos[1], shelf.pos[2], shelf.pos[3], "~r~[E]~s~ "..shelf.drawText)
											end
											if IsControlJustPressed(0, Config.KeyControls['shelf']) then 
												shelf_menu = shelf
												OpenShelvesMenu(k,v,num,shelf)
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

function OpenShelvesMenu(id,val,num,shelf)
	ESX.TriggerServerCallback('t1ger_shops:getItemStock', function(stock_data)
		local elements = {}
		if next(stock_data) then 
			for k,v in pairs(stock_data) do
				if v.type == shelf.type and v.qty > 0 then 
					local list_label = ('%s <span style="color:MediumSeaGreen;"> [ $%s ]</span>'):format(v.label,v.price)
					table.insert(elements, {label = list_label, name = v.label, item = v.item, price = v.price, str_match = v.str_match, type = 'slider', value = 1, min = 1, max = v.qty})
				end
			end
			if #elements > 0 then 
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_item_menu',
					{
						title    = 'Shelf [ '..shelf.drawText..' ]',
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					local loopDone, selected_weapon = false, nil
					local item_price = math.floor(data.current.price * data.current.value)
					local itemInBasket, int = IsItemInBasket(data.current.item)
					if data.current.str_match == "weapon" and data.current.value > 1 then
						return TriggerEvent('t1ger_shops:notify', Lang['basket_one_weapon_type'])
					end
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_add_to_basket', {
						title    = 'Put '..data.current.value..'x '..data.current.name..' for $'..item_price..' into basket?',
						align    = 'center',
						elements = {
							{label = 'No',  value = 'button_no'},
							{label = 'Yes', value = 'button_yes'},
						}
					}, function(data2, menu2)
						if data2.current.value == 'button_yes' then
							menu.close()
							if data.current.str_match == "weapon" then
								if itemInBasket then
									TriggerEvent('t1ger_shops:notify', Lang['similar_wep_in_basket'])
									menu2.close()
									return OpenShelvesMenu(id,val,num,shelf)
								else
									ESX.TriggerServerCallback('t1ger_shops:getLoadout', function(loadout)
										if #loadout > 0 then 
											for k,v in pairs(loadout) do
												if data.current.item == v.name then
													TriggerEvent('t1ger_shops:notify', Lang['wep_already_in_loadout'])
													menu2.close()
													return OpenShelvesMenu(id,val,num,shelf)
												else
													if k == #loadout then loopDone = true end
												end
											end
										else
											loopDone = true
										end
									end)
									while not loopDone do Citizen.Wait(5) end
								end
							end
							if data.current.str_match == "ammo" then
								selected_weapon = GetSelectedPedWeapon(player)
								if selected_weapon == -1569615261 then
									TriggerEvent('t1ger_shops:notify', Lang['hold_wep_in_hands'])
									menu2.close()
									return OpenShelvesMenu(id,val,num,shelf)
								else
									if GetPedAmmoTypeFromWeapon(player, selected_weapon) ~= data.current.item then
										TriggerEvent('t1ger_shops:notify', Lang['ammo_incompatible'])
										menu2.close()
										return OpenShelvesMenu(id,val,num,shelf)
									end
									if itemInBasket then
										if (GetAmmoInPedWeapon(player, selected_weapon) + basket.items[int].count + data.current.value) > 250 then 
											TriggerEvent('t1ger_shops:notify', Lang['ammo_limit_exceed'])
											menu2.close()
											return OpenShelvesMenu(id,val,num,shelf)
										end								
									end
								end
							end
							ESX.TriggerServerCallback('t1ger_shops:updateItemStock', function(hasItemStock)
								if hasItemStock ~= nil and hasItemStock then
									if itemInBasket then
										basket.items[int].count = basket.items[int].count + data.current.value
										basket.items[int].price = basket.items[int].price + item_price
									else
										table.insert(basket.items, {label = data.current.name, item = data.current.item, count = data.current.value, price = item_price, str_match = data.current.str_match, weapon = selected_weapon})
									end
									basket.bill = basket.bill + item_price
									basket.shopID = id
									TriggerEvent('t1ger_shops:notify', Lang['basket_item_added']:format(data.current.value,data.current.name,item_price))
									menu2.close()
									OpenShelvesMenu(id,val,num,shelf)
								else
									TriggerEvent('t1ger_shops:notify', Lang['item_not_available'])
								end
							end, id, data.current.item, data.current.value)
						end
						menu2.close()
					end, function(data2, menu2)
						menu2.close()
						OpenShelvesMenu(id,val,num,shelf)
					end)
				end, function(data, menu)
					menu.close()
					shelf_menu = nil
				end)
			else
				TriggerEvent('t1ger_shops:notify', Lang['no_stock_in_shelf'])
				shelf_menu = nil
			end
		else
			TriggerEvent('t1ger_shops:notify', Lang['no_stock_in_shelf'])
			shelf_menu = nil
		end
	end, id)
end

-- ## STOCK MANAGEMENT ## -- 
function OpenStockManageMenu(id,val,num,shelf)
	local elements = {
		{label = 'View Stock', value = 'view_stock'},
		{label = 'Add Stock', value = 'add_stock'},
		{label = 'Remove Stock', value = 'remove_stock'}
	}
	if Config.T1GER_Deliveries == true then 
		if isOwner == id then
			table.insert(elements, {label = 'Order Stock', value = 'order_stock'})
		end
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_restock_main_menu',
		{
			title    = 'Shelf [ '..shelf.drawText..' ]',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		menu.close()
		if data.current.value == 'add_stock' then
			AddStockFunction(id,val,num,shelf)
		elseif data.current.value == 'remove_stock' then 
			RemoveStockFunction(id,val,num,shelf)
		elseif data.current.value == 'view_stock' then 
			ViewShelfStock(id,val,num,shelf)
		elseif data.current.value == 'order_stock' then 
			OrderStockFunction(id,val,num,shelf)
		end
	end, function(data, menu)
		menu.close()
		shelf_menu = nil
	end)
end

-- function to add stock:
function AddStockFunction(id,val,num,shelf)
	ESX.TriggerServerCallback('t1ger_shops:getUserInventory', function(inventory)
		local list_items = {}
		if next(inventory) then
			-- items:
			for k,v in ipairs(inventory) do
				if v.count > 0 then
					if Config.ItemCompatibility == true then
						for _,y in pairs(Config.Items) do
							if v.name == y.item then
								for arr,shop_type in pairs(y.type) do
									if val.type == shop_type then 
										local inv_label = ('<span style="color:GoldenRod;">%sx</span> %s'):format(v.count,v.label)
										table.insert(list_items, {label = inv_label, value = v.name, shopID = id, shelf = shelf })
									end
									break
								end
								break
							end
						end
					else
						local inv_label = ('<span style="color:GoldenRod;">%sx</span> %s'):format(v.count,v.label)
						table.insert(list_items, {label = inv_label, value = v.name, shopID = id, shelf = shelf })
					end
				end
			end
			-- loadout weapons:
			local LoadoutFetched, AmmoFetched = false, false
			if Config.WeaponLoadout == true then
				ESX.TriggerServerCallback('t1ger_shops:getLoadout', function(loadout)
					if #loadout > 0 then
						local userLoadout = {}
						-- loadout:
						for k,v in pairs(loadout) do
							local inv_label = ('<span style="color:GoldenRod;">%sx</span> %s [loadout]'):format(1, v.label)
							table.insert(list_items, {label = inv_label, value = v.name, name = v.label, loadout = true, type = "weapon", ammo = v.ammo, shopID = id, shelf = shelf })
							table.insert(userLoadout, {label = inv_label, value = v.name, name = v.label, ammo = v.ammo, shopID = id, shelf = shelf })
							if k == #loadout then
								LoadoutFetched = true
							end
						end
						-- ammo:
						for k,v in pairs(Config.AmmoTypes) do
							for _,y in pairs(userLoadout) do 
								local ped_ammoType = GetPedAmmoTypeFromWeapon(player, GetHashKey(y.value))
								if ped_ammoType == v.hash and y.ammo > 0 then
									local inv_label = ('<span style="color:GoldenRod;">%sx</span> %s [loadout]'):format(y.ammo, v.label)
									table.insert(list_items, {label = inv_label, value = v.hash, name = v.label, loadout = true, type = "ammo", ammo = y.ammo, ammoType = ped_ammoType, weapon = y.value, shopID = id, shelf = shelf })
									break
								end
							end
							if k == #Config.AmmoTypes then AmmoFetched = true end
						end
					else
						LoadoutFetched = true
						AmmoFetched = true
					end
				end)
			else
				LoadoutFetched = true
				AmmoFetched = true
			end

			while not LoadoutFetched and not AmmoFetched do
				Citizen.Wait(10)
			end 

			if #list_items > 0 then
				local menu_title = 'User Inventory'; if Config.WeaponLoadout then menu_title = 'Inventory & Loadout' end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_restock_list_items',
					{
						title    = menu_title,
						align    = 'center',
						elements = list_items
					},
				function(data, menu)
					menu.close()
					-- menu 2
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shelf_restock_item_amount', {title = 'Enter Restock Amount'}, function(data2, menu2)
						local restock_amount = tonumber(data2.value)
						if restock_amount == nil or restock_amount == '' or restock_amount == 0 then
							TriggerEvent('t1ger_shops:notify', Lang['invalid_amount'])
						else
							-- menu 3
							menu2.close()
							ESX.TriggerServerCallback('t1ger_shops:doesItemExists', function(itemExists)
								if itemExists == nil or not itemExists then
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shelf_restock_item_price', {title = "Enter Item Price"}, function(data3, menu3)
										local restock_price = tonumber(data3.value)
										if restock_price == nil or restock_price == '' or restock_price == 0 then
											TriggerEvent('t1ger_shops:notify', Lang['invalid_amount'])
										else
											menu3.close()
											if Config.WeaponLoadout then
												if data.current.loadout then
													AddLoadoutStock(data.current,restock_amount,restock_price,id)
												else
													TriggerServerEvent('t1ger_shops:itemDeposit', data.current.value, restock_amount, restock_price, id, data.current.shelf)
												end
											else
												TriggerServerEvent('t1ger_shops:itemDeposit', data.current.value, restock_amount, restock_price, id, data.current.shelf)
											end
											OpenStockManageMenu(id,val,num,shelf)
										end
									end, function(data3, menu3)
										menu3.close()
										AddStockFunction(id,val,num,shelf)
									end)
								else
									if Config.WeaponLoadout then
										if data.current.loadout then
											AddLoadoutStock(data.current,restock_amount,0,id)
										else
											TriggerServerEvent('t1ger_shops:itemDeposit', data.current.value, restock_amount, 0, id, data.current.shelf)
										end
									else
										TriggerServerEvent('t1ger_shops:itemDeposit', data.current.value, restock_amount, 0, id, data.current.shelf)
									end
									OpenStockManageMenu(id,val,num,shelf)
								end
							end, id, data.current.value, shelf.type)
							-- menu 3 end
						end
					end, function(data2, menu2)
						menu2.close()
						AddStockFunction(id,val,num,shelf)
					end)
					-- menu 2 end

				end, function(data, menu)
					menu.close()
					OpenStockManageMenu(id,val,num,shelf)
				end)
			else
				TriggerEvent('t1ger_shops:notify', Lang['no_items_to_display'])
				OpenStockManageMenu(id,val,num,shelf)
			end
		else
			OpenStockManageMenu(id,val,num,shelf)
		end
	end, id)
end

-- function to remove stock:
function RemoveStockFunction(id,val,num,shelf)
	ESX.TriggerServerCallback('t1ger_shops:getItemStock', function(item_stock)
		local elements = {}
		if next(item_stock) then 
			for k,v in pairs(item_stock) do
				if shelf.type == v.type then
					local list_label = ('<span style="color:GoldenRod;">%sx</span> %s'):format(v.qty,v.label)
					table.insert(elements, {label = list_label, item = v.item, name = v.label, qty = v.qty, type = v.type, str_match = v.str_match})
				end
			end
			if #elements > 0 then 
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_stock_remove',
					{
						title    = 'Shelf Stock',
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					menu.close()
					-- menu 2
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shelf_remove_item_amount', {title = 'Enter Amount to Remove'}, function(data2, menu2)
						local remove_amount = tonumber(data2.value)
						if remove_amount == nil or remove_amount == '' or remove_amount == 0 or remove_amount > data.current.qty or (data.current.str_match == 'weapon' and remove_amount > 1) then
							TriggerEvent('t1ger_shops:notify', Lang['invalid_amount'])
						else
							menu2.close()
							if data.current.str_match ~= nil then
								if data.current.str_match == 'ammo' then
									local ammo_arr = {ammo_type = data.current.item, value = remove_amount, label = data.current.name, id = id, type = data.current.type, str_match = data.current.str_match}
									AddAmmoToLoadout(ammo_arr, nil, nil)
								elseif data.current.str_match == 'weapon' then
									local weapon_arr = {item = data.current.item, value = remove_amount, label = data.current.name, id = id, type = data.current.type, str_match = data.current.str_match}
									AddWeaponToLoadout(weapon_arr, nil, nil)
								end
							else
								TriggerServerEvent('t1ger_shops:itemWithdraw', data.current.item, data.current.name, remove_amount, id, data.current.type)
							end
							OpenStockManageMenu(id,val,num,shelf)
						end
					end, function(data2, menu2)
						menu2.close()
						RemoveStockFunction(id,val,num,shelf)
					end)
				end, function(data, menu)
					menu.close()
					OpenStockManageMenu(id,val,num,shelf)
				end)
			else
				TriggerEvent('t1ger_shops:notify', Lang['stock_inv_empty'])
				OpenStockManageMenu(id,val,num,shelf)
			end
		else
			TriggerEvent('t1ger_shops:notify', Lang['stock_inv_empty'])
			OpenStockManageMenu(id,val,num,shelf)
		end
	end, id)
end

-- change item price in shelf stock:
function ViewShelfStock(id,val,num,shelf)
	ESX.TriggerServerCallback('t1ger_shops:getItemStock', function(item_stock)
		local elements = {}
		if next(item_stock) then 
			for k,v in pairs(item_stock) do
				if shelf.type == v.type then
					local list_label = ('<span style="color:GoldenRod;">%sx</span> %s <span style="color:MediumSeaGreen;"> [ $%s ]</span>'):format(v.qty,v.label,v.price)
					table.insert(elements, {label = list_label, item = v.item, name = v.label, qty = v.qty, price = v.price, shelf = v.type})
				end
			end
			if #elements > 0 then 
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'view_shelf_item_stock',
					{
						title    = 'Shelf Overview',
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					local selected = data.current
					if isOwner == id then 
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_edit_selected_item', {
							title    = selected.name,
							align    = 'center',
							elements = {
								{label = 'Price', type = 'slider', value = selected.price, min = 1, max = 99999999, action = "price"},
							}
						}, function(data2, menu2)
							menu2.close()
							if data2.current.action == 'price' then
								TriggerServerEvent('t1ger_shops:updateItemPrice', id, shelf.type, selected.item, data2.current.value)
								TriggerEvent('t1ger_shops:notify', Lang['shelf_item_price_change']:format(selected.name,selected.price,data2.current.value))
								menu.close()
								OpenStockManageMenu(id,val,num,shelf)
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					end
				end, function(data, menu)
					menu.close()
					OpenStockManageMenu(id,val,num,shelf)
				end)
			else
				TriggerEvent('t1ger_shops:notify', Lang['stock_inv_empty'])
				OpenStockManageMenu(id,val,num,shelf)
			end
		else
			TriggerEvent('t1ger_shops:notify', Lang['stock_inv_empty'])
			OpenStockManageMenu(id,val,num,shelf)
		end
	end, id)
end

-- function to order stock:
function OrderStockFunction(id,val,num,shelf)
	local elements = {}
	for k,v in pairs(Config.Items) do
		for arr,itemType in pairs(v.type) do
			if val.type == itemType then 
				local order_item = v.item
				if v.str_match ~= nil and v.str_match == "ammo" and Config.WeaponLoadout then
					order_item = v.ammo_type
				end  
				local string_match = nil
				if v.str_match ~= nil then
					string_match = v.str_match
				end
				table.insert(elements, {label = v.label, item = order_item, price = v.price, str_match = string_match})
				break
			end
		end
	end
	if #elements > 0 then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_order_item_stock', {
			title    = "Shelf ["..shelf.drawText.."] Order",
			align    = 'center',
			elements = elements
		}, function(data, menu)
			local selected = data.current
			-- menu 2 start:
			menu.close()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'order_item_amount', {
				title = 'Enter Amount to Order'
			}, function(data2, menu2)
				local amount = tonumber(data2.value)
				if amount then 
					menu2.close()
					local item_price = (selected.price*(1-(Config.OrderItemPercent/100)))
					local order_price = math.floor(item_price * amount)
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'order_stock_confirmation', {
						title    = "Confirm Order Price: [$"..order_price.."]",
						align    = 'center',
						elements = {
							{label = 'No',  value = 'button_no'},
							{label = 'Yes', value = 'button_yes'},
						}
					}, function(data3, menu3)
						if data3.current.value == 'button_yes' then
							menu3.close()
							ESX.TriggerServerCallback('t1ger_shops:payStockOrder', function(orderPaid)
								if orderPaid then
									TriggerServerEvent('t1ger_shops:createOrder', id, selected.label, selected.item, selected.str_match, amount, selected.price, order_price, shelf.type)
								else
									TriggerEvent('t1ger_shops:notify', Lang['insufficient_money'])
								end
							end, id, order_price)
							OpenStockManageMenu(id,val,num,shelf)
						end
						menu3.close()
					end, function(data3, menu3)
						menu3.close()
						OrderStockFunction(id,val,num,shelf)
					end)
				else
					TriggerEvent('t1ger_shops:notify', Lang['invalid_amount'])
				end
			end,
			function(data2, menu2)
				menu2.close()
				OrderStockFunction(id,val,num,shelf)
			end)
			-- menu 2 end:
		end, function(data, menu)
			menu.close()
			OpenStockManageMenu(id,val,num,shelf)
		end)
	else
		menu.close()
		print("no items available for ordering")
		OpenStockManageMenu(id,val,num,shelf)
	end
end

-- ## SHELF MANAGEMENT ## --

-- Comand to open shelve management menu:
RegisterCommand(Config.ShelfCommand, function(source, args)
	if isOwner > 0 then 
		local loc = Config.Shops[isOwner].cashier
		if #(coords - vector3(loc[1], loc[2], loc[3])) < 15.0 then
			OpenShelfManageMenu(isOwner)
		else
			TriggerEvent('t1ger_shops:notify', Lang['not_inside_your_shop'])
		end
	end
end, false)


-- function to open menu:
function OpenShelfManageMenu(id)
	local elements = {
		{label = 'Add Shelf', value = 'add_shelf'},
		{label = 'Remove Shelf', value = 'remove_shelf'}
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_interaction_menu',
		{
			title    = 'Shelf Management Menu',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		menu.close()
		if data.current.value == 'add_shelf' then
			AddShelfMenu(id)
		end
		if data.current.value == 'remove_shelf' then
			RemoveShelfMenu(id)
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- function to add new shelf in shop:
function AddShelfMenu(id)
	local pos = {round(coords.x,2),round(coords.y,2),round(coords.z,2),round(GetEntityHeading(player),2)}
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shelf_enter_type', {
		title = "Enter Shelf Type: "
	}, function(data, menu)
		--menu.close()
		if data.value == nil or data.value == '' then
			TriggerEvent('t1ger_shops:notify', Lang['invalid_string'])
		else
			menu.close()
			local type = string.lower(data.value)
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shelf_enter_drawText', {
				title = "Enter Shelf 3D Text: "
			}, function(data2, menu2)
				if data2.value == nil or data2.value == '' then
					TriggerEvent('t1ger_shops:notify', Lang['invalid_string'])
				else
					menu2.close()
					local fixChars = string.lower(data2.value)
					local text = (fixChars):gsub("^%l", string.upper)
					local elements = {
						{label = 'Confirm New Shelf', value = 'confirm_new_shelf'},
						{label = 'Pos: ('..pos[1]..', '..pos[2]..', '..pos[3]..', '..pos[4]..')'},
						{label = 'Type: '..type},
						{label = '3D Text: '..text}
					}
					ESX.UI.Menu.CloseAll()
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'new_shelf_overview',
						{
							title    = 'New Shelf View',
							align    = "center",
							elements = elements
						},
					function(data3, menu3)
						if data3.current.value == 'confirm_new_shelf' then 
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'new_shelf_final_confirmation', {
								title    = 'Final Confirmation',
								align    = 'center',
								elements = {
									{label = 'No',  value = 'button_no'},
									{label = 'Yes', value = 'button_yes'},
								}
							}, function(data4, menu4)
								if data4.current.value == 'button_yes' then
									local table = {pos = pos, type = type, drawText = text}
									TriggerServerEvent('t1ger_shops:updateShelves', id, table, true)
									menu3.close()
								end
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		end
	end,
	function(data, menu)
		menu.close()
		OpenShelfManageMenu(id)
	end)
end

-- function to remove a shelf from shop:
function RemoveShelfMenu(id)
	local elements = {}
	ESX.TriggerServerCallback('t1ger_shops:fetchShelves', function(shelves)
		if #shelves > 0 then
			for k,v in pairs(shelves) do 
				table.insert(elements, {label = v.drawText, pos = v.pos, type = v.type, drawText = v.drawText})
			end
			ESX.UI.Menu.CloseAll()
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelves_list_menu',
				{
					title    = 'Shop Shelves',
					align    = 'center',
					elements = elements
				},
			function(data, menu)
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shelf_confirm_removal', {
					title    = 'Confirm Removal',
					align    = 'center',
					elements = {
						{label = 'No',  value = 'button_no'},
						{label = 'Yes', value = 'button_yes'},
					}
				}, function(data2, menu2)
					if data2.current.value == 'button_yes' then
						local chk = data.current
						local table = {pos = chk.pos, type = chk.type, drawText = chk.drawText}
						TriggerServerEvent('t1ger_shops:updateShelves', id, table, false)
						menu.close()
					end
					menu2.close()
				end, function(data2, menu2)
					menu2.close()
				end)
			end, function(data, menu)
				menu.close()
			end)
		else
			TriggerEvent('t1ger_shops:notify', Lang['no_shelves'])
		end
	end, id)
end

-- ## WEAPON / AMMO ## --

RegisterNetEvent('t1ger_shops:addAmmoClient')
AddEventHandler('t1ger_shops:addAmmoClient', function(weapon, amount)
	local add_amount = (GetAmmoInPedWeapon(player, weapon) + amount)
	SetPedAmmo(player, weapon, add_amount)
end)

function AddAmmoToLoadout(item, price, paymentType)
	ESX.TriggerServerCallback('t1ger_shops:getLoadout', function(loadout)
		local selected_weapon = GetSelectedPedWeapon(player)
		if selected_weapon ~= -1569615261 then
			local ped_ammoType = GetPedAmmoTypeFromWeapon(player, selected_weapon)
			if item.ammo_type == ped_ammoType then
				for k,v in pairs(loadout) do
					if selected_weapon == GetHashKey(v.name) then
						local cur_ammo = GetAmmoInPedWeapon(player, v.name)
						local new_ammo = (cur_ammo + item.value)
						if new_ammo <= 250 then 
							SetPedAmmo(player, v.name, new_ammo)
							if price ~= nil or paymentType ~= nil then 
								TriggerServerEvent('t1ger_shops:purchaseAmmo', item, price, paymentType)
							else
								TriggerServerEvent('t1ger_shops:loadoutWithdraw', item.ammo_type, item.label, item.value, item.id, item.type, item.str_match)
							end
						else
							TriggerEvent('t1ger_shops:notify', Lang['ammo_limit_exceed'])
						end
						break
					else
						if k == #loadout then
							TriggerEvent('t1ger_shops:notify', Lang['ammo_unavailable'])
						end
					end
				end
			else
				TriggerEvent('t1ger_shops:notify', Lang['ammo_incompatible'])
			end
		else
			TriggerEvent('t1ger_shops:notify', Lang['hold_wep_in_hands'])
		end
	end)
end

function AddWeaponToLoadout(item, price, paymentType)
	ESX.TriggerServerCallback('t1ger_shops:getLoadout', function(loadout)
		if #loadout > 0 then 
			for k,v in pairs(loadout) do
				if item.item == v.name then
					TriggerEvent('t1ger_shops:notify', Lang['wep_already_in_loadout'])
					break
				else
					if k == #loadout then
						if price ~= nil or paymentType ~= nil then 
							TriggerServerEvent('t1ger_shops:purchaseWeapon', item, price, paymentType)
						else
							TriggerServerEvent('t1ger_shops:loadoutWithdraw', item.item, item.label, item.value, item.id, item.type, item.str_match)
						end
					end
				end
			end
		else
			if price ~= nil or paymentType ~= nil then 
				TriggerServerEvent('t1ger_shops:purchaseWeapon', item, price, paymentType)
			else
				TriggerServerEvent('t1ger_shops:loadoutWithdraw', item.item, item.label, item.value, item.id, item.type, item.str_match)
			end
		end
	end)
end

-- function to add loadout stock:
function AddLoadoutStock(selected_item,amount,price,id)
	local selected = selected_item 
	local ammoType = 'N/A'; if selected.ammoType ~= nil then ammoType = selected.ammoType end
	if selected.type == "ammo" then
		if amount > selected.ammo then 
			TriggerEvent('t1ger_shops:notify', Lang['ammo_restock_amount'])
		else
			local new_ammo = (selected.ammo - amount)
			SetPedAmmo(player, selected.weapon, new_ammo)
			TriggerServerEvent('t1ger_shops:loadoutDeposit', selected, amount, price, id, selected.shelf)
		end
	elseif selected.type == "weapon" then
		if amount > 1 then
			TriggerEvent('t1ger_shops:notify', Lang['wep_restock_amount'])
		else
			TriggerServerEvent('t1ger_shops:loadoutDeposit', selected, amount, price, id, selected.shelf)
		end
	end
end

-- Function to empty basket:
function EmptyShopBasket(reason)
    if reason ~= nil then
        TriggerServerEvent('t1ger_shops:emptyShopBasket', basket.shopID, basket.items)
        Citizen.Wait(200)
		TriggerEvent('t1ger_shops:notify', reason)
    end
    basket.bill = 0
    basket.items = {}
    basket.shopID = 0
end

-- Check if item exists in basket:
function IsItemInBasket(item)
    for i = 1, #basket.items do if item == basket.items[i].item then return true, i end end
    return false, nil
end

-- Update Shops CFG Data:
RegisterNetEvent('t1ger_shops:updateShopsDataCL')
AddEventHandler('t1ger_shops:updateShopsDataCL', function(id, data, results)
	Config.Shops[id].data = data
	shops = results
end)