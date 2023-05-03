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

--------------------------------------------
-- ## NORMAL GARAGE THREAD & FUNCTIONS ## --
--------------------------------------------

local garage_blips, garage_menu = {}, false
Citizen.CreateThread(function()
	for i = 1, #Config.Garage.Locations do
		garage_blips[i] = T1GER_CreateBlip(Config.Garage.Locations[i].pos, Config.Garage.Locations[i].blip, Config.Garage.Locations[i].name)
	end
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Garage.Locations) do
			local distance, actVehicle, actPos, actText = 0, false, vector3(0.0,0.0,0.0), ''
			if not IsPedInAnyVehicle(player, true) and not IsVehicleNearby() then
				actPos = v.pos
				distance = #(coords - v.pos)
				actText = v.text
			else
				actPos = vector3(v.spawn.x,v.spawn.y,v.spawn.z)
				distance = #(coords - vector3(v.spawn.x,v.spawn.y,v.spawn.z))
				actText = v.text2
			end
			-- Interact:
			if v.marker.enable and distance <= v.marker.drawDist then 
				sleep = false
				if not garage_menu then 
					if distance > v.dist then 
						local mk = v.marker
						DrawMarker(mk.type, actPos.x, actPos.y, actPos.z, 0, 0, 0, 0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
					end
					if distance <= v.dist then
						T1GER_DrawTxt(actPos.x, actPos.y, actPos.z, actText)
						if IsControlJustPressed(0, Config.JobGarage.Keybind) then
							GarageMenu(v)
						end
					end
				end
				if #(coords - v.pos) > v.dist and garage_menu then
					ESX.UI.Menu.CloseAll()
					garage_menu = false
				end
			end
		end
		if sleep then
			Citizen.Wait(1000) 
		end 
	end
end)

function GarageMenu(val)
	local vehicle = 0
	if IsPedInAnyVehicle(player, false) then 
		vehicle = GetVehiclePedIsIn(player, false)
	else
		vehicle = IsVehicleNearby()
	end
	if vehicle ~= 0 and DoesEntityExist(vehicle) then
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		local props = GetVehicleProperties(vehicle)
		props.plate = plate
		local fuel = GetVehicleFuel(vehicle)
		if IsVehiclePlateValid(plate) then
			if IsTypeAllowed(plate, val.type) then
				if Config.StoreAnotherVehicle then 
					TriggerServerEvent('t1ger_garage:setVehicleStored', plate, props, fuel, val.name)
					if DoesEntityExist(vehicle) then 
						T1GER_DeleteVehicle(vehicle)
					end
				else
					if IsVehicleOwned(plate) then 
						TriggerServerEvent('t1ger_garage:setVehicleStored', plate, props, fuel, val.name)
						if DoesEntityExist(vehicle) then 
							T1GER_DeleteVehicle(vehicle)
						end
					else
						TriggerEvent('t1ger_garage:notify', Lang['you_dont_own_vehicle'])
					end
				end
			else
				TriggerEvent('t1ger_garage:notify', 'You cannot park this type of vehicle in this type of garage!')
			end
		else
			TriggerEvent('t1ger_garage:notify', Lang['you_dont_own_vehicle'])
		end
	else
		local elements = {}
		ESX.TriggerServerCallback('t1ger_garage:getOwnedVehicles', function(results) 
			if not results then
				ESX.UI.Menu.CloseAll()
				garage_menu = false
				return TriggerEvent('t1ger_garage:notify', Lang['no_owned_veh_in_garage']) 
			else
				for i = 1, #results do
					if results[i].garage ~= 'impound' then 
						if results[i].state then
							local props = json.decode(results[i].vehicle)
							local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
							table.insert(elements, {
								label = name..' ['..results[i].plate..']',
								name = name,
								value = results[i],
								plate = results[i].plate,
								fuel = results[i].fuel,
								props = props,
								type = val.type
							})
						end
					end
				end
				if next(elements) == nil then 
					garage_menu = false
					ESX.UI.Menu.CloseAll()
					return TriggerEvent('t1ger_garage:notify', Lang['no_owned_veh_in_garage'])
				end
				-- vehicle display:
				garage_menu = true
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_vehicle_list',
					{
						title    = Lang['select_vehicle'],
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					if not data.current.seized then
						local elements2 = {
							{label = Lang['spawn_vehicle'], value = 'spawn_vehicle'}
						}
						if Config.Garage.Transfer then 
							table.insert(elements2, {label = 'Transfer Vehicle', value = 'transfer_vehicle'})
						end
						local info = data.current
						if info.props.engineHealth ~= nil then
							table.insert(elements2,{ label = "Fuel: "..round(info.fuel,1).."% | Engine: "..round(info.props.engineHealth,2), value = nil, fuel = info.fuel, engine = info.props.engineHealth })
						else
							table.insert(elements2,{ label = "Fuel: "..round(info.fuel,1).."%", value = nil, fuel = info.fuel })
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'view_vehicle_info',
							{
								title    = info.name..' ['..info.plate..']',
								align    = 'center',
								elements = elements2
							},
						function(data2, menu2)
							if data2.current.value == 'spawn_vehicle' then
								SpawnVehicle(val, data.current.props, data.current.fuel)
								ESX.UI.Menu.CloseAll()
								garage_menu = false
							end
							if data2.current.value == 'transfer_vehicle' then
								local elements3 = {}
								for k,v in pairs(Config.Garage.Locations) do
									if v.name ~= val.name and v.type == val.type then
										table.insert(elements3, {label = 'Garage: '..v.name, value = v})
									end 
								end
								if next(elements3) then
									ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_transfer',
										{
											title    = Lang['transfer_veh'],
											align    = 'center',
											elements = elements3
										},
									function(data3, menu3)
										TriggerServerEvent('t1ger_garage:transferVehicle', data.current.plate, data3.current.value.name)
										ESX.UI.Menu.CloseAll()
										garage_menu = false
									end, function(data3, menu3)
										menu3.close()
									end)
								else
									menu2.close()
									TriggerEvent('t1ger_garage:notify', Lang['no_garage_to_transfer'])
								end
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					else
						TriggerEvent('t1ger_garage:notify', Lang['veh_seized_contact_pol'])
						ESX.UI.Menu.CloseAll()
						garage_menu = false
					end
				end, function(data2, menu)
					menu.close()
					garage_menu = false
				end)
			end
		end, val.name, val.type)
	end
end

