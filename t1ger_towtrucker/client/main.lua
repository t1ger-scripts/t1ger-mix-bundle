-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local player, coords, ply_veh = nil, {}, nil
Citizen.CreateThread(function()
    while true do
        player = PlayerPedId()
        coords = GetEntityCoords(player)
		if IsPedInAnyVehicle(player, false) then
			ply_veh = GetVehiclePedIsIn(player, false)
		end
        Citizen.Wait(500)
    end
end)

local towServices = {}
local towBlips = {}
local isOwner = 0
local towID = 0

RegisterNetEvent('t1ger_towtrucker:loadTowServices')
AddEventHandler('t1ger_towtrucker:loadTowServices', function(results, cfg, num, id)
	Config.TowServices = cfg
	towServices = results
	isOwner = num
	TriggerEvent('t1ger_towtrucker:setTowID', id)
	Citizen.Wait(200)
	UpdateTowServiceBlips()
end)

RegisterNetEvent('t1ger_towtrucker:syncTowServices')
AddEventHandler('t1ger_towtrucker:syncTowServices', function(results, cfg)
	Config.TowServices = cfg
	towServices = results
	Citizen.Wait(200)
	UpdateTowServiceBlips()
end)

RegisterNetEvent('t1ger_towtrucker:setTowID')
AddEventHandler('t1ger_towtrucker:setTowID', function(id)
	towID = id
end)

function UpdateTowServiceBlips()
	for k,v in pairs(towBlips) do
		RemoveBlip(v)
	end
	for i = 1, #Config.TowServices do
		if Config.TowServices[i].owned == true then
            CreateTowServiceBlip(Config.TowServices[i], towServices[i])
		else
			CreateTowServiceBlip(Config.TowServices[i], nil)
		end
	end
end

function CreateTowServiceBlip(cfg, data)
	local mk = Config.BlipSettings['service']
	local bName = mk.name; if data ~= nil then bName = data.name end
	if mk.enable then
		local blip = AddBlipForCoord(cfg.boss_pos.x, cfg.boss_pos.y, cfg.boss_pos.z)
		SetBlipSprite (blip, mk.sprite)
		SetBlipDisplay(blip, mk.display)
		SetBlipScale  (blip, mk.scale)
		SetBlipColour (blip, mk.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(bName)
		EndTextCommandSetBlipName(blip)
		table.insert(towBlips, blip)
	end
end

-- ## BOSS / MANAGE ## --

local bossMenu = nil
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
		local sleep = true 
		for k,v in pairs(Config.TowServices) do
			local bossDistance = #(coords - v.boss_pos)
			if bossDistance < 6.0 then
				sleep = false
				if bossMenu ~= nil then
					bossDistance = #(coords - bossMenu.boss_pos)
					while bossMenu ~= nil and bossDistance > 1.5 do
						bossMenu = nil
						Citizen.Wait(1)
					end
					if bossMenu == nil then
						ESX.UI.Menu.CloseAll()
					end
				else
					local mk = Config.MarkerSettings['boss']
					if bossDistance >= 2.0 then
						if mk.enable then
							DrawMarker(mk.type, v.boss_pos.x, v.boss_pos.y, v.boss_pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
						end
					elseif bossDistance < 2.0 then
						if v.owned == true then
							if (T1GER_isJob(Config.Society[v.society].name)) or (isOwner == k) then
								T1GER_DrawTxt(v.boss_pos.x, v.boss_pos.y, v.boss_pos.z, Lang['draw_service_menu'])
								if IsControlJustPressed(0, Config.KeyControls['service_menu']) then
									bossMenu = v
									OpenTowServiceMenu(k,v)
								end
							else
								T1GER_DrawTxt(v.boss_pos.x, v.boss_pos.y, v.boss_pos.z, Lang['draw_service_no_access'])
							end
						else
							if (T1GER_isJob(Config.Society[v.society].name) and PlayerData.job.grade_name ~= 'boss') or (isOwner == 0) then
								T1GER_DrawTxt(v.boss_pos.x, v.boss_pos.y, v.boss_pos.z, Lang['draw_buy_service']:format(comma_value(math.floor(v.price))))
								if IsControlJustPressed(0, Config.KeyControls['buy_service']) then
									bossMenu = v
									PurchaseTowService(k,v)
								end
							else
								T1GER_DrawTxt(v.boss_pos.x, v.boss_pos.y, v.boss_pos.z, Lang['draw_service_own_one'])
							end
						end
					end
				end
			end
		end
		if sleep then
			Citizen.Wait(1000)
		end
    end
end)

function PurchaseTowService(id,val)
	local elements = {
		{ label = 'No', value = 'decline_purchase' },
		{ label = 'Yes', value = 'confirm_purchase' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tow_service_purchase_confirmation',
		{
			title    = 'Confirm | Price: $'..comma_value(math.floor(val.price)),
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value ~= 'decline_purchase' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'enter_service_name', {
				title = 'Enter Tow Service Name'
			}, function(data2, menu2)
				local name = tostring(data2.value)
				if name == nil or name == '' then
					TriggerEvent('t1ger_towtrucker:notify', Lang['invalid_string'])
				else
					menu2.close()
					ESX.TriggerServerCallback('t1ger_towtrucker:buyTowService', function(purchased)
						if purchased then
							TriggerEvent('t1ger_towtrucker:notify', (Lang['service_purchased']):format(comma_value(math.floor(val.price))))
							isOwner = id
							TriggerServerEvent('t1ger_towtrucker:updateTowServices', id, val, true, name)
						else
							TriggerEvent('t1ger_towtrucker:notify', Lang['not_enough_money'])
						end
					end, id, val, name)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		end
		menu.close()
		bossMenu = nil
	end, function(data, menu)
		menu.close()
		bossMenu = nil
	end)
end

function OpenTowServiceMenu(id,val)
	ESX.UI.Menu.CloseAll()
	local elements = {}
	if (T1GER_isJob(Config.Society[val.society].name) and PlayerData.job.grade_name == 'boss') or isOwner == id then
		table.insert(elements, {label = 'Rename Tow Service', value = 'rename_tow_service'})
		table.insert(elements, {label = 'Sell Tow Service', value = 'sell_tow_service'})
		table.insert(elements, {label = 'Boss Menu', value = 'boss_menu'})
	end
	if #elements > 0 then 
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tow_service_main',
			{
				title    = 'Tow Service ['..tostring(id)..']',
				align    = 'center',
				elements = elements
			},
		function(data, menu)
			local action = data.current.value
			if action == 'rename_tow_service' then
				RenameTowService(id,val)
			elseif action == 'sell_tow_service' then
				SellTowService(id,val)
			elseif action == 'boss_menu' then
				BossMenu(id,val)
			end
		end, function(data, menu)
			menu.close()
			bossMenu = nil
		end)
	else
		TriggerEvent('t1ger_towtrucker:notify', Lang['boss_menu_no_access'])
		bossMenu = nil
	end
end

function RenameTowService(id,val)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_tow_service', {
		title = 'Enter Tow Service Name'
	}, function(data, menu)
		local name = tostring(data.value)
		if name == nil or name == '' then
			TriggerEvent('t1ger_towtrucker:notify', Lang['invalid_string'])
		else
			menu.close()
			TriggerServerEvent('t1ger_towtrucker:updateTowServices', id, val, nil, name)
			TriggerEvent('t1ger_towtrucker:notify', Lang['tow_service_renamed'])
			OpenTowServiceMenu(id,val)
		end
	end,
	function(data, menu)
		menu.close()
		OpenTowServiceMenu(id,val)
	end)
end

