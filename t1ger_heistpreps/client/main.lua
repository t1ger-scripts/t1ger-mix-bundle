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

local usingPhoneBox, hasJob = false, false

RegisterCommand(Config.RequestJobCommand, function(source, args)
	if usingPhoneBox == true then 
		return TriggerEvent('t1ger_heistpreps:notify', Lang['already_using_phone_box'])
	end
	if hasJob == true then 
		return TriggerEvent('t1ger_heistpreps:notify', Lang['have_ongoing_job'])
	end
	local obj, isAllowed = IsPhoneBoxAllowed(coords)
	if isAllowed == true then 
		GetRandomPreparation(obj)
	else
		return TriggerEvent('t1ger_heistpreps:notify', Lang['not_near_phonebox'])
	end
end, false)

function GetRandomPreparation(obj)
	usingPhoneBox = true
	hasJob = true
	local anim = {dict = 'anim@heists@keypad@', lib = 'idle_a'}
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	TaskTurnPedToFaceEntity(player, obj, 1.0)
	Citizen.Wait(1000)
	T1GER_LoadAnim(anim.dict)
	FreezeEntityPosition(player, true)
	if Config.ProgressBars then
		exports['progressBars']:startUI(2000, Lang['pb_request_job'])
	end
	TaskPlayAnim(player, anim.dict, anim.lib, 2.0, -2.0, -1, 1, 0, 0, 0, 0 )
	Citizen.Wait(2000)
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)

	local type = GetRandomJobType()
	--- debug -----
	--type = 'keycard'
	---------------
	-- get location:
	local num = GetRandomJobLocation(type)
	--- debug -----
	--num = 1
	---------------
	if num ~= nil then 
		if type == 'hacking' then 
			HackingPrep(type, num)
		elseif type == 'drills' then
			DrillsPrep(type, num)
		elseif type == 'thermite' then 
			ThermitePrep(type, num)
		elseif type == 'explosives' then
			ExplosivesPrep(type, num)
		elseif type == 'keycard' then 
			KeycardPrep(type, num)
		end
	else
        TriggerEvent('t1ger_heistpreps:notify', Lang['no_jobs_available']:format(type))
		hasJob = false
	end
	usingPhoneBox = false
end

-- ## HACKING DEVICE PREPARATION JOB ## --

local hack_data = {}
local hack_blip = nil

function HackingPrep(type, num)
	TriggerServerEvent('t1ger_heistpreps:hacking:spawnDevice', type, num)
	local location = Config.Jobs[type][num].location
	hack_blip = CreateJobBlip(Config.Blips[type], location)
	local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(location.x, location.y, location.z))
	local sender, subject = Lang['hacking_setup_job'], Lang['encrypted_message']
	local msg = Lang['hacking_job_start']:format(street)
	local textureDict, iconType = 'CHAR_LESTER', 7
	TriggerEvent('t1ger_heistpreps:notifyAdvanced', sender, subject, msg, textureDict, iconType)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Jobs['hacking']) do
			if v.inUse == true and next(v.cache) then
				if v.cache.started == true then
					local plyCoords = GetEntityCoords(player)

					if hack_data[k] == nil then
						hack_data[k] = {prop = nil, propCreated = false}
					end

					if v.cache.pickedUp == nil then
						if hack_data[k].prop == nil then 
							while not NetworkDoesNetworkIdExist(v.cache.netId) do
								Wait(1000)
							end
							hack_data[k].prop = NetworkGetEntityFromNetworkId(v.cache.netId)
						end
					end

					if hack_data[k].prop ~= nil and DoesEntityExist(hack_data[k].prop) then
						if hack_data[k].propCreated == false then 
							SetEntityAsMissionEntity(hack_data[k].prop, true, true)
							hack_data[k].propCreated = true 
						end

						local propCoords = GetEntityCoords(hack_data[k].prop)
						local distance = #(plyCoords - propCoords)

						if distance < 5.0 and hack_data[k].prop ~= nil and v.cache.pickedUp == nil then
							sleep = false
							if IsControlJustPressed(0, Config.KeyControls['pickup_device']) and distance < 1.5 then
								if hack_blip ~= nil and DoesBlipExist(hack_blip) then 
									RemoveBlip(hack_blip)
									hack_blip = true
								end
								PickUpObject(k,v)
							end
						end
					end


					if (v.cache.pickedUp ~= nil and v.cache.pickedUp == true) and v.cache.decrypting == nil then
						local decryptCoords = vector3(v.decrypt.pos[1], v.decrypt.pos[2], v.decrypt.pos[3])
						local distance = #(plyCoords - decryptCoords)
						if distance < 5.0 and v.cache.decrypting == nil then
							sleep = false
							T1GER_DrawTxt(decryptCoords.x, decryptCoords.y, decryptCoords.z, Lang['draw_decrypt_device'])
							if IsControlJustPressed(0, Config.KeyControls['decrypt_device']) and distance < 2.0 then
								local closestPlayer, dist = ESX.Game.GetClosestPlayer()
								if closestPlayer ~= -1 and dist <= 1.0 then
									return TriggerEvent('t1ger_heistpreps:notify', Lang['someone_is_too_close'])
								else
									DecryptHackingDevice(k,v)
								end
							end
						end
					end

					if (v.cache.decrypting ~= nil and v.cache.decrypting == true) and (v.cache.decryption ~= nil and next(v.cache.decryption)) then
						local decryptCoords = vector3(v.decrypt.pos[1], v.decrypt.pos[2], v.decrypt.pos[3])
						local distance = #(plyCoords - decryptCoords)
						if distance < 5.0 and v.cache.decryption.done == true and v.cache.decryption.collected == false then
							sleep = false
							T1GER_DrawTxt(decryptCoords.x, decryptCoords.y, decryptCoords.z, Lang['draw_collect_device'])
							if IsControlJustPressed(0, Config.KeyControls['collect_device']) and distance < 1.5 then
								local closestPlayer, dist = ESX.Game.GetClosestPlayer()
								if closestPlayer ~= -1 and dist <= 1.0 then
									return TriggerEvent('t1ger_heistpreps:notify', Lang['someone_is_too_close'])
								else
									CollectDevice(k,v)
								end
							end
						end
					end

				end
			end
		end
		if sleep then 
			Citizen.Wait(2000)
		end
	end