function SpawnVehicle(val, props, fuel)
	local veh_cache = T1GER_GetClosestVehicle(val.spawn)
	if veh_cache ~= 0 then
		Citizen.Wait(250)
		return TriggerEvent('t1ger_garage:notify', Lang['spawn_area_blocked'])
	end
	T1GER_LoadModel(props.model)
	ESX.Game.SpawnVehicle(props.model, vector3(val.spawn.x,val.spawn.y,val.spawn.z), val.spawn.w, function(vehicle)
		while not DoesEntityExist(vehicle) do
			Wait(10)
		end
		SetVehicleProperties(vehicle, props)
		if Config.Garage.Teleport then 
			TaskWarpPedIntoVehicle(player, vehicle, -1)
		end
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		if Config.T1GER_Keys then
			exports['t1ger_keys']:SetVehicleLocked(vehicle, 0)
		end
		SetVehicleFuel(vehicle, fuel)
		TriggerServerEvent('t1ger_garage:updateState', plate, 'garage')
	end)
end

-----------------------------------------
-- ## JOB GARAGE THREAD & FUNCTIONS ## --
-----------------------------------------

local job_garage_blips, job_garage_menu = {}, false
Citizen.CreateThread(function()
	for i = 1, #Config.JobGarage.Locations do
		job_garage_blips[i] = T1GER_CreateBlip(Config.JobGarage.Locations[i].pos, Config.JobGarage.Locations[i].blip)
	end
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.JobGarage.Locations) do
			if T1GER_GetJob(v.jobs) then
				local distance, actVehicle, actPos, actText = 0, false, vector3(0.0,0.0,0.0), ''
				if not IsPedInAnyVehicle(player, true) and not IsVehicleNearby() then
					actPos = v.pos
					distance = #(coords - v.pos)
					actText = v.text
				else
					actPos = vector3(v.spawn.x,v.spawn.y,v.spawn.z)
					distance = #(coords - vector3(v.spawn.x,v.spawn.y,v.spawn.z))
					actText = v.text2
				end
				-- Interact:
				if v.marker.enable and distance <= v.marker.drawDist then 
					sleep = false
					if not job_garage_menu then 
						if distance > v.dist then 
							local mk = v.marker
							DrawMarker(mk.type, actPos.x, actPos.y, actPos.z, 0, 0, 0, 0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
						end
						if distance <= v.dist then
							T1GER_DrawTxt(actPos.x, actPos.y, actPos.z, actText)
							if IsControlJustPressed(0, Config.JobGarage.Keybind) then
								JobGarageMenu(v)
							end
						end
					end
					if #(coords - v.pos) > v.dist and job_garage_menu then
						ESX.UI.Menu.CloseAll()
						job_garage_menu = false
					end
				end
			end
		end
		if sleep then
			Citizen.Wait(1000) 
		end 
	end
end)

function JobGarageMenu(val)
	local vehicle = 0
	if IsPedInAnyVehicle(player, false) then 
		vehicle = GetVehiclePedIsIn(player, false)
	else
		vehicle = IsVehicleNearby()
	end
	if vehicle ~= 0 and DoesEntityExist(vehicle) then
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		local props = GetVehicleProperties(vehicle)
		props.plate = plate
		local fuel = GetVehicleFuel(vehicle)
		if IsVehiclePlateValid(plate) then
			if IsTypeAllowed(plate, val.type) then
				TriggerServerEvent('t1ger_garage:setJobVehicleStored', plate, props, fuel)
			else
				TriggerEvent('t1ger_garage:notify', 'You cannot park this type of vehicle in this type of garage!')
			end
		else
			TriggerEvent('t1ger_garage:notify', Lang['vehicle_deleted']:format(plate))
		end
		if DoesEntityExist(vehicle) then 
			T1GER_DeleteVehicle(vehicle)
		end
	else
		local elements = {}
		if val.options == 'both' then
			table.insert(elements, {label = 'Vehicle Spawner', value = 'vehicle_spawner', jobs = val.jobs})
			table.insert(elements, {label = 'Society Vehicles', value = 'society_vehicles', jobs = val.jobs})
		elseif val.options == 'society' then
			table.insert(elements, {label = 'Society Vehicles', value = 'society_vehicles', jobs = val.jobs})
		elseif val.options == 'spawner' then
			table.insert(elements, {label = 'Vehicle Spawner', value = 'vehicle_spawner', jobs = val.jobs})
		end
		ESX.UI.Menu.CloseAll()
		job_garage_menu = true
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_veh_type',
			{
				title    = Lang['job_vehicles'],
				align    = 'center',
				elements = elements
			},
		function(data, menu)
			local elements2 = {}
			-- vehicle spawner menu:
			if data.current.value == 'vehicle_spawner' then
				for k,v in pairs(Config.JobVehicles[PlayerData.job.name]) do
					if PlayerData.job.grade >= v.grade then
						if val.type == v.type then 
							table.insert(elements2, {label = v.label, model = v.model, type = v.type})
						end
					end
				end
				if next(elements2) == nil then 
					job_garage_menu = false
					ESX.UI.Menu.CloseAll()
					return TriggerEvent('t1ger_garage:notify', Lang['no_job_vehicles_avail'])
				end
				-- vehicle display:
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_veh_list',
					{
						title    = Lang['select_vehicle'],
						align    = 'center',
						elements = elements2
					},
				function(data2, menu2)
					ESX.UI.Menu.CloseAll()
					job_garage_menu = false
					SpawnJobVehicle(val, data2.current.model, data2.current.label, data.current.jobs)
				end, function(data2, menu2)
					menu2.close()
				end)
			end
			-- society vehicle spawner:
			if data.current.value == 'society_vehicles' then
				ESX.TriggerServerCallback('t1ger_garage:getSocietyVehicles', function(results) 
					if not results then
						ESX.UI.Menu.CloseAll()
						job_garage_menu = false
						return TriggerEvent('t1ger_garage:notify', Lang['no_society_vehicles'])
					else
						for i = 1, #results do
							if results[i].garage ~= 'impound' then 
								if results[i].state then
									local props = json.decode(results[i].vehicle)
									local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
									table.insert(elements2, {
										label = name..' ['..results[i].plate..']',
										name = name,
										value = results[i],
										plate = results[i].plate,
										fuel = results[i].fuel,
										props = props,
										type = val.type,
										seized = results[i].seized
									})
								end
							end
						end
						if next(elements2) == nil then 
							job_garage_menu = false
							ESX.UI.Menu.CloseAll()
							return TriggerEvent('t1ger_garage:notify', Lang['no_society_vehicles'])
						end
						-- vehicle display:
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_veh_list',
							{
								title    = Lang['select_vehicle'],
								align    = 'center',
								elements = elements2
							},
						function(data2, menu2)
							ESX.UI.Menu.CloseAll()
							job_garage_menu = false
							if not data2.current.seized then
								SpawnJobVehicle(val, data2.current.props.model, data2.current.name, data.current.jobs, data2.current.fuel, data2.current.props)
							else
								TriggerEvent('t1ger_garage:notify', Lang['veh_seized_contact_pol'])
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					end
				end, val.type, data.current.jobs[1])
			end
		end, function(data, menu)
			menu.close()
			job_garage_menu = false
		end)
	end
end

