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

-- Job Config Data:
RegisterNetEvent('t1ger_goldcurrency:updateConfigCL')
AddEventHandler('t1ger_goldcurrency:updateConfigCL',function(data)
    Config.GoldJobs = data
end)

local NPC = nil
local NPC_blip = nil
RegisterNetEvent('t1ger_goldcurrency:createNPC')
AddEventHandler('t1ger_goldcurrency:createNPC', function(data)
    if NPC ~= nil then
        DeleteEntity(NPC)
        Citizen.Wait(200)
        CreateJobNPC(data)
    else
        CreateJobNPC(data)
    end
end)

-- NPC Mission Thread:
local interacting = false
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(3)
		local sleep = true 
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, Config.JobNPC.pos[1], Config.JobNPC.pos[2], Config.JobNPC.pos[3], false)
		if distance <= 1.5 and not interacting then
			sleep = false
			DrawText3Ds(Config.JobNPC.pos[1], Config.JobNPC.pos[2], Config.JobNPC.pos[3], Config.JobNPC.drawText)
			if IsControlJustPressed(0, Config.JobNPC.keybind) then
				interacting = true
				RequestJobFromNPC()
			end
		end
		if sleep then Citizen.Wait(1500) end	
	end
end)

-- Get Job From NPC:
function RequestJobFromNPC()
	-- Check Cooldown:
	ESX.TriggerServerCallback('t1ger_goldcurrency:getJobCooldown', function(cooldown) 
		if not cooldown then
			-- Load Animation:
			local anim = {dict = 'missheistdockssetup1ig_5@base', lib = 'workers_talking_base_dockworker1'}
			LoadAnim(anim.dict)
			-- Play Anim & Progbar
			FreezeEntityPosition(player, true)
			TaskPlayAnim(player, anim.dict, anim.lib, 3.0, 0.5, -1, 31, 1.0, 0, 0)
			if Config.ProgressBars then 
				exports['progressBars']:startUI((Config.JobNPC.talkSeconds * 1000), Lang['pb_talking'])
			end
			Citizen.Wait((Config.JobNPC.talkSeconds * 1000))
			-- Clean Up:
			FreezeEntityPosition(player, false)
			ClearPedTasks(player)
			-- Check Job Fees:
			ESX.TriggerServerCallback('t1ger_goldcurrency:getJobFees', function(hasMoney) 
				if hasMoney then
					ESX.TriggerServerCallback('t1ger_goldcurrency:checkCops', function(copsOnline) 
						if copsOnline then
							GetAvailableGoldJob(Config.JobNPC.jobFees)
						else
							ShowNotifyESX(Lang['not_enough_cops'])
						end
					end)
				else
					ShowNotifyESX(Lang['not_enough_money'])
				end
			end, Config.JobNPC.jobFees)
		else
			interacting = false
		end
	end)
end