function SellTowService(id,val)
	local sellPrice = (val.price * Config.SalePercentage)
	local elements = {
		{ label = 'No', value = 'decline_sale' },
		{ label = 'Yes', value = 'confirm_sale' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tow_service_sell_confirmation',
		{
			title    = 'Confirm Sale | Price: $'..comma_value(math.floor(sellPrice)),
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'confirm_sale' then
			ESX.UI.Menu.CloseAll()
			TriggerServerEvent('t1ger_towtrucker:sellTowService', id, val, math.floor(sellPrice))
			TriggerServerEvent('t1ger_towtrucker:updateTowServices', id, val, false, nil)
			isOwner = 0
			TriggerEvent('t1ger_towtrucker:notify', (Lang['service_sold']):format(comma_value(math.floor(sellPrice))))
			bossMenu = nil
		else
			menu.close()
			OpenTowServiceMenu(id,val)
		end
	end, function(data, menu)
		menu.close()
		OpenTowServiceMenu(id,val)
	end)
end

function BossMenu(id,val)
	local cfg = Config.Society[val.society]
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_main_menu',
		{
			title    = cfg.label,
			align    = 'center',
			elements = {
				{ label = 'Boss Actions', value = 'boss_actions', job = cfg.name },
				{ label = 'Account Balance', value = 'get_balance', job = cfg.name}
			}
		},
	function(data, menu)
		if data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', data.current.job, function(data, menu)
				menu.close()
			end, {withdraw = cfg.withdraw, deposit = cfg.deposit, wash = cfg.wash, employees = cfg.employees, grades = cfg.grades})
		elseif data.current.value == 'get_balance' then
			ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(amount)
				TriggerEvent('t1ger_towtrucker:notify', Lang['get_account_balance']:format(comma_value(amount)))
			end, data.current.job)
		end
	end, function(data, menu)
		menu.close()
		OpenTowServiceMenu(id,val)
	end)
end

-- ## IMPOUND ## --

local impoundMenu = nil
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
		local sleep = true 
		for k,v in pairs(Config.TowServices) do
			local impoundDist = #(coords - vector3(v.impound_pos.x, v.impound_pos.y, v.impound_pos.z))
			if impoundDist < 6.0 then
				sleep = false
				if impoundMenu ~= nil then
					impoundDist = #(coords - vector3(impoundMenu.impound_pos.x, impoundMenu.impound_pos.y, impoundMenu.impound_pos.z))
					while impoundMenu ~= nil and impoundDist > 1.5 do
						impoundMenu = nil
						Citizen.Wait(1)
					end
					if impoundMenu == nil then
						ESX.UI.Menu.CloseAll()
					end
				else
					local mk = Config.MarkerSettings['impound']
					if impoundDist >= 2.0 then
						if mk.enable then
							DrawMarker(mk.type, v.impound_pos.x, v.impound_pos.y, v.impound_pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
						end
					elseif impoundDist < 2.0 then
						if v.owned == true then
							if (T1GER_isJob(Config.Society[v.society].name)) or (isOwner == k) then
								T1GER_DrawTxt(v.impound_pos.x, v.impound_pos.y, v.impound_pos.z, Lang['draw_impound_menu'])
								if IsControlJustPressed(0, Config.KeyControls['impound_menu']) then
									impoundMenu = v
									OpenImpoundMenu(k,v)
								end
							end
						end
					end
				end
			end
		end
		if sleep then
			Citizen.Wait(1000)
		end
    end
end)

function OpenImpoundMenu(id,val)
	ESX.UI.Menu.CloseAll()
	local elements = {
		{ label = 'Impound List', value = 'impound_list' },
	}
	if IsPedInAnyVehicle(player, 0) then
		table.insert(elements, {label = 'Impound Vehicle', value = 'impound_vehicle'})
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tow_impound_main',
		{
			title    = 'Impound ['..tostring(id)..']',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'impound_list' then
			ImpoundList(id,val)
		end
		if data.current.value == 'impound_vehicle' then
			ImpoundCurrentVehicle(id,val)
		end
	end, function(data, menu)
		menu.close()
		impoundMenu = nil
	end)
end

function ImpoundList(id,val)
	local elements = {}
	ESX.TriggerServerCallback('t1ger_towtrucker:GetImpoundVehicles', function(impoundList)
		if impoundList ~= nil then
			if next(impoundList) then
				for k,v in pairs(impoundList) do
					local props = json.decode(v.props)
					local veh_label = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
					table.insert(elements, {
						label = veh_label..' ['..v.plate..']',
						name = veh_label,
						value = v,
						plate = v.plate, 
						vehicle = props, 
						owner = v.owner
					})
				end
				if next(elements) then
					ESX.UI.Menu.CloseAll()
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'impound_veh_list',
						{
							title    = 'Click to Release Vehicle',
							align    = 'center',
							elements = elements
						},
					function(data, menu)
						if data.current.value ~= nil then 
							ESX.Game.SpawnVehicle(data.current.vehicle.model, {x = val.impound_pos.x, y = val.impound_pos.y, z = (val.impound_pos.z + 1.0)}, val.impound_pos.w, function(impoundVehicle)
								ESX.Game.SetVehicleProperties(impoundVehicle, data.current.vehicle)
								SetVehRadioStation(impoundVehicle, "OFF")
								TaskWarpPedIntoVehicle(player, impoundVehicle, -1)
								SetVehicleFuelLevel(impoundVehicle, 100.0)
								if Config.T1GER_Keys then
									exports['t1ger_keys']:SetVehicleLocked(impoundVehicle, 0)
								end
							end)
							TriggerServerEvent('t1ger_towtrucker:releaseImpound', id, data.current.plate, data.current.vehicle, data.current.owner)
							ESX.UI.Menu.CloseAll()
							impoundMenu = nil
						end
					end, function(data, menu)
						OpenImpoundMenu(id,val)
					end)
				else
					return TriggerEvent('t1ger_towtrucker:notify', Lang['no_impound_vehicles'])
				end
			end
		else
			return TriggerEvent('t1ger_towtrucker:notify', Lang['no_impound_vehicles'])
		end
	end, id)
end

function ImpoundCurrentVehicle(id,val)
	local elements = {
		{ label = 'No', value = 'decline_impound' },
		{ label = 'Yes', value = 'confirm_impound' },
	}
	local vehicle = GetVehiclePedIsIn(player, false)
	local props = ESX.Game.GetVehicleProperties(vehicle)
	local plate = tostring(GetVehicleNumberPlateText(vehicle))
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tow_service_impound_confirmation',
		{
			title    = 'Impound Vehicle? ['..plate..']',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value ~= 'decline_impound' then
			ESX.TriggerServerCallback('t1ger_towtrucker:impoundVehicle',function(impounded, notify)
				if impounded then
					DeleteVehicle(vehicle)
				end
				TriggerEvent('t1ger_towtrucker:notify', notify)
				ESX.UI.Menu.CloseAll()
				impoundMenu = nil
			end, id, plate, props)
		end
	end, function(data, menu)
		OpenImpoundMenu(id,val)
	end)
end

function IsVehicleInTowImpound(plate)
	local isImpounded, impoundID, name, checked = false, 0, nil, false
	ESX.TriggerServerCallback('t1ger_towtrucker:isVehicleInTowImpound', function(state, id)
		isImpounded = state
		impoundID = id
		checked = true
	end, plate)
	while not checked do 
		Citizen.Wait(10)
	end
	if towServices[impoundID] ~= nil then
		name = towServices[impoundID].name
	end
	return isImpounded, impoundID, name
end

-- ## GARAGE ## --

