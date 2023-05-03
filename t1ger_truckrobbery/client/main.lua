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

local map_blip = nil

-- Job Start Thread:
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		local cfg = Config.TruckRobbery
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.computer.pos[1], cfg.computer.pos[2], cfg.computer.pos[3], false)
		if distance < cfg.computer.draw.dist then
			sleep = false
			DrawText3Ds(cfg.computer.pos[1], cfg.computer.pos[2], cfg.computer.pos[3], cfg.computer.draw.text)
			if IsControlJustPressed(0, cfg.computer.keybind) then
				if distance < 2.0 then
					if not isCop then
						ESX.TriggerServerCallback('t1ger_truckrobbery:copCount', function(cops)
							if cops >= cfg.police.minCops then
								ESX.TriggerServerCallback('t1ger_truckrobbery:getCooldown', function(cooldown)
									if cooldown == nil then
										ESX.TriggerServerCallback('t1ger_truckrobbery:getJobFees', function(hasMoney)
											if hasMoney then
												OpenHackFunction()
											else
												ShowNotifyESX(Lang['not_enough_money'])
											end
										end)
									else
										ShowNotifyESX((Lang['cooldown_time_left']:format(cooldown)))
									end
								end)
							else
								ShowNotifyESX(Lang['not_enough_police'])
							end
						end)
					end
				else
					ShowNotifyESX('Move closer to the computer.')
				end
			end
		end
		if sleep then 
			Citizen.Wait(1000)
		end
	end
end)

-- Function to hack into the location:
function OpenHackFunction()
	local cfg = Config.TruckRobbery
	LoadAnim(cfg.computer.anim.dict)
	TaskPlayAnimAdvanced(player, cfg.computer.anim.dict, cfg.computer.anim.lib, cfg.computer.pos[1], cfg.computer.pos[2], cfg.computer.pos[3], 0.0, 0.0, cfg.computer.pos[4], 3.0, 1.0, -1, 30, 1.0, 0, 0 )
	SetEntityHeading(player, cfg.computer.pos[4])
	FreezeEntityPosition(player, true)
	if Config.progressBars then 
		exports['progressBars']:startUI((cfg.computer.mHacking.duration * 1000), Lang['progbar_hacking'])
	end
	Citizen.Wait(cfg.computer.mHacking.duration * 1000)
	if cfg.computer.mHacking.enable then 
		TriggerEvent("mhacking:show")
		TriggerEvent("mhacking:start", cfg.computer.mHacking.blocks, cfg.computer.mHacking.seconds, HackCallback)
	else
		HackCallback(true)
	end
end

-- Callback function for hacking function:
function HackCallback(success)
	ClearPedTasks(player)
    FreezeEntityPosition(player,false)
	if Config.TruckRobbery.computer.mHacking.enable then 
		TriggerEvent('mhacking:hide')
	end
	if success then
		TriggerServerEvent('t1ger_truckrobbery:startJobSV')
	else
		ShowNotifyESX(Lang['hacking_failed'])
	end
end

