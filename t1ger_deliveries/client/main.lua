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

local deliveryCompanies = {}
local companyBlips = {}
local isOwner = 0
local deliveryID = 0

-- Load Companies:
RegisterNetEvent('t1ger_deliveries:loadCompanies')
AddEventHandler('t1ger_deliveries:loadCompanies', function(results, cfg, state, id)
	Config.Companies = cfg
	deliveryCompanies = results
	isOwner = state
	TriggerEvent('t1ger_deliveries:deliveryID', id)
	Citizen.Wait(200)
	UpdateCompanyBlips()
end)

-- Update Companies:
RegisterNetEvent('t1ger_deliveries:syncServices')
AddEventHandler('t1ger_deliveries:syncServices', function(results, cfg)
	Config.Companies = cfg
	deliveryCompanies = results
	Citizen.Wait(200)
	UpdateCompanyBlips()
end)

RegisterNetEvent('t1ger_deliveries:deliveryID')
AddEventHandler('t1ger_deliveries:deliveryID', function(id)
	deliveryID = id
end)

-- function to update blips on map:
function UpdateCompanyBlips()
	for k,v in pairs(companyBlips) do RemoveBlip(v) end
	for i = 1, #Config.Companies do
		if Config.Companies[i].owned then
            CreateCompanyBlip(Config.Companies[i], deliveryCompanies[i])
		else
			CreateCompanyBlip(Config.Companies[i], nil)
		end
	end
end

-- Create Map Blips for Tow Services:
function CreateCompanyBlip(cfg, data)
	local mk = Config.BlipSettings['company']
	local bName = mk.name; if data ~= nil then bName = data.name end
	if mk.enable then
		local blip = AddBlipForCoord(cfg.menu.x, cfg.menu.y, cfg.menu.z)
		SetBlipSprite (blip, mk.sprite)
		SetBlipDisplay(blip, mk.display)
		SetBlipScale  (blip, mk.scale)
		SetBlipColour (blip, mk.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(bName)
		EndTextCommandSetBlipName(blip)
		table.insert(companyBlips, blip)
	end
end

local currentMenu = nil
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
		local sleep = true 
		for k,v in pairs(Config.Companies) do
			local distance = #(coords - v.menu)
			if distance < 6.0 then
				sleep = false
				if currentMenu ~= nil then
					distance = #(coords - currentMenu.menu)
					while currentMenu ~= nil and distance > 1.5 do
						currentMenu = nil
						Citizen.Wait(1)
					end
					if currentMenu == nil then
						ESX.UI.Menu.CloseAll()
					end
				else
					local mk = Config.MarkerSettings['menu']
					if distance >= 2.0 then
						if mk.enable then
							DrawMarker(mk.type, v.menu.x, v.menu.y, v.menu.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
						end
					elseif distance < 2.0 then
						-- test:
						if v.owned == true then
							if (T1GER_isJob(Config.Society[v.society].name)) or (isOwner == k) then
								T1GER_DrawTxt(v.menu.x, v.menu.y, v.menu.z, Lang['draw_company_menu'])
								if IsControlJustPressed(0, Config.KeyControls['company_menu']) then
									currentMenu = v
									OpenCompanyMenu(k,v)
								end
							else
								T1GER_DrawTxt(v.menu.x, v.menu.y, v.menu.z, Lang['draw_company_no_access'])
							end
						else
							if (T1GER_isJob(Config.Society[v.society].name) and PlayerData.job.grade_name ~= 'boss') or (isOwner == 0) then
								T1GER_DrawTxt(v.menu.x, v.menu.y, v.menu.z, Lang['draw_buy_company']:format(comma_value(math.floor(v.price))))
								if IsControlJustPressed(0, Config.KeyControls['buy_company']) then
									currentMenu = v
									PurchaseCompany(k,v)
								end
							else
								T1GER_DrawTxt(v.menu.x, v.menu.y, v.menu.z, Lang['draw_company_own_one'])
							end
						end
					end
				end
			end
		end
		if sleep then
			Citizen.Wait(1500)
		end
    end
end)

function PurchaseCompany(id,val)
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
			-- Name Section Start:
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'enter_company_name', {
				title = 'Enter Company Name'
			}, function(data2, menu2)
				local name = tostring(data2.value)
				if name == nil or name == '' then
					TriggerEvent('t1ger_deliveries:notify', Lang['invalid_string'])
				else
					menu2.close()
					-- Purchase Functions:
					ESX.TriggerServerCallback('t1ger_deliveries:buyCompany', function(purchased)
						if purchased then
							TriggerEvent('t1ger_deliveries:notify', (Lang['company_purchased']):format(comma_value(math.floor(val.price))))
							isOwner = tonumber(id)
							TriggerServerEvent('t1ger_deliveries:updateCompany', id, val, true, name)
						else
							TriggerEvent('t1ger_deliveries:notify', Lang['not_enough_money'])
						end
					end, id, val, name)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
			-- Name Section End
		end
		menu.close()
		currentMenu = nil
	end, function(data, menu)
		menu.close()
		currentMenu = nil
	end)
end

function OpenCompanyMenu(id,val)
	ESX.UI.Menu.CloseAll()
	local elements = {}
	if (T1GER_isJob(Config.Society[val.society].name) and PlayerData.job.grade_name == 'boss') or isOwner == id then
		table.insert(elements, {label = 'Rename Company', value = 'rename_company'})
		table.insert(elements, {label = 'Sell Company', value = 'sell_company'})
		table.insert(elements, {label = 'Boss Menu', value = 'boss_menu'})
		table.insert(elements, {label = 'Company Level', value = 'company_level'})
	end
	table.insert(elements, {label = 'Request Job', value = 'request_job'})
	if Config.T1GER_Shops then
		table.insert(elements, {label = 'Shop Orders', value = 'shop_orders'})
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'company_main',
		{
			title    = 'Company ['..tostring(id)..']',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		local action = data.current.value

		if action == 'rename_company' then
			RenameCompany(id,val)
		elseif action == 'sell_company' then
			SellCompany(id,val)
		elseif action == 'boss_menu' then
			BossMenu(id,val)
		elseif action == 'company_level' then
			CompanyLevel(id,val)
		elseif action == 'request_job' then
			RequestJob(id,val)
		elseif action == 'shop_orders' then
			ShopDeliveries(id,val)
		end

	end, function(data, menu)
		menu.close()
		currentMenu = nil
	end)
end

function RenameCompany(id,val)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_company', {
		title = 'Enter Company Name'
	}, function(data, menu)
		local name = tostring(data.value)
		if name == nil or name == '' then
			TriggerEvent('t1ger_deliveries:notify', Lang['invalid_string'])
		else
			menu.close()
			TriggerServerEvent('t1ger_deliveries:updateCompany', id, val, nil, name)
			TriggerEvent('t1ger_deliveries:notify', Lang['company_renamed'])
			OpenCompanyMenu(id,val)
		end
	end,
	function(data, menu)
		menu.close()
		OpenCompanyMenu(id,val)
	end)
end

