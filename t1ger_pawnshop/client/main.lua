-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
player = nil
coords = {}

Citizen.CreateThread(function()
    while true do
		player = PlayerPedId()
		coords = GetEntityCoords(player)
        Citizen.Wait(500)
    end
end)

local curShop = nil
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Pawnshops) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			if curShop ~= nil then
				distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, curShop.pos[1], curShop.pos[2], curShop.pos[3], false)
				while curShop ~= nil and distance > 1.0 do curShop = nil; Citizen.Wait(1) end
				if curShop == nil then ESX.UI.Menu.CloseAll() end
			else
				local mk = v.marker
				if distance <= mk.drawDist then
					sleep = false
					if distance >= 1.0 and mk.enable then 
						DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3] - 0.975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
					elseif distance < 1.0 then
						DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], v.drawText)
						if IsControlJustPressed(0, v.keyBind) then
							curShop = v
							OpenPawnshopMenu(k,v)
						end
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
    end
end)

-- Pawnshop Menu:
function OpenPawnshopMenu(id,val)
	local elements = {
		{ label = Lang['buy'], value = 'buy' },
		{ label = Lang['sell'], value = 'sell' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pawnshop_main_menu',
		{
			title    = 'Pawnshop',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'buy' then
			OpenBuyMenu(id,val)
		end
		if data.current.value == 'sell' then
			OpenSellMenu(id,val)
		end
	end, function(data, menu)
		menu.close()
		curShop = nil
	end)
end

-- Pawnshop Buy Menu:
function OpenBuyMenu(id,val)
	local elements = {}

	for k,v in ipairs(Config.Items) do
		if v.buy.enable then
			table.insert(elements, {label = v.label .. " | "..('<span style="color:green;">%s</span>'):format("$"..v.buy.price..""), item = v.name, name = v.label, price = v.buy.price})
		end
	end
	table.insert(elements, {label = Lang['button_return'], value = 'return'})

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pawnshop_buy_menu',
		{
			title    = Lang['buy_menu_title'],
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'return' then 
			menu.close()
		else
			ESX.UI.Menu.CloseAll()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pawnshop_buy_dialog', {
				title = 'Amount to Buy?'
			}, function(data2, menu2)
				local amount = tonumber(data2.value)
				if amount == nil or amount == '' then
					ShowNotifyESX(Lang['invalid_amount'])
				else
					menu2.close()
					local amount = tonumber(data2.value)
					local total_price = tonumber(data.current.price * amount)
					TriggerServerEvent('t1ger_pawnshop:buyItem', amount, total_price, data.current.item, data.current.name)
					OpenPawnshopMenu(id,val)
				end
			end,
			function(data2, menu2)
				menu2.close()	
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- Pawnshop Sell Menu:
function OpenSellMenu(id,val)
	local elements = {}

	for k,v in ipairs(Config.Items) do
		if v.sell.enable then
			table.insert(elements, {label = v.label .. " | "..('<span style="color:green;">%s</span>'):format("$"..v.sell.price..""), item = v.name, name = v.label, price = v.sell.price})
		end
	end
	table.insert(elements, {label = Lang['button_return'], value = 'return'})

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pawnshop_sell_menu',
		{
			title    = Lang['sell_menu_title'],
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'return' then 
			menu.close()
		else
			ESX.UI.Menu.CloseAll()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pawnshop_sell_dialog', {
				title = 'Amount to Sell?'
			}, function(data2, menu2)
				local amount = tonumber(data2.value)
				if amount == nil or amount == '' then
					ShowNotifyESX(Lang['invalid_amount'])
				else
					menu2.close()
					local amount = tonumber(data2.value)
					local total_price = tonumber(data.current.price * amount)
					TriggerServerEvent('t1ger_pawnshop:sellItem', amount, total_price, data.current.item, data.current.name)
					OpenPawnshopMenu(id,val)
				end
			end,
			function(data2, menu2)
				menu2.close()	
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- Create Pawnshop Blips:
Citizen.CreateThread(function()
	for k,v in pairs(Config.Pawnshops) do
		local bp = v.blip
		if bp.enable then
			local blip = AddBlipForCoord(v.pos[1], v.pos[2], v.pos[3])
			SetBlipSprite(blip, bp.sprite)
			SetBlipDisplay(blip, bp.display)
			SetBlipScale  (blip, bp.scale)
			SetBlipColour (blip, bp.color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(bp.name)
			EndTextCommandSetBlipName(blip)
		end
	end
end)