-- Truck Robbery Map Blip:
function CreateTruckRobberyMapBlip()
	local cfg = Config.TruckRobbery.computer
	if cfg.blip.enable then
		local mk = cfg.blip
		map_blip = AddBlipForCoord(cfg.pos[1], cfg.pos[2], cfg.pos[3])
		SetBlipSprite (map_blip, mk.sprite)
		SetBlipDisplay(map_blip, mk.display)
		SetBlipScale  (map_blip, mk.scale)
		SetBlipColour (map_blip, mk.color)
		SetBlipAsShortRange(map_blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(mk.label)
		EndTextCommandSetBlipName(map_blip)
	end
end

-- Making sure that players don't get the same mission at the same time
RegisterNetEvent('t1ger_truckrobbery:startJobCL')
AddEventHandler('t1ger_truckrobbery:startJobCL',function()
    local num = math.random(1,#Config.TruckSpawns)
    local takenNum = 0
    while Config.TruckSpawns[num].InUse and takenNum < 100 do
        takenNum = takenNum + 1
        num = math.random(1,#Config.TruckSpawns)
    end
    if takenNum == 100 then
        ShowNotifyESX(Lang['no_available_jobs'])
    else
        TriggerEvent('t1ger_truckrobbery:truckRobberyJob', num)
        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
		ShowNotifyESX('Go to the armored truck.')
    end
end)

local ArmoredTruck = nil
local StopTheJob = false
local TruckDemolished = false
local TruckIsExploded = false

RegisterNetEvent('t1ger_truckrobbery:truckRobberyJob')
AddEventHandler('t1ger_truckrobbery:truckRobberyJob',function(num)
	local job = Config.TruckSpawns[num]
	Config.TruckSpawns[num].inUse = true
	TriggerServerEvent('t1ger_truckrobbery:SyncDataSV', Config.TruckSpawns)

	local TruckRobbed = false
	local ArmoredTruckSpawned = false
	local SecuritySpawned = false
	local Guards = {}
	local truck_blip = CreateTruckBlip(job)
	local truck_pos = {}

	while not TruckRobbed do
		Citizen.Wait(1)
		local sleep = true
		if job.inUse then 
			local distance = 0
			if DoesEntityExist(ArmoredTruck) then 
				truck_pos = GetEntityCoords(ArmoredTruck)
				distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, truck_pos.x, truck_pos.y, truck_pos.z, false)
			else
				distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, job.pos[1], job.pos[2], job.pos[3], false)
			end
			if distance < 150.0 then 
				sleep = false
				if DoesEntityExist(ArmoredTruck) then truck_pos = GetEntityCoords(ArmoredTruck) end
				-- Spawn Job Vehicle:
				if distance < 100.0 and not ArmoredTruckSpawned then
					ClearAreaOfVehicles(job.pos[1], job.pos[2], job.pos[3], 10.0, false, false, false, false, false)
					ArmoredTruck = CreateArmoredTruck('stockade', job.pos)
					ArmoredTruckSpawned = true
				end
				-- Spawn Security:
				if distance < 100.0 and ArmoredTruckSpawned and not SecuritySpawned then
					for i = 1, #job.security do
						Guards[i] = CreateGuardsInVeh(job.security[i])
					end
					SecuritySpawned = true
				end
				-- Backup if truck is not there:
				if ArmoredTruckSpawned or SecuritySpawned then
					if not DoesEntityExist(ArmoredTruck) then 
						if SecuritySpawned then
							for i = 1, #job.security do
								if DoesEntityExist(Guards[i]) then 
									DeleteEntity(Guards[i])
								end
							end
						end
						ArmoredTruckSpawned = false
						SecuritySpawned = false
						--truck_blip = CreateTruckBlip(job)
					end
				end
				if ArmoredTruck ~= nil and ArmoredTruckSpawned and SecuritySpawned then
					if DoesBlipExist(truck_blip) then RemoveBlip(truck_blip) end
					if DoesEntityExist(ArmoredTruck) then 
						if not DoesBlipExist(truck_blip) then
							truck_blip = AddBlipForEntity(ArmoredTruck)
						end
						local cfg = Config.TruckRobbery.truckBlip
						SetBlipSprite(truck_blip, cfg.sprite)
						SetBlipColour(truck_blip, cfg.color)
						SetBlipDisplay(truck_blip, cfg.display)
						SetBlipScale(truck_blip, cfg.scale)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(cfg.label)
						EndTextCommandSetBlipName(truck_blip)
					elseif DoesBlipExist(truck_blip) then
						RemoveBlip(truck_blip)
					end
				end
				if ArmoredTruckSpawned and SecuritySpawned then 
					local truck_pos = GetEntityCoords(ArmoredTruck) 
					local truck_dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, truck_pos.x, truck_pos.y, truck_pos.z, false)
					
					if truck_dist > 40.0 then
						DrawMissionText(Lang['reach_the_truck'])
					end

					if truck_dist < 40.0 and truck_dist > 5.0 and not TruckDemolished then
						local i = 0
						for k,v in pairs(job.security) do
							if DoesEntityExist(Guards[i]) then
								if not IsEntityDead(Guards[i]) then 
									DrawMissionText(Lang['kill_the_guards'])
								end
								if IsEntityDead(Guards[i]) and IsPedInAnyVehicle(Guards[i], true) then
									DeleteEntity(Guards[i])
								end
							end
							i = i + 1
						end
					end

					if truck_dist <= 5.0 and not TruckDemolished then
						local closest_veh = GetClosestVehicle(coords.x, coords.y, coords.z, 20.0, 0, 70)
						if GetEntityModel(closest_veh) == GetHashKey('stockade') then
							local d1 = GetModelDimensions(GetEntityModel(closest_veh))
							local veh_pos = GetOffsetFromEntityInWorldCoords(closest_veh, 0.0,d1["y"]+0.60,0.0)
							local distVeh = GetDistanceBetweenCoords(veh_pos.x, veh_pos.y, veh_pos.z, coords.x, coords.y, coords.z, false);
							if distVeh < 2.0 then
								DrawText3Ds(veh_pos.x, veh_pos.y, veh_pos.z, Lang['open_truck_door'])
								if IsControlJustPressed(1, 47) then 
									SetVehicleDoorShut(closest_veh, 2, 1)
									SetVehicleDoorShut(closest_veh, 3, 1)
									SetVehicleDoorShut(closest_veh, 5, 1)
									SetVehicleDoorShut(closest_veh, 6, 1)
									Wait(200)
									BlowTheTruckDoor()
								end
							end
						end
					end

					if TruckIsExploded then
						truck_pos = GetEntityCoords(ArmoredTruck) 
						truck_dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, truck_pos.x, truck_pos.y, truck_pos.z, false)
		
						if truck_dist > 45.0 then
							Citizen.Wait(500)
						end
		
						if truck_dist < 4.5 then
							local closest_veh = GetClosestVehicle(coords.x, coords.y, coords.z, 20.0, 0, 70)
							if GetEntityModel(closest_veh) == GetHashKey('stockade') then
								local d2 = GetModelDimensions(GetEntityModel(closest_veh))
								local veh_pos = GetOffsetFromEntityInWorldCoords(closest_veh, 0.0,d2["y"]+0.60,0.0)
								local truck_dist = GetDistanceBetweenCoords(veh_pos.x, veh_pos.y, veh_pos.z, coords.x, coords.y, coords.z, false);
								if truck_dist < 2.0 then
									DrawText3Ds(veh_pos.x, veh_pos.y, veh_pos.z, Lang['rob_the_truck'])
									if IsControlJustPressed(1, 38) then
										RobbingTheMoney()
									end
								end
							end
						end
					end
				end

				if StopTheJob then
				
					Config.TruckSpawns[num].inUse = false
					Wait(150)
					TriggerServerEvent('t1ger_truckrobbery:SyncDataSV',Config.TruckSpawns)
					Citizen.Wait(500)
					SetEntityAsNoLongerNeeded(ArmoredTruck)
					if DoesBlipExist(truck_blip) then
						RemoveBlip(truck_blip)
					end
					local i = 0
					for k,v in pairs(job.security) do
						if DoesEntityExist(Guards[i]) then
							DeleteEntity(Guards[i])
						end
						i = i +1
					end
					ArmoredTruck = nil
					ArmoredTruckSpawned = false
					SecuritySpawned = false
					Guards = {}
					truck_blip = nil
					TruckDemolished = false
					TruckIsExploded = false
					StopTheJob = false
					TruckRobbed = true
					break
				end

			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- function create truck blip:
function CreateTruckBlip(job)
	local cfg = Config.TruckRobbery.truckBlip
	local blip = AddBlipForCoord(job.pos[1],job.pos[2],job.pos[3])
	SetBlipSprite(blip, cfg.sprite)
	SetBlipColour(blip, cfg.color)
	SetBlipDisplay(blip, cfg.display)
	SetBlipScale(blip, cfg.scale)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(cfg.label)
	EndTextCommandSetBlipName(blip)
	return blip
end

-- Function to create job ped(s):
function CreateGuardsInVeh(guard)
	LoadModel(guard.ped)
	local NPC = CreatePedInsideVehicle(ArmoredTruck, 1, guard.ped, guard.seat, true, true)
	NetworkRegisterEntityAsNetworked(NPC)
	SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(NPC), true)
	SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(NPC), true)
	SetPedFleeAttributes(NPC, 0, false)
	SetPedCombatAttributes(NPC, 46, 1)
	SetPedCombatAbility(NPC, 100)
	SetPedCombatMovement(NPC, 2)
	SetPedCombatRange(NPC, 2)
	SetPedKeepTask(NPC, true)
	GiveWeaponToPed(NPC, GetHashKey(guard.weapon), 250, false, true)
	SetPedAsCop(NPC, true)
	SetPedDropsWeaponsWhenDead(NPC, false)
	TaskVehicleDriveWander(NPC, ArmoredTruck, 50.0, 443)
	SetPedArmour(NPC, 100)
	SetPedAccuracy(NPC, 60)
	SetEntityInvincible(NPC, false)
	SetEntityVisible(NPC, true)
	SetEntityAsMissionEntity(NPC)
	return NPC
end