function SellCompany(id,val)
	local sellPrice = (val.price * Config.SalePercentage)
	local elements = {
		{ label = 'No', value = 'decline_sale' },
		{ label = 'Yes', value = 'confirm_sale' },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'company_sell_confirmation',
		{
			title    = 'Confirm Sale | Price: $'..comma_value(math.floor(sellPrice)),
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'confirm_sale' then
			ESX.UI.Menu.CloseAll()
			TriggerServerEvent('t1ger_deliveries:sellCompany', id, val, math.floor(sellPrice))
			TriggerServerEvent('t1ger_deliveries:updateCompany', id, val, false, nil)
			isOwner = 0
			TriggerEvent('t1ger_deliveries:notify', (Lang['company_sold']):format(comma_value(math.floor(sellPrice))))
			currentMenu = nil
		else
			menu.close()
			OpenCompanyMenu(id,val)
		end
	end, function(data, menu)
		menu.close()
		OpenCompanyMenu(id,val)
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
				TriggerEvent('t1ger_deliveries:notify', Lang['get_account_balance']:format(comma_value(amount)))
			end, data.current.job)
		end
	end, function(data, menu)
		menu.close()
		OpenCompanyMenu(id,val)
	end)
end

function CompanyLevel(id,val)
	local cfg = val.data
	local state = 'No'
	if cfg.certificate == true then
		state = 'Yes'
	end
	local elements = {
		{ label = 'Has Certificate: '..state, value = 'view_certifcate_state' }
	}
	if cfg.certificate == false then
		table.insert(elements, { label = 'Buy Certificate', value = 'buy_certifcate' })
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "company_skill_level",
		{
			title    = 'Company Level: '..math.floor(cfg.level),
			align    = 'center',
			elements = elements
		},
	function(data, menu)

		if data.current.value == 'buy_certifcate' then
			ESX.TriggerServerCallback('t1ger_deliveries:buyCertifcate', function(status)
				if status == true then
					Config.Companies[id].data.certificate = true
					TriggerEvent('t1ger_deliveries:notify', Lang['certificate_acquired'])
					TriggerServerEvent('t1ger_deliveries:updateCompanyDataSV', id, Config.Companies[id].data)
				elseif status == false then 
					TriggerEvent('t1ger_deliveries:notify', Lang['not_enough_money'])
				end
			end, id)
			menu.close()
			OpenCompanyMenu(id,val)
		end

	end, function(data, menu)
		menu.close()
		OpenCompanyMenu(id,val)
	end)
end

function RequestJob(id,val)
	local elements = {}
	for k,v in ipairs(Config.JobValues) do
		if k ~= 4 then 
			table.insert(elements, {jobValue = k, label = v.label, level = v.level, certificate = v.certificate, vehicles = v.vehicles})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'request_job',
		{
			title    = 'Select Job Value',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if val.data.level >= data.current.level then
			if data.current.certificate == false then 
				menu.close()
				SelectJobVehicle(data.current.jobValue, data.current.label, data.current.level, data.current.certificate, data.current.vehicles, nil, id, val)
			elseif data.current.certificate == true and val.data.certificate == true then 
				menu.close()
				SelectJobVehicle(data.current.jobValue, data.current.label, data.current.level, data.current.certificate, data.current.vehicles, nil, id, val)
			else
				TriggerEvent('t1ger_deliveries:notify', Lang['job_needs_certificate'])
			end
		else
			TriggerEvent('t1ger_deliveries:notify', Lang['job_level_mismatch'])
		end
	end, function(data, menu)
		menu.close()
		OpenCompanyMenu(id,val)
	end)
end

function ShopDeliveries(id,val)
	local elements = {}
	ESX.TriggerServerCallback('t1ger_deliveries:getShopOrders', function(orders)
		local job = Config.JobValues[4]
		if next(orders) then
			for k,v in pairs(orders) do
				if v.taken == false then
					table.insert(elements, {
						label = ("Order to Shop ["..v.shopID.."]"),
						shopOrder = v, jobValue = 4, jobName = job.label, level = job.level, certificate = job.certificate, vehicles = job.vehicles 
					})
				end
			end
			if next(elements) then 
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_order_list',
					{
						title    = 'Available Orders',
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					if val.data.level >= data.current.level then
						if data.current.certificate == false then 
							menu.close()
							SelectJobVehicle(data.current.jobValue, data.current.label, data.current.level, data.current.certificate, data.current.vehicles, data.current.shopOrder, id, val)
						elseif data.current.certificate == true and val.data.certificate == true then 
							menu.close()
							SelectJobVehicle(data.current.jobValue, data.current.label, data.current.level, data.current.certificate, data.current.vehicles, data.current.shopOrder, id, val)
						else
							TriggerEvent('t1ger_deliveries:notify', Lang['job_needs_certificate'])
						end
					else
						TriggerEvent('t1ger_deliveries:notify', Lang['job_level_mismatch'])
					end
				end, function(data, menu)
					menu.close()
					OpenCompanyMenu(id,val)
				end)
			else
				TriggerEvent('t1ger_deliveries:notify', Lang['no_available_orders'])
			end
		else
			TriggerEvent('t1ger_deliveries:notify', Lang['no_available_orders'])
		end
	end)
end

local jobVehicle = nil
local jobTrailer, jobForklift = nil, nil
local vehicle_deposit = 0
local deliveryCache = {}

