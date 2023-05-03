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

-- Config Data:
RegisterNetEvent('t1ger_yachtheist:updateConfigCL')
AddEventHandler('t1ger_yachtheist:updateConfigCL',function(data)
    Config.Yacht = data
end)

-- ## YACHT ## --
local interacting = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(3)
		local sleep = true 
		local cfg = Config.Yacht
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.terminal.pos[1], cfg.terminal.pos[2], cfg.terminal.pos[3], false)
		if distance <= 3.0 and not interacting and not isCop then
			sleep = false
			if distance <= 1.0 then 
				DrawText3Ds(cfg.terminal.pos[1], cfg.terminal.pos[2], cfg.terminal.pos[3] + 0.2, Lang['yacht_heist_interact'])
				if IsControlJustPressed(0, 38) then
					interacting = true
					if not cfg.cooldown then
						if not cfg.terminal.activated then
							ESX.TriggerServerCallback('t1ger_yachtheist:checkPolice', function(canStart) 
								if canStart then 
									Config.Yacht.terminal.activated = true
									TriggerServerEvent('t1ger_yachtheist:updateConfigSV', Config.Yacht)
									if Config.ProgressBars then
										exports['progressBars']:startUI(1000, Lang['pb_starting'])
									end
									Citizen.Wait(1000)
									PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
									PrepareYachtHeist()
								else
									ShowNotifyESX(Lang['not_enough_cops'])
								end
							end)
						else
							ShowNotifyESX(Lang['yacht_activated'])
						end
					else
						ShowNotifyESX(Lang['yacht_cooldown'])
					end
					interacting = false
				end
			end
		end
		if sleep then Citizen.Wait(1500) end 
	end
end)

-- Prepare The Yacht Heist:
local trolley_obj = nil
local emptyTrolley_obj = nil
function PrepareYachtHeist()
	local cfg = Config.Yacht
	-- Spawn Trolley:
	local trolley = GetHashKey('hei_prop_hei_cash_trolly_01')
	LoadModel(trolley)
	local objCache = GetClosestObjectOfType(cfg.trolley.pos[1], cfg.trolley.pos[2], cfg.trolley.pos[3], 2.0, trolley, false, false, false)
	if objCache ~= 0 then 
		SetEntityAsMissionEntity(objCache)
		TriggerServerEvent('t1ger_yachtheist:forceDeleteSV', ObjToNet(objCache))
	end
	Wait(200)
	local object = CreateObject(trolley, cfg.trolley.pos[1], cfg.trolley.pos[2], cfg.trolley.pos[3], true)
	SetEntityRotation(object, 0.0, 0.0, cfg.trolley.pos[4]+180.0)
	PlaceObjectOnGroundProperly(object)
	SetEntityAsMissionEntity(object, true, true)
	trolley_obj = ObjToNet(object)
	SetModelAsNoLongerNeeded(trolley)
	-- Trigger Heist Event:
	TriggerEvent('t1ger_yachtheist:goonsHandler')
end

RegisterNetEvent('t1ger_yachtheist:forceDeleteCL')
AddEventHandler('t1ger_yachtheist:forceDeleteCL', function(objNet)
	if NetworkHasControlOfNetworkId(objNet) then
		DeleteObject(NetToObj(objNet))
	end
end)

-- Control Vault Door:
local vault_door = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
		local sleep = true 
		local cfg = Config.Yacht
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.vault.pos[1], cfg.vault.pos[2], cfg.vault.pos[3], false)
		if distance < 15.0 then
			sleep = false
			if vault_door and DoesEntityExist(vault_door) then
				if not cfg.keypad.hacked then FreezeEntityPosition(vault_door, true) else FreezeEntityPosition(vault_door, false) end
			else
				vault_door = GetClosestObjectOfType(cfg.vault.pos[1], cfg.vault.pos[2], cfg.vault.pos[3], 1.5, cfg.vault.model, false, false, false)
			end
		end
		if sleep then Citizen.Wait(1500) end 
    end