local garageMenu = nil
Citizen.CreateThread(function()
	Citizen.Wait(2000)
	while true do 
		Citizen.Wait(1)
		local sleep = true 
		for k,v in pairs(Config.TowServiceGarage) do
			if v.enable == true then 
				local garageDist = #(coords - vector3(v.pos.x, v.pos.y, v.pos.z))
				if garageDist < 6.0 then
					sleep = false
					if garageMenu ~= nil then
						garageDist = #(coords - vector3(garageMenu.pos.x, garageMenu.pos.y, garageMenu.pos.z))
						while garageMenu ~= nil and garageDist > 1.5 do
							garageMenu = nil
							Citizen.Wait(1)
						end
						if garageMenu == nil then
							ESX.UI.Menu.CloseAll()
						end
					else
						local mk = Config.MarkerSettings['garage']
						if garageDist >= 2.0 then
							if mk.enable then
								DrawMarker(mk.type, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
							end
						elseif garageDist < 2.0 then
							if Config.TowServices[k].owned == true then
								if (T1GER_isJob(Config.Society[Config.TowServices[k].society].name)) or (isOwner == k) then
									if IsPedInAnyVehicle(player, true) then 
										T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, Lang['draw_store_del_veh'])
									else
										T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, Lang['draw_garage_menu'])
									end
									if IsControlJustPressed(0, Config.KeyControls['garage_menu']) then
										garageMenu = v
										OpenGarageMenu(k,v)
									end
								end
							end
						end
					end
				end
			end
		end
		if sleep then
			Citizen.Wait(1000)
		end
	end
end)

function OpenGarageMenu(id,val)
	local vehicle = GetVehiclePedIsIn(player, false)
	if vehicle ~= 0 and DoesEntityExist(vehicle) then
		if DoesEntityExist(vehicle) then 
			DeleteVehicle(vehicle)
			garageMenu = nil
		end
	else
		local elements = {}
		for k,v in ipairs(val.vehicles) do
			if PlayerData.job.grade >= v.grade then
				table.insert(elements, {label = v.label, model = v.model})
			end
		end
		if next(elements) == nil then 
			garageMenu = nil
			ESX.UI.Menu.CloseAll()
			return TriggerEvent('t1ger_towtrucker:notify', 'No job vehicles available.')
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tow_job_veh_list',
			{
				title    = 'Select Job Vehicle',
				align    = 'center',
				elements = elements
			},
		function(data, menu)
			SpawnJobVehicle(val, data.current.model, data.current.label, data.current.jobs)
			ESX.UI.Menu.CloseAll()
			garageMenu = nil
		end, function(data, menu)
			menu.close()
			garageMenu = nil
		end)
	end
end

function SpawnJobVehicle(val, model, name)
	ESX.Game.SpawnVehicle(model, vector3(val.pos.x,val.pos.y,val.pos.z), val.pos.w, function(vehicle)
		while not DoesEntityExist(vehicle) do
			Wait(5)
		end
		if val.teleport then 
			TaskWarpPedIntoVehicle(player, vehicle, -1)
		end
		local plate = 'TOWTRUCK'
		if Config.T1GER_Dealerships then 
			plate = exports['t1ger_dealerships']:ProduceNumberPlate()
		else
			-- insert your own plate generation function/export in here
		end
		SetVehicleNumberPlateText(vehicle, plate)
		if Config.T1GER_Keys then
			exports['t1ger_keys']:SetVehicleLocked(vehicle, 0)
			exports['t1ger_keys']:GiveJobKeys(plate, name, true)
		end
		SetVehicleFuelLevel(vehicle, val.fuel)
	end)
end

-- ## TOW TRUCKER INTERACTION MENU ## --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0, Config.KeyControls['interaction_menu']) then
			if Config.TowServices[towID] ~= nil then
				if T1GER_isJob(Config.Society[Config.TowServices[towID].society].name) then
					OpenTowTruckerActionMenu()
				end
			end
		end
	end
end)

RegisterCommand(Config.InteractionMenuCmd, function(source, args)
	if T1GER_isJob(Config.Society[Config.TowServices[towID].society].name) then
		OpenTowTruckerActionMenu()
	end
end, false)

local holdingObj, carryModel = false, 0

function OpenTowTruckerActionMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {
		{ label = 'Billing', value = 'billing' },
		{ label = 'Impound Vehicle',  value = 'impound_vehicle' },
		{ label = 'Unlock Vehicle',  value = 'unlock_vehicle'},
		{ label = 'Flip Vehicle',  value = 'flip_vehicle'},
		{ label = 'Push Vehicle',  value = 'push_vehicle'},
		{ label = 'Tow/Detach Vehicle',  value = 'flatbed_tow'},
		{ label = 'Prop Emotes',  value = 'prop_emotes'},
		{ label = 'NPC Jobs', value = 'npc_jobs' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'towtrucker_action_main_menu',
		{
			title    = 'Tow Trucker Menu',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		local action = data.current.value
		if action == 'billing' then
			Billing()
		elseif action == 'impound_vehicle' then
			ImpoundClosestVehicle()
		elseif action == 'unlock_vehicle' then
			UnlockClosestVehicle()
		elseif action == 'flip_vehicle' then 
			FlipClosestVehicle()
		elseif action == 'push_vehicle' then 
			PushClosestVehicle()
		elseif action == 'flatbed_tow' then 
			FlatbedTowFunction()
		elseif action == 'prop_emotes' then
			if IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
				TriggerEvent('t1ger_towtrucker:notify', Lang['action_not_possible'])
			else
				menu.close()
				if not holdingObj then 
					CarryObjectsMainMenu()
				else
					TriggerEvent('t1ger_towtrucker:notify', Lang['already_holding_obj'])
				end
			end
		elseif action == 'npc_jobs' then
			TowTruckerJobs()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function Billing()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'towtrucker_billing_dialog', {title = 'Invoice Amount' }, function(data, menu)
		local amount = tonumber(data.value)
		if amount then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer == -1 or closestDistance > 3.0 then
				TriggerEvent('t1ger_towtrucker:notify', Lang['no_players_nearby'])
			else
				local cfg = Config.Society[Config.TowServices[towID].society]
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), cfg.account, cfg.label, amount)
			end
		else
			TriggerEvent('t1ger_towtrucker:notify', Lang['invalid_amount'])
		end
	end, function(data, menu)
		menu.close()	
		OpenTowTruckerActionMenu()
	end)
end

function ImpoundClosestVehicle()
	local cfg = Config.ImpoundVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local impounded = false
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		T1GER_GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
		local impound_pos = GetOffsetFromEntityInWorldCoords(targetVeh, d1.x-0.2,0.0,0.0)
		while not impounded do 
			Citizen.Wait(1)
			local dist = #(coords - vector3(impound_pos.x, impound_pos.y, impound_pos.z))
			if dist < cfg.drawText.dist then
				T1GER_DrawTxt(impound_pos.x, impound_pos.y, impound_pos.z, cfg.drawText.str)
				if IsControlJustPressed(0, cfg.drawText.keybind) then 
					if dist <= cfg.drawText.interactDist then
						TaskTurnPedToFaceEntity(player, targetVeh, 1.0)
						Citizen.Wait(500)
						SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
						Citizen.Wait(300)
						if cfg.freeze then FreezeEntityPosition(player, true) end
						TaskStartScenarioInPlace(player, cfg.scenario, 0, true)
						if Config.ProgressBars then 
							exports['progressBars']:startUI((cfg.progressBar.timer), cfg.progressBar.text)
						end
						Citizen.Wait(cfg.progressBar.timer - 1000)
						ClearPedTasks(player)
						Citizen.Wait(1000)
						FreezeEntityPosition(player, false)
						impounded = true
						break
					else
						TriggerEvent('t1ger_towtrucker:notify', Lang['move_closer_interact'])
					end
				end
			end
		end
		local veh_props = ESX.Game.GetVehicleProperties(targetVeh)
		local fuel = GetVehicleFuelLevel(targetVeh)
		if Config.T1GER_Garage then
			exports['t1ger_garage']:SetVehicleImpounded(targetVeh, false)
		else
			print('insert your impound event/function in here, to update state of the vehicle')
		end
		ESX.Game.DeleteVehicle(targetVeh)
		TriggerEvent('t1ger_towtrucker:notify', Lang['vehicle_impounded']:format(veh_props.plate))
	else
		TriggerEvent('t1ger_towtrucker:notify', Lang['no_vehicle_nearby'])
	end