function SpawnJobVehicle(val, model, name, jobs, fuel, props)
	local veh_cache = T1GER_GetClosestVehicle(val.spawn)
	if veh_cache ~= 0 then
		Citizen.Wait(250)
		return TriggerEvent('t1ger_garage:notify', Lang['spawn_area_blocked'])
	end
	local plate = nil
	T1GER_LoadModel(model)
	ESX.Game.SpawnVehicle(model, vector3(val.spawn.x,val.spawn.y,val.spawn.z), val.spawn.w, function(vehicle)
		while not DoesEntityExist(vehicle) do
			Wait(5)
		end
		if Config.JobGarage.Teleport then 
			TaskWarpPedIntoVehicle(player, vehicle, -1)
		end
		if props ~= nil then
			SetVehicleProperties(vehicle, props)
			plate = tostring(GetVehicleNumberPlateText(vehicle))
		else
			if Config.T1GER_Dealerships then 
				plate = exports['t1ger_dealerships']:ProduceNumberPlate()
			else
				plate = exports['esx_vehicleshop']:GeneratePlate()
			end
			SetVehicleNumberPlateText(vehicle, plate)
		end
		if Config.T1GER_Keys then
			exports['t1ger_keys']:SetVehicleLocked(vehicle, 0)
			if val.jobKeys ~= nil then
				if val.jobKeys == 1 then 
					exports['t1ger_keys']:GiveJobKeys(plate, name, true)
				elseif val.jobKeys == 2 then 
					exports['t1ger_keys']:GiveJobKeys(plate, name, false, jobs)
				end
			end
		end
		if fuel ~= nil then 
			SetVehicleFuel(vehicle, fuel)
		else
			SetVehicleFuel(vehicle, Config.JobGarage.FuelLevel)
		end
		TriggerServerEvent('t1ger_garage:updateState', plate, 'job')
	end)
end

------------------------------------
-- ## EXTRA THREAD & FUNCTIONS ## --
------------------------------------
local extra_blips, extra_menu = {}, false
Citizen.CreateThread(function()
	for i = 1, #Config.Extras.Locations do
		extra_blips[i] = T1GER_CreateBlip(Config.Extras.Locations[i].pos, Config.Extras.Locations[i].blip)
	end
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Extras.Locations) do
			local distance = #(coords - v.pos)
			if distance <= 10.0 then
				if IsPedInAnyVehicle(player, false) then
					sleep = false
					local vehicle = GetVehiclePedIsIn(player, false)
					if CheckClasses(vehicle, v.classes) then
						if not extra_menu then 
							if v.marker.enable and distance > 3.0 then 
								local mk = v.marker
								DrawMarker(mk.type, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
							end
							if distance < 3.0 then
								T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, v.text)
								if IsControlJustPressed(0, Config.Extras.Keybind) then
									OpenExtraMenu(v)
								end
							end
						end
					end
					if distance > 3.0 and extra_menu then
						ESX.UI.Menu.CloseAll()
						extra_menu = false
					end 
				end
			end
		end
		if sleep then
			Citizen.Wait(1000) 
		end 
	end
end)

function OpenExtraMenu(val)
	extra_menu = true
	local elements = {
		{label = 'Livery', value = 'livery'},
		{label = 'Extra', value = 'extra'}
	}
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_main_menu', {
		title    = Lang['veh_extra_menu'],
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		local vehicle = GetVehiclePedIsIn(player, false)
		if data.current.value == 'extra' then
			local elements2 = {}
			for id = 0, 12 do
				if DoesExtraExist(vehicle, id) then
					local state = IsVehicleExtraTurnedOn(vehicle, id) 
					if state then
						table.insert(elements2, {
							label = "Extra: "..id.." "..('<span style="color:green;">%s</span>'):format("On"),
							value = id,
							state = not state
						})
					else
						table.insert(elements2, {
							label = "Extra: "..id.." "..('<span style="color:red;">%s</span>'):format("Off"),
							value = id,
							state = not state
						})
					end
				end
			end
			if next(elements2) == nil then
				ESX.UI.Menu.CloseAll()
				extra_menu = false
				return TriggerEvent('t1ger_garage:notify', Lang['veh_no_extras'])
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_actions', {
				title    = Lang['select_extra'],
				align    = 'top-left',
				elements = elements2
			}, function(data2, menu2)
				SetVehicleExtra(vehicle, data2.current.value, not data2.current.state)
				local newData = data2.current
				if data2.current.state then
					newData.label = "Extra: "..data2.current.value.." "..('<span style="color:green;">%s</span>'):format("On")
				else
					newData.label = "Extra: "..data2.current.value.." "..('<span style="color:red;">%s</span>'):format("Off")
				end
				newData.state = not data2.current.state

				menu2.update({value = data2.current.value}, newData)
				menu2.refresh()
			end, function(data2, menu2)
				menu2.close()
			end)
		end
		if data.current.value == 'livery' then
			elements2 = {}
			local liveries = GetVehicleLiveryCount(vehicle)
			if liveries ~= -1 then
				SetVehicleModKit(vehicle, 0)
				for i = 1, liveries, 1 do
					local index = i - 1
					local name = GetLabelText(GetLiveryName(vehicle, index))
					if name == 'NULL' then name = 'Livery #'..index end 
					table.insert(elements2, {label = name, value = index})
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'livery_actions', {
					title    = Lang['select_livery'],
					align    = 'top-left',
					elements = elements2
				}, function(data2, menu2)
					SetVehicleLivery(vehicle, data2.current.value)
				end, function(data2, menu2)
					menu2.close()
				end)
			else
				ESX.UI.Menu.CloseAll()
				extra_menu = false
				TriggerEvent('t1ger_garage:notify', Lang['veh_no_liveries'])
			end
		end
	end, function(data, menu)
		menu.close()
		extra_menu = false
	end)
end

--------------------------------------
-- ## IMPOUND THREAD & FUNCTIONS ## --
-------------------------------------- 