end)

function DecryptHackingDevice(id, val)
	Citizen.Wait(200)

	if val.cache.decrypting ~= nil or val.cache.decrypting == true then
		return TriggerEvent('t1ger_heistpreps:notify', Lang['device_being_decrypted'])
	else
		TriggerServerEvent('t1ger_heistpreps:hacking:decrypting', 'hacking', id)
	end

	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	FreezeEntityPosition(player, true)
	TaskStartScenarioInPlace(player, 'WORLD_HUMAN_STAND_MOBILE', -1, true)
	if Config.ProgressBars then exports['progressBars']:startUI(3000, Lang['pb_decrypting']) end
	Citizen.Wait(3000)

	while Config.Jobs['hacking'][id].cache.decrypting == nil do 
		Citizen.Wait(500)
	end

	TriggerServerEvent('t1ger_heistpreps:removeItem', val.item[1].name, val.item[1].amount)

	if Config.DataCrackMinigame == true then 
		TriggerEvent("datacrack:start", val.decrypt.difficulty, function(output)
			if output == true then
				TriggerEvent('t1ger_heistpreps:notify', Lang['decryption_started'])
				TriggerServerEvent('t1ger_heistpreps:hacking:startDecryption', 'hacking', id, coords)
			else
				TriggerEvent('t1ger_heistpreps:notify', Lang['decryption_failed'])
			end
			ClearPedTasks(player)
			FreezeEntityPosition(player, false)
		end)
	else
		if Config.ProgressBars then exports['progressBars']:startUI(3000, 'STARTING DECRYPTION SOFTWARE') end
		Citizen.Wait(3000)
		TriggerEvent('t1ger_heistpreps:notify', Lang['decryption_started'])
		TriggerServerEvent('t1ger_heistpreps:hacking:startDecryption', 'hacking', id, coords)
		ClearPedTasks(player)
		FreezeEntityPosition(player, false)
	end
end

function PickUpObject(id, val)
	local anim = {dict = 'mp_common', name = 'givetake2_a'}
	T1GER_LoadAnim(anim.dict)
	TaskTurnPedToFaceEntity(player, hack_data[id].prop, 1.0)
	Citizen.Wait(1000)
	TaskPlayAnim(player, anim.dict, anim.name, 4.0, 4.0, -1, 0, 1, 0,0,0)
	Citizen.Wait(1500)
	NetworkFadeOutEntity(hack_data[id].prop, false, false)
	Citizen.Wait(500)
	TriggerServerEvent('t1ger_heistpreps:giveItem', val.item[1].name, val.item[1].amount)
	ClearPedTasks(player)
	DeleteEntity(hack_data[id].prop)
	DeleteObject(hack_data[id].prop)
	hack_data[id].prop = false
	TriggerServerEvent('t1ger_heistpreps:hacking:pickUp', 'hacking', id)
	TriggerEvent('t1ger_heistpreps:notify', Lang['find_spot_to_decrypt'])
end

function CollectDevice(id, val)
	TriggerServerEvent('t1ger_heistpreps:hacking:collected', 'hacking', id)
	Citizen.Wait(3000)
	hack_data[id] = nil
	hasJob = false
end

-- ## DRILLS PREPARATION JOB ## --

local drills_data = {}
local drill_blips = {}

function DrillsPrep(type, num)
	TriggerServerEvent('t1ger_heistpreps:drills:spawnCrates', type, num)

	local location = Config.Jobs[type][num].location

	drill_blips[1] = CreateJobBlip(Config.Blips[type], location)
	drill_blips[2] = CreateRadiusBlip(Config.Blips[type], location, 50.0)
	local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(location.x, location.y, location.z))
	
	local sender, subject = Lang['drills_setup_job'], Lang['encrypted_message']
	local msg = Lang['drills_job_start']:format(street)
	local textureDict, iconType = 'CHAR_LESTER', 7
	TriggerEvent('t1ger_heistpreps:notifyAdvanced', sender, subject, msg, textureDict, iconType)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Jobs['drills']) do
			if v.inUse == true then
				local plyCoords = GetEntityCoords(player)

				if drills_data[k] == nil then
					drills_data[k] = {props = {}, npc = {}}
					SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
					AddRelationshipGroup('NPC')
				end

				for num,crate in pairs(v.crates) do
					local crateCoords = vector3(crate.pos[1], crate.pos[2], crate.pos[3])
					local distance = #(plyCoords - crateCoords)

					if drills_data[k].npc[num] == nil then 
						drills_data[k].npc[num] = {peds = {}} 
					end

					if distance <= 200.0 then
						if drills_data[k].props[num] == nil then
							while not NetworkDoesNetworkIdExist(crate.netId) do
								Wait(500)
							end
							drills_data[k].props[num] = NetworkGetEntityFromNetworkId(crate.netId)
							if DoesEntityExist(drills_data[k].props[num]) then
								SetEntityVisible(drills_data[k].props[num], true) 
							end
						end
					end

					for i = 1, #crate.npc do
						if drills_data[k].npc[num].peds[i] == nil then 
							while not NetworkDoesNetworkIdExist(crate.npc[i].netId) do
								Wait(500)
							end
							drills_data[k].npc[num].peds[i] = NetworkGetEntityFromNetworkId(crate.npc[i].netId)
								SetContrustionWorkerSettings(drills_data[k].npc[num].peds[i], crate.npc[i])
							Citizen.Wait(10)
						end
					end

					if drills_data[k].props[num] ~= nil and DoesEntityExist(drills_data[k].props[num]) then
						if distance < 5.0 and drills_data[k].props[num] ~= nil and crate.searched == false then
							sleep = false
							if IsControlJustPressed(0, Config.KeyControls['search_crate']) and distance < 2.0 then
								SearchCrate(k,v,num,crate)
							end
						end
					end
				end

			end
		end
		if sleep then 
			Citizen.Wait(2000)
		end
	end