end

function UnlockClosestVehicle()
	local cfg = Config.UnlockVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local unlocked = false
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		T1GER_GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
		local unlockPos = GetOffsetFromEntityInWorldCoords(targetVeh, d1.x-0.2,0.0,0.0)
		while not unlocked do 
			Citizen.Wait(1)
			local dist = #(coords - vector3(unlockPos.x, unlockPos.y, unlockPos.z))
			if dist < cfg.drawText.dist then
				T1GER_DrawTxt(unlockPos.x, unlockPos.y, unlockPos.z, cfg.drawText.str)
				if IsControlJustPressed(0, cfg.drawText.keybind) then 
					if dist <= cfg.drawText.interactDist then
						T1GER_LoadAnim(cfg.anim.dict)
						TaskTurnPedToFaceEntity(player, targetVeh, 1.0)
						Citizen.Wait(500)
						SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
						Citizen.Wait(300)
						if cfg.freeze then FreezeEntityPosition(player, true) end
						TaskPlayAnim(player, cfg.anim.dict, cfg.anim.lib, 3.0, 3.0, -1, 31, 1.0, 0, 0, 0)
						if Config.ProgressBars then 
							exports['progressBars']:startUI((cfg.progressBar.timer), cfg.progressBar.text)
						end
						Citizen.Wait(cfg.progressBar.timer)
						ClearPedTasks(player)
						FreezeEntityPosition(player, false)
						unlocked = true
						break
					else
						TriggerEvent('t1ger_towtrucker:notify', Lang['move_closer_interact'])
					end
				end
			end
		end
		PlayVehicleDoorOpenSound(targetVeh, 0)
		SetVehicleDoorsLockedForAllPlayers(targetVeh, false)
		SetVehicleDoorsLocked(targetVeh, 1)
		if Config.T1GER_Keys then
			exports['t1ger_keys']:SetVehicleLocked(targetVeh, 0)
		end
		TriggerEvent('t1ger_towtrucker:notify', Lang['vehicle_unlocked'])
	else
		TriggerEvent('t1ger_towtrucker:notify', Lang['no_vehicle_nearby'])
	end
end

function FlipClosestVehicle()
	local cfg = Config.FlipVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local flipped = false 
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		T1GER_GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
		local flip_pos = GetOffsetFromEntityInWorldCoords(targetVeh, d1.x-0.2,0.0,0.0)
		while not flipped do 
			Citizen.Wait(1)
			local dist = #(coords - vector3(flip_pos.x, flip_pos.y, flip_pos.z))
			if dist < cfg.drawText.dist then
				T1GER_DrawTxt(flip_pos.x, flip_pos.y, flip_pos.z, cfg.drawText.str)
				if IsControlJustPressed(0, cfg.drawText.keybind) then
					if dist <= cfg.drawText.interactDist then
						TaskTurnPedToFaceEntity(player, targetVeh, 1.0)
						Citizen.Wait(500)
						SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
						Citizen.Wait(300)
						if cfg.freeze then FreezeEntityPosition(player, true) end
						TaskStartScenarioInPlace(player, cfg.scenario, 0, true)
						if Config.ProgressBars then 
							exports['progressBars']:startUI((cfg.progressBar.timer), cfg.progressBar.text)
						end
						Citizen.Wait(cfg.progressBar.timer - 1000)
						ClearPedTasks(player)
						Citizen.Wait(1000)
						FreezeEntityPosition(player, false)
						flipped = true
						break
					else
						TriggerEvent('t1ger_towtrucker:notify', Lang['move_closer_interact'])
					end
				end
			end
		end
		SetVehicleOnGroundProperly(targetVeh)
	else
		TriggerEvent('t1ger_towtrucker:notify', Lang['no_vehicle_nearby'])
	end
end