function SelectJobVehicle(jobValue, label, level, certificate, vehicles, shopOrder, id, val)
	local elements = {
		{label = 'Society Vehicles', value = 'society_vehicles'},
		{label = 'Rent Vehicles', value = 'rent_vehicles'},
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_select_vehicle',
		{
			title    = 'Select Job Vehicle',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'society_vehicles' then 
			SocietyVehicles(jobValue, label, level, certificate, vehicles, shopOrder, id, val)
		elseif data.current.value == 'rent_vehicles' then
			RentVehicle(jobValue, label, level, certificate, vehicles, shopOrder, id, val) 
		end
	end, function(data, menu)
		menu.close()
		RequestJob(id,val)
	end)
end

function SocietyVehicles(jobValue, label, level, certificate, vehicles, shopOrder, id, val)
	local elements = {}
	ESX.TriggerServerCallback('t1ger_deliveries:getSocietyVehicles', function(results)
		if next(results) then
			for k,v in pairs(results) do
				if v.state == true then 
					local props = json.decode(v.vehicle)
					local vehName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
					table.insert(elements, {label = vehName.." ["..v.plate.."]", name = vehName, model = props.model, props = props})
				end
			end
			if next(elements) then 
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_select_society_vehicle',
					{
						title    = 'Select Society Vehicle',
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					vehicle_deposit = nil
					TriggerEvent('t1ger_deliveries:notify', 'Society Owned Vehicle Taken Out')
					SpawnJobVehicle(data.current.model, val.spawn, val.spawn.w, data.current.props)
					ESX.UI.Menu.CloseAll()
					Wait(500)
					if jobValue == 1 or jobValue == 2 then 
						TriggerEvent('t1ger_deliveries:parcelDelivery', id, val, jobValue, nil)
					elseif jobValue == 3 then
						TriggerEvent('t1ger_deliveries:highValueDelivery', id, val, jobValue)
					elseif jobValue == 4 then
						TriggerServerEvent('t1ger_deliveries:updateOrderState', shopOrder, true)
						TriggerEvent('t1ger_deliveries:parcelDelivery', id, val, jobValue, shopOrder)
					end
				end, function(data, menu)
					menu.close()
				end)
			else
				TriggerEvent('t1ger_deliveries:notify', 'No Owned Society Vehicles.')
			end
		else
			TriggerEvent('t1ger_deliveries:notify', 'No Owned Society Vehicles.')
		end
	end, Config.Society[val.society].name)
end

function RentVehicle(jobValue, label, level, certificate, vehicles, shopOrder, id, val)
	local elements = {}
	for k,v in ipairs(vehicles) do
		table.insert(elements, {label = v.name.." [deposit: $"..v.deposit.."]", name = v.name, model = v.model, deposit = v.deposit})
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_select_rent_vehicle',
		{
			title    = 'Select Rental Vehicle',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		ESX.TriggerServerCallback('t1ger_deliveries:payVehicleDeposit', function(paid)
			if paid then
				vehicle_deposit = data.current.deposit
				TriggerEvent('t1ger_deliveries:notify', Lang['deposit_veh_paid']:format(data.current.deposit))
				local model = data.current.model
				SpawnJobVehicle(model, val.spawn, val.spawn.w)
				ESX.UI.Menu.CloseAll()
				Wait(500)
				if jobValue == 1 or jobValue == 2 then 
					TriggerEvent('t1ger_deliveries:parcelDelivery', id, val, jobValue, nil)
				elseif jobValue == 3 then
					TriggerEvent('t1ger_deliveries:highValueDelivery', id, val, jobValue)
				elseif jobValue == 4 then
					TriggerServerEvent('t1ger_deliveries:updateOrderState', shopOrder, true)
					TriggerEvent('t1ger_deliveries:parcelDelivery', id, val, jobValue, shopOrder)
				end
			else
				TriggerEvent('t1ger_deliveries:notify', Lang['not_enough_to_deposit'])
			end
		end, data.current.deposit)
	end, function(data, menu)
		menu.close()
	end)
end

-- ## HIGH VALUE JOBS ## --
RegisterNetEvent('t1ger_deliveries:highValueDelivery')
AddEventHandler('t1ger_deliveries:highValueDelivery', function(id, val, jobValue, shopOrder)
	deliveryCache.complete = false
	deliveryCache.paycheck = 0
	deliveryCache.id = id 
	deliveryCache.val = val 
	deliveryCache.num = math.random(1,#Config.HighValueJobs)
	local trailerModel = Config.HighValueJobs[deliveryCache.num].trailer
	deliveryCache.jobValue = jobValue
	deliveryCache.forkliftTaken = false
	deliveryCache.palletDelivered = false
	deliveryCache.curPallet_state = false
	deliveryCache.onGoingDelivery = false
	deliveryCache.dropOffPos = {}
	deliveryCache.dropOffPallet = {}
	deliveryCache.currentRoute = 0
	deliveryCache.truckHealth = 0
	deliveryCache.palletPrice = 0
	deliveryCache.deliveredPallets = 0
	deliveryCache.palletObjEntity = nil

	while true do
		Citizen.Wait(3)
		local player = PlayerPedId()
		local coords = GetEntityCoords(player)
		local mk = val.refill.marker

		-- Spawn job trailer:
		if DoesEntityExist(jobVehicle) and not deliveryCache.trailerSpawned then
			SpawnTruckTrailer(trailerModel, val.trailerSpawn, val.trailerSpawn.w)
			deliveryCache.trailerSpawned = true
		end

		-- Spawn Forklift
		if not deliveryCache.forkliftSpawned then
			local jk = val.forklift
			ESX.Game.SpawnVehicle(jk.model, {x = jk.pos.x, y = jk.pos.y, z = jk.pos.z}, jk.pos.w, function(veh)
				SetEntityCoordsNoOffset(veh, jk.pos.x, jk.pos.y, jk.pos.z)
				SetEntityHeading(veh, jk.pos.w)
				SetVehicleOnGroundProperly(veh)
				SetEntityAsMissionEntity(jobForklift, true, true)
				jobForklift = veh
				if Config.T1GER_Keys then
					local vehicle_plate = tostring(GetVehicleNumberPlateText(veh))
					local vehicle_name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
					exports['t1ger_keys']:SetVehicleLocked(veh, 0)
					exports['t1ger_keys']:GiveJobKeys(vehicle_plate, vehicle_name, true)
				end
			end)
			deliveryCache.forkliftSpawned = true
		end

		-- Fill up truck:
		local distance = #(coords - val.refill.pos)
		if distance < mk.dist and not deliveryCache.traillerFilledUp then 
			if DoesEntityExist(jobForklift) then
				DrawMarker(mk.type, val.refill.pos.x, val.refill.pos.y, val.refill.pos.z-0.965, 0, 0, 0, 180.0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z,mk.color.r,mk.color.g,mk.color.b,mk.color.a, false, true, 2)
				if (GetDistanceBetweenCoords(coords, val.refill.pos.x, val.refill.pos.y, val.refill.pos.z, true) < 3.5)  then
					T1GER_DrawTxt(val.refill.pos.x, val.refill.pos.y, val.refill.pos.z+0.8, Lang['draw_fill_up_trailer'])
					if IsControlJustPressed(0, Config.KeyControls['fill_up_trailer']) then
						local curVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
						if curVeh ~= 0 then 
							if GetEntityModel(curVeh) == GetEntityModel(jobForklift) then
								ForkliftIntoTruck(val.cargo.pos, val.cargo.marker, Config.HighValueJobs[deliveryCache.num].prop, deliveryCache.jobValue)
							else
								TriggerEvent('t1ger_deliveries:notify', Lang['forklift_mismatch'])
							end
						else
							TriggerEvent('t1ger_deliveries:notify', Lang['not_inside_forklift'])
						end
					end
				end
			end
		end

		-- Park Forklift:
		if deliveryCache.traillerFilledUp and not deliveryCache.truckingStarted then 
			local d1 = GetModelDimensions(GetEntityModel(jobTrailer))
			local trunk = GetOffsetFromEntityInWorldCoords(jobTrailer, 0.0, d1["y"]-2.0, 0.0-0.9)
			if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunk.x, trunk.y, trunk.z, true) > 5.0) then 
				DrawMissionText(Lang['forklift_into_trailer'])
			end
			if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunk.x, trunk.y, trunk.z, true) < 5.0) then 
				T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_park_forklift'])
				if IsControlJustPressed(0, Config.KeyControls['park_forklift']) then
					DoScreenFadeOut(1000)
					while not IsScreenFadedOut() do
						Wait(0)
					end
					Citizen.Wait(150)
					DeleteVehicle(jobForklift)
					jobForklift = nil
					SetVehicleDoorShut(jobTrailer, 5, true)
					SetVehicleDoorShut(jobTrailer, 6, true)
					SetVehicleDoorShut(jobTrailer, 7, true)
					deliveryCache.truckingStarted = true
					DoScreenFadeIn(1000)
					Citizen.Wait(100)
					TriggerEvent('t1ger_deliveries:notify', Lang['trailer_filled_up'])
					SetTruckingRoute()
				end
			end
		end

		if deliveryCache.truckingStarted then 
			-- Taking out forklift from trailer:
			if deliveryCache.deliveredPallets < deliveryCache.maxPallets then 
				if #(coords - vector3(deliveryCache.dropOffPos.x, deliveryCache.dropOffPos.y, deliveryCache.dropOffPos.z)) < 25.0 and not deliveryCache.forkliftTaken and not deliveryCache.onGoingDelivery then
					if IsPedInAnyVehicle(player) then
						DrawMissionText(Lang['park_instrunctions'])
						local mk4 = val.refill.marker
						DrawMarker(30, deliveryCache.dropOffPos.x, deliveryCache.dropOffPos.y, deliveryCache.dropOffPos.z, 0, 0, 0, deliveryCache.dropOffPos.w, 0, 0, mk4.scale.x+1.0, mk4.scale.y+1.0, mk4.scale.z+1.0,mk4.color.r,mk4.color.g,mk4.color.b,mk4.color.a, false, false, 2)
					end
					if not IsPedInAnyVehicle(player) then 
						local d1 = GetModelDimensions(GetEntityModel(jobTrailer))
						local trunk = GetOffsetFromEntityInWorldCoords(jobTrailer, 0.0, d1["y"]-3.80, 0.0-0.9)
						if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunk.x, trunk.y, trunk.z, true) < 5.0) and jobForklift == nil then 
							T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_take_forklift'])
							if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunk.x, trunk.y, trunk.z, true) < 3.5) then 
								if IsControlJustPressed(0, Config.KeyControls['take_forklift']) then
									local plyPos = GetEntityCoords(GetPlayerPed(-1))
									SetVehicleDoorOpen(jobTrailer, 5, false, false)
									SetVehicleDoorOpen(jobTrailer, 6, false, false)
									SetVehicleDoorOpen(jobTrailer, 7, false, false)
									Wait(300)
									DoScreenFadeOut(1000)
									while not IsScreenFadedOut() do
										Wait(0)
									end
									ESX.Game.SpawnVehicle(val.forklift.model, {x = trunk.x, y = trunk.y, z = trunk.z}, GetEntityHeading(GetPlayerPed(-1)), function(veh)
										SetEntityCoordsNoOffset(veh, trunk.x, trunk.y, trunk.z)
										SetEntityHeading(veh, GetPlayerPed(-1))
										SetVehicleOnGroundProperly(veh)
										SetEntityAsMissionEntity(jobForklift, true, true)
										jobForklift = veh
										if Config.T1GER_Keys then
											local vehicle_plate = tostring(GetVehicleNumberPlateText(veh))
											local vehicle_name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
											exports['t1ger_keys']:SetVehicleLocked(veh, 0)
											exports['t1ger_keys']:GiveJobKeys(vehicle_plate, vehicle_name, true)
										end
										Wait(100)
										TaskWarpPedIntoVehicle(player, jobForklift, -1)
									end)
									local pSpot = deliveryCache.dropOffPallet.pickup
									ESX.Game.SpawnObject(Config.HighValueJobs[deliveryCache.num].prop, {x = pSpot.x, y = pSpot.y, z = pSpot.z}, function(pallet)
										SetEntityHeading(pallet, 150.0)
										SetEntityAsMissionEntity(pallet, true, true)
										PlaceObjectOnGroundProperly(pallet)
										Wait(500)
										deliveryCache.palletObjEntity = pallet
									end)
									DoScreenFadeIn(1000)
									Citizen.Wait(100)
									deliveryCache.onGoingDelivery = true
									deliveryCache.forkliftTaken = true
								end
							end
						end
					end
				end
			end

			if deliveryCache.forkliftTaken and deliveryCache.onGoingDelivery then 
				local pcoords = GetEntityCoords(deliveryCache.palletObjEntity)
				local mk = val.cargo.marker
				if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, pcoords.x, pcoords.y, pcoords.z, true) < 10.0) and not deliveryCache.palletDelivered then
					DrawMarker(mk.type, pcoords.x, pcoords.y, pcoords.z+1.6, 0, 0, 0, 180.0, 0, 0, mk.scale.x+0.2, mk.scale.y+0.2, mk.scale.z+0.2, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
					if IsEntityInAir(deliveryCache.palletObjEntity) then
						deliveryCache.curPallet_state = true
					end
					if not deliveryCache.curPallet_state then 
						DrawMissionText(Lang['pick_up_the_pallet'])
					end
				end

				if deliveryCache.curPallet_state then
					local coords = GetEntityCoords(GetPlayerPed(-1))
					local dSpot = deliveryCache.dropOffPallet.drop_off
					if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, dSpot.x, dSpot.y, dSpot.z, true) > 4.0) then 
						DrawMissionText(Lang['drop_off_the_pallet'])
					end
					if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, dSpot.x, dSpot.y, dSpot.z, true) < 25.0) then
						DrawMarker(27, dSpot.x, dSpot.y, dSpot.z-0.95, 0, 0, 0, 0.0, 0, 0, 1.0, 1.0, 1.0, 220, 60, 60, 100, false, true, 2, false, false, false, false)
						if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, dSpot.x, dSpot.y, dSpot.z, true) < 4.0) then
							T1GER_DrawTxt(dSpot.x, dSpot.y, dSpot.z, Lang['draw_deliver_pallet'])
							if IsControlJustPressed(0, Config.KeyControls['deliver_pallet']) then
								if not IsEntityInAir(deliveryCache.palletObjEntity) then
									DeleteObject(deliveryCache.palletObjEntity)
									deliveryCache.curPallet_state = false
									deliveryCache.palletObjEntity = nil
									deliveryCache.palletDelivered = true
									TriggerEvent('t1ger_deliveries:notify', Lang['park_fork_in_trailer'])
								else
									TriggerEvent('t1ger_deliveries:notify', Lang['place_pallet_on_ground'])
								end
							end
						end
					end
				end

				if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, deliveryCache.dropOffPos.x, deliveryCache.dropOffPos.y, deliveryCache.dropOffPos.z, true) < 25.0) and deliveryCache.palletDelivered then 
					if IsPedInAnyVehicle(player) then 
						local d1 = GetModelDimensions(GetEntityModel(jobTrailer))
						local trunk = GetOffsetFromEntityInWorldCoords(jobTrailer, 0.0, d1["y"]-3.0, 0.0-0.9)
						if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunk.x, trunk.y, trunk.z, true) < 5.0) and DoesEntityExist(jobForklift) then 
							T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_park_forklift'])
							if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunk.x, trunk.y, trunk.z, true) < 3.5) then 
								if IsControlJustPressed(0, Config.KeyControls['park_forklift']) then
									DoScreenFadeOut(1000)
									while not IsScreenFadedOut() do
										Wait(0)
									end
									Citizen.Wait(150)
									DeleteVehicle(jobForklift)
									jobForklift = nil
									deliveryCache.forkliftTaken = false
									deliveryCache.palletDelivered = false
									deliveryCache.onGoingDelivery = false
									SetVehicleDoorShut(jobTrailer, 5, true)
									SetVehicleDoorShut(jobTrailer, 6, true)
									SetVehicleDoorShut(jobTrailer, 7, true)
									DoScreenFadeIn(1000)
									Citizen.Wait(250)
									deliveryCache.deliveredPallets = deliveryCache.deliveredPallets + 1
									Config.HighValueJobs[deliveryCache.num].route[deliveryCache.currentRoute].done = true
									PalletDeliveryPay()
									if deliveryCache.deliveredPallets < deliveryCache.maxPallets then 
										SetTruckingRoute()
										TriggerEvent('t1ger_deliveries:notify', Lang['set_delivery_route'])
									elseif deliveryCache.deliveredPallets >= deliveryCache.maxPallets then 
										if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
										TriggerEvent('t1ger_deliveries:notify', Lang['delivery_pallets_done'])
										SetReturnBlip(val.spawn.x,val.spawn.y,val.spawn.z)
									end
								end
							end
						end 
					end
				end
			end

			local mk7 = val.refill.marker
			-- Return Veh & Paycheck Thread:
			if deliveryCache.deliveredPallets >= deliveryCache.maxPallets then 
				if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, val.spawn.x, val.spawn.y, val.spawn.z, true) < mk7.dist) and deliveryCache.truckingStarted then 
					if DoesEntityExist(jobVehicle) then
						DrawMarker(mk7.type, val.spawn.x,val.spawn.y,val.spawn.z-0.965, 0, 0, 0, 180.0, 0, 0, mk7.scale.x, mk7.scale.y, mk7.scale.z,mk7.color.r,mk7.color.g,mk7.color.b,mk7.color.a, false, true, 2)
						if (GetDistanceBetweenCoords(coords, val.spawn.x,val.spawn.y,val.spawn.z, true) < 4.0)  then
							T1GER_DrawTxt(val.spawn.x,val.spawn.y,val.spawn.z+0.8, Lang['draw_return_vehicle'])
							if IsControlJustPressed(0, Config.KeyControls['return_vehicle']) then
								local curVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
								if curVeh > 0 then
									if GetEntityModel(curVeh) == GetEntityModel(jobVehicle) then
										ReturnVehAndGetPaycheck()
									else
										TriggerEvent('t1ger_deliveries:notify', Lang['job_veh_mismatch'])
									end
								else
									TriggerEvent('t1ger_deliveries:notify', Lang['sit_in_job_veh'])
								end
							end
						end
					end
				end
			end

		end

		-- reset:
		if deliveryCache.complete then 
			vehDeposit = 0
			jobVehicle = nil
			jobTrailer = nil
			jobForklift = nil
			for i = 1, #Config.HighValueJobs[deliveryCache.num].route do
				Config.HighValueJobs[deliveryCache.num].route[i].done = false
			end 
			deliveryCache = {}
			break
		end

	end