local impound_blips, impound_menu = {}, false
Citizen.CreateThread(function()
	for i = 1, #Config.Impound.Locations do
		impound_blips[i] = T1GER_CreateBlip(Config.Impound.Locations[i].pos, Config.Impound.Locations[i].blip)
	end
	impound_blips['pol_impound'] = T1GER_CreateBlip(Config.Impound.Seize.pos, Config.Impound.Seize.blip)
	while true do
		Citizen.Wait(1)
		local sleep = true
		if not impound_menu then 
			for k,v in pairs(Config.Impound.Locations) do
				local distance = #(coords - v.pos)
				-- Draw Marker:
				if v.marker.enable and distance <= v.marker.drawDist and distance > v.dist then
					local mk = v.marker
					sleep = false
					DrawMarker(mk.type, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
				end
				-- Draw Text
				if distance <= v.dist then
					sleep = false
					T1GER_DrawTxt(v.pos.x, v.pos.y, v.pos.z, v.text)
					if IsControlJustPressed(0, v.keybind) then
						ImpoundMenu(v)
					end
				end
				if distance > v.dist and impound_menu then
					ESX.UI.Menu.CloseAll()
					impound_menu = false
				end
			end
			-- Police Impound Register
			local distance = #(coords - Config.Impound.Seize.pos)
			if distance <= Config.Impound.Seize.marker.drawDist then
				if T1GER_GetJob(Config.Impound.Seize.jobs) then
					sleep = false
					if distance > 2.0 then
						local mk = Config.Impound.Seize.marker
						DrawMarker(mk.type, Config.Impound.Seize.pos.x, Config.Impound.Seize.pos.y, Config.Impound.Seize.pos.z, 0, 0, 0, 0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2)
					end
					if distance <= 2.0 then
						T1GER_DrawTxt(Config.Impound.Seize.pos.x, Config.Impound.Seize.pos.y, Config.Impound.Seize.pos.z, Config.Impound.Seize.text)
						if IsControlJustPressed(0, Config.Impound.Seize.keybind) then
							PoliceImpoundRegister()
						end 
					end
					if distance > 2.0 and impound_menu then
						ESX.UI.Menu.CloseAll()
						impound_menu = false
					end
				end
			end
			if sleep then
				Citizen.Wait(1000) 
			end 
		end
	end
end)

function ImpoundMenu(val)
	local vehicle = GetVehiclePedIsIn(player, false)
	if vehicle ~= 0 and DoesEntityExist(vehicle) then
		return TriggerEvent('t1ger_garage:notify', Lang['inside_veh_error'])
	end
	local elements = {
		{label = 'Personal Vehicles', value = 'personal_vehicles'},
		{label = 'Job Vehicles', value = 'job_vehicles'}
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'impound_veh_selection',
		{
			title    = Lang['select_veh_type'],
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		if data.current.value == 'personal_vehicles' then 
			local elements2 = {}
			ESX.TriggerServerCallback('t1ger_garage:getImpoundedVehicles', function(results) 
				if not results then
					return TriggerEvent('t1ger_garage:notify', Lang['no_impounded_vehicles'])
				else
					for i = 1, #results do
						local props = json.decode(results[i].vehicle)
						local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = name..' ['..results[i].plate..']'
						if results[i].seized then 
							label = name..' ['..results[i].plate..'] [SEIZED]'
						end
						table.insert(elements2, {
							label = label,
							name = name,
							value = results[i],
							plate = results[i].plate,
							fuel = results[i].fuel,
							props = props,
							type = val.type,
							seized = results[i].seized
						})
					end
					if next(elements2) == nil then
						return TriggerEvent('t1ger_garage:notify', Lang['no_impounded_vehicles'])
					end
					impound_menu = true
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'list_impounded_vehicles',
						{
							title    = Lang['pay_impound_fees']:format(Config.Impound.Fees),
							align    = 'center',
							elements = elements2
						},
					function(data2, menu2)
						ESX.UI.Menu.CloseAll()
						impound_menu = false
						if not data2.current.seized then 
							local veh_cache = T1GER_GetClosestVehicle(val.spawn)
							if veh_cache ~= 0 then
								Citizen.Wait(250)
								return TriggerEvent('t1ger_garage:notify', Lang['spawn_area_blocked'])
							end
							ESX.TriggerServerCallback('t1ger_garage:getImpoundFees', function(feesPaid) 
								if not feesPaid then
									return TriggerEvent('t1ger_garage:notify', Lang['not_enough_money'])
								else
									SpawnImpoundVehicle(val, data2.current.props, data2.current.fuel)
								end
							end, Config.Impound.Fees)
						else
							TriggerEvent('t1ger_garage:notify', Lang['veh_seized_contact_pol'])
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				end
			end, val)
		end 
		if data.current.value == 'job_vehicles' then 
			local elements2 = {}
			ESX.TriggerServerCallback('t1ger_garage:getImpoundedJobVehicles', function(results) 
				if not results then
					return TriggerEvent('t1ger_garage:notify', Lang['no_impounded_vehicles'])
				else
					for i = 1, #results do
						local props = json.decode(results[i].vehicle)
						local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = name..' ['..results[i].plate..']'
						if results[i].seized then 
							label = name..' ['..results[i].plate..'] [SEIZED]'
						end
						table.insert(elements2, {
							label = label,
							name = name,
							value = results[i],
							plate = results[i].plate,
							fuel = results[i].fuel,
							props = props,
							type = val.type,
							seized = results[i].seized
						})
					end
					if next(elements2) == nil then
						return TriggerEvent('t1ger_garage:notify', Lang['no_impounded_vehicles'])
					end
					impound_menu = true
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'list_impounded_vehicles2',
						{
							title    = Lang['pay_impound_fees']:format(Config.Impound.Fees),
							align    = 'center',
							elements = elements2
						},
					function(data2, menu2)
						ESX.UI.Menu.CloseAll()
						impound_menu = false
						if not data2.current.seized then 
							ESX.TriggerServerCallback('t1ger_garage:getImpoundFees', function(feesPaid) 
								if not feesPaid then
									return TriggerEvent('t1ger_garage:notify', Lang['not_enough_money'])
								else
									SpawnImpoundVehicle(val, data2.current.props, data2.current.fuel)
								end
							end, Config.Impound.Fees)
						else
							TriggerEvent('t1ger_garage:notify', Lang['veh_seized_contact_pol'])
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				end
			end, val)
		end
	end, function(data, menu)
		menu.close()
		impound_menu = false
	end)
end

function PoliceImpoundRegister()
	if T1GER_GetJob(Config.Impound.Seize.jobs) then
		local elements = {}
		ESX.TriggerServerCallback('t1ger_garage:getSeizedVehicles', function(results) 
			if not results then
				impound_menu = false
				return TriggerEvent('t1ger_garage:notify', Lang['no_seized_vehicles'])
			else
				for i = 1, #results do
					local props = json.decode(results[i].vehicle)
					local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
					table.insert(elements, {
						label = name..' ['..results[i].plate..']',
						name = name,
						plate = results[i].plate,
						value = results[i],
						props = props,
						seized = results[i].seized
					})
				end
				if next(elements) == nil then
					return TriggerEvent('t1ger_garage:notify', Lang['no_seized_vehicles'])
				end
				impound_menu = true
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'list_seized_vehicles',
					{
						title    = Lang['release_vehicle'],
						align    = 'center',
						elements = elements
					},
				function(data, menu)
					ESX.UI.Menu.CloseAll()
					impound_menu = false
					TriggerServerEvent('t1ger_garage:updateSeized', data.current.plate, false)
				end, function(data, menu)
					menu.close()
					impound_menu = false
				end)
			end
		end, val)
	end
end

RegisterCommand(Config.Impound.Command, function()
	if T1GER_GetJob(Config.Impound.Jobs) then 
		SetVehicleImpounded(nil, false)
	end
end, false)

RegisterCommand(Config.Impound.Seize.command, function()
	if T1GER_GetJob(Config.Impound.Seize.jobs) then 
		SetVehicleImpounded(nil, true)
	end
end, false)

function SetVehicleImpounded(car, state)
	local vehicle, seize = 0, false
	if state ~= nil then
		seize = state
	end
	if car ~= nil then 
		vehicle = car
	else
		if IsPedInAnyVehicle(player, false) then
			vehicle = GetVehiclePedIsIn(player, false)
		else
			--vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 71)
			vehicle = T1GER_GetClosestVehicle2(coords, 6.0)
		end
	end
	if vehicle ~= 0 and DoesEntityExist(vehicle) then 
		T1GER_GetControlOfEntity(vehicle)
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		local props = GetVehicleProperties(vehicle)
		props.plate = plate
		local fuel = GetVehicleFuel(vehicle)
		if IsVehiclePlateValid(plate) then
			TriggerServerEvent('t1ger_garage:setVehicleImpounded', plate, props, fuel, 'impound', seize)
			if seize then
				TriggerEvent('t1ger_garage:notify', Lang['u_seized_vehicle']:format(plate))
			else 
				TriggerEvent('t1ger_garage:notify', Lang['u_impounded_vehicle']:format(plate))
			end
		else
			TriggerEvent('t1ger_garage:notify', Lang['vehicle_deleted']:format(plate))
		end
		if DoesEntityExist(vehicle) then 
			T1GER_DeleteVehicle(vehicle)
		end
	end