local steer_angle = 0.0
function PushClosestVehicle()
	local cfg = Config.PushVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local pushed = false 
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		T1GER_GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local front = nil
		local new_dist = 0
		while not pushed do 
			Citizen.Wait(1)
			local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
			local rear_pos = GetOffsetFromEntityInWorldCoords(targetVeh, 0.0, d1.y - 0.25, 0.0)
			local front_pos = GetOffsetFromEntityInWorldCoords(targetVeh, 0.0, d2.y + 0.25, 0.0)
			local veh_pos = GetEntityCoords(targetVeh)
			local distance = #(coords - vector3(veh_pos.x, veh_pos.y, veh_pos.z))
			local dist_rear = #(coords - vector3(rear_pos.x, rear_pos.y, rear_pos.z))
			local dist_front = #(coords - vector3(front_pos.x, front_pos.y, front_pos.z))
			if distance < 5.0 then
				if dist_rear < cfg.drawText.dist then
					T1GER_DrawTxt(rear_pos.x, rear_pos.y, rear_pos.z + 0.4, cfg.drawText.str1)
					T1GER_DrawTxt(rear_pos.x, rear_pos.y, rear_pos.z + 0.30, cfg.drawText.str2)
					front = false
					new_dist = dist_rear
				elseif dist_front < cfg.drawText.dist then
					T1GER_DrawTxt(front_pos.x, front_pos.y, front_pos.z + 0.4, cfg.drawText.str1)
					T1GER_DrawTxt(front_pos.x, front_pos.y, front_pos.z + 0.30, cfg.drawText.str2)
					front = true
					new_dist = dist_front
				end
				if IsControlJustPressed(0, cfg.stopKey) then 
					steer_angle = 0.0 
					pushed = true
				end
				if IsControlPressed(0, cfg.pushKey) then
					if new_dist <= cfg.drawText.interactDist then
						T1GER_LoadAnim(cfg.anim.dict)
						if front then    
							AttachEntityToEntity(player, targetVeh, GetPedBoneIndex(6286), 0.0, (d2.y + 0.25), (d1.z + 1.0), 0.0, 0.0, 180.0, false, false, false, true, false, true)
						else
							AttachEntityToEntity(player, targetVeh, GetPedBoneIndex(6286), 0.0, (d1.y - 0.25), (d1.z + 1.0), 0.0, 0.0, 0.0, false, false, false, true, false, true)
						end
						TaskPlayAnim(player, cfg.anim.dict, cfg.anim.lib, 3.0, 3.0, -1, 35, 1.0, 0, 0, 0)
						Citizen.Wait(300)
						while true do
							Citizen.Wait(1)
							DisplayHelpText(('Steer vehicle with ~INPUT_MOVE_LEFT_ONLY~ and ~INPUT_MOVE_RIGHT_ONLY~'))
							
							if front then SetVehicleForwardSpeed(targetVeh, -0.80) else SetVehicleForwardSpeed(targetVeh, 0.80) end
							if HasEntityCollidedWithAnything(targetVeh) then SetVehicleOnGroundProperly(targetVeh) end

							local veh_speed = GetFrameTime() * 75
							if IsDisabledControlPressed(0, cfg.leftKey) then
								SetVehicleSteeringAngle(targetVeh, steer_angle)
								steer_angle = steer_angle + veh_speed
							elseif IsDisabledControlPressed(0, cfg.rightKey) then
								SetVehicleSteeringAngle(targetVeh, steer_angle)
								steer_angle = steer_angle - veh_speed
							else
								SetVehicleSteeringAngle(targetVeh, steer_angle)
								if steer_angle < -0.7 then steer_angle = steer_angle + veh_speed
								elseif steer_angle > 0.7 then steer_angle = steer_angle - veh_speed
								else steer_angle = 0.0 end
							end

							if steer_angle > 25.0 then steer_angle = 25.0 elseif steer_angle < -25.0 then steer_angle = -25.0 end
		
							if not IsDisabledControlPressed(0, cfg.pushKey) then
								StopAnimTask(player, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
								DetachEntity(player, false, false)
								break
							end
						end
					else
						TriggerEvent('t1ger_towtrucker:notify', Lang['move_closer_interact'])
					end
				end
			end
		end
	else
		TriggerEvent('t1ger_towtrucker:notify', Lang['no_vehicle_nearby'])
	end
end

local towing = {inUse = false, truck = nil, target = nil}

RegisterCommand(Config.FlatbedTowing.command, function(source, args)
	if towing.inUse == false then 
		FlatbedTowFunction()
	else
		towing.inUse = false
	end
end, false)

function FlatbedTowFunction()
	ESX.UI.Menu.CloseAll()
	local cfg = Config.FlatbedTowing
	local towtruck = GetVehiclePedIsIn(player, false)
	if towtruck == 0 or towtruck == nil then
		towtruck = T1GER_GetClosestVehicle(coords, 3.0)
	end
	local complete = false
	if (DoesEntityExist(towtruck) and IsEntityAVehicle(towtruck)) then
		if GetEntityModel(towtruck) == GetEntityModel(towing.target) then 
			if GetLastDrivenVehicle() == towtruck then
				return TriggerEvent('t1ger_towtrucker:notify', Lang['veh_not_towtruck'])
			else
				towtruck = GetLastDrivenVehicle()
			end
		end
		if IsVehicleTowTruck(towtruck) then 
			T1GER_GetControlOfEntity(towtruck)
			SetEntityAsMissionEntity(towtruck, true, true)
			towing.truck = towtruck
			towing.inUse = true
			while not complete do
				Citizen.Wait(1)
				local sleep = true

				local d1,d2 = GetModelDimensions(GetEntityModel(towtruck))
				local truck_pos = GetOffsetFromEntityInWorldCoords(towtruck, (d1.x-0.05), (d1.y + 1.0), 0.0)
				local attach_point = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, (d1.y - 3.0), 0.0)
				local distance = #(coords - vector3(truck_pos.x, truck_pos.y, truck_pos.z))

				if distance <= cfg.drawText.dist then
					sleep = false

					if towing.target == nil then
						local attachDist = #(coords - vector3(attach_point.x, attach_point.y, attach_point.z))
						if attachDist < cfg.marker.drawDist then 
							local mk = cfg.marker
							DrawMarker(mk.type, attach_point.x, attach_point.y, attach_point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
						end
						if distance <= cfg.drawText.dist then 
							T1GER_DrawTxt(truck_pos.x, truck_pos.y, truck_pos.z + 0.4, cfg.drawText.attach)
						end
						if IsControlJustPressed(0, cfg.attachKey) then 
							if distance <= cfg.interactDist then
								local targetVehicle = T1GER_GetClosestVehicle(attach_point, 2.0)
								if (DoesEntityExist(targetVehicle) and IsEntityAVehicle(targetVehicle)) then
									if VehicleIsBlacklisted(targetVehicle) then 
										return TriggerEvent('t1ger_towtrucker:notify', Lang['pickup_blacklisted'])
									else
										T1GER_GetControlOfEntity(targetVehicle)
										SetEntityAsMissionEntity(targetVehicle, true, true)
										local cfgTruck = k
										for k,v in pairs(Config.FlatbedTowing.trucks) do 
											if IsVehicleModel(towtruck, k) then
												cfgTruck = k
												break
											end
										end
										local sk = Config.FlatbedTowing.trucks[cfgTruck]
										AttachEntityToEntity(targetVehicle, towtruck, GetEntityBoneIndexByName(towtruck, sk.boneIndex_name), sk.offset[1], sk.offset[2], sk.offset[3], 0, 0, 0, 1, 1, 0, 1, 0, 1)
										towing.target = targetVehicle
										towing.inUse = false
										complete = true
									end
								else
									TriggerEvent('t1ger_towtrucker:notify', Lang['park_pickup_marker'])
								end
							else
								TriggerEvent('t1ger_towtrucker:notify', Lang['move_closer_interact'])
							end
						end
					else
						if distance <= cfg.drawText.dist then 
							T1GER_DrawTxt(truck_pos.x, truck_pos.y, truck_pos.z + 0.4, cfg.drawText.detach)
						end
						if IsControlJustPressed(0, cfg.detachKey) then
							if distance <= cfg.interactDist then
								DetachEntity(towing.target)
								SetEntityCoords(towing.target, attach_point.x, attach_point.y, attach_point.z, 1, 0, 0, 1)
								SetVehicleOnGroundProperly(towing.target)
								towing.target = nil
								towing.inUse = false
								complete = true
							else
								TriggerEvent('t1ger_towtrucker:notify', Lang['move_closer_interact'])
							end 
						end
					end
				end

				if distance > 20.0 then 
					TriggerEvent('t1ger_towtrucker:notify', Lang['towtruck_too_far'])
					complete = true
				end

				if towing.inUse == false then
					complete = true
				end

				if sleep then 
					Citizen.Wait(500)
				end
			end
			towing.inUse = false
		else
			TriggerEvent('t1ger_towtrucker:notify', Lang['towtruck_not_found'])
		end
	end
end

function CarryObjectsMainMenu()
	local elements = {}
	for k,v in pairs(Config.PropEmotes) do
		table.insert(elements, {label = v.label, prop = v.model, bone = v.bone, pos = v.pos, rot = v.rot})
	end
	table.insert(elements, {label = 'Remove Obj', value = 'remove_obj'})
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'towtrucker_prop_emotes_menu',
		{
			title    = 'Prop Emotes',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
			if data.current.value == 'remove_obj' then
				menu.close()
				local coords = GetEntityCoords(GetPlayerPed(-1))
				ClearPedTasks(PlayerPedId())
				ClearPedSecondaryTask(PlayerPedId())
				Citizen.Wait(250)
				DetachEntity(carryModel)
				local allObjects = {"prop_roadcone02a", "prop_tool_box_04", "prop_consign_02a", "prop_mp_barrier_02b"}
				for i = 1, #allObjects, 1 do
					local object = GetClosestObjectOfType(coords, 1.0, GetHashKey(allObjects[i]), false, false, false)
					if object ~= 0 then 
						SetEntityAsMissionEntity(object)
						TriggerServerEvent('t1ger_towtrucker:forceDelete', ObjToNet(object))
						break
					end
				end
				holdingObj = false
				CarryObjectsMainMenu()
			else
				menu.close()
				local coords = GetEntityCoords(GetPlayerPed(-1))
				local selct = data.current
				carryModel = 0
				holdingObj = true
				if selct.prop == "prop_consign_02a" or selct.prop == "prop_mp_barrier_02b" then PlayPushObjAnim() end
				ESX.Game.SpawnObject(selct.prop, {x = coords.x, y = coords.y, z = coords.z}, function(spawnModel)
					carryModel = spawnModel
					local boneIndex = GetPedBoneIndex(PlayerPedId(), selct.bone)
					local pX, pY, pZ, rX, rY, rZ = round(selct.pos[1],2), round(selct.pos[2],2), round(selct.pos[3],2), round(selct.rot[1],2), round(selct.rot[2],2), round(selct.rot[3],2)
					AttachEntityToEntity(carryModel, PlayerPedId(), boneIndex, pX, pY, pZ, rX, rY, rZ, true, true, false, true, 2, 1)
				end)
			end
		else
			TriggerEvent('t1ger_towtrucker:notify', Lang['action_not_possible'])
		end
	end, function(data, menu)
		menu.close()
		OpenTowTruckerActionMenu()
	end)
end

Citizen.CreateThread(function()
    while true do 
		Citizen.Wait(4)
		if IsControlJustPressed(0, Config.KeyControls['push_pickup_objs']) and carryModel ~= 0 then
			if not IsPedInAnyVehicle(player, true) then
				if Config.TowServices[towID] ~= nil then
					if T1GER_isJob(Config.Society[Config.TowServices[towID].society].name) then 
						local placedObjs = {"prop_roadcone02a", "prop_tool_box_04", "prop_consign_02a", "prop_mp_barrier_02b"}
						local coords, nearDist = GetEntityCoords(GetPlayerPed(-1)), -1
						carryModel = nil
						local objName, zk = nil, Config.PropEmotes
						for i = 1, #placedObjs, 1 do
							local object = GetClosestObjectOfType(coords, 1.5, GetHashKey(placedObjs[i]), false, false, false)
							if DoesEntityExist(object) then
								local objCoords = GetEntityCoords(object)
								local objDist  = GetDistanceBetweenCoords(coords, objCoords, true)
								if nearDist == -1 or nearDist > objDist then nearDist = objDist; carryModel = object; objName = placedObjs[i] end
							end
						end
						if holdingObj then 
							holdingObj = false
							if (objName == 'prop_roadcone02a') or (objName == 'prop_tool_box_04') then PlayPickUpAnim() end
							Citizen.Wait(250)
							DetachEntity(carryModel)
							ClearPedTasks(PlayerPedId())
							ClearPedSecondaryTask(PlayerPedId())
							PlaceObjectOnGroundProperly(carryModel)
						else
							local Dist = GetDistanceBetweenCoords(GetEntityCoords(carryModel), GetEntityCoords(PlayerPedId()), true)
							if Dist < 1.75 then
								holdingObj = true
								if (objName == 'prop_roadcone02a') or (objName == 'prop_tool_box_04') then PlayPickUpAnim() end
								Citizen.Wait(250)
								ClearPedTasks(PlayerPedId())
								ClearPedSecondaryTask(PlayerPedId())
								if (objName == 'prop_consign_02a') or (objName == 'prop_mp_barrier_02b') then 
									PlayPushObjAnim()
								end
								Citizen.Wait(250)
								AttachEntityToEntity(carryModel, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), zk[objName].bone), zk[objName].pos[1], zk[objName].pos[2], zk[objName].pos[3], zk[objName].rot[1], zk[objName].rot[2], zk[objName].rot[3], true, true, false, true, 2, 1)
							end
						end
					end
				end
			end
		end
		if holdingObj then
			DisableControlAction(0, 23, true)
		end
	end