end)

-- Event to handle goons
local goons, goons_spawned, heist_ply = {}, false, false
RegisterNetEvent('t1ger_yachtheist:goonsHandler')
AddEventHandler('t1ger_yachtheist:goonsHandler', function()
	ShowNotifyESX(Lang['find_vault_room'])
	local cfg = Config.Yacht
	while true do
		Citizen.Wait(1)
		local sleep = true
		if Config.Yacht.terminal.activated then 
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.keypad.pos[1], cfg.keypad.pos[2], cfg.keypad.pos[3], false)
			if distance < 100.0 then 
				sleep = false
				if distance < 80.0 and not goons_spawned then
					ClearAreaOfPeds(cfg.keypad.pos[1], cfg.keypad.pos[2], cfg.keypad.pos[3], 10.0, 1)
					SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
					AddRelationshipGroup('JobNPCs')
					for i = 1, #cfg.goons do
						goons[i] = CreateJobPed(cfg.goons[i])
					end
					goons_spawned = true
				end
				-- Activate NPC's:
				if distance < 50.0 and goons_spawned and not heist_ply then
					SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
					AddRelationshipGroup('JobNPCs')
					for i = 1, #goons do 
						ClearPedTasksImmediately(goons[i])
						TaskCombatPed(goons[i], player, 0, 16)
						SetPedFleeAttributes(goons[i], 0, false)
						SetPedCombatAttributes(goons[i], 5, true)
						SetPedCombatAttributes(goons[i], 16, true)
						SetPedCombatAttributes(goons[i], 46, true)
						SetPedCombatAttributes(goons[i], 26, true)
						SetPedSeeingRange(goons[i], 75.0)
						SetPedHearingRange(goons[i], 50.0)
						SetPedEnableWeaponBlocking(goons[i], true)
					end
					SetRelationshipBetweenGroups(0, GetHashKey("JobNPCs"), GetHashKey("JobNPCs"))
					SetRelationshipBetweenGroups(5, GetHashKey("JobNPCs"), GetHashKey("PLAYER"))
					SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("JobNPCs"))
					heist_ply = true
				end
			end
		end
		if Config.Yacht.cooldown then
			break
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- Keypad Hacking
local hacking, securing = false, false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
		local sleep = true 
		local cfg = Config.Yacht
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.keypad.pos[1], cfg.keypad.pos[2], cfg.keypad.pos[3], false)
		if cfg.terminal.activated and distance < 5.0 and not hacking then
			sleep = false 
			if not cfg.keypad.hacked and not isCop then
				if distance <= 1.25 then
					DrawText3Ds(cfg.keypad.pos[1], cfg.keypad.pos[2], cfg.keypad.pos[3]+0.4, Lang['hack_keypad'])
					if IsControlJustPressed(0, 38) then
						hacking = true
						KeypadHackFunction(cfg)
					end
				end
			end
			if distance <= 1.25 and isCop and not securing then
				DrawText3Ds(cfg.keypad.pos[1], cfg.keypad.pos[2], cfg.keypad.pos[3]+0.3, Lang['secure_vault'])
				if IsControlJustPressed(0, 47) then
					securing = true
					SecureHeistFunction(cfg)
				end
			end
		end
		if sleep then Citizen.Wait(1500) end 
    end
end)