-- Get Available Gold Job
function GetAvailableGoldJob(fees)
	local id = math.random(1, #Config.GoldJobs)
    local i = 0
    while Config.GoldJobs[id].inUse and i < 100 do
        i = i + 1
        id = math.random(1, #Config.GoldJobs)
    end
    if i == 100 then
        ShowNotifyESX(Lang['no_jobs_available'])
    else
        Config.GoldJobs[id].inUse = true
		TriggerServerEvent('t1ger_goldcurrency:updateConfigSV', Config.GoldJobs)
		local ran_veh = math.random(1, #Config.JobVehicles)
		local veh_model = Config.JobVehicles[ran_veh]
		TriggerServerEvent('t1ger_goldcurrency:prepareJobSV', id, fees, veh_model)
    end
	interacting = false
end

-- Event for Gold Job:
local job_veh = nil
local job_goons = {}
local veh_lockpicked = false
local job_end = false
RegisterNetEvent('t1ger_goldcurrency:startTheGoldJob')
AddEventHandler('t1ger_goldcurrency:startTheGoldJob', function(id, veh_model)
	if Config.UsePhoneMSG then JobNotifyMSG(Lang['go_to_the_location']) else ShowNotifyESX(Lang['go_to_the_location']) end
	local cfg = Config.GoldJobs[id]
	local job_complete = false
	local veh_spawned, goons_spawned, job_player, delivery_created, delivery, veh_delivered = false, false, false, false, nil, false
	-- Create Job Blip:
	local blip = CreateJobBlip(cfg)
	while not job_complete do
		Citizen.Wait(1)
		local sleep = true
		if cfg.inUse then
			-- distance check:
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.pos[1], cfg.pos[2], cfg.pos[3], false)
			if distance < 150.0 then
				sleep = false
				-- Spawn Job Vehicle:
				if distance < 100.0 and not veh_spawned then
					ClearAreaOfVehicles(cfg.pos[1], cfg.pos[2], cfg.pos[3], 10.0, false, false, false, false, false)
					job_veh = CreateJobVehicle(veh_model, cfg.pos)
					veh_spawned = true
				end
				-- Spawn Goons:
				if distance < 100.0 and not goons_spawned then
					ClearAreaOfPeds(cfg.pos[1], cfg.pos[2], cfg.pos[3], 10.0, 1)
					SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
					AddRelationshipGroup('JobNPCs')
					for i = 1, #cfg.goons do
						job_goons[i] = CreateJobPed(cfg.goons[i])
					end
					goons_spawned = true
				end
				-- Activate NPC's:
				if distance < 60.0 and goons_spawned and not job_player then
					SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
					AddRelationshipGroup('JobNPCs')
					for i = 1, #job_goons do 
						ClearPedTasksImmediately(job_goons[i])
						TaskCombatPed(job_goons[i], player, 0, 16)
						SetPedFleeAttributes(job_goons[i], 0, false)
						SetPedCombatAttributes(job_goons[i], 5, true)
						SetPedCombatAttributes(job_goons[i], 16, true)
						SetPedCombatAttributes(job_goons[i], 46, true)
						SetPedCombatAttributes(job_goons[i], 26, true)
						SetPedSeeingRange(job_goons[i], 75.0)
						SetPedHearingRange(job_goons[i], 50.0)
						SetPedEnableWeaponBlocking(job_goons[i], true)
					end
					SetRelationshipBetweenGroups(0, GetHashKey("JobNPCs"), GetHashKey("JobNPCs"))
					SetRelationshipBetweenGroups(5, GetHashKey("JobNPCs"), GetHashKey("PLAYER"))
					SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("JobNPCs"))
					job_player = true
				end
				-- Lockpick Vehicle:
				local veh_pos = GetEntityCoords(job_veh) 
				local veh_dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, veh_pos.x, veh_pos.y, veh_pos.z, false)
				if veh_dist < 2.5 and not veh_lockpicked then
					DrawText3Ds(veh_pos.x, veh_pos.y, veh_pos.z, Lang['press_to_lockpick'])
					if IsControlJustPressed(0, 47) then 
						LockpickJobVehicle()
					end
				end
				-- Create Delivery Blip & Route:
				if veh_lockpicked and not delivery_created then
					if GetEntityModel(GetVehiclePedIsIn(player, false)) == GetHashKey(veh_model) then
						if DoesBlipExist(blip) then RemoveBlip(blip) end 
						if Config.UsePhoneMSG then JobNotifyMSG(Lang['deliver_veh_msg']) else ShowNotifyESX(Lang['deliver_veh_msg']) end
						if DoesBlipExist(blip) then RemoveBlip(blip) end
						delivery = Config.Delivery
						blip = AddBlipForCoord(delivery.pos[1], delivery.pos[2], delivery.pos[3])
						SetBlipSprite(blip, delivery.blip.sprite)
						SetBlipColour(blip, delivery.blip.color)
						SetBlipRoute(blip, delivery.blip.route)
						SetBlipRouteColour(blip, delivery.blip.color)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(delivery.blip.label)
						EndTextCommandSetBlipName(blip)
						delivery_created = true
					end
				end
			end
			-- distance check for drugs delivery pos
			if delivery_created then 
				local delivery_dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, delivery.pos[1], delivery.pos[2], delivery.pos[3], false)
				if delivery_dist < 75.0 then
					sleep = false 
					-- Delivery spot & marker:
					if not veh_delivered then
						local mk = delivery.marker
						if delivery_dist < mk.drawDist then
							if DoesEntityExist(job_veh) then
								if GetEntityModel(GetVehiclePedIsIn(player, false)) == GetHashKey(veh_model) then
									DrawMarker(mk.type, delivery.pos[1], delivery.pos[2], delivery.pos[3]-0.97, 0, 0, 0, 180.0, 0, 0, mk.scale.x, mk.scale.y, mk.scale.z,mk.color.r,mk.color.g,mk.color.b,mk.color.a, false, true, 2, false, false, false, false)
									if delivery_dist < 2.0 then
										DrawText3Ds(delivery.pos[1], delivery.pos[2], delivery.pos[3], Lang['press_to_deliver'])
										if IsControlJustPressed(0, 38) then
											if DoesBlipExist(blip) then RemoveBlip(blip) end
											SetVehicleForwardSpeed(job_veh, 0)
											SetVehicleEngineOn(job_veh, false, false, true)
											if IsPedInAnyVehicle(player, true) then
												TaskLeaveVehicle(player, job_veh, 4160)
												SetVehicleDoorsLockedForAllPlayers(job_veh, true)
											end
											Citizen.Wait(700)
											FreezeEntityPosition(job_veh, true)
											veh_delivered = true
										end
									end
								end
							end
						end
					end 
					-- Reward & Reset:
					if veh_delivered then 
						TriggerServerEvent('t1ger_goldcurrency:giveJobReward')
						job_end = true
					end
				end
			end
			-- End Job if these are true:
			if veh_spawned then
				if not DoesEntityExist(job_veh) then
					job_end = true
					if Config.UsePhoneMSG then JobNotifyMSG(Lang['veh_is_taken']) else ShowNotifyESX(Lang['veh_is_taken']) end
				end
			end
			if veh_lockpicked and DoesEntityExist(job_veh) then
				local veh_pos = GetEntityCoords(job_veh)
				if GetDistanceBetweenCoords(coords, veh_pos.x, veh_pos.y, veh_pos.z, false) > 50.0 then 
					job_end = true
					if Config.UsePhoneMSG then JobNotifyMSG(Lang['too_far_from_veh']) else ShowNotifyESX(Lang['too_far_from_veh']) end	
				end
			end
			if job_end then
				-- reset config data:
				Config.GoldJobs[id].inUse = false
				TriggerServerEvent('t1ger_goldcurrency:updateConfigSV', Config.GoldJobs)
				Citizen.Wait(500)
				-- Delete Job Vehicle:
				DeleteVehicle(job_veh)
				job_veh = nil
				-- blip:
				if DoesBlipExist(blip) then RemoveBlip(blip) end 
				-- goons:
				local i = 0
                for k,v in pairs(Config.GoldJobs[id].goons) do
                    if DoesEntityExist(job_goons[i]) then
                        DeleteEntity(job_goons[i])
                    end
                    i = i +1
				end
				job_goons = {}
				veh_lockpicked = false
				job_complete = true
				job_end = false
				break
			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- Lockpick Job Vehicle:
function LockpickJobVehicle()
	-- Police Alert:
	if Config.PoliceSettings.enableAlert then AlertPoliceFunction() end
	-- Player Animation
	local anim = {dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', lib = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'}
	LoadAnim(anim.dict)	
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(250)
	FreezeEntityPosition(player, true)
	TaskPlayAnim(player, anim.dict, anim.lib, 3.0, -8, -1, 63, 0, 0, 0, 0 )
	-- progbar:
	if Config.ProgressBars then
		exports['progressBars']:startUI(7500, Lang['pb_lockpicking'])
	end
	Citizen.Wait(7500)
	-- cleanup:
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
	veh_lockpicked = true
	SetVehicleDoorsLockedForAllPlayers(job_veh, false)
	ShowNotifyESX(Lang['vehicle_lockpicked'])
end

-- Function to create job vehicle:
function CreateJobVehicle(model, pos)
	LoadModel(model)
    local vehicle = CreateVehicle(model, pos[1], pos[2], pos[3], pos[4], true, false)
	NetworkRegisterEntityAsNetworked(vehicle)
	SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(vehicle), true)
	SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(vehicle), true)
    SetVehicleNeedsToBeHotwired(vehicle, true)
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

-- Function to create job ped(s):
function CreateJobPed(goon)
	LoadModel(goon.ped)
	local goonNPC = CreatePed(4, GetHashKey(goon.ped), goon.pos[1], goon.pos[2], goon.pos[3], goon.pos[4], false, true)
	NetworkRegisterEntityAsNetworked(goonNPC)
	SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(goonNPC), true)
	SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(goonNPC), true)
	SetPedCanSwitchWeapon(goonNPC, true)
	SetEntityInvincible(goonNPC, false)
	SetEntityVisible(goonNPC, true)
	SetEntityAsMissionEntity(goonNPC)
	LoadAnim(goon.anim.dict)
	TaskPlayAnim(goonNPC, goon.anim.dict, goon.anim.lib, 8.0, -8, -1, 49, 0, 0, 0, 0)
	GiveWeaponToPed(goonNPC, GetHashKey(goon.weapon), 255, false, false)
	SetPedDropsWeaponsWhenDead(goonNPC, false)
	SetPedCombatAttributes(goonNPC, false)
	SetPedFleeAttributes(goonNPC, 0, false)
	SetPedEnableWeaponBlocking(goonNPC, true)
	SetPedRelationshipGroupHash(goonNPC, GetHashKey("JobNPCs"))	
	TaskGuardCurrentPosition(goonNPC, 15.0, 15.0, 1)
	return goonNPC