end)

function SearchCrate(id, val, num, crate)
	local anim = {dict = 'anim@gangops@facility@servers@bodysearch@', name = 'player_search'}
	local anim2 = {dict = 'amb@medic@standing@kneel@base', name = 'base'}
	T1GER_LoadAnim(anim.dict)
	T1GER_LoadAnim(anim2.dict)
	local closestPlayer, dist = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and dist <= 1.0 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.lib, 3) or IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim2.dict, anim2.lib, 3) then
			return TriggerEvent('t1ger_heistpreps:notify', Lang['drills_being_searched'])
		end
	end
	TaskTurnPedToFaceEntity(player, drills_data[id].props[num], 1.0)
	Citizen.Wait(1000)
	TaskPlayAnim(player, anim2.dict, anim2.name, 2.0, -2.0, -1, 1, 0, false, false, false)
	TaskPlayAnim(player, anim.dict, anim.name, 2.0, -2.0, -1, 48, 0, false, false, false)
	if Config.ProgressBars then exports['progressBars']:startUI(5000, Lang['pb_searching_crate']) end
	Citizen.Wait(5000)
	math.randomseed(GetGameTimer())
	local chance = math.random(0,100)
	for i = 1, #crate.npc do
		SetPedShouldPlayNormalScenarioExit(drills_data[id].npc[num].peds[i])
		TaskCombatPed(drills_data[id].npc[num].peds[i], player, 0, 16)
		SetPedCombatAttributes(drills_data[id].npc[num].peds[i], 5, true)
		SetPedCombatAttributes(drills_data[id].npc[num].peds[i], 16, true)
		SetPedCombatAttributes(drills_data[id].npc[num].peds[i], 46, true)
		SetPedCombatAttributes(drills_data[id].npc[num].peds[i], 26, true)
		TaskSetBlockingOfNonTemporaryEvents(drills_data[id].npc[num].peds[i], false)
		SetBlockingOfNonTemporaryEvents(drills_data[id].npc[num].peds[i], false)
	end
	SetRelationshipBetweenGroups(0, GetHashKey("NPC"), GetHashKey("NPC"))
	SetRelationshipBetweenGroups(5, GetHashKey("NPC"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("JobNPCs"))
	ClearPedTasks(player)
	Citizen.Wait(200)
	NetworkFadeOutEntity(drills_data[id].props[num], false, false)
	Citizen.Wait(500)
	DeleteEntity(drills_data[id].props[num])
	DeleteObject(drills_data[id].props[num])
	Citizen.Wait(200)
	drills_data[id].props[num] = false
	TriggerServerEvent('t1ger_heistpreps:drills:searched', 'drills', id, num)
end

function SetContrustionWorkerSettings(entity, data)
	SetPedCanSwitchWeapon(entity, true)
	SetEntityVisible(entity, true)
	SetPedDropsWeaponsWhenDead(entity, false)
	SetPedRelationshipGroupHash(entity, GetHashKey("NPC"))
	SetPedFleeAttributes(entity, 0, false)
	SetPedSeeingRange(entity, 75.0)
	SetPedHearingRange(entity, 50.0)
	SetBlockingOfNonTemporaryEvents(entity, true)
	TaskSetBlockingOfNonTemporaryEvents(entity, true)
	SetBlockingOfNonTemporaryEvents(entity, true)
	TaskStartScenarioInPlace(entity, data.scenario, -1, false)
	SetEntityAsMissionEntity(entity)
	SetPedKeepTask(entity, true)
end

RegisterNetEvent('t1ger_heistpreps:drills:resetCurJob')
AddEventHandler('t1ger_heistpreps:drills:resetCurJob', function(type, num)
	if drill_blips[1] ~= nil and DoesBlipExist(drill_blips[1]) then 
		RemoveBlip(drill_blips[1])
	end
	if drill_blips[2] ~= nil and DoesBlipExist(drill_blips[2]) then 
		RemoveBlip(drill_blips[2])
	end
	drill_blips = {}
	TriggerEvent('t1ger_heistpreps:notify', Lang['got_necessary_drills'])
	Citizen.Wait(3000)
	hasJob = false
end)

RegisterNetEvent('t1ger_heistpreps:drills:resetCurJob2')
AddEventHandler('t1ger_heistpreps:drills:resetCurJob2', function(num)
	Citizen.Wait(3000)
	drills_data[num] = nil
end)

-- ## THERMAL CHARGES PREPARATION JOB ## --

local thermite_data = {}
local thermite_blip = nil

function ThermitePrep(type, num)
	TriggerServerEvent('t1ger_heistpreps:thermite:spawnConvoy', type, num)

	local location = Config.Jobs[type][num].location
	
	while thermite_data[num] == nil do
		Citizen.Wait(500)
	end

	while thermite_data[num].vehicle == nil do 
		Citizen.Wait(500)
	end
						
	if thermite_blip == nil then
		if DoesBlipExist(thermite_blip) then RemoveBlip(thermite_blip) end
		thermite_blip = CreateEntityBlip(thermite_data[num].vehicle, Config.Blips[type])
		local sender, subject = Lang['thermite_setup_job'], Lang['encrypted_message']
		local msg = Lang['thermite_job_start']
		local textureDict, iconType = 'CHAR_LESTER', 7
		TriggerEvent('t1ger_heistpreps:notifyAdvanced', sender, subject, msg, textureDict, iconType)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Jobs['thermite']) do
			if v.inUse == true and next(v.cache) then
				if v.cache.started == true then
					local plyCoords = GetEntityCoords(player)

					if thermite_data[k] == nil then
						thermite_data[k] = {npc = {}, npcSettings = {}}
					end

					while not NetworkDoesNetworkIdExist(v.cache.netId) do
						Wait(1000)
					end

					thermite_data[k].vehicle = NetworkGetEntityFromNetworkId(v.cache.netId)
					if thermite_data[k].vehSettings == nil then 
						thermite_data[k].vehSettings = true
						while not DoesEntityExist(thermite_data[k].vehicle) do
							Citizen.Wait(100)
						end
						SetVehicleSettings(thermite_data[k].vehicle, v.vehicle)
					end

					for num,agent in pairs(v.agents) do
						while not NetworkDoesNetworkIdExist(v.cache.agents[num]) do
							Wait(1000)
						end
						thermite_data[k].npc[num] = NetworkGetEntityFromNetworkId(v.cache.agents[num])
						if thermite_data[k].npcSettings[num] == nil then
							thermite_data[k].npcSettings[num] = true
							SetConvoyPedSettings(thermite_data[k].npc[num], agent)
							if num == 1 then
								TaskVehicleDriveToCoordLongrange(thermite_data[k].npc[num], thermite_data[k].vehicle, v.stopLocation.x, v.stopLocation.y, v.stopLocation.z, 60.0, 787004, 2.0)
							end
						end
					end

					if DoesEntityExist(thermite_data[k].vehicle) then

						local convoyDriver = GetPedInVehicleSeat(thermite_data[k].vehicle, -1)
						local alerted = GetPedAlertness(convoyDriver)
						if DoesEntityExist(convoyDriver) and IsPedDeadOrDying(convoyDriver, true) == true and (alerted ~= -1 and alerted > 0) then 
							SetDriverAbility(convoyDriver, 1.0)
							SetDriverAggressiveness(convoyDriver, 1.0)
							SetPedCombatAttributes(convoyDriver, 52, true)
							TaskVehicleDriveToCoordLongrange(convoyDriver, thermite_data[k].vehicle, v.stopLocation.x, v.stopLocation.y, v.stopLocation.z, 60.0, 787004, 2.0)
						end

						local vehCoords = GetEntityCoords(thermite_data[k].vehicle)
						local distance = #(plyCoords - vehCoords)

						if distance < 5.0 and IsPedInAnyVehicle(player, false) == false and v.cache.searching == nil then
							sleep = false
							local d1 = GetModelDimensions(GetEntityModel(thermite_data[k].vehicle))
							local trunk = GetOffsetFromEntityInWorldCoords(thermite_data[k].vehicle, 0.0, d1["y"]+0.60, 0.0)
							if #(plyCoords - vector3(trunk.x, trunk.y, trunk.z)) < 1.5 then 
								T1GER_DrawTxt(trunk.x, trunk.y, trunk.z, Lang['draw_search_c_trunk'])
								if IsControlJustPressed(0, Config.KeyControls['search_c_trunk']) then
									for i = 0, 3 do
										local ped = GetPedInVehicleSeat(thermite_data[k].vehicle, (i-1))
										local isDead = IsEntityDead(ped)
										if isDead == false then
											TriggerEvent('t1ger_heistpreps:notify', Lang['kill_guard_b4_search'])
											break
										else
											if i == 3 then 
												SearchConvoyTrunk(k,v)
											end
										end
									end
								end
							end

						end

						local stopCoords = vector3(v.stopLocation.x,v.stopLocation.y,v.stopLocation.z)
						local convoyDist = #(vehCoords - stopCoords)

						if convoyDist < 10.0 and thermite_data[k].stopSettings == nil then 
							sleep = false
							SetVehicleForwardSpeed(thermite_data[k].vehicle, 2.0)
							if convoyDist <= 3.0 then
								SetVehicleBrake(thermite_data[k].vehicle, true)
								Citizen.Wait(2000)
								FreezeEntityPosition(thermite_data[k].vehicle, true)
								Citizen.Wait(1000)
								ResetThermiteJob(k,v)
								thermite_data[k].stopSettings = true
							end
						end

					end

				end
			end
		end

		if sleep then 
			Citizen.Wait(2000)
		end
	end
