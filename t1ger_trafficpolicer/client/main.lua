-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
player = nil
coords = {}
ply_veh = nil

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

-- Command to open Traffic Policer Menu::
RegisterCommand(Config.Command, function(source, args)
	if IsPlayerJobCop() then TrafficPolicerMenu() end
end, false)

-- Thread to handle hotkey for Traffic Policer Menu:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0, Config.Keybind) then if IsPlayerJobCop() then TrafficPolicerMenu() end end
	end
end)

-- Traffic Policer Main Menu:
function TrafficPolicerMenu()
	local elements = {
		{label = Lang['person_lookup'], value = 'person_lookup'},
		{label = Lang['plate_lookup'],  value = 'plate_lookup'},
		{label = Lang['impound_vehicle'],  value = 'impound_vehicle'},
		{label = Lang['unlock_vehicle'],  value = 'unlock_vehicle'},
		{label = Lang['issue_citation'],  value = 'issue_citation'}, -- not done
		{label = Lang['breathalyzer_test'],  value = 'breathalyzer_test'},
		{label = Lang['drug_swap_test'],  value = 'drug_swap_test'}
	}
	if Config.T1GER_Garage then
		table.insert(elements, {label = Lang['seize_vehicle'], value = 'seize_vehicle'}) 
	end
	if Config.BarricadeSystem then
		table.insert(elements, {label = 'Barricade', value = 'openBarricade'})
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'traffic_policer_main', {
		title    = Lang['menu_main_title'],
		align    = 'center',
		elements = elements
	}, function(data, menu)
		local action = data.current.value

		-- Check Drivers License & Person:
		if action == 'person_lookup' then LookupClosestPlayer() end

		-- Plate Lookup:
		if action == 'plate_lookup' then LookupClosestVehicle() end

		-- Impound Vehicle:
		if action == 'impound_vehicle' then ImpoundClosestVehicle() end

		-- Unlock Vehicle:
		if action == 'unlock_vehicle' then UnlockClosestVehicle() end

		-- Seize Vehicle:
		if Config.T1GER_Garage == true and action == 'seize_vehicle' then SeizeClosestVehicle() end

		-- Breathalyzer Test:
		if action == 'breathalyzer_test' then BreathalyzerTest() end

		-- Drug Swab Test:
		if action == 'drug_swap_test' then DrugSwabTest() end

		-- Issue Citation:
		if action == 'issue_citation' then OpenCitationMain() end

		if action == 'openBarricade' then
			menu.close()
			TriggerEvent("marcusbarricade:openMenu") 
		end


	end, function(data, menu)
		menu.close()
	end)
end

-- Function to lookup closest player
function LookupClosestPlayer()
	local target = GetClosestPlayer()
	if target then
		ESX.UI.Menu.CloseAll()
		ESX.TriggerServerCallback('t1ger_trafficpolicer:lookupPlayer', function(data)
			if data ~= nil then 
				local sex = 'Male'; if data.sex == 'F' or data.sex == 'f' then sex = 'Female' end
				local license = '~r~No~s~'; if data.license then license = '~g~Valid~s~' end
				local cfg = Config.PlayerLookup
				-- request:
				TriggerEvent('t1ger_trafficpolicer:notify', (Lang['ply_lookup_request']):format(data.firstname..' '..data.lastname, data.dob))
				PlayRadioSound()
				Citizen.Wait(1000)
				-- reply:
				TriggerEvent('t1ger_trafficpolicer:notify', Lang['ply_lookup_reply'])
				PlayRadioSound()
				-- results:
				Citizen.Wait(cfg.delay * 1000)
				BeginTextCommandThefeedPost("STRING")
				AddTextComponentSubstringPlayerName((Lang['ply_lookup_result']):format((data.firstname..' '..data.lastname), sex, data.dob))
				EndTextCommandThefeedPostMessagetext(cfg.notify.textureDict, cfg.notify.textureName, false, cfg.notify.iconType, cfg.notify.title, cfg.notify.subtitle)
				if Config.ESX_License then TriggerEvent('t1ger_trafficpolicer:notify', 'License: '..license) end
				PlayRadioSound()
				EndTextCommandThefeedPostTicker(false, cfg.notify.showInBrief)
			else
				TriggerEvent('t1ger_trafficpolicer:notify', Lang['ply_not_found'])
			end
		end, GetPlayerServerId(target))
		--end, GetPlayerServerId(PlayerId()))
	end