end

function SpawnImpoundVehicle(val, props, fuel)
	T1GER_LoadModel(props.model)
	ESX.Game.SpawnVehicle(props.model, vector3(val.spawn.x,val.spawn.y,val.spawn.z), val.spawn.w, function(vehicle)
		while not DoesEntityExist(vehicle) do
			Wait(5)
		end
		SetVehicleProperties(vehicle, props)
		if val.teleport then 
			TaskWarpPedIntoVehicle(player, vehicle, -1)
		end
		if Config.T1GER_Keys then
			exports['t1ger_keys']:SetVehicleLocked(vehicle, 0)
		end
		SetVehicleFuel(vehicle, fuel)
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		TriggerServerEvent('t1ger_garage:updateState', plate, 'impound')
	end)
end

-------------------------------------
-- ## PRIVATE GARAGES AND STUFF ## --
------------------------------------- 

local garage_id 	= 0
local pvt_garages 	= {}
local pvt_blips		= {}

-- Load Private Garages:
RegisterNetEvent('t1ger_garage:loadPrivateGarages')
AddEventHandler('t1ger_garage:loadPrivateGarages', function(results, id, cfg)
	if Config.EnablePrivateGarages == true then
		Config.PrivateGarages = cfg
		pvt_garages = results
		garage_id = id
		Citizen.Wait(200)
		UpdateGarageBlips()
	end
end)

-- Update Private Garages:
RegisterNetEvent('t1ger_garage:syncPrivateGarages')
AddEventHandler('t1ger_garage:syncPrivateGarages', function(results, cfg)
	if Config.EnablePrivateGarages == true then
		Config.PrivateGarages = cfg
		pvt_garages = results
		Citizen.Wait(200)
		UpdateGarageBlips()
	end
end)


RegisterNetEvent('t1ger_garage:sendCacheCL')
AddEventHandler('t1ger_garage:sendCacheCL', function(data, id)
	Config.PrivateGarages[id].cache = data
end)

-- function to update blips on map:
function UpdateGarageBlips()
	if Config.EnablePrivateGarages == true then 
		for k,v in pairs(pvt_blips) do RemoveBlip(v) end
		for i = 1, #Config.PrivateGarages do
			if Config.PrivateGarages[i].owned then
				if garage_id == i then 
					if Config.ShowBlipOwned then 
						CreatePrivateGarageBlip(Config.PrivateGarages[i], Lang['blip_your_garage'])
					end
				else
					if Config.ShowBlipPlayer then
						CreatePrivateGarageBlip(Config.PrivateGarages[i], Lang['blip_player_garage'])
					end
				end
			else
				if Config.ShowBlipPurchase then 
					CreatePrivateGarageBlip(Config.PrivateGarages[i], Lang['blip_purchase_garage'])
				end
			end
		end
	end
end

local ply_garage, inside_garage, closest_garage = false, false, 0
Citizen.CreateThread(function()
	Citizen.Wait(2000)
	if Config.EnablePrivateGarages then
		while true do
			Citizen.Wait(1)
			local sleep = true
			for k,v in pairs(Config.PrivateGarages) do
				local garage_pos = vector3(v.pos[1], v.pos[2], v.pos[3])
				local distance = #(coords - garage_pos)
				if distance < Config.LoadDist then 
					if not ply_garage then 
						sleep = false
						local mk = Config.PrivateGarageMarker
						if mk.enable and distance <= mk.drawDist and distance > Config.InteractDist then
							DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
						end
						if distance <= Config.InteractDist then
							local action = nil
							if garage_id == k then 
								T1GER_DrawTxt(garage_pos.x, garage_pos.y, garage_pos.z, Lang['draw_pvtgarage_owned'])
								action = 'owned'
							else
								if v.owned then
									T1GER_DrawTxt(garage_pos.x, garage_pos.y, garage_pos.z, Lang['draw_pvtgarage_player'])
								else
									if garage_id == 0 then 
										T1GER_DrawTxt(garage_pos.x, garage_pos.y, garage_pos.z, Lang['draw_pvtgarage_buy']:format(comma_value(v.price)))
										action = 'purchase'
									else
										T1GER_DrawTxt(garage_pos.x, garage_pos.y, garage_pos.z, Lang['draw_pvtgarage_none'])
									end
								end
							end
							if action ~= nil and IsControlJustPressed(0, Config.InteractKey) then
								PrivateGarageMain(k,v,action)
							end
						end
					end
					if distance > Config.InteractDist and ply_garage then
						ESX.UI.Menu.CloseAll()
						ply_garage = false
					end
				end
			end
			if sleep then
				Citizen.Wait(1000)
			end
		end
	end
end)