-- Function to Secure & Reset Heist:
function SecureHeistFunction(cfg)
	FreezeEntityPosition(player, true)
	if Config.ProgressBars then
		exports['progressBars']:startUI(1000, Lang['pb_securing'])
	end
	TriggerServerEvent('t1ger_yachtheist:resetHeistSV')
	Citizen.Wait(1000)
	TriggerServerEvent('t1ger_yachtheist:PoliceNotifySV', "secure")
	FreezeEntityPosition(player, false)
	-- Clean Up Trolley Obj:
	Citizen.Wait(1000)
	if NetworkDoesEntityExistWithNetworkId(trolley_obj) then
		local trollyObj_cache = NetToObj(trolley_obj)
		Citizen.Wait(250) 
		while not NetworkHasControlOfEntity(trollyObj_cache) do
			Citizen.Wait(10)
			NetworkRequestControlOfEntity(trollyObj_cache)
		end
		Citizen.Wait(250) 
		DeleteObject(trollyObj_cache)
	end 
	Citizen.Wait(1000) 
	if NetworkDoesEntityExistWithNetworkId(emptyTrolley_obj) then
		local emptyTrollyObj_cache = NetToObj(emptyTrolley_obj)
		Citizen.Wait(250) 
		while not NetworkHasControlOfEntity(emptyTrollyObj_cache) do
			Citizen.Wait(0)
			NetworkRequestControlOfEntity(emptyTrollyObj_cache)
		end
		Citizen.Wait(250) 
		DeleteObject(emptyTrollyObj_cache)
	end
end

-- Function to Hack the Keypad:
function KeypadHackFunction(cfg)
	ESX.TriggerServerCallback('t1ger_yachtheist:getItem', function(hasItem) 
		if hasItem then
			-- Play Animation:
			SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
			Citizen.Wait(200)
			FreezeEntityPosition(player, true)
			local anim = {dict = 'anim@heists@keypad@', lib = 'idle_a'}
			LoadAnim(anim.dict)
			if Config.ProgressBars then
				exports['progressBars']:startUI(8500, Lang['pb_hacking'])
			end
			TaskPlayAnim(player, anim.dict, anim.lib, 2.0, -2.0, -1, 1, 0, 0, 0, 0 )
			Citizen.Wait(3500)
			TaskStartScenarioInPlace(player, 'WORLD_HUMAN_STAND_MOBILE', -1, true)
			Citizen.Wait(5000)
			TriggerEvent("mhacking:show")
			TriggerEvent("mhacking:start", 7, 25, HackingCallback)
		else
			ShowNotifyESX(Lang['need_hacker_item'])
			hacking = false
		end
	end, Config.DatabaseItems['hackerDevice'], 1)
end

-- Hacking Callback
function HackingCallback(success)
	TriggerEvent('mhacking:hide')
	if success then 
		Config.Yacht.keypad.hacked = true
		PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
	else
		Config.Yacht.keypad.hacked = false
	end
	TriggerServerEvent('t1ger_yachtheist:updateConfigSV', Config.Yacht)
	TriggerServerEvent('t1ger_yachtheist:PoliceNotifySV', "alert")
	Citizen.Wait(1000)
	hacking = false
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
end

-- Trolley Thread:
local grabbing = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
		local sleep = true 
		local cfg = Config.Yacht
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.trolley.pos[1], cfg.trolley.pos[2], cfg.trolley.pos[3], true)
		if distance < 7.0 and cfg.keypad.hacked and not cfg.trolley.taken and not cfg.trolley.grabbing and not grabbing and not isCop then
			sleep = false 
			if NetworkDoesEntityExistWithNetworkId(trolley_obj) then
				if distance <= 1.0 then
					DrawText3Ds(cfg.trolley.pos[1], cfg.trolley.pos[2], cfg.trolley.pos[3], Lang['grab_cash'])
					if IsControlJustPressed(0,38) then
						Config.Yacht.trolley.grabbing = true
						TriggerServerEvent('t1ger_yachtheist:updateConfigSV', Config.Yacht)
						grabbing = true
						TrolleyGrabCash(cfg)
					end
				end
			end
		end
		if sleep then Citizen.Wait(1500) end 
    end
end)