end

-- Function to lookup a plate:
function LookupClosestVehicle()
	local cfg = Config.PlateLookup
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		local plate = ESX.Game.GetVehicleProperties(targetVeh).plate
		local vehLabel = GetVehName(targetVeh)
		-- Request:
		TriggerEvent('t1ger_trafficpolicer:notify', (Lang['plate_lookup_request']):format(vehLabel, tostring(plate)))
		PlayRadioSound()
		Citizen.Wait(1000)
		-- Reply:
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['plate_lookup_reply'])
		PlayRadioSound()
		local ownerTxt, insuranceText = '', '~r~No~s~'
		ESX.TriggerServerCallback('t1ger_trafficpolicer:lookupPlate', function(data)
			if data ~= nil then
				if data.insurance ~= nil then
					if data.insurance == true then insuranceText = '~g~Yes~s~' end
				end
				ownerTxt = data.firstname..' '..data.lastname..', dob: '..data.dob
			else
				math.randomseed(GetGameTimer())
				local chance = math.random(0,100)
				if chance < cfg.npc_veh.chance then 
					ownerTxt = cfg.npc_veh.unreg
				else
					ownerTxt = cfg.npc_veh.stolen
				end
			end
		end, tostring(plate))
		Citizen.Wait(cfg.delay * 1000)
		-- Results:
		BeginTextCommandThefeedPost("STRING")
		AddTextComponentSubstringPlayerName((Lang['plate_lookup_result']):format(tostring(plate), vehLabel, ownerTxt))
		EndTextCommandThefeedPostMessagetext(cfg.notify.textureDict, cfg.notify.textureName, false, cfg.notify.iconType, cfg.notify.title, cfg.notify.subtitle)
		if Config.T1GER_Insurance then
			if ownerTxt ~= cfg.npc_veh.unreg and ownerTxt ~= cfg.npc_veh.stolen then 
				TriggerEvent('t1ger_trafficpolicer:notify', (cfg.insurance):format(insuranceText))
			end
		end
		PlayRadioSound()
		EndTextCommandThefeedPostTicker(false, cfg.notify.showInBrief)
	else
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['plate_not_readed'])
	end
end

-- Function to impound closest vehicle:
function ImpoundClosestVehicle()
	local cfg = Config.ImpoundVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local impounded = false
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
		local impound_pos = GetOffsetFromEntityInWorldCoords(targetVeh, d1.x-0.2,0.0,0.0)
		while not impounded do 
			Citizen.Wait(1)
			local dist = GetDistanceBetweenCoords(coords, vector3(impound_pos.x, impound_pos.y, impound_pos.z), true)
			if dist < cfg.drawText.dist then
				DrawText3Ds(impound_pos.x, impound_pos.y, impound_pos.z, cfg.drawText.str)
				if IsControlJustPressed(0, 38) and dist <= cfg.drawText.interactDist then
					TaskTurnPedToFaceEntity(player, targetVeh, 1.0)
					Citizen.Wait(400)
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
		TriggerEvent('t1ger_trafficpolicer:notify', (Lang['vehicle_impounded']):format(veh_props.plate))
	else
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['no_vehicle_nearby'])
	end
end

-- Function to unlock closest vehicle:
function UnlockClosestVehicle()
	local cfg = Config.UnlockVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local unlocked = false
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
		local unlockPos = GetOffsetFromEntityInWorldCoords(targetVeh, d1.x-0.2,0.0,0.0)
		while not unlocked do 
			Citizen.Wait(1)
			local dist = GetDistanceBetweenCoords(coords, vector3(unlockPos.x, unlockPos.y, unlockPos.z), true)
			if dist < cfg.drawText.dist then
				DrawText3Ds(unlockPos.x, unlockPos.y, unlockPos.z, cfg.drawText.str)
				if IsControlJustPressed(0, 38) and dist <= cfg.drawText.interactDist then
					LoadAnim(cfg.anim.dict)
					TaskTurnPedToFaceEntity(player, targetVeh, 1.0)
					Citizen.Wait(400)
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
				end
			end
		end
		PlayVehicleDoorOpenSound(targetVeh, 0)
		SetVehicleDoorsLockedForAllPlayers(targetVeh, false)
		SetVehicleDoorsLocked(targetVeh, 1)
		if Config.T1GER_Keys then
			exports['t1ger_keys']:SetVehicleLocked(targetVeh, 0)
		end
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['vehicle_unlocked'])
	else
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['no_vehicle_nearby'])
	end