end)

function PlayPushObjAnim()
	T1GER_LoadAnim("anim@heists@box_carry@")
	TaskPlayAnim((PlayerPedId()), "anim@heists@box_carry@", "idle", 4.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function PlayPickUpAnim()
	T1GER_LoadAnim("random@domestic")
	TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
end

RegisterNetEvent('t1ger_towtrucker:forceDeleteCL')
AddEventHandler('t1ger_towtrucker:forceDeleteCL', function(objNet)
	if NetworkHasControlOfNetworkId(objNet) then
		DeleteObject(NetToObj(objNet))
	end
end)

local towJob = {}

function TowTruckerJobs()
	local elements = {
		{ label = 'Find Call', value = 'find_job' },
		{ label = 'Cancel Job', value = 'cancel_job' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'towtrucker_npc_job_menu',
		{
			title    = 'NPC Job Menu',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'find_job' then
			if towJob.started ~= nil and towJob.started == true then
				return TriggerEvent('t1ger_towtrucker:notify', Lang['job_already_inUse'])
			end
			menu.close()
			math.randomseed(GetGameTimer())
			local type = Config.JobTypes[math.random(#Config.JobTypes)]
			local num = math.random(1,#Config.TowTruckerJobs[type])
			local distance_check = CheckDistance(type, num)
			local count = 0
			while not distance_check and count < 100 do
				count = count + 1
				num = math.random(1,#Config.TowTruckerJobs[type])
				while Config.TowTruckerJobs[type][num].inUse and count < 100 do
					count = count + 1
					num = math.random(1,#Config.TowTruckerJobs[type])
				end
				distance_check = CheckDistance(type, num)
			end
			if count == 100 then
				TriggerEvent('t1ger_towtrucker:notify', Lang['job_no_calls_available'])
			else
				Config.TowTruckerJobs[type][num].inUse = true
				towJob.started = true
				Wait(200)
				TriggerServerEvent('t1ger_towtrucker:JobDataSV', type, num, Config.TowTruckerJobs[type][num])
				TriggerEvent('t1ger_towtrucker:startJobWithNPC', type, num)
			end
		end
		if data.current.value == 'cancel_job' then
			menu.close()
			CancelCurrentJob()
		end
	end, function(data, menu)
		menu.close()
		OpenTowTruckerActionMenu()
	end)
end

local CancelJob = false
RegisterNetEvent('t1ger_towtrucker:startJobWithNPC')
AddEventHandler('t1ger_towtrucker:startJobWithNPC', function(type, num)
	local JobDone = false
	local job = Config.TowTruckerJobs[type][num]
	local blip = CreateJobBlip(job.pos)
	local TowTruck = nil
	local buttonClicked = false

	while not JobDone do 
		Citizen.Wait(0)

		if job.inUse then

			local coords = GetEntityCoords(GetPlayerPed(-1))
			local jobDistance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, job.pos[1], job.pos[2], job.pos[3], false)

			if jobDistance < 100.0 and towJob.veh == nil then
				towJob.veh = CreateJobVehicle(job, type)
				SetEntityAsMissionEntity(towJob.veh, true, true)
			end

			if type == 'break_downs' then

				if towJob.alertCall == nil then
					local message = Lang['job_breakdown_msg']
					TriggerEvent('t1ger_towtrucker:notifyAdvanced', 'CHAR_TOW_TONYA', 'CHAR_TOW_TONYA', 6, 'TOW EMERGENCY CALL', false, '~r~BREAKDOWN~s~', message)
					towJob.alertCall = true 
				end

				if jobDistance < 90.0 and towJob.ped == nil then
					towJob.ped = CreateJobPed(job)	
					SetEntityAsMissionEntity(towJob.ped, true, true)
				end

				if jobDistance < 10.0 then 

					if jobDistance < 6.0 and towJob.pedShouted == nil then
						TriggerEvent('t1ger_towtrucker:notify', Lang['job_shout_msg'])
						towJob.pedShouted = true
					end

					local d1,d2 = GetModelDimensions(GetEntityModel(towJob.veh))
					local engineCoords = GetOffsetFromEntityInWorldCoords(towJob.veh, 0.0,d2.y+0.2,0.0)
					local vehicleDist = #(coords - engineCoords)

					if vehicleDist < 5.0 and towJob.inspected == nil then
						T1GER_DrawTxt(engineCoords.x, engineCoords.y, engineCoords.z, Lang['draw_inspect_vehicle'])
						if IsControlJustPressed(0, Config.KeyControls['inspect_vehicle']) and vehicleDist <= 1.0 and not buttonClicked then
							if IsPedInAnyVehicle(player, true) then
								return TriggerEvent('t1ger_towtrucker:notify', Lang['action_not_possible'])
							end
							buttonClicked = true
							SetVehicleDoorOpen(towJob.veh, 4, 0, 0)
							TaskTurnPedToFaceEntity(GetPlayerPed(-1), towJob.veh, 1.0)
							Citizen.Wait(1000)
							local animDict = "mini@repair"
							T1GER_LoadAnim(animDict)
							if not IsEntityPlayingAnim(GetPlayerPed(-1), animDict, "fixing_a_player", 3) then
								TaskPlayAnim(GetPlayerPed(-1), animDict, "fixing_a_player", 5.0, -5, -1, 16, false, false, false, false)
							end
							if Config.ProgressBars then 
								exports['progressBars']:startUI((3000), Lang['pb_towjob'])
							end
							Citizen.Wait(3000)
							SetVehicleDoorShut(towJob.veh, 4, 1, 1)
							ClearPedTasks(GetPlayerPed(-1))
							TriggerEvent('t1ger_towtrucker:notify', Lang['job_attach_veh'])
							towJob.inspected = true
							buttonClicked = false
						end
					end

					local pedCoords = GetEntityCoords(towJob.ped)
					local pedDist = #(coords - pedCoords)

					if pedDist < 5.0 and towJob.inspected and IsEntityAttachedToAnyVehicle(towJob.veh) and towJob.talked == nil then
						T1GER_DrawTxt(pedCoords.x, pedCoords.y, pedCoords.z, Lang['draw_ask_npc_follow'])
						if IsControlJustPressed(0, Config.KeyControls['npc_follow']) and pedDist <= 1.0 and not buttonClicked then
							buttonClicked = true
							TowTruck = GetEntityAttachedTo(towJob.veh)
							if IsVehicleSeatFree(TowTruck, 0) then 
								ClearPedTasksImmediately(towJob.ped)
								FreezeEntityPosition(towJob.ped, false)
								TaskEnterVehicle(towJob.ped, TowTruck, 20000, 0, 1.0, 1, 0)
							else
								TriggerEvent('t1ger_towtrucker:notify', Lang['job_seat_occupied'])
							end
							SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("NPC"))
							SetRelationshipBetweenGroups(0, GetHashKey("NPC"), GetHashKey("PLAYER"))
							towJob.talked = true
							buttonClicked = false
						end
					end

				end

				if IsEntityAttachedToAnyVehicle(towJob.veh) and (GetPedInVehicleSeat(TowTruck, 0) == towJob.ped) then
					if towJob.destination == nil then
						if DoesBlipExist(blip) then 
							RemoveBlip(blip)
						end
						TriggerEvent('t1ger_towtrucker:notify', Lang['job_dropoff_msg1'])
						blip = CreateJobBlip(job.dropoff)
						towJob.destination = true
					end
				end

				local dropoffDist = #(coords - vector3(job.dropoff[1], job.dropoff[2], job.dropoff[3]))

				if dropoffDist < 20.0 and towJob.destination ~= nil then
					if IsEntityAttachedToAnyVehicle(towJob.veh) then 
						local mk = Config.MarkerSettings['dropoff']
						DrawMarker(mk.type, job.dropoff[1], job.dropoff[2], job.dropoff[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
					end
					if dropoffDist < 10.0 and towJob.dropMessage == nil then 
						TriggerEvent('t1ger_towtrucker:notify', Lang['job_park_inside_marker'])
						towJob.dropMessage = true
					end
					local vehicleCoords = GetEntityCoords(towJob.veh)
					local vehDist = #(vehicleCoords - vector3(job.dropoff[1], job.dropoff[2], job.dropoff[3]))
					if not IsEntityAttachedToAnyVehicle(towJob.veh) and vehDist < 3.0 and towJob.detached == nil then
						TaskLeaveVehicle(towJob.ped, TowTruck, 0)
						Citizen.Wait(3000)
						TaskTurnPedToFaceEntity(towJob.ped, towJob.veh, 1.0)
						Citizen.Wait(1000)
						TriggerEvent('t1ger_towtrucker:notify', Lang['job_collect_cash'])
						towJob.detached = true
					end
					local pedCoords = GetEntityCoords(towJob.ped)
					local pedDist = #(coords - pedCoords)
					if pedDist < 5.0 and towJob.detached ~= nil and towJob.collected == nil then
						T1GER_DrawTxt(pedCoords.x, pedCoords.y, pedCoords.z, Lang['draw_collect_cash'])
						if IsControlJustPressed(0, Config.KeyControls['collect_cash']) then
							T1GER_LoadAnim("mp_common")
							TaskPlayAnim(player, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
							TaskPlayAnim(towJob.ped, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
							Citizen.Wait(2000)
							if DoesBlipExist(blip) then RemoveBlip(blip) end
							TaskWanderStandard(towJob.ped, 10.0, 10)
							TriggerEvent('t1ger_towtrucker:notify', Lang['job_thanking_msg'])
							TriggerServerEvent('t1ger_towtrucker:getJobReward', job.payout)
							towJob.collected = true
							DeleteEntity(towJob.veh)
							Citizen.Wait(10000)
							CancelJob = true
						end
					end
				end

			end

			if type == 'illegally_parked' then

				if towJob.alertCall == nil then
					local message = Lang['job_illegal_parked_msg']
					TriggerEvent('t1ger_towtrucker:notifyAdvanced', 'CHAR_TOW_TONYA', 'CHAR_TOW_TONYA', 6, 'TOW EMERGENCY CALL', false, '~r~ILLEGAL PARKING~s~', message)
					towJob.alertCall = true 
				end

				if towJob.veh ~= nil and DoesEntityExist(towJob.veh) then
					local vehicleCoords = GetEntityCoords(towJob.veh)
					local vehicleDist = #(coords - vehicleCoords)

					if vehicleDist <= 20.0 then
						if towJob.notified == nil then
							TriggerEvent('t1ger_towtrucker:notify', Lang['job_attach_veh2'])
							towJob.notified = true
						end
					end

					if IsEntityAttachedToAnyVehicle(towJob.veh) then
						if towJob.destination == nil then
							if DoesBlipExist(blip) then 
								RemoveBlip(blip)
							end
							TriggerEvent('t1ger_towtrucker:notify', Lang['job_dropoff_msg2'])
							blip = CreateJobBlip(job.dropoff)
							towJob.destination = true
						end
					end
					
					local dropoffDist = #(coords - vector3(job.dropoff[1], job.dropoff[2], job.dropoff[3]))

					if dropoffDist < 20.0 and towJob.destination ~= nil then
						if IsEntityAttachedToAnyVehicle(towJob.veh) then 
							local mk = Config.MarkerSettings['dropoff']
							DrawMarker(mk.type, job.dropoff[1], job.dropoff[2], job.dropoff[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
						end
						if dropoffDist < 10.0 and towJob.dropMessage == nil then 
							TriggerEvent('t1ger_towtrucker:notify', Lang['job_park_inside_marker'])
							towJob.dropMessage = true
						end
						local vehDist = #(vehicleCoords - vector3(job.dropoff[1], job.dropoff[2], job.dropoff[3]))
						if not IsEntityAttachedToAnyVehicle(towJob.veh) and vehDist < 3.0 and towJob.detached == nil then
							TriggerEvent('t1ger_towtrucker:notify', Lang['job_attach_note'])
							towJob.detached = true
						end
						if vehicleDist < 5.0 and towJob.detached ~= nil and towJob.collected == nil then
							T1GER_DrawTxt(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, Lang['draw_attach_note'])
							if IsControlJustPressed(0, Config.KeyControls['attach_note']) then
								TaskPlayAnim(player, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
								Citizen.Wait(2000)
								if DoesBlipExist(blip) then RemoveBlip(blip) end
								TriggerEvent('t1ger_towtrucker:notify', Lang['job_veh_delivered'])
								TriggerServerEvent('t1ger_towtrucker:getJobReward', job.payout)
								towJob.collected = true
								DeleteEntity(towJob.veh)
								CancelJob = true
							end
						end
					end

				end

			end

			if CancelJob == true then
				if DoesEntityExist(towJob.veh) then DeleteVehicle(towJob.veh) end
				if type == 'break_downs' then
					if DoesEntityExist(towJob.ped) then
						SetEntityAsNoLongerNeeded(towJob.ped)
					end
				end
				if DoesBlipExist(blip) then RemoveBlip(blip) end
				Config.TowTruckerJobs[type][num].inUse = false
				Wait(200)
				TriggerServerEvent('t1ger_towtrucker:JobDataSV', type, num, Config.TowTruckerJobs[type][num])
				towJob = {}
				CancelJob = false
				break
			end

		end
	end

end)

function CreateJobVehicle(data, type)
	local entity = nil
	ClearAreaOfVehicles(data.pos[1], data.pos[2], data.pos[3], 10.0, false, false, false, false, false)
	-- Get Job Vehicle Model:
	math.randomseed(GetGameTimer())
	local num = math.random(#Config.TowTruckerJobs.JobVehicles)
	local model = Config.TowTruckerJobs.JobVehicles[num]
	-- Spawn Vehicle:
	ESX.Game.SpawnVehicle(model, {x = data.pos[1], y = data.pos[2], z = data.pos[3]}, data.pos[4], function(vehicle)
		SetEntityCoordsNoOffset(vehicle, data.pos[1], data.pos[2], data.pos[3])
		SetEntityHeading(vehicle, data.pos[4])
		SetVehicleOnGroundProperly(vehicle)
		if type == 'break_downs' then 
			SetVehicleEngineHealth(vehicle, 100.0)
			SetVehicleDoorOpen(vehicle, 4, 0, 0)
		end
		entity = vehicle
	end)

	while not DoesEntityExist(entity) do
		Citizen.Wait(10)
	end

	return entity
end

function CreateJobPed(data)
	SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
	AddRelationshipGroup('NPC')
	T1GER_LoadModel(data.ped)
	local entity = CreatePed(7, GetHashKey(data.ped), data.npc_pos[1], data.npc_pos[2], data.npc_pos[3]-0.97, data.npc_pos[4], 0, true, true)
	NetworkRegisterEntityAsNetworked(entity)
	SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
	SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(entity), true)
	SetPedKeepTask(entity, true)
	SetPedDropsWeaponsWhenDead(entity, false)
	SetEntityInvincible(entity, false)
	SetEntityVisible(entity, true)
	TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
	FreezeEntityPosition(entity, true)
	SetPedRelationshipGroupHash(entity, GetHashKey("NPC"))	
	SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("NPC"))
	SetRelationshipBetweenGroups(0, GetHashKey("NPC"), GetHashKey("PLAYER"))
	while not DoesEntityExist(entity) do
		Citizen.Wait(10)
	end
	return entity
end

function CheckDistance(type, num)
	local check_pos = Config.TowTruckerJobs[type][num].pos
	local travel_dist = CalculateTravelDistanceBetweenPoints(coords.x, coords.y, coords.z, check_pos[1], check_pos[2], check_pos[3])
	if travel_dist < Config.TowTruckerJobs.TravelDistance then
		return true
	else
		return false
	end
end


-- Function for job blip in progress:
function CreateJobBlip(pos)
	local blip = AddBlipForCoord(pos[1],pos[2],pos[3])
	SetBlipSprite(blip, 1)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', 'Tow Trucker Job')
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.7) -- set scale
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 5)
	return blip
end

function CancelCurrentJob()
	CancelJob = true
	if towJob.veh ~= nil or towJob.ped ~= nil then 
		ClearPedTasksImmediately(towJob.ped)
		FreezeEntityPosition(towJob.ped, false)
		TriggerEvent('t1ger_towtrucker:notify', Lang['job_cancel_by_ply'])
	end
end

AddEventHandler('esx:onPlayerDeath', function(data)
	CancelCurrentJob()
end)

RegisterNetEvent('t1ger_towtrucker:JobDataCL')
AddEventHandler('t1ger_towtrucker:JobDataCL',function(type, num, data)
	Config.TowTruckerJobs[type][num] = data
end)

local using_repairkit = false
RegisterNetEvent('t1ger_towtrucker:useRepairKit')
AddEventHandler('t1ger_towtrucker:useRepairKit', function(data)
	local vehicle = T1GER_GetClosestVehicle(coords, 4.0)
	if vehicle ~= 0 then
		if using_repairkit then return end
		using_repairkit = true

		-- Get Control of Vehicle:
		T1GER_GetControlOfEntity(vehicle)

		-- Get Repair Veh Position:
		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		local hood = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d2.y+0.2,0.0)
		local distance = (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
		local vehRepaired = false

		-- Repair thread:
        while not vehRepaired do
            Citizen.Wait(1)
            distance = (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
			T1GER_DrawTxt(hood.x, hood.y, hood.z, Lang['draw_repair_kit'])
			if IsControlJustPressed(0, Config.KeyControls['use_repairkit']) then 
				if distance < 1.0 then 
					SetVehicleDoorOpen(vehicle, 4, 0, 0)
					TaskTurnPedToFaceEntity(player, vehicle, 1.0)
					Citizen.Wait(1000)
					local animDict = "mini@repair"
					T1GER_LoadAnim(animDict)
					if not IsEntityPlayingAnim(player, animDict, "fixing_a_player", 3) then
						TaskPlayAnim(player, animDict, "fixing_a_player", 5.0, -5, -1, 16, false, false, false, false)
					end
					-- repair options:
					local repairDuration = (((3000-GetVehicleEngineHealth(vehicle)) - (GetVehicleBodyHealth(vehicle)/2))*2 + data.duration)
					if Config.ProgressBars then
						exports['progressBars']:startUI((repairDuration), data.progbar)
					end
					Citizen.Wait(repairDuration)
					if GetVehicleEngineHealth(vehicle) < data.setEngine then
						SetVehicleEngineHealth(vehicle, data.setEngine)
					end
					if GetVehicleBodyHealth(vehicle) < 975.0 then
						SetVehicleBodyHealth(vehicle, 975.0)
					end
					for i = 0, 5 do
						SetVehicleTyreFixed(vehicle, i)
					end
					-- end:
					SetVehicleDoorShut(vehicle, 4, 1, 1)
					ClearPedTasks(player)
					TriggerEvent('t1ger_towtrucker:notify', Lang['repairkit_used'])
					vehRepaired = true
					using_repairkit = false
					break
				else
					distance = #(coords - vector3(hood.x, hood.y, hood.z))
				end
			end
        end
	end
	using_repairkit = false
end)