-- function for private garages:
function PrivateGarageMain(id,val,action)
	local elements = {}
	if action == 'purchase' then
		elements = {
			{ label = Lang['button_no'], value = 'no' },
			{ label = Lang['button_yes'], value = 'yes' }
		}
	end
	if action == 'owned' then
		elements = {
			{ label = Lang['enter_garage'], value = 'enter_garage' },
			{ label = Lang['sell_garage'], value = 'sell_garage' },
		}
	end
	local menu_title = 'Garage: '..tonumber(id)
	if action == 'purchase' then
		menu_title = 'Confirm | Price: $'..comma_value(val.price)
	end
	ESX.UI.Menu.CloseAll()
	ply_garage = true 
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pvt_garage_main',
		{
			title    = menu_title,
			align    = 'center',
			elements = elements
		},
	function(data, menu)

		if data.current.value == 'no' then
			menu.close()
			ply_garage = false
		end

		if data.current.value == 'yes' then
			ESX.TriggerServerCallback('t1ger_garage:buyPrivateGarage', function(purchased) 
				if purchased then
					TriggerEvent('t1ger_garage:notify', Lang['pvt_garage_purchased']:format(val.price))
					garage_id = tonumber(id)
					TriggerServerEvent('t1ger_garage:updatePrivateGarage', tonumber(id), val, true)
				else
					TriggerEvent('t1ger_garage:notify', Lang['not_enough_money'])
				end
			end, tonumber(id), val)
			menu.close()
			ply_garage = false
		end

		if data.current.value == 'sell_garage' then
			local sellPrice = (val.price * Config.SellPercent)
			local elements2 = {
				{ label = Lang['button_no'], value = 'decline_sale' },
				{ label = Lang['button_yes'], value = 'confirm_sale' },
			}
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_sell_confirmation',
				{
					title    = 'Confirm Sale | Price: $'..comma_value(math.floor(sellPrice)),
					align    = 'center',
					elements = elements2
				},
			function(data2, menu2)
				if data2.current.value == 'confirm_sale' then
					TriggerServerEvent('t1ger_garage:sellGarage', id, val, math.floor(sellPrice))
					garage_id = 0
					TriggerServerEvent('t1ger_garage:updatePrivateGarage', tonumber(id), val, false)
					TriggerEvent('t1ger_garage:notify', Lang['pvt_garage_sold']:format(comma_value(math.floor(sellPrice))))
					ESX.UI.Menu.CloseAll()
					ply_garage = false
				else
					menu2.close()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end

		if data.current.value == 'enter_garage' then
			menu.close()
			ply_garage = false
			if closest_garage == 0 then 
				EnterPrivateGarage(id,val)
			end
		end

	end, function(data, menu)
		menu.close()
		ply_garage = false
	end)
end

-- Enter Closest Garage:
function EnterPrivateGarage(id,val)
	closest_garage = tonumber(id)
	local vehicle, can_enter, checked = GetVehiclePedIsIn(player, false), false, false

	if vehicle ~= 0 and DoesEntityExist(vehicle) then 
		local props = GetVehicleProperties(vehicle)
		local plate = tostring(GetVehicleNumberPlateText(vehicle))
		props.plate = plate
		local fuel = GetVehicleFuel(vehicle)
		if IsVehicleOwned(plate) then 
			ESX.TriggerServerCallback('t1ger_garage:checkPrivateGarage', function(can_store, message) 
				if can_store then
					TriggerServerEvent('t1ger_garage:enterPrivateGarage', id, plate, tonumber(message))
					can_enter = true
					checked = true
				else
					return TriggerEvent('t1ger_garage:notify', message)
				end
			end, id, plate, props, fuel)
		else
			return TriggerEvent('t1ger_garage:notify', Lang['you_dont_own_vehicle'])
		end
	else
		can_enter = true
		checked = true
	end

	while not checked do
		Citizen.Wait(10)
	end

	if can_enter then 
		-- Create Shell Object:´
		T1GER_LoadModel(Config.GarageShells[val.prop])
		local data = CreateShellObject(id,val)
		while next(data) == nil do Citizen.Wait(100) end
		-- Fade in:
		FadeTransition(true, 1000, false, 0)
		inside_garage = true
		-- Delete Vehicle:
		if vehicle ~= 0 then 
			ESX.Game.DeleteVehicle(vehicle)
			ESX.Game.DeleteVehicle(GetVehiclePedIsIn(player, false))
		end
		-- teleport:
		SetEntityCoords(player, data.offsets.entrance.x, data.offsets.entrance.y, data.offsets.entrance.z)
		SetEntityHeading(player, data.offsets.cfg.heading)
		-- fade out:
		FadeTransition(false, 1500, true, 1000)
	else
		closest_garage = 0
	end
end

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true 
		if closest_garage ~= 0 then 
			local cur_garage = Config.PrivateGarages[closest_garage]
			if next(cur_garage.cache) then
				-- exit:
				local entrance_dist = #(coords - cur_garage.cache.offsets.entrance)
				if entrance_dist <= 3.0 then
					sleep = false
					if entrance_dist <= 1.5 then
						T1GER_DrawTxt(cur_garage.cache.offsets.entrance.x, cur_garage.cache.offsets.entrance.y, cur_garage.cache.offsets.entrance.z, Lang['draw_pvtgarage_leave'])
						if IsControlJustPressed(0, Config.InteractKey) then
							LeaveGarage(cur_garage, nil)
						end
					end
				end
				-- vehicles
				if cur_garage.cache.vehicles ~= nil and next(cur_garage.cache.vehicles) then
					for k,v in pairs(cur_garage.cache.vehicles) do
						local veh_dist = #(coords - v.pos)
						if veh_dist <= 3.0 then
							if GetEntityModel(GetVehiclePedIsIn(player)) == v.props.model then
								sleep = false
								T1GER_DrawDisplay(v.pos.x, v.pos.y, v.pos.z-0.3, "~r~[E]~s~ Take Vehicle Out")
								if v.props.engineHealth ~= nil then 
									T1GER_DrawDisplay(v.pos.x, v.pos.y, v.pos.z-0.4, "Fuel: "..round(v.fuel,1).."% | Engine: "..round(v.props.engineHealth,2))
								else
									T1GER_DrawDisplay(v.pos.x, v.pos.y, v.pos.z-0.4, "Fuel: "..round(v.fuel,1).."%")
								end
								if IsPedInAnyVehicle(player, false) then 
									if IsControlJustPressed(0, 38) then
										local cur_veh = {id = k, val = v, vehicle = GetVehiclePedIsIn(player, false)}
										LeaveGarage(cur_garage, cur_veh)
									end
								end
							end
						end
					end
				end
			end
		end
		if sleep then Citizen.Wait(1500) end
	end
end)