end)

function SearchConvoyTrunk(id, val)
	local anim = {dict = 'anim@gangops@facility@servers@bodysearch@', name = 'player_search'}
	T1GER_LoadAnim(anim.dict)
	local closestPlayer, dist = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and dist <= 1.0 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.name, 3) then
			return TriggerEvent('t1ger_heistpreps:notify', Lang['convoy_being_searched'])
		end
	end
	if val.cache.searching == false then
		return TriggerEvent('t1ger_heistpreps:notify', Lang['convoy_being_searched'])
	end
	TriggerServerEvent('t1ger_heistpreps:thermite:searching', 'thermite', id)
	SetVehicleDoorOpen(thermite_data[id].vehicle, 5, false, false)
	Citizen.Wait(1000)
	TaskTurnPedToFaceEntity(player, thermite_data[id].vehicle, 1.0)
	Citizen.Wait(1000)
	FreezeEntityPosition(player, true)
	TaskPlayAnim(player, anim.dict, anim.name, 2.0, -2.0, -1, 48, 0, false, false, false)
	if Config.ProgressBars then exports['progressBars']:startUI(5000, Lang['pb_searching_convoy']) end
	Citizen.Wait(5000)
	TriggerServerEvent('t1ger_heistpreps:giveItem', val.item.name, val.item.amount)
	TriggerEvent('t1ger_heistpreps:notify', Lang['found_thermal_charges']:format(val.item.amount))
	FreezeEntityPosition(player, false)
	ClearPedTasks(player)
	ResetThermiteJob(id, val)