-- Function to grab cash from Trolley:
local total_cash = 0
function TrolleyGrabCash(cfg) 

	-- local function within:
	local function GrabCashFromTrolley()
		local cash_prop = GetHashKey('hei_prop_heist_cash_pile')
		LoadModel(cash_prop)
		local cashPile = CreateObject(cash_prop, coords, true)
		FreezeEntityPosition(cashPile, true)
		SetEntityInvincible(cashPile, true)
		SetEntityNoCollisionEntity(cashPile, player)
		SetEntityVisible(cashPile, false, false)
		AttachEntityToEntity(cashPile, player, GetPedBoneIndex(player, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
		local takingCashTime = GetGameTimer()
		Citizen.CreateThread(function()
			while GetGameTimer() - takingCashTime < 37000 do
				Citizen.Wait(0)			
				if HasAnimEventFired(player, GetHashKey("CASH_APPEAR")) then
					if not IsEntityVisible(cashPile) then
						SetEntityVisible(cashPile, true, false)
					end
				end		
				if HasAnimEventFired(player, GetHashKey("RELEASE_CASH_DESTROY")) then
					if IsEntityVisible(cashPile) then
						SetEntityVisible(cashPile, false, false)
						ESX.TriggerServerCallback('t1ger_yachtheist:addGrabbedCash', function(amount)
							total_cash = total_cash + amount
						end)
					end
				end
			end
			DeleteObject(cashPile)
		end)
	end
	-- Check if someone is grabbing:
	if IsEntityPlayingAnim(obj_cache, 'anim@heists@ornate_bank@grab_cash', 'cart_cash_dissapear', 3) then
		return ShowNotifyESX(Lang['cash_arleady_grabbing'])
	end
	-- -- -- -- --
	local obj_cache = NetToObj(trolley_obj)
	-- Load Anim:
	local animDict = 'anim@heists@ornate_bank@grab_cash'
	LoadAnim(animDict)
	-- Request Control of Trolley Object:
	while not NetworkHasControlOfEntity(obj_cache) do
		Citizen.Wait(5)
		NetworkRequestControlOfEntity(obj_cache)
	end
	-- Create & Load Bag Object:
	local bag_prop = GetHashKey('hei_p_m_bag_var22_arm_s')
	LoadModel(bag_prop)
	local bag_obj = CreateObject(bag_prop, coords, true, false, false)
	SetPedComponentVariation(player, 5, 0, 0, 0)
	-- First Scene:
	local scene1 = NetworkCreateSynchronisedScene(GetEntityCoords(obj_cache), GetEntityRotation(obj_cache), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(player, scene1, animDict, "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag_obj, scene1, animDict, "bag_intro", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene1)
	Citizen.Wait(1500)
	GrabCashFromTrolley()
	-- Second Scene:
	local scene2 = NetworkCreateSynchronisedScene(GetEntityCoords(obj_cache), GetEntityRotation(obj_cache), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(player, scene2, animDict, "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag_obj, scene2, animDict, "bag_grab", 4.0, -8.0, 1)
	NetworkAddEntityToSynchronisedScene(obj_cache, scene2, animDict, "cart_cash_dissapear", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene2)
	Citizen.Wait(37000)
	-- Third scene:
	local scene3 = NetworkCreateSynchronisedScene(GetEntityCoords(obj_cache), GetEntityRotation(obj_cache), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(player, scene3, animDict, "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag_obj, scene3, animDict, "bag_exit", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene3)
	-- Load & Create Empty Trolley Prop
	local empty_trolleyProp = GetHashKey('hei_prop_hei_cash_trolly_03')
	LoadModel(empty_trolleyProp)
	local empty_trolleyObj = CreateObject(empty_trolleyProp, GetEntityCoords(obj_cache) + vector3(0.0, 0.0, - 0.985), true)
	SetEntityRotation(empty_trolleyObj, GetEntityRotation(obj_cache))
	while not NetworkHasControlOfEntity(obj_cache) do
		Citizen.Wait(5)
		NetworkRequestControlOfEntity(obj_cache)
	end
	DeleteObject(obj_cache)
	PlaceObjectOnGroundProperly(empty_trolleyObj)
	SetEntityAsMissionEntity(empty_trolleyObj, true, true)
	emptyTrolley_obj = ObjToNet(empty_trolleyObj)
	Citizen.Wait(1900) 
	DeleteObject(bag_obj)
	if Config.EnablePlayerMoneyBag then
		SetPedComponentVariation(player, 5, 45, 0, 2)
	end
	RemoveAnimDict(animDict)
	SetModelAsNoLongerNeeded(empty_trolleyProp)
	SetModelAsNoLongerNeeded(bag_prop)
	Citizen.Wait(2000)
	Config.Yacht.trolley.taken = true
	Config.Yacht.trolley.grabbing = false
	TriggerServerEvent('t1ger_yachtheist:updateConfigSV', Config.Yacht)
	Citizen.Wait(2000)
	grabbing = false
end

-- Thread for Draw Rects During Grabbing Cash:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local sleep = true 
		if Config.Yacht.trolley.grabbing and grabbing then
			sleep = false
			-- background bar:
			drawRct(0.91, 0.95, 0.1430, 0.035, 0, 0, 0, 80)
			-- text settings:
			SetTextScale(0.4, 0.4)
			SetTextFont(4)
			SetTextProportional(1)
			SetTextColour(255, 255, 255, 255)
			SetTextEdge(2, 0, 0, 0, 150)
			SetTextEntry("STRING")
			SetTextCentre(1)
			AddTextComponentString("TAKE:")
			DrawText(0.925,0.9535)
		end
		if sleep then Citizen.Wait(2000) end
	end
end)

-- Thread to display text during grabbing:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local sleep = true 
		if Config.Yacht.trolley.grabbing and grabbing then
			sleep = false
			SetTextScale(0.45, 0.45)
			SetTextFont(4)
			SetTextProportional(1)
			SetTextColour(255, 255, 255, 255)
			SetTextEdge(2, 0, 0, 0, 150)
			SetTextEntry("STRING")
			SetTextCentre(1)
			AddTextComponentString(comma_value("$"..total_cash..""))
			DrawText(0.97,0.9523)
		end
		if sleep then Citizen.Wait(2000) end
	end
end)

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

-- ## SAFES ## --
local safe_drilling = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(3)
		local sleep = true
		for k,v in pairs(Config.Safes) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], true)
			if distance < 5.0 then
				sleep = false
				if distance < 1.0 then
					local cfg = Config.Yacht
					if cfg.terminal.activated and cfg.keypad.hacked then
						if not v.robbed then
							if not v.failed then
								if not safe_drilling and not isCop then 
									DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['drill_close_safe'])
									if IsControlJustPressed(0, 38) then
										ESX.TriggerServerCallback('t1ger_yachtheist:removeItem', function(hasItem)
											if hasItem then DrillClosestSafe(k,v) else ShowNotifyESX(Lang['no_drill_item']) end
										end, Config.DatabaseItems['drill'], 1)
									end
								end
							else
								DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['safe_destroyed'])
							end
							if IsControlJustPressed(2, 178) then TriggerEvent("Drilling:Stop") end
						else
							DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['safe_drilled'])
						end
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- Function to Drill Closest Safe:
function DrillClosestSafe(id,val)
	local anim = {dict = "anim@heists@fleeca_bank@drilling", lib = "drill_straight_idle"}
	local closestPlayer, dist = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and dist <= 1.0 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), anim.dict, anim.lib, 3) then
            return ShowNotifyESX(Lang['safe_drilled_by_ply'])
		end
	end
	safe_drilling = true
	FreezeEntityPosition(player, true)
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(250)
	LoadAnim(anim.dict)
	local drill_prop = GetHashKey('hei_prop_heist_drill')
	local boneIndex = GetPedBoneIndex(player, 28422)
	LoadModel(drill_prop)
	SetEntityCoords(player, val.anim_pos[1], val.anim_pos[2], val.anim_pos[3]-0.95)
	SetEntityHeading(player, val.anim_pos[4])
	TaskPlayAnimAdvanced(player, anim.dict, anim.lib, val.anim_pos[1], val.anim_pos[2], val.anim_pos[3], 0.0, 0.0, val.anim_pos[4], 1.0, -1.0, -1, 2, 0, 0, 0 )
	local drill_obj = CreateObject(drill_prop, 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(drill_obj, player, boneIndex, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
	SetEntityAsMissionEntity(drill_obj, true, true)
	RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
	local drill_sound = GetSoundId()
	Citizen.Wait(100)
	PlaySoundFromEntity(drill_sound, "Drill", drill_obj, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
	Citizen.Wait(100)
	local particle_dict = "scr_fbi5a"
	local particle_lib = "scr_bio_grille_cutting"
	RequestNamedPtfxAsset(particle_dict)
	while not HasNamedPtfxAssetLoaded(particle_dict) do
		Citizen.Wait(0)
	end
	SetPtfxAssetNextCall(particle_dict)
	local effect = StartParticleFxLoopedOnEntity(particle_lib, drill_obj, 0.0, -0.6, 0.0, 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
	ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.0)
	Citizen.Wait(100)
	TriggerEvent("Drilling:Start",function(drill_status)		
		if drill_status == 1 then
			Config.Safes[id].robbed = true
			TriggerServerEvent('t1ger_yachtheist:SafeDataSV', "robbed", id, true)
			TriggerServerEvent('t1ger_yachtheist:vaultReward')
			safe_drilling = false
		elseif (drill_status == 3) then
			ShowNotifyESX(Lang['drilling_paused'])
			TriggerServerEvent('t1ger_yachtheist:giveItem', Config.DatabaseItems['drill'], 1)
			safe_drilling = false
		elseif (drill_status == 2) then
			Config.Safes[id].failed = true
			TriggerServerEvent("t1ger_yachtheist:SafeDataSV", "failed", id, true)
			ShowNotifyESX(Lang['you_destroyed_safe'])
			safe_drilling = false
		end
		ClearPedTasksImmediately(player)
		StopSound(drill_sound)
		ReleaseSoundId(drill_sound)
		DeleteObject(drill_obj)
		DeleteEntity(drill_obj)
		FreezeEntityPosition(player, false)
		StopParticleFxLooped(effect, 0)
		StopGameplayCamShaking(true)
	end)
end

-- Event to update safe state:
RegisterNetEvent('t1ger_yachtheist:SafeDataCL')
AddEventHandler('t1ger_yachtheist:SafeDataCL', function(type, id, state)
	if type == "robbed" then
		Config.Safes[id].robbed = state
	elseif type == "failed" then
		Config.Safes[id].failed = state
	end
end)

-- Yacht Blip:
Citizen.CreateThread(function()
	CreateYachtBlip(Config.Yacht)
end)

-- function to create map blip:
function CreateYachtBlip(data)
	local bp = data.blip
	if bp.enable then
		local blip = AddBlipForCoord(data.terminal.pos[1], data.terminal.pos[2], data.terminal.pos[3])
		SetBlipSprite (blip, bp.sprite)
		SetBlipDisplay(blip, bp.display)
		SetBlipScale  (blip, bp.scale)
		SetBlipColour (blip, bp.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(bp.str)
		EndTextCommandSetBlipName(blip)
	end
end

RegisterNetEvent('t1ger_yachtheist:resetHeistCL')
AddEventHandler('t1ger_yachtheist:resetHeistCL', function()
	-- Reset Config:
	Config.Yacht.terminal.activated = false
	Config.Yacht.keypad.hacked = false
	Config.Yacht.trolley.grabbing = false
	Config.Yacht.trolley.taken = false
	Config.Yacht.cooldown = true

	for i = 1, #Config.Safes do 
		Config.Safes[i].robbed = false
		Config.Safes[i].failed = false
	end

	Wait(300)

	-- reset locales:
	interacting = false
	trolley_obj = nil
	emptyTrolley_obj = nil
	vault_door = nil
	goons = {}
	goons_spawned = false
	heist_ply = false
	hacking = false
	securing = false
	grabbing = false
	total_cash = 0
	safe_drilling = false
end)