end)

function ForkliftIntoTruck(palletSpots, objMarker, prop, jobValue)
	SetVehicleDoorOpen(jobTrailer, 5, false, false)
	SetVehicleDoorOpen(jobTrailer, 6, false, false)
	SetVehicleDoorOpen(jobTrailer, 7, false, false)
	-- Prepare Objects:
	local objCache = {}
	deliveryCache.maxPallets = #palletSpots
	local curPallet = {state = false, num = nil}
	local drawPalletText = true
	local totalPallets = #palletSpots
	for num,v in pairs(palletSpots) do
		ESX.Game.SpawnObject(prop, {x = v.x, y = v.y, z = v.z}, function(pallet)
            SetEntityHeading(pallet, 150.0)
            SetEntityAsMissionEntity(pallet, true, true)
            PlaceObjectOnGroundProperly(pallet)
            Wait(1000)
			objCache[num] = pallet
        end)
	end
	local fillingTrailer = true 

	-- Thread to fill up trailer:
	while fillingTrailer do 
		Citizen.Wait(3) 
		local player = PlayerPedId()
		local coords = GetEntityCoords(player)

		for num,v in pairs(objCache) do
			local pcoords = GetEntityCoords(objCache[num])
			local mk = objMarker
			if #(coords - pcoords) < mk.dist then 
				DrawMarker(mk.type, pcoords.x, pcoords.y, pcoords.z+1.6, 0, 0, 0, 180.0, 0, 0, mk.scale.x+0.2, mk.scale.y+0.2, mk.scale.z+0.2, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
				if not curPallet.state then
					if IsEntityInAir(objCache[num]) then
						curPallet.state = true
						curPallet.num = num
					end
				end
			end
			if not curPallet.state then
				DrawMissionText(Lang['pick_up_pallet'])
			end
		end

		if curPallet.state then
			local d1 = GetModelDimensions(GetEntityModel(jobTrailer))
			local trunk = GetOffsetFromEntityInWorldCoords(jobTrailer, 0.0, d1["y"]-1.0, 0.0-0.3)
			if #(coords - trunk) > 5.0 then 
				DrawMissionText(Lang['load_into_trailer'])
			end
			if #(coords - trunk) < 5.0 then 
				T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_pallet_in_trailer'])
				if IsControlJustPressed(0, Config.KeyControls['put_pallet_in_trailer']) then
					DeleteObject(objCache[curPallet.num])
					curPallet.state = false
					objCache[curPallet.num] = nil
					totalPallets = totalPallets - 1
					if totalPallets == 0 then 
						fillingTrailer = false
						deliveryCache.traillerFilledUp = true
					end
				end
			end
		end

		if drawPalletText then 
			drawRct(0.91, 0.95, 0.07, 0.035, 0, 0, 0, 80)
			SetTextScale(0.40, 0.40)
			SetTextFont(4)
			SetTextProportional(1)
			SetTextColour(255, 255, 255, 255)
			SetTextEdge(2, 0, 0, 0, 150)
			SetTextEntry("STRING")
			SetTextCentre(1)
			AddTextComponentString("Pallets ["..(math.floor(deliveryCache.maxPallets - totalPallets)).."/"..tonumber(deliveryCache.maxPallets).."]")
			DrawText(0.945,0.9523)
		end
	end
end

function SetTruckingRoute()
	local quickLoop = Config.HighValueJobs[deliveryCache.num].route
	for i = 1, #quickLoop, 1 do 
		if not quickLoop[i].done then
			deliveryCache.dropOffPos = quickLoop[i].pos
			deliveryCache.dropOffPallet = quickLoop[i].pallet
			deliveryCache.currentRoute = i
		end
	end
	SetTruckingBlip(deliveryCache.dropOffPos.x, deliveryCache.dropOffPos.y, deliveryCache.dropOffPos.z)
	deliveryCache.truckHealth = GetVehicleBodyHealth(jobVehicle)
	deliveryCache.palletPrice = CalculatePrice(deliveryCache.jobValue)
end

function PalletDeliveryPay()
	local newVehBody = GetVehicleBodyHealth(jobVehicle)
	local dmgPercent = (1-(Config.DamagePercent/100))
	if newVehBody < (deliveryCache.truckHealth*dmgPercent) then 
		TriggerEvent('t1ger_deliveries:notify', Lang['pallet_damaged_transit'])
		deliveryCache.paycheck = deliveryCache.paycheck
	else
		deliveryCache.paycheck = deliveryCache.paycheck + deliveryCache.palletPrice
		TriggerEvent('t1ger_deliveries:notify', (Lang['paycheck_add_amount']:format(deliveryCache.palletPrice)))
	end
end

function SetTruckingBlip(x,y,z)
	if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
	deliveryCache.blip = AddBlipForCoord(x,y,z)
	SetBlipSprite(deliveryCache.blip, 501)
	SetBlipColour(deliveryCache.blip, 5)
	SetBlipRoute(deliveryCache.blip, true)
	SetBlipScale(deliveryCache.blip, 0.7)
	SetBlipAsShortRange(deliveryCache.blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Lang['trucking_blip'])
	EndTextCommandSetBlipName(deliveryCache.blip)
end

function SpawnTruckTrailer(trailerModel, vehCoords, vehHeading)
	ESX.Game.SpawnVehicle(trailerModel, {x = vehCoords.x, y = vehCoords.y, z = vehCoords.z}, vehHeading, function(trailer)
		SetEntityCoordsNoOffset(trailer, vehCoords.x, vehCoords.y, vehCoords.z)
		SetEntityHeading(trailer, vehHeading)
		FreezeEntityPosition(trailer, true)
		SetVehicleOnGroundProperly(trailer)
		FreezeEntityPosition(trailer, false)
		SetEntityAsMissionEntity(jobTrailer, true, true)
		jobTrailer = trailer
		SetVehicleDoorsLockedForAllPlayers(jobTrailer, false)
	end)
	TriggerEvent('t1ger_deliveries:notify', Lang['job_trailer_spawned'])
end

-- ## LOW & MEDIUM VALUE JOBS ## --
RegisterNetEvent('t1ger_deliveries:parcelDelivery')
AddEventHandler('t1ger_deliveries:parcelDelivery', function(id, val, jobValue, shopOrder)
	deliveryCache.complete = false
	deliveryCache.started = false
	deliveryCache.jobValue = jobValue
	deliveryCache.paycheck = 0
	deliveryCache.id = id 
	deliveryCache.val = val 

	local mk1 = val.refill.marker

	while true do
		Citizen.Wait(1)
		local sleep = true 
		-- Fill up vehicle:
		if deliveryCache.started == false then
			local distance = #(coords - val.refill.pos)
			if distance <= mk1.dist then
				if DoesEntityExist(jobVehicle) then
					sleep = false 
					DrawMarker(mk1.type, val.refill.pos.x, val.refill.pos.y, val.refill.pos.z-0.965, 0, 0, 0, 180.0, 0, 0, mk1.scale.x, mk1.scale.y, mk1.scale.z,mk1.color.r,mk1.color.g,mk1.color.b,mk1.color.a, false, true, 2)
					if distance < 3.5 then
						T1GER_DrawTxt(val.refill.pos.x, val.refill.pos.y, val.refill.pos.z+0.8, Lang['draw_fill_up_vehicle'])
						if IsControlJustPressed(0, Config.KeyControls['fill_up_vehicle']) then
							local curVeh = GetVehiclePedIsIn(player, false)
							if curVeh ~= 0 then
								if GetEntityModel(curVeh) == GetEntityModel(jobVehicle) then
									if deliveryCache.jobValue == 1 or deliveryCache.jobValue == 4 then
										deliveryCache.objProp = Config.ParcelProp
									elseif deliveryCache.jobValue == 2 then
										deliveryCache.commerical = math.random(1,#Config.MedValueJobs)
										deliveryCache.objProp = Config.MedValueJobs[deliveryCache.commerical].prop
									end
									RefillJobVehicle(val.cargo.pos, val.cargo.marker, deliveryCache.jobValue, shopOrder)
								else
									TriggerEvent('t1ger_deliveries:notify', Lang['job_veh_mismatch'])
								end
							else
								TriggerEvent('t1ger_deliveries:notify', Lang['sit_in_job_veh'])
							end
						end
					end
				end
			end
		end

		-- Delivery:
		if deliveryCache.started == true then

			-- taking out parcel:
			if deliveryCache.parcel == nil then
				local distance = #(coords - deliveryCache.pos)
				if distance < 20.0 then
					if not IsPedInAnyVehicle(player) then
						if deliveryCache.deliveredParcels < deliveryCache.maxDeliveries then
							local d1 = GetModelDimensions(GetEntityModel(jobVehicle))
							local trunk = GetOffsetFromEntityInWorldCoords(jobVehicle, 0.0, d1["y"]+0.60, 0.0)
							if #(coords - trunk) < 2.0 then
								sleep = false 
								if deliveryCache.parcel == nil then
									T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_take_parcel'])
									if IsControlJustPressed(0, Config.KeyControls['take_parcel']) then
										SetVehicleDoorOpen(jobVehicle, 2 , false, false)
										SetVehicleDoorOpen(jobVehicle, 3 , false, false)
										Wait(250)
										T1GER_LoadModel(deliveryCache.objProp)
										deliveryCache.parcel = CreateObject(GetHashKey(deliveryCache.objProp), coords.x, coords.y, coords.z, true, true, true)
										AttachEntityToEntity(deliveryCache.parcel, player, GetPedBoneIndex(player,  28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
										T1GER_LoadAnim("anim@heists@box_carry@")
										TaskPlayAnim(player, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
										Wait(300)
										SetVehicleDoorShut(jobVehicle, 2 , false, true)
										SetVehicleDoorShut(jobVehicle, 3 , false, true)
									end
								end
							end
						end
					end
				end
			end

			-- deliver parcel:
			if deliveryCache.parcel ~= nil then
				local distance = #(coords - deliveryCache.pos)
				if distance < 20.0 then
					local mk2 = Config.MarkerSettings['delivery']
					if distance >= 2.0 then
						sleep = false 
						DrawMarker(mk2.type, deliveryCache.pos.x, deliveryCache.pos.y, deliveryCache.pos.z, 0, 0, 0, 180.0, 0, 0, mk2.scale.x, mk2.scale.y, mk2.scale.z, mk2.color.r, mk2.color.g, mk2.color.b, mk2.color.a, false, true, 2)
					end
					if distance < 2.0 then
						sleep = false
						T1GER_DrawTxt(deliveryCache.pos.x, deliveryCache.pos.y, deliveryCache.pos.z, Lang['draw_deliver_parcel'])
						if IsControlJustPressed(0, Config.KeyControls['deliver_parcel']) then
							if deliveryCache.deliveredParcels < deliveryCache.maxDeliveries then
								if IsEntityAttachedToAnyPed(deliveryCache.parcel) then 
									DeleteObject(deliveryCache.parcel)
									ClearPedTasks(player)
									deliveryCache.deliveredParcels = deliveryCache.deliveredParcels + 1
									if deliveryCache.jobValue == 1 then 
										Config.LowValueJobs[deliveryCache.num].done = true
									elseif deliveryCache.jobValue == 2 then 
										Config.MedValueJobs[deliveryCache.commerical].deliveries[deliveryCache.num].done = true
									end
									ParcelDeliveryPay()
									if deliveryCache.deliveredParcels < deliveryCache.maxDeliveries then 
										SetDeliveryRoute(deliveryCache.jobValue)
										TriggerEvent('t1ger_deliveries:notify', Lang['set_delivery_route'])
									elseif deliveryCache.deliveredParcels == deliveryCache.maxDeliveries then 
										if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
										TriggerEvent('t1ger_deliveries:notify', Lang['delivery_complete'])
										if deliveryCache.jobValue == 4 then
											TriggerServerEvent('t1ger_deliveries:orderDeliveryDone', shopOrder)
										end
										SetReturnBlip(val.spawn.x,val.spawn.y,val.spawn.z)
									end
									deliveryCache.parcel = nil 
								else
									TriggerEvent('t1ger_deliveries:notify', Lang['parcel_not_ind_hand'])
								end
							end
						end
					end
				end
			end

			-- return vehicle
			if deliveryCache.deliveredParcels == deliveryCache.maxDeliveries and deliveryCache.parcel == nil then
				local player = PlayerPedId(player)
				local coords = GetEntityCoords(player)
				if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, val.spawn.x, val.spawn.y, val.spawn.z, false) < mk1.dist then
					if DoesEntityExist(jobVehicle) then
						sleep = false
						DrawMarker(mk1.type, val.spawn.x, val.spawn.y, val.spawn.z-0.965, 0, 0, 0, 180.0, 0, 0, mk1.scale.x, mk1.scale.y, mk1.scale.z,mk1.color.r,mk1.color.g,mk1.color.b,mk1.color.a, false, true, 2, false, false, false, false)
						if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, val.spawn.x, val.spawn.y, val.spawn.z, false) < 4.0 then
							T1GER_DrawTxt(val.spawn.x, val.spawn.y, val.spawn.z+0.8, Lang['draw_return_vehicle'])
							if IsControlJustPressed(0, Config.KeyControls['return_vehicle']) then
								local curVeh = GetVehiclePedIsIn(player, false)
								if curVeh ~= 0 then
									if GetEntityModel(curVeh) == GetEntityModel(jobVehicle) then
										ReturnVehAndGetPaycheck()
									else
										TriggerEvent('t1ger_deliveries:notify', Lang['job_veh_mismatch'])
									end
								else
									TriggerEvent('t1ger_deliveries:notify', Lang['sit_in_job_veh'])
								end
							end
						end
					end
				end
			end

		end

		-- reset:
		if deliveryCache.complete then 
			vehDeposit = 0
			jobVehicle = nil
			if jobValue == 1 then
				for i = 1, #Config.LowValueJobs do
					Config.LowValueJobs[i].done = false
				end
			elseif jobValue == 2 then
				for i = 1, #Config.MedValueJobs do
					for k,v in pairs(Config.MedValueJobs[i].deliveries) do
						v.done = false
					end
				end 
			end
			deliveryCache = {}
			break
		end

		if sleep then
			Citizen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		if deliveryCache.started then
			sleep = false
			drawRct(0.865, 0.95, 0.1430, 0.035, 0, 0, 0, 80)
			SetTextScale(0.40, 0.40)
			SetTextFont(4)
			SetTextProportional(1)
			SetTextColour(255, 255, 255, 255)
			SetTextEdge(2, 0, 0, 0, 150)
			SetTextEntry("STRING")
			SetTextCentre(1)
			AddTextComponentString("Parcels ["..comma_value(deliveryCache.maxDeliveries-deliveryCache.deliveredParcels).."/"..tonumber(deliveryCache.maxDeliveries).."] | Paycheck [$"..comma_value(deliveryCache.paycheck).."]")
			DrawText(0.933,0.9523)
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

function RefillJobVehicle(objSpots, objMarker, jobValue, shopOrder)
	local objCache = {}
	-- Prepare Vehicle:
	SetVehicleEngineOn(jobVehicle, false, false, false)
	SetVehicleDoorOpen(jobVehicle, 2 , false, false)
	SetVehicleDoorOpen(jobVehicle, 3 , false, false)
	if IsPedInAnyVehicle(player, true) then
		TaskLeaveVehicle(player, jobVehicle, 4160)
		SetVehicleDoorsLockedForAllPlayers(jobVehicle, true)
	end
	Citizen.Wait(500)
	FreezeEntityPosition(jobVehicle, true)
	-- Prepare Objects:
	if jobValue == 4 then
		deliveryCache.maxDeliveries = 1
	else
		deliveryCache.maxDeliveries = #objSpots
	end
	local currentObj = {state = false, num = nil}
	local drawObjText = true
	local totalObjects = #objSpots
	if jobValue == 4 then
		totalObjects = 1
	end
	for num,v in pairs(objSpots) do
		local cache = { entity = CreateObject(GetHashKey(deliveryCache.objProp), v.x, v.y, v.z-0.965, true, true, true), pos = v }
		objCache[num] = cache
		PlaceObjectOnGroundProperly(objCache[num].entity)
		if jobValue == 4 then break end
	end
	-- Thread to fill up job vehicle:
	local fillingVeh = true 
	while fillingVeh do 
		Citizen.Wait(1)
		local player = GetPlayerPed(-1)
		local coords = GetEntityCoords(player)
		for k,v in pairs(objCache) do
			local mk = objMarker
			local distance = #(coords - v.pos)
			if distance < mk.dist and not currentObj.state then
				if distance >= 1.0 then
					DrawMarker(mk.type, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 180.0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
				end
				if distance < 1.0 then
					T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, Lang['draw_pick_up_parcel'])
					if IsControlJustPressed(0, Config.KeyControls['pick_up_parcel']) then
						AttachEntityToEntity(objCache[k].entity, player, GetPedBoneIndex(player, 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
						T1GER_LoadAnim("anim@heists@box_carry@")
						TaskPlayAnim(player, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
						currentObj.state = true
						currentObj.num = k
					end 
				end
			end
		end

		if currentObj.state then
			local d1 = GetModelDimensions(GetEntityModel(jobVehicle))
			local trunk = GetOffsetFromEntityInWorldCoords(jobVehicle, 0.0,d1["y"]+0.60,0.0)
			if #(coords - trunk) < 2.0 then
				T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_parcel_in_veh'])
				if IsControlJustPressed(0, Config.KeyControls['parcel_in_veh']) then
					DeleteObject(objCache[currentObj.num].entity)
					ClearPedTasks(player)
					currentObj.state = false
					objCache[currentObj.num] = nil
					totalObjects = totalObjects - 1
					if totalObjects == 0 then 
						if jobValue == 4 then
							SetShopRoute(jobValue, shopOrder)
						else
							SetDeliveryRoute(jobValue)
						end
						SetVehicleDoorsLockedForAllPlayers(jobVehicle, false)
						FreezeEntityPosition(jobVehicle, false)
						SetVehicleEngineOn(jobVehicle, true, false, false)
						SetVehicleDoorShut(jobVehicle, 2 , false, true)
						SetVehicleDoorShut(jobVehicle, 3 , false, true)
						deliveryCache.started = true
						deliveryCache.deliveredParcels = 0
						TriggerEvent('t1ger_deliveries:notify', Lang['vehicle_filled_up'])
						fillingVeh = false
					end
				end
			end
		end

		if drawObjText then 
			drawRct(0.91, 0.95, 0.07, 0.035, 0, 0, 0, 80)
			SetTextScale(0.40, 0.40)
			SetTextFont(4)
			SetTextProportional(1)
			SetTextColour(255, 255, 255, 255)
			SetTextEdge(2, 0, 0, 0, 150)
			SetTextEntry("STRING")
			SetTextCentre(1)
			AddTextComponentString("Parcels ["..(math.floor(deliveryCache.maxDeliveries - totalObjects)).."/"..tonumber(deliveryCache.maxDeliveries).."]")
			DrawText(0.945,0.9523)
		end
	end
end

function SetShopRoute(jobValue, shopOrder)
	deliveryCache.pos = vector3(shopOrder.pos[1], shopOrder.pos[2], shopOrder.pos[3])
	SetDeliveryBlip(deliveryCache.pos.x, deliveryCache.pos.y, deliveryCache.pos.z)
	deliveryCache.vehHealth = GetVehicleBodyHealth(jobVehicle)
	deliveryCache.parcelPrice = CalculatePrice(jobValue)
end

function SetDeliveryRoute(jobValue)
	local id = 0
	if jobValue == 1 then 
		id = math.random(#Config.LowValueJobs)
		while Config.LowValueJobs[id].done do 
			id = math.random(#Config.LowValueJobs)
		end
		deliveryCache.pos = Config.LowValueJobs[id].pos
	elseif jobValue == 2 then 
		id = math.random(#Config.MedValueJobs[deliveryCache.commerical].deliveries)
		while Config.MedValueJobs[deliveryCache.commerical].deliveries[id].done do 
			id = math.random(#Config.MedValueJobs[deliveryCache.commerical].deliveries)
		end
		deliveryCache.pos = Config.MedValueJobs[deliveryCache.commerical].deliveries[id].pos
	end
	deliveryCache.num = id
	SetDeliveryBlip(deliveryCache.pos.x, deliveryCache.pos.y, deliveryCache.pos.z)
	deliveryCache.vehHealth = GetVehicleBodyHealth(jobVehicle)
	deliveryCache.parcelPrice = CalculatePrice(jobValue)
end

function SetDeliveryBlip(x,y,z)
	if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
	deliveryCache.blip = AddBlipForCoord(x,y,z)
	SetBlipSprite(deliveryCache.blip, 501)
	SetBlipColour(deliveryCache.blip, 5)
	SetBlipRoute(deliveryCache.blip, true)
	SetBlipScale(deliveryCache.blip, 0.7)
	SetBlipAsShortRange(deliveryCache.blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Lang['delivery_blip'])
	EndTextCommandSetBlipName(deliveryCache.blip)
end

-- Adjust pricing here:
function CalculatePrice(level)
	local reward = Config.Reward
	math.randomseed(GetGameTimer())
	local random = math.random(reward.min,reward.max)
	local packagePrice = (random * (((reward.valueAddition[level])/100) + 1)) 
	return math.floor(packagePrice)
end

function ParcelDeliveryPay()
	local newVehBody = GetVehicleBodyHealth(jobVehicle)
	local dmgPercent = (1-(Config.DamagePercent/100))
	if newVehBody < (deliveryCache.vehHealth*dmgPercent) then 
		TriggerEvent('t1ger_deliveries:notify', Lang['parcel_damaged_transit'])
		deliveryCache.paycheck = deliveryCache.paycheck
	else
		deliveryCache.paycheck = deliveryCache.paycheck + deliveryCache.parcelPrice
		TriggerEvent('t1ger_deliveries:notify', Lang['paycheck_add_amount']:format(deliveryCache.parcelPrice))
	end
end

function ReturnVehAndGetPaycheck()
	if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
	SetVehicleEngineOn(jobVehicle, false, false, false)
	if IsPedInAnyVehicle(player, true) then
		TaskLeaveVehicle(player, jobVehicle, 4160)
		SetVehicleDoorsLockedForAllPlayers(jobVehicle, true)
	end
	local newVehBody = GetVehicleBodyHealth(jobVehicle)
	Citizen.Wait(500)
	FreezeEntityPosition(jobVehicle, true)
	local giveDeposit = false
	local dmgDeposit = (1-(Config.DepositDamage/100))
	if newVehBody < (1000*dmgDeposit) then 
		giveDeposit = false
		TriggerEvent('t1ger_deliveries:notify', Lang['deposit_not_returned'])
	else
		giveDeposit = true
	end
	if vehicle_deposit == nil then 
		giveDeposit = false
	end
	DeleteVehicle(jobVehicle)
	if DoesEntityExist(jobTrailer) then DeleteVehicle(jobTrailer) end
	TriggerServerEvent('t1ger_deliveries:retrievePaycheck', deliveryCache.paycheck, vehicle_deposit, giveDeposit, deliveryCache.id, deliveryCache.val)
	deliveryCache.complete = true
end

function SpawnJobVehicle(model, pos, heading, props)
	ESX.Game.SpawnVehicle(model, {x = pos.x, y = pos.y, z = pos.z}, heading, function(veh)
		SetEntityCoordsNoOffset(veh, pos.x, pos.y, pos.z)
		SetEntityHeading(veh, heading)
		SetVehicleOnGroundProperly(veh)
		SetEntityAsMissionEntity(jobVehicle, true, true)
		if props ~= nil then 
			ESX.Game.SetVehicleProperties(veh, props)
		end
		jobVehicle = veh
		if Config.T1GER_Keys then
			local vehicle_plate = GetVehicleNumberPlateText(jobVehicle)
			local vehicle_name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(jobVehicle)))
			exports['t1ger_keys']:SetVehicleLocked(jobVehicle, 0)
			exports['t1ger_keys']:GiveJobKeys(vehicle_plate, vehicle_name, true)
		end
	end)
	TriggerEvent('t1ger_deliveries:notify', Lang['job_veh_spawned'])
end

function SetReturnBlip(x,y,z)
	if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
	deliveryCache.blip = AddBlipForCoord(x,y,z)
	SetBlipSprite(deliveryCache.blip, 164)
	SetBlipColour(deliveryCache.blip, 2)
	SetBlipRoute(deliveryCache.blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Lang['return_blip'])
	EndTextCommandSetBlipName(deliveryCache.blip)
end

-- Update Companies CFG Data:
RegisterNetEvent('t1ger_deliveries:updateCompanyDataCL')
AddEventHandler('t1ger_deliveries:updateCompanyDataCL', function(id, data)
	Config.Companies[id].data = data
end)

RegisterCommand('canceldelivery', function(source, args)
	deliveryCache.complete = true
	if DoesEntityExist(jobTrailer) then DeleteVehicle(jobTrailer) end 
	if DoesEntityExist(jobVehicle) then DeleteVehicle(jobVehicle) end
	if DoesBlipExist(deliveryCache.blip) then RemoveBlip(deliveryCache.blip) end
end, false)

RegisterCommand('deliveryDuty', function(source, args)
	ESX.TriggerServerCallback('t1ger_deliveries:hasCompany', function(isBoss, id) 
		if isBoss then 
			TriggerEvent('t1ger_deliveries:notify', 'Your job has been set to boss for delivery')
		else
			TriggerEvent('t1ger_deliveries:notify', 'You do not own any delivery companies to use this function.')
		end
	end)
end, false)