end

function ResetThermiteJob(id, val)
	TriggerServerEvent('t1ger_heistpreps:thermite:reset', 'thermite', id)
	for k,v in pairs(val.agents) do
		if DoesEntityExist(thermite_data[id].npc[k]) then 
			NetworkFadeOutEntity(thermite_data[id].npc[k], false, false)
			Citizen.Wait(500)
			DeleteEntity(thermite_data[id].npc[k])
		end
	end
	if DoesEntityExist(thermite_data[id].vehicle) then 
		NetworkFadeOutEntity(thermite_data[id].vehicle, false, false)
		Citizen.Wait(500)
		DeleteEntity(thermite_data[id].vehicle)
	end
	if thermite_blip ~= nil and DoesBlipExist(thermite_blip) then 
		RemoveBlip(thermite_blip)
	end
	hasJob = false
end

RegisterNetEvent('t1ger_heistpreps:thermite:resetCL')
AddEventHandler('t1ger_heistpreps:thermite:resetCL', function(type, num)
	Citizen.Wait(3000)
	thermite_data[num] = nil
end)

function SetVehicleSettings(entity, data)
	NetworkRegisterEntityAsNetworked(entity)
    SetEntityAsMissionEntity(entity, true, true)
    SetVehicleIsStolen(entity, false)
    SetVehicleIsWanted(entity, false)
    SetVehRadioStation(entity, 'OFF')
    SetVehicleFuelLevel(entity, 100.0)
	SetVehicleOnGroundProperly(entity)
	if Config.T1GER_Keys then 
		exports['t1ger_keys']:SetVehicleLocked(entity, 0)
	end
end

function SetConvoyPedSettings(entity, data)
    SetEntityAsMissionEntity(entity, true, true)
	GiveWeaponToPed(entity, GetHashKey(data.weapon), 250, false, true)
	SetPedCanSwitchWeapon(entity, true)
	SetPedAsCop(entity, true)
	SetPedDropsWeaponsWhenDead(entity, false)
	SetPedCombatAbility(entity, 2)
	SetPedArmour(entity, data.armour)
	SetPedAccuracy(entity, data.accuracy)
	SetPedSuffersCriticalHits(entity, data.criticalHits)
end

-- ## EXPLOSIVES PREPARATION JOB ## --

local explosives_data = {}
local explosives_blip = {}

function ExplosivesPrep(type, num)
	TriggerServerEvent('t1ger_heistpreps:explosives:spawnCase', type, num)

	local location = Config.Jobs[type][num].location

	explosives_blip[1] = CreateJobBlip(Config.Blips['explosives'], location)
	explosives_blip[2] = CreateRadiusBlip(Config.Blips['explosives'], location, 60.0)
	local sender, subject = Lang['explosives_setup_job'], Lang['encrypted_message']
	local msg = Lang['explosives_job_start']
	local textureDict, iconType = 'CHAR_LESTER', 7
	TriggerEvent('t1ger_heistpreps:notifyAdvanced', sender, subject, msg, textureDict, iconType)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Jobs['explosives']) do
			if v.inUse == true and next(v.cache) then
				if v.cache.started == true then
					local plyCoords = GetEntityCoords(player)

					if explosives_data[k] == nil then
						explosives_data[k] = {prop = nil, settings = false}
					end

					if v.cache.collected == nil then
						if explosives_data[k].prop == nil then 
							while not NetworkDoesNetworkIdExist(v.cache.netId) do
								Wait(1000)
							end
							explosives_data[k].prop = NetworkGetEntityFromNetworkId(v.cache.netId)
						end
					end

					if explosives_data[k].prop ~= nil and DoesEntityExist(explosives_data[k].prop) then
						if explosives_data[k].settings == false then
							PlaceObjectOnGroundProperly(explosives_data[k].prop)
							Citizen.Wait(1000)
							FreezeEntityPosition(explosives_data[k].prop, true)
							SetEntityAsMissionEntity(explosives_data[k].prop, true, true)
							explosives_data[k].settings = true 
						end

						local propCoords = GetEntityCoords(explosives_data[k].prop)
						local distance = #(plyCoords - propCoords)

						if distance < 5.0 and explosives_data[k].prop ~= nil and v.cache.collected == nil then
							sleep = false
							if IsControlJustPressed(0, Config.KeyControls['collect_explosive_case']) and distance < 2.0 then
								CollectExplosivesCase(k,v)
							end
						end

						if (v.cache.collected ~= nil and v.cache.collected == true) and v.cache.placed == nil then
							local shoreDist = #(plyCoords - v.shore)
							if shoreDist <= 4.0 then
								sleep = false
								T1GER_DrawTxt(v.shore.x, v.shore.y, v.shore.z, Lang['draw_place_case'])
								if IsControlJustPressed(0, Config.KeyControls['place_explosive_case']) then
									PlaceExplosiveCase(k,v)
								end
							end
						end

						if (v.cache.placed ~= nil and v.cache.placed == true) then
							if distance < 5.0 and v.cache.lockpicking == false then
								sleep = false
								T1GER_DrawTxt(propCoords.x, propCoords.y, propCoords.z+0.05, Lang['draw_unlock_case'])
								if IsControlJustPressed(0, Config.KeyControls['unlock_explosive_case']) and distance <= 2.0 then 
									UnlockExplosiveCase(k,v)
								end
							end
						end

					end

				end
			end
		end
		if sleep then 
			Citizen.Wait(2000)
		end
	end
end)