function CreateShellObject(id,val)
	-- Get Shell Coords:
	local shell_pos = GetSafeShellCoords(val.pos)
	-- Create Shell Object:
	local shell_created, shell_obj, shell_netid, shell_coords = CreateGarageShell(id,val,shell_pos)
	while not shell_created do Citizen.Wait(10) end
	-- offsets:
	local offset = Config.Offsets[val.prop]
	local offset_data = {}
	offset_data.cfg = offset
	offset_data.entrance = GetOffsetFromEntityInWorldCoords(shell_obj, offset.entrance[1], offset.entrance[2], offset.entrance[3])
	-- create vehicles:
	local pvt_vehicles, spawned = {}, false
	ESX.TriggerServerCallback('t1ger_garage:getPrivateGarageVehicles', function(veh_array) 
		if next(veh_array) ~= nil then 
			for k,v in pairs(veh_array) do
				ClearAreaOfVehicles(offset.veh[v.id].pos[1], offset.veh[v.id].pos[2], offset.veh[v.id].pos[3], 1.0)
				local veh_pos = GetOffsetFromEntityInWorldCoords(shell_obj, offset.veh[v.id].pos[1], offset.veh[v.id].pos[2], offset.veh[v.id].pos[3])
				local heading = offset.veh[v.id].heading
				ESX.Game.SpawnLocalVehicle(v.props.model, {x = veh_pos[1], y = veh_pos[2], z = veh_pos[3] + 0.5}, heading, function(car)
					SetVehicleProperties(car, v.props)
					SetVehicleOnGroundProperly(car)
					SetVehicleUndriveable(car, true)
					SetVehicleFuel(v.fuel)
					SetVehicleEngineOn(car, false, true, true)
					if Config.T1GER_Keys then 
						exports['t1ger_keys']:SetVehicleLocked(car, 0)
					end
				end)
				table.insert(pvt_vehicles, {id = v.id, plate = v.plate, props = v.props, fuel = v.fuel, pos = vector3(veh_pos[1], veh_pos[2], veh_pos[3]), h = heading})
				Wait(50)
			end
			spawned = true
		else
			spawned = true
		end
	end, id, val)
	while not spawned do 
		Citizen.Wait(10)
	end
	-- Sync Data:
	local data = {id = id, val = val, prop = val.prop, shell_obj = shell_obj, shell_netid = shell_netid, shell_coords = shell_coords, offsets = offset_data, vehicles = pvt_vehicles }
	TriggerServerEvent('t1ger_garage:sendCacheSV', id, data)
	return data
end

function GetSafeShellCoords(pos)
	local spawn_pos = vector3(pos[1], pos[2], (pos[3] - 8.0))
	local done = false
    local player_pos = {x = GetEntityCoords(player).x, y = GetEntityCoords(player).y, z = GetEntityCoords(player).z}
	while not done do
		Citizen.Wait(1)
		local objects = ObjectNearSpawnPoint(spawn_pos.x, spawn_pos.y, spawn_pos.z)
		if objects then
			if spawn_pos.z > -140.0 then 
				spawn_pos = (spawn_pos + vector3(0.25,-0.25,-0.60))
			else
				spawn_pos = (spawn_pos + vector3(-0.25,0.25,0.60))
			end
		end
		objects = ObjectNearSpawnPoint(spawn_pos.x, spawn_pos.y, spawn_pos.z)
		if not objects then
			local inWater = IsPropInWater(spawn_pos)
			if not inWater then
				local RayHandle = StartShapeTestRay(player_pos.x, player_pos.y, player_pos.z, spawn_pos.x, spawn_pos.y, spawn_pos.z, 1, PlayerPedId(), 0)
				local _, hit, endCoords, surfaceNormal, object = GetShapeTestResult(RayHandle)
				if hit == 1 then
					--print('Shell Obj Hit | Generating New Safe Coords')
					player_pos.z = (player_pos.z - 5.0)
					objects = true
				else
					done = true
				end
			else
				objects = true
			end
		end
	end
	return spawn_pos
end

function CreateGarageShell(id,val,pos)
	--T1GER_LoadModel(Config.GarageShells[val.prop])
	local pos = vector3(pos[1], pos[2], pos[3])
	local object = CreateObject(Config.GarageShells[val.prop], pos.x, pos.y, pos.z, true, true)
	FreezeEntityPosition(object, true)
	SetEntityCoords(object, pos.x, pos.y, pos.z)
	-- Sync Shell:
	SetEntityAsMissionEntity(object, true, true)
	NetworkRegisterEntityAsNetworked(object)
	local net_id = NetworkGetNetworkIdFromEntity(object)
	SetNetworkIdCanMigrate(net_id, false)
	SetNetworkIdExistsOnAllMachines(net_id, true)
	NetworkSetNetworkIdDynamic(net_id, true)
	return true, object, net_id, pos
end

function LeaveGarage(cur_garage, current_vehicle)
	local cfg = cur_garage	
	-- Fade In:
	FadeTransition(true, 1000, false, 0)
	SetRainLevel(-1.0)

	ESX.Game.DeleteVehicle(GetVehiclePedIsIn(player, false))
	
	-- Delete Vehicles:
	if next(cfg.cache.vehicles) then 
		for k,v in pairs(cfg.cache.vehicles) do 
			local vehicle = GetClosestVehicle(v.pos.x, v.pos.y, v.pos.z, 30.0, v.props.model, 71)
			ESX.Game.DeleteVehicle(vehicle)
			DeleteEntity(vehicle)
		end
	end

	-- Delete Shell Object:
	local obj_entity = NetworkGetEntityFromNetworkId(cfg.cache.shell_netid)
	T1GER_GetControlOfEntity(obj_entity)
	if DoesEntityExist(obj_entity) then
		SetEntityAsMissionEntity(obj_entity, true, true)
		SetEntityAsNoLongerNeeded(cfg.cache.shell_obj)
		DeleteObject(obj_entity)
		DeleteEntity(obj_entity)
	else
		SetEntityAsMissionEntity(obj_entity, true, true)
		SetEntityAsNoLongerNeeded(cfg.cache.shell_obj)
		DeleteObject(cfg.cache.shell_obj)
		DeleteEntity(cfg.cache.shell_obj)
	end

	-- Teleport:
	SetEntityCoords(player, cur_garage.pos[1], cur_garage.pos[2], cur_garage.pos[3])
	SetEntityHeading(player, cur_garage.h)

	-- Exit /w vehicle:
	if current_vehicle ~= nil then
		ESX.Game.SpawnVehicle(current_vehicle.val.props.model,{x = cur_garage.pos[1], y = cur_garage.pos[2], z = cur_garage.pos[3] + 1}, cur_garage.h, function(car)
			SetVehicleProperties(car, current_vehicle.val.props)
			SetVehicleEngineOn(car, true, true, false)
			SetVehicleOnGroundProperly(car)
			TaskWarpPedIntoVehicle(player, car, -1)
			SetVehicleFuel(car, current_vehicle.val.fuel)
		end)
		TriggerServerEvent('t1ger_garage:leavePrivateGarage', cfg.cache.id, current_vehicle.val.plate)
	end

	-- Reset:
	closest_garage = 0
	inside_garage = false
	FadeTransition(false, 1500, true, 1000)
end