-- Function to blow the truck door:
function BlowTheTruckDoor()
	local cfg = Config.TruckRobbery
	if IsVehicleStopped(ArmoredTruck) then
		TruckDemolished = true
		
		LoadAnim('anim@heists@ornate_bank@thermal_charge_heels')
		
		if cfg.police.notify then
			NotifyPoliceFunction()
		end
		
		local x,y,z = table.unpack(GetEntityCoords(player))
		local itemC4prop = CreateObject(GetHashKey('prop_c4_final_green'), x, y, z+0.2,  true,  true, true)
		AttachEntityToEntity(itemC4prop, player, GetPedBoneIndex(player, 60309), 0.06, 0.0, 0.06, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
		SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
		Citizen.Wait(500)
		FreezeEntityPosition(player, true)
		TaskPlayAnim(player, 'anim@heists@ornate_bank@thermal_charge_heels', "thermal_charge", 3.0, -8, -1, 63, 0, 0, 0, 0 )
		if Config.progressBars then 
			exports['progressBars']:startUI(5500, Lang['progbar_plant_c4'])
		end
		Citizen.Wait(5500)
		
		ClearPedTasks(player)
		DetachEntity(itemC4prop)
		AttachEntityToEntity(itemC4prop, ArmoredTruck, GetEntityBoneIndexByName(ArmoredTruck, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
		FreezeEntityPosition(player, false)
		Citizen.Wait(500)
		if Config.progressBars then 
			exports['progressBars']:startUI((cfg.rob.detonateTimer * 1000), Lang['progbar_detonating'])	
		end
		Citizen.Wait((cfg.rob.detonateTimer * 1000))
		
		local c4_explode_pos = GetWorldPositionOfEntityBone(ArmoredTruck, GetEntityBoneIndexByName(ArmoredTruck, 'door_pside_r'))
		SetVehicleDoorBroken(ArmoredTruck, 2, false)
		SetVehicleDoorBroken(ArmoredTruck, 3, false)
		AddExplosion(c4_explode_pos.x, c4_explode_pos.y, c4_explode_pos.z, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
		ApplyForceToEntity(ArmoredTruck, 0, c4_explode_pos.x, c4_explode_pos.y, c4_explode_pos.z, 0.0, 0.1, 0.0, GetEntityBoneIndexByName(ArmoredTruck, 'door_pside_r'), false, true, false, false, true)
		DeleteEntity(itemC4prop)
		TruckIsExploded = true
		ShowNotifyESX(Lang['begin_to_rob'])
	else
		ShowNotifyESX(Lang['truck_not_stopped'])
	end
end

-- Function to rob the loot
function RobbingTheMoney()
	local cfg = Config.TruckRobbery
	LoadAnim('anim@heists@ornate_bank@grab_cash_heels')
	local moneyBag = CreateObject(GetHashKey(cfg.rob.bag_prop), coords.x, coords.y,coords.z, true, true, true)
	AttachEntityToEntity(moneyBag, player, GetPedBoneIndex(player, 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	TaskPlayAnim(player, "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
	FreezeEntityPosition(player, true)
	if Config.progressBars then 
		exports['progressBars']:startUI((cfg.rob.takeLootTimer * 1000), Lang['progbar_robbing'])
	end
	Citizen.Wait((cfg.rob.takeLootTimer * 1000))
	
	DeleteEntity(moneyBag)
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
	
	if cfg.rob.enableMoneyBag then
		SetPedComponentVariation(player, 5, 45, 0, 2)
	end
	
	TriggerServerEvent('t1ger_truckrobbery:jobReward')
	Citizen.Wait(1000)
	StopTheJob = true
end

-- Function to create job vehicle:
function CreateArmoredTruck(model, pos)
	LoadModel(model)
    local vehicle = CreateVehicle(model, pos[1], pos[2], pos[3], 52.0, true, false)
	NetworkRegisterEntityAsNetworked(vehicle)
	SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(vehicle), true)
	SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(vehicle), true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
    SetVehicleIsStolen(vehicle, false)
    SetVehicleIsWanted(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleFuelLevel(vehicle, 80.0)
    DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	SetVehicleOnGroundProperly(vehicle)
    return vehicle
end

-- Sync Config Data:
RegisterNetEvent('t1ger_truckrobbery:SyncDataCL')
AddEventHandler('t1ger_truckrobbery:SyncDataCL',function(data)
    Config.TruckSpawns = data
end)
AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	StopTheJob = true
end)