function CollectExplosivesCase(id,val)
	local anim = {dict = 'mp_common', name = 'givetake2_a'}
	T1GER_LoadAnim(anim.dict)
	local offset = val.offset
	local boneIndex = GetPedBoneIndex(player, offset.bone)
	local pX, pY, pZ, rX, rY, rZ = round(offset.pos[1],2), round(offset.pos[2],2), round(offset.pos[3],2), round(offset.rot[1],2), round(offset.rot[2],2), round(offset.rot[3],2)
	FreezeEntityPosition(player, true)
	TaskPlayAnim(player, anim.dict, anim.name, 4.0, 4.0, -1, 48, 1, 0,0,0)
	for i = 1, 2 do
		if explosives_blip[i] ~= nil and DoesBlipExist(explosives_blip[i]) then 
			RemoveBlip(explosives_blip[i])
			explosives_blip[i] = false
		end
	end
	Citizen.Wait(2000)
	FreezeEntityPosition(player, false)
	FreezeEntityPosition(explosives_data[id].prop, false)
	AttachEntityToEntity(explosives_data[id].prop, player, boneIndex, pX, pY, pZ, rX, rY, rZ, true, true, false, true, 2, 1)
	ClearPedTasks(player)
	TriggerServerEvent('t1ger_heistpreps:explosives:collected', 'explosives', id)
	TriggerEvent('t1ger_heistpreps:notify', Lang['return_to_the_shore'])
	
	if explosives_blip[1] ~= nil and explosives_blip[1] == false then 
		explosives_blip[1] = CreateJobBlip(Config.Blips['explosives'], val.shore)
		Citizen.Wait(200)
		SetBlipAsShortRange(explosives_blip[1], false)
		SetBlipRoute(explosives_blip[1], false)
	end

end

function PlaceExplosiveCase(id,val)
	local anim = {dict = 'random@domestic', name = 'pickup_low'}
	T1GER_LoadAnim(anim.dict)
	TaskPlayAnim(player, anim.dict, anim.name, 5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
	TriggerServerEvent('t1ger_heistpreps:explosives:placed', 'explosives', id)
	Citizen.Wait(1000)
	DetachEntity(explosives_data[id].prop)
	ClearPedTasks(player)
	PlaceObjectOnGroundProperly(explosives_data[id].prop)
	FreezeEntityPosition(explosives_data[id].prop, true)
	TriggerEvent('t1ger_heistpreps:notify', Lang['unlock_the_case'])
	for i = 1, 2 do
		if explosives_blip[i] ~= nil and DoesBlipExist(explosives_blip[i]) then 
			RemoveBlip(explosives_blip[i])
			explosives_blip[i] = false
		end
	end
end

function UnlockExplosiveCase(id,val)
	TriggerServerEvent('t1ger_heistpreps:explosives:lockpicking', 'explosives', id, true)
	local unlocked = nil
	if Config.LockpickingMinigame then
		TriggerEvent('lockpick:client:openLockpick', function(result)
			unlocked = result
		end)
	else
		if Config.ProgressBars then exports['progressBars']:startUI(2000, Lang['pb_unlocking']) end
		Citizen.Wait(2000)
		unlocked = true
	end
	while unlocked == nil do
		Citizen.Wait(200)
	end
	if unlocked == true then 
		TriggerServerEvent('t1ger_heistpreps:explosives:unlocked', 'explosives', id)
		TriggerEvent('t1ger_heistpreps:notify', Lang['found_explosive_charge'])
		Citizen.Wait(500)
		NetworkFadeOutEntity(explosives_data[id].prop, false, false)
		Citizen.Wait(1000)
		DeleteEntity(explosives_data[id].prop)
		-- reset job:
		Citizen.Wait(3000)
		explosives_blip = {}
		hasJob = false
	else
		TriggerServerEvent('t1ger_heistpreps:explosives:lockpicking', 'explosives', id, false)
		TriggerEvent('t1ger_heistpreps:notify', Lang['failed_to_unlock'])
	end
end

RegisterNetEvent('t1ger_heistpreps:explosives:reset')
AddEventHandler('t1ger_heistpreps:explosives:reset', function(type, num)
	Citizen.Wait(3000)
	explosives_data[id] = nil
end)

-- ## KEYCARD PREPARATION JOB ## --

local keycard_data = {}
local keycard_blips = {}
local keycard_t_blips = {}

function KeycardPrep(type, num)
	TriggerServerEvent('t1ger_heistpreps:keycard:spawnPed', type, num)

	local location = Config.Jobs[type][num].location

	keycard_blips[1] = CreateJobBlip(Config.Blips['keycard'], location)
	keycard_blips[2] = CreateRadiusBlip(Config.Blips['keycard'], location, 50.0)
	local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(location.x, location.y, location.z))
	local sender, subject = Lang['keycard_setup_job'], Lang['encrypted_message']
	local msg = Lang['keycard_job_start']:format(street)
	local textureDict, iconType = 'CHAR_LESTER', 7
	TriggerEvent('t1ger_heistpreps:notifyAdvanced', sender, subject, msg, textureDict, iconType)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Jobs['keycard']) do
			if v.inUse == true and next(v.cache) then
				if v.cache.started == true then

					local plyCoords = GetEntityCoords(player)

					if keycard_data[k] == nil then
						keycard_data[k] = {settings = false, trucks = {}}
					end

					if keycard_data[k].npc == nil and v.cache.searchedKeys == false then
						while not NetworkDoesNetworkIdExist(v.cache.netId) do
							Wait(500)
						end
						keycard_data[k].npc = NetworkGetEntityFromNetworkId(v.cache.netId)
						while not DoesEntityExist(keycard_data[k].npc) do
							Citizen.Wait(250) 
						end
						SetBankManSettings(keycard_data[k].npc, v)
					end

					if keycard_data[k].npc ~= nil and DoesEntityExist(keycard_data[k].npc) then

						local pedCoords = GetEntityCoords(keycard_data[k].npc)
						local isDead = IsEntityDead(keycard_data[k].npc)

						if isDead == false then
							if GetIsTaskActive(keycard_data[k].npc, 222) == false then 
								TaskWanderInArea(keycard_data[k].npc, v.location.x, v.location.y, v.location.z, 35.0, 20, 1.0)
							end
						else
							local distance = #(plyCoords - pedCoords)
							if distance <= 2.0 and v.cache.searchedKeys == false then
								sleep = false
								T1GER_DrawTxt(pedCoords.x, pedCoords.y, pedCoords.z, Lang['draw_search_ped'])
								if IsControlJustPressed(0, Config.KeyControls['search_bank_ped']) then
									SearchBankPed(k,v)
								end
							end
						end
					end

					if v.cache.searchedKeys ~= nil and v.cache.searchedKeys == true then 
						
						for num,data in pairs(v.spawns) do 
							if data.searched ~= nil and data.searched == false then 

								if keycard_data[k].trucks[num] == nil and data.netId ~= nil then
									while not NetworkDoesNetworkIdExist(data.netId) do
										Citizen.Wait(250)
									end
									keycard_data[k].trucks[num] = NetworkGetEntityFromNetworkId(data.netId)
									while not DoesEntityExist(keycard_data[k].trucks[num]) do 
										Citizen.Wait(200)
									end
									SetBankTrunkSettings(keycard_data[k].trucks[num])
								end
							end
						end

						if next(keycard_data[k].trucks) then
							for i = 1, #keycard_data[k].trucks do 
								if v.spawns[i].searched == false then 
									if keycard_data[k].trucks[i] ~= nil and DoesEntityExist(keycard_data[k].trucks[i]) then
										plyCoords = GetEntityCoords(player)
										local truckCoords = GetEntityCoords(keycard_data[k].trucks[i])
										local truckDist = #(plyCoords - truckCoords)
										if truckDist <= 10.0 then 
											sleep = false
											if truckDist < 5.0 then 
												local d1,d2 = GetModelDimensions(GetEntityModel(keycard_data[k].trucks[i]))
												local unlockCoords = GetOffsetFromEntityInWorldCoords(keycard_data[k].trucks[i], 0.0,d1.y+0.5,0.7)
												T1GER_DrawTxt(unlockCoords.x, unlockCoords.y, unlockCoords.z, Lang['draw_unlock_b_truck'])
												if IsControlJustPressed(0, Config.KeyControls['unlock_bank_truck']) then
													UnlockAndSearchTruck(k,v,i,keycard_data[k].trucks[i])
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
		end
		if sleep then 
			Citizen.Wait(2000)
		end
	end