end

function SeizeClosestVehicle()
	local cfg = Config.SeizeVehicle
	local coordA = GetEntityCoords(player, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(player, 0.0, cfg.dist, 0.0)
	local targetVeh = GetVehicleInDirection(coordA, coordB)
	local seized = false
	if (DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh)) then
		ESX.UI.Menu.CloseAll()
		GetControlOfEntity(targetVeh)
		SetEntityAsMissionEntity(targetVeh, true, true)
		local d1,d2 = GetModelDimensions(GetEntityModel(targetVeh))
		local seize_pos = GetOffsetFromEntityInWorldCoords(targetVeh, d1.x-0.2,0.0,0.0)
		while not seized do 
			Citizen.Wait(1)
			local dist = #(coords - vector3(seize_pos.x, seize_pos.y, seize_pos.z))
			if dist < cfg.drawText.dist then
				DrawText3Ds(seize_pos.x, seize_pos.y, seize_pos.z, cfg.drawText.str)
				if IsControlJustPressed(0, 38) and dist <= cfg.drawText.interactDist then
					TaskTurnPedToFaceEntity(player, targetVeh, 1.0)
					Citizen.Wait(400)
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
					seized = true
				end
			end
		end
		local veh_props = ESX.Game.GetVehicleProperties(targetVeh)
		local fuel = GetVehicleFuelLevel(targetVeh)
		if Config.T1GER_Garage then
			exports['t1ger_garage']:SetVehicleImpounded(targetVeh, true)
		else
			print('insert your impound event/function in here, to update state of the vehicle')
		end
		ESX.Game.DeleteVehicle(targetVeh)
		TriggerEvent('t1ger_trafficpolicer:notify', (Lang['vehicle_seized']):format(veh_props.plate))
	else
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['no_vehicle_nearby'])
	end
end

-- Breathalyzer Test:
function BreathalyzerTest()
	local target = GetClosestPlayer()
	if target then
		ESX.UI.Menu.CloseAll()
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['request_breathalyzer'])
		TriggerServerEvent('t1ger_trafficpolicer:requestBreathalyzerTest', GetPlayerServerId(target))
	end
end

-- Drug Swab Test:
function DrugSwabTest()
	local target = GetClosestPlayer()
	if target then
		ESX.UI.Menu.CloseAll()
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['request_drugswab'])
		TriggerServerEvent('t1ger_trafficpolicer:requestDrugSwabTest', GetPlayerServerId(target))
	end
end

-- Function to play Radio FX Sound:
function PlayRadioSound()
	LoadAnim("random@arrests")
	local animLib = "generic_radio_enter"
	if IsPlayerFreeAiming(PlayerId()) then animLib = "radio_chatter" end
	TaskPlayAnim(player, "random@arrests", animLib, 5.0, 2.0, -1, 50, 2.0, 0, 0, 0 )
	PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
    PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
    Wait(1000)
	PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	Wait(500)
	ClearPedTasks(player)
	StopSound()
end

-- Function to Get Vehicle In Direction:
function GetVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, player, 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

-- Function to get closest player:
function GetClosestPlayer()
	local target, dist = ESX.Game.GetClosestPlayer()
	if dist ~= -1 and dist <= 2.0 then
		return target
	else
		TriggerEvent('t1ger_trafficpolicer:notify', Lang['no_players_nearby'])
		return nil
	end
end

-- Function to get control of entity:
function GetControlOfEntity(entity)
	local netTime = 15
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) and netTime > 0 do 
		NetworkRequestControlOfEntity(entity)
		Citizen.Wait(100)
		netTime = netTime -1
	end
end

-- Check if Player has Police Job:
function IsPlayerJobCop()	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	for k,v in pairs(Config.Jobs) do
		if PlayerData.job.name == v then return true end
	end
	return false
end

-- Check if player has a specific job:
function HasPlayerJob(jobName)	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	if PlayerData.job.name == jobName then return true end
	return false
end