function IsPropInWater(pos)
	local in_water = false
	T1GER_LoadModel(GetHashKey('s_m_y_dealer_01'))
	local ped = T1GER_CreatePed(5, GetHashKey('s_m_y_dealer_01'), pos.x, pos.y, pos.z, 0.0)
	local ped_coords = GetEntityCoords(ped)
    local chk,height = GetWaterHeight(ped_coords.x, ped_coords.y, ped_coords.z)
    if not IsEntityInWater(ped) and not chk then in_water = false else in_water = true end
    DeleteEntity(ped)
    SetEntityAsNoLongerNeeded(ped)
    return in_water
end

-- function to check objects near point
function ObjectNearSpawnPoint(x,y,z)
    if IsAnyObjectNearPoint(x, y, z, 15.0, false) then
        return true
    else
        return false
    end
end

function FadeTransition(fadeOut, duration, wait, timer)
	if fadeOut then 
		DoScreenFadeOut(duration); while not IsScreenFadedOut() do Citizen.Wait(10) end
	else
		if wait then Citizen.Wait(timer) end
		DoScreenFadeIn(duration)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		if inside_garage then
			sleep = false  
			NetworkOverrideClockTime(21, 0, 0)
			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypePersist('CLEAR')
			SetWeatherTypeNow('CLEAR')
			SetWeatherTypeNowPersist('CLEAR')
			SetRainLevel(0.0)
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- Create Map Blips for Tow Services:
function CreatePrivateGarageBlip(cfg, name)
	local mk = Config.PrivateGarageBlip
	if mk.enable then
		blip = AddBlipForCoord(cfg.pos[1], cfg.pos[2], cfg.pos[3])
		SetBlipSprite (blip, mk.sprite)
		SetBlipDisplay(blip, mk.display)
		SetBlipScale  (blip, mk.scale)
		if name == Lang['blip_your_garage'] then 
			SetBlipColour (blip, 1)
		else
			SetBlipColour (blip, mk.color)
		end
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(name)
		EndTextCommandSetBlipName(blip)
		table.insert(pvt_blips, blip)
	end
end

-------------------------------------
-- ## OTHER FUNCTIONS AND STUFF ## --
------------------------------------- 

-- Command to see vehicle / garages:
RegisterCommand(Config.Garage.Command, function(source, args)
	ESX.TriggerServerCallback('t1ger_garage:getAllOwnedVehicles', function(results)
		if not results then
			TriggerEvent('t1ger_garage:notify', Lang['no_owned_vehicles'])
		else
			local elements = {}
			for i = 1, #results do
				local props = json.decode(results[i].vehicle)
				local veh_name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
				table.insert(elements, {
					label = veh_name..' ['..results[i].plate..']',
					value = results[i]
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_veh_list',
				{
					title    = Lang['owned_veh_list'],
					align    = 'center',
					elements = elements
				},
			function(data, menu)
				local elements2 = {}
				local current = data.current.value
				local garage, stored = '', 'No'
				if current.garage == nil then 
					garage = 'Garage: ALL'
				elseif current.garage == 'impound' then 
					garage = 'Garage: Impound'
				else
					garage = 'Garage: '..current.garage
				end
				table.insert(elements2, {label = garage, value = 'garage'})
				if current.state == true then
					stored = 'Yes'
				end
				table.insert(elements2, {label = 'Stored: '..stored, value = 'state'})
				if current.seized == true then
					table.insert(elements2, {label = 'Seized: Yes', value = 'seized'})
				end
				table.insert(elements2, {label = 'Type: '..current.type, value = 'type'})
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_details',
					{
						title    = data.current.label,
						align    = 'center',
						elements = elements2
					},
				function(data2, menu2)
					
				end, function(data2, menu2)
					menu2.close()
				end)
			end, function(data, menu)
				menu.close()
			end)
		end
	end)
end, false)

-- function to check if plate exists in database:
function IsVehiclePlateValid(plate)
	local fetched, valid = false, false
	ESX.TriggerServerCallback('t1ger_garage:isVehiclePlateValid', function(result)
		valid = result
		fetched = true
	end, plate)
	while not fetched do
		Citizen.Wait(5)
	end
	return valid
end

-- function to check if plate is owned by identifier
function IsVehicleOwned(plate)
	local fetched, valid = false, false
	ESX.TriggerServerCallback('t1ger_garage:isVehicleOwned', function(result)
		valid = result
		fetched = true
	end, plate)
	while not fetched do
		Citizen.Wait(5)
	end
	return valid
end

function IsTypeAllowed(plate, type)
	local fetched, valid = false, false
	if Config.UseTypeCheck == true then 
		ESX.TriggerServerCallback('t1ger_garage:isTypeAllowed', function(result)
			valid = result
			fetched = true
		end, plate, type)
		while not fetched do
			Citizen.Wait(5)
		end
	else
		valid = true
	end
	return valid
end

-- function to set vehicle properties
function SetVehicleProperties(vehicle, props)
	ESX.Game.SetVehicleProperties(vehicle, props)
end

-- function to get vehicle properties
function GetVehicleProperties(vehicle)
	local props = ESX.Game.GetVehicleProperties(vehicle)
	return props
end

-- function to get vehicle fuel
function GetVehicleFuel(vehicle)
	if Config.HasFuelScript then 
		return exports["LegacyFuel"]:GetFuel(vehicle)
	else
		return GetVehicleFuelLevel(vehicle)
	end
end

-- function to set vehicle fuel
function SetVehicleFuel(vehicle, value)
	if Config.HasFuelScript then
		exports["LegacyFuel"]:SetFuel(vehicle, value)
	else
		SetVehicleFuelLevel(vehicle, value)
	end
end

-- function to get closest vehicle:
function IsVehicleNearby()
	local vehicle = T1GER_GetClosestVehicle(coords)
	if vehicle ~= 0 then
		return vehicle
	end
	return false
end

-- function to check classes for extras
function CheckClasses(vehicle, table)
	for k,v in pairs(table) do
		if GetVehicleClass(vehicle) == v then 
			return true
		end
	end
	return false
end

-- Function to get closest vehicle:
function T1GER_GetClosestVehicle(pos)
    local closestVeh = StartShapeTestCapsule(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, 1.0, 10, player, 7)
    local a, b, c, d, entityHit = GetShapeTestResult(closestVeh)
	if IsEntityAVehicle(entityHit) then
		return entityHit
	else
		return 0 
	end
end

-- Function to get closest vehicle:
function T1GER_GetClosestVehicle2(pos, radius)
    local closestVeh = StartShapeTestCapsule(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, radius, 10, player, 7)
    local a, b, c, d, entityHit = GetShapeTestResult(closestVeh)
	local tick = 100
	while entityHit == 0 and tick > 0 do 
		tick = tick - 1
		closestVeh = StartShapeTestCapsule(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, radius, 10, player, 7)
		local a1, b1, c1, d1, entityHit2 = GetShapeTestResult(closestVeh)
		if entityHit2 ~= 0 then 
			entityHit = entityHit2
			break
		end
		Citizen.Wait(10)
	end
    return entityHit
end