end)

function SearchBankPed(id,val)
	for i = 1, 2 do 
		if keycard_blips[i] ~= nil and DoesBlipExist(keycard_blips[i]) then
			RemoveBlip(keycard_blips[i])
			keycard_blips[i] = false
		end
	end

	local anim = {dict = 'anim@gangops@facility@servers@bodysearch@', name = 'player_search'}
	local anim2 = {dict = 'amb@medic@standing@kneel@base', name = 'base'}
	T1GER_LoadAnim(anim.dict)
	T1GER_LoadAnim(anim2.dict)
	local closestPlayer, dist = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and dist <= 1.0 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.lib, 3) or IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim2.dict, anim2.lib, 3) then
			return TriggerEvent('t1ger_heistpreps:notify', Lang['bankman_being_searched'])
		end
	end
	TaskTurnPedToFaceEntity(player, keycard_data[id].npc, 1.0)
	Citizen.Wait(1000)
	TaskPlayAnim(player, anim2.dict, anim2.name, 2.0, -2.0, -1, 1, 0, false, false, false)
	TaskPlayAnim(player, anim.dict, anim.name, 2.0, -2.0, -1, 48, 0, false, false, false)
	if Config.ProgressBars then exports['progressBars']:startUI(5000, Lang['pb_searching_ped']) end
	Citizen.Wait(5000)
	TriggerServerEvent('t1ger_heistpreps:keycard:searchedKeys', 'keycard', id)
	local sender, subject = Lang['keycard_setup_job'], Lang['encrypted_message']
    local msg = Lang['trucks_tracked_down']
    local textureDict, iconType = 'CHAR_LESTER', 7
    TriggerEvent('t1ger_heistpreps:notifyAdvanced', sender, subject, msg, textureDict, iconType)
	ClearPedTasks(player)
	Citizen.Wait(1000)
	NetworkFadeOutEntity(keycard_data[id].npc, false, false)
	Citizen.Wait(1000)
	DeleteEntity(keycard_data[id].npc)
	keycard_data[id].npc = false

	for num,data in pairs(val.spawns) do 
		if keycard_t_blips[num] == nil then
			keycard_t_blips[num] = CreateEntityBlip2(Config.Blips['truck'], vector3(data.pos.x, data.pos.y, data.pos.z))
		end
	end
end

function UnlockAndSearchTruck(id,val,num,bankTruck)
	local anim = {dict = 'anim@mp_player_intmenu@key_fob@', name = 'fob_click'}
	local prop = GetHashKey('p_car_keys_01')
	local offset = {pos = vector3(0.09,0.04,0.0), rot = vector3(0.09,0.04,0.0)}
	T1GER_LoadModel(prop)
	T1GER_LoadAnim(anim.dict)
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED")) 
	local keyFob = CreateObject(prop, coords.x, coords.y, coords.z, true, true, false)
	AttachEntityToEntity(keyFob, player, GetPedBoneIndex(player, 57005), offset.pos.x, offset.pos.y, offset.pos.z, offset.rot.x, offset.rot.y, offset.rot.z, true, true, false, true, 1, true)
	TaskPlayAnim(player, anim.dict, anim.name, 15.0, -10.0, 1500, 49, 0, false, false, false)
	PlaySoundFromEntity(-1, "Remote_Control_Fob", player, "PI_Menu_Sounds", 1, 0)
	SetVehicleLights(bankTruck,2)
	Citizen.Wait(200)
	SetVehicleLights(bankTruck,1)
	Citizen.Wait(200)
	SetVehicleLights(bankTruck,2)
	Citizen.Wait(200)
	if Config.T1GER_Keys then 
		exports['t1ger_keys']:SetVehicleLocked(bankTruck, 0)
	else
		SetVehicleDoorsLocked(bankTruck, 0)
	end
	PlaySoundFromEntity(-1, "Remote_Control_Close", bankTruck, "PI_Menu_Sounds", 1, 0)
	SetVehicleDoorOpen(bankTruck, 2, false, false)
	SetVehicleDoorOpen(bankTruck, 3, false, false)
	-- end animation:
	Citizen.Wait(200)
	SetVehicleLights(bankTruck,1)
	SetVehicleLights(bankTruck,0)
	Citizen.Wait(200)
	DeleteEntity(keyFob)
	-- Animation for searching:
	Citizen.Wait(500)
	local anim = {dict = 'anim@gangops@facility@servers@bodysearch@', name = 'player_search'}
	T1GER_LoadAnim(anim.dict)
	local closestPlayer, dist = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and dist <= 2.0 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.name, 3) then
			return TriggerEvent('t1ger_heistpreps:notify', Lang['truck_being_searched'])
		end
	end
	TaskTurnPedToFaceEntity(player, vehicle, 1.0)
	Citizen.Wait(500)
	FreezeEntityPosition(player, true)
	TaskPlayAnim(player, anim.dict, anim.name, 2.0, -2.0, -1, 48, 0, false, false, false)
	if Config.ProgressBars then exports['progressBars']:startUI(5000, Lang['pb_searching_truck']) end
	Citizen.Wait(5000)
	FreezeEntityPosition(player, false)
	ClearPedTasks(player)
	TriggerServerEvent('t1ger_heistpreps:keycard:truckSearched', 'keycard', id, num)
	if keycard_t_blips[num] ~= nil and DoesBlipExist(keycard_t_blips[num]) then RemoveBlip(keycard_t_blips[num]) end 
	Citizen.Wait(2000)
	if keycard_data[id].trucks[num] ~= nil and DoesEntityExist(keycard_data[id].trucks[num]) then
		NetworkFadeOutEntity(keycard_data[id].trucks[num], false, false)
		Citizen.Wait(1000)
		DeleteEntity(keycard_data[id].trucks[num])
		keycard_data[id].trucks[num] = false
	end
end

RegisterNetEvent('t1ger_heistpreps:keycard:resetCurJob')
AddEventHandler('t1ger_heistpreps:keycard:resetCurJob', function(type, num)
	TriggerEvent('t1ger_heistpreps:notify', Lang['found_keycards'])
	local cfg = Config.Jobs[type][num]
	for i = 1, #cfg.spawns do
		if keycard_t_blips[i] ~= nil and DoesEntityExist(keycard_t_blips[i]) then
			RemoveBlip(keycard_t_blips[i])
		end
	end
	Citizen.Wait(3000)
	keycard_t_blips = {}
	keycard_blips = {}
	hasJob = false
end)

RegisterNetEvent('t1ger_heistpreps:keycard:resetCurJob2')
AddEventHandler('t1ger_heistpreps:keycard:resetCurJob2', function(num)
	Citizen.Wait(3000)
	keycard_data[num] = nil
end)

function SetBankManSettings(entity, data)
    SetEntityAsMissionEntity(entity, true, true)
	SetPedCanSwitchWeapon(entity, true)
	SetPedAsCop(entity, true)
	SetPedDropsWeaponsWhenDead(entity, false)
	SetPedArmour(entity, 100)
	SetPedAccuracy(entity, 100)
	-- Combat:
	SetPedFleeAttributes(entity, 0, false)
	SetPedCombatAbility(entity, 2)
	SetPedCombatMovement(entity, 2)
	SetPedCombatRange(entity, 2)
	SetPedCombatAttributes(entity, 5, true)
	SetPedCombatAttributes(entity, 46, true)
end

function SetBankTrunkSettings(entity)
	SetEntityAsMissionEntity(entity, true, true)
	NetworkRegisterEntityAsNetworked(entity)
    SetVehicleIsStolen(entity, false)
    SetVehicleIsWanted(entity, false)
    SetVehRadioStation(entity, 'OFF')
    SetVehicleFuelLevel(entity, 100.0)
	SetVehicleOnGroundProperly(entity)
	if Config.T1GER_Keys then 
		exports['t1ger_keys']:SetVehicleLocked(entity, 2)
	end
end

function CreateJobBlip(data, pos)
	local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(blip, data.sprite)
	SetBlipColour(blip, data.color)
	AddTextEntry('MYBLIP', data.name)
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, data.scale) -- set scale
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 5)
	return blip
end

function CreateRadiusBlip(data, pos, radius)
	local blip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, data.color)
	SetBlipAlpha(blip, 100)
	SetBlipAsShortRange(blip, true)
	return blip
end

function CreateEntityBlip(entity, data)
	local cfg = Config.Blips['thermite']
	local blip = AddBlipForEntity(entity)
	SetBlipSprite(blip, data.sprite)
	SetBlipColour(blip, data.color)
	AddTextEntry('MYBLIP', data.name)
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, data.scale) -- set scale
	return blip
end

function CreateEntityBlip2(data, pos)
	local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(blip, data.sprite)
	SetBlipColour(blip, data.color)
	AddTextEntry('MYBLIP', data.name)
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, data.scale) -- set scale
	return blip
end