end

function CreateJobBlip(cfg)
	local blip = AddBlipForCoord(cfg.pos[1], cfg.pos[2], cfg.pos[3])
	SetBlipSprite(blip, 1)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', 'Gold Job')
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.8) -- set scale
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 5)
	return blip
end


-- Create Job NPC:
function CreateJobNPC(data)
	LoadModel(data.ped)
	NPC = CreatePed(7, GetHashKey(data.ped), data.pos[1], data.pos[2], data.pos[3]-0.97, data.pos[4], 0, true, true)
	FreezeEntityPosition(NPC, true)
	SetBlockingOfNonTemporaryEvents(NPC, true)
	TaskStartScenarioInPlace(NPC, data.scenario, 0, false)
	SetEntityInvincible(NPC, true)
	SetEntityAsMissionEntity(NPC, true)
	-- Create Blip
	CreateBlipForNPC(NPC, data.blip)
end

-- Create NPC Blip:
function CreateBlipForNPC(entity, blip)
	if DoesBlipExist(NPC_blip) then 
		RemoveBlip(NPC_blip)
	end
	local pos = GetEntityCoords(entity)
	if blip.enable then
		Citizen.CreateThread(function()
			NPC_blip = AddBlipForCoord(pos[1], pos[2], pos[3])
			SetBlipSprite (NPC_blip, blip.sprite)
			SetBlipDisplay(NPC_blip, 4)
			SetBlipScale  (NPC_blip, blip.scale)
			SetBlipColour (NPC_blip, blip.color)
			SetBlipAsShortRange(NPC_blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(blip.str)
			EndTextCommandSetBlipName(NPC_blip)
		end)
	end
end

AddEventHandler('esx:onPlayerDeath', function(data)
	job_end = true
	Citizen.Wait(5000)
	job_end = false
end)

RegisterCommand('gold_cancel', function(source, args)
	job_end = true
	ShowNotifyESX(Lang['cancel_job'])
end, false)

-- ## [[ SMELTERY SECTION ]] ## --

-- Gold Smelting Thread:
local plySmelting = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Smeltery) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			local mk = v.marker
			if distance <= mk.drawDist and not plySmelting then
				sleep = false 
				if distance >= 1.50 and mk.enable then 
					DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3] - 0.975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
				elseif distance < 1.50 then
					DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], v.drawText)
					if IsControlJustPressed(0, v.keybind) then
						plySmelting = true
						OpenSmeltingFunction(k,v)
					end
				end
			end
		end
		if sleep then Citizen.Wait(1500) end
    end
end)

-- Function to smelt gold:
function OpenSmeltingFunction(id,val)
	ESX.TriggerServerCallback('t1ger_goldcurrency:removeItem', function(itemRemoved)
		-- prepare for melting:
		FreezeEntityPosition(player, true)
		SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'))
		Citizen.Wait(200)
		-- remove items:
		if itemRemoved then
			if Config.ProgressBars then
				exports['progressBars']:startUI(((Config.SmelterySettings.time * 1000)), Lang['pb_smelting'])
			end
			TaskStartScenarioInPlace(player, "PROP_HUMAN_BUM_BIN", 0, true)
			Citizen.Wait((Config.SmelterySettings.time * 1000))
			-- Reward:
			local amount = Config.SmelterySettings.output
			ESX.TriggerServerCallback('t1ger_goldcurrency:addItem', function(itemAdded) 
				if not itemAdded then
					TriggerServerEvent('t1ger_goldcurrency:giveItem', Config.DatabaseItems['goldwatch'], Config.SmelterySettings.input)
				end
			end, Config.DatabaseItems['goldbar'], amount)
		else
			ShowNotifyESX(Lang['not_enough_watches'])
		end
		-- Clean Up:
		ClearPedTasks(player)
		FreezeEntityPosition(player, false)
		plySmelting = false
	end, Config.DatabaseItems['goldwatch'], Config.SmelterySettings.input)
end

-- Create Smeltery Blip:
Citizen.CreateThread(function()
	for k,v in pairs(Config.Smeltery) do
		local bp = v.blip
		if bp.enable then
			local blip = AddBlipForCoord(v.pos[1], v.pos[2], v.pos[3])
			SetBlipSprite(blip, bp.sprite)
			SetBlipDisplay(blip, bp.display)
			SetBlipScale  (blip, bp.scale)
			SetBlipColour (blip, bp.color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(bp.str)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- ## [[ EXCHANGE SECTION ]] ## --

-- Gold Exchange Thread:
local plyExchanging = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Exchange) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			local mk = v.marker
			if distance <= mk.drawDist and not plyExchanging then
				sleep = false 
				if distance >= 1.0 and mk.enable then 
					DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3] - 0.975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
				elseif distance < 1.0 then
					DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], v.drawText)
					if IsControlJustPressed(0, v.keybind) then
						plyExchanging = true
						OpenGoldExchangeFunction(k,v)
					end
				end
			end
		end
		if sleep then Citizen.Wait(1500) end
    end
end)

-- Function to exchange gold:
function OpenGoldExchangeFunction(id,val)
	ESX.TriggerServerCallback('t1ger_goldcurrency:getExchangeCooldown', function(cooldown) 
		if not cooldown then
			ESX.TriggerServerCallback('t1ger_goldcurrency:removeItem', function(itemRemoved)
				-- prepare for exchange:
				FreezeEntityPosition(player, true)
				SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'))
				Citizen.Wait(200)
				-- remove items:
				if itemRemoved then
					if Config.ProgressBars then
						exports['progressBars']:startUI(((Config.ExchangeSettings.time * 1000)), Lang['pb_exchanging'])
					end
					Citizen.Wait((Config.ExchangeSettings.time * 1000))
					-- Reward:
					local amount = Config.ExchangeSettings.money.amount
					TriggerServerEvent('t1ger_goldcurrency:giveExchangeReward', amount, Config.ExchangeSettings.money.dirty)
					TriggerServerEvent('t1ger_goldcurrency:addExchangeCooldown')
				else
					ShowNotifyESX(Lang['not_enough_goldbar'])
				end
				-- Clean Up:
				ClearPedTasks(player)
				FreezeEntityPosition(player, false)
				plyExchanging = false
			end, Config.DatabaseItems['goldbar'], Config.ExchangeSettings.input)
		else
			plyExchanging = false
		end
	end)
end

-- Create Smeltery Blip:
Citizen.CreateThread(function()
	for k,v in pairs(Config.Exchange) do
		local bp = v.blip
		if bp.enable then
			local blip = AddBlipForCoord(v.pos[1], v.pos[2], v.pos[3])
			SetBlipSprite(blip, bp.sprite)
			SetBlipDisplay(blip, bp.display)
			SetBlipScale  (blip, bp.scale)
			SetBlipColour (blip, bp.color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(bp.str)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

