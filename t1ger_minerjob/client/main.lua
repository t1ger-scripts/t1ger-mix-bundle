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

local plyMining = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Mining) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			local mk = v.marker
			if distance <= mk.drawDist and not plyMining and not v.inUse then
				sleep = false 
				if distance >= 1.0 and mk.enable then 
					DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3] - 0.975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
				elseif distance < 1.0 then
					DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], v.drawText)
					if IsControlJustPressed(0, v.keybind) then
						plyMining = true
						OpenMiningFunction(k,v)
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
    end
end)

-- Mining Function:
function OpenMiningFunction(id,val)
	ESX.TriggerServerCallback('t1ger_minerjob:getInventoryItem', function(hasItem) 
		if hasItem then
			-- update spot state:
			TriggerServerEvent('t1ger_minerjob:mineSpotStateSV', id, true)

			-- prepare for mining:
			FreezeEntityPosition(player, true)
			SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'))
			Citizen.Wait(200)

			-- Load pickaxe:
			local pickaxeObj = GetHashKey('prop_tool_pickaxe')
			LoadModel(pickaxeObj)

			-- Load animation:
			local anim = {dict = 'melee@hatchet@streamed_core_fps', lib = 'plyr_front_takedown'}
			LoadAnim(anim.dict)

			-- Create obj and attach to player:
			local object = CreateObject(pickaxeObj, coords.x, coords.y, coords.z, true, false, false)
			AttachEntityToEntity(object, player, GetPedBoneIndex(player, 57005), 0.1, 0.0, 0.0, -90.0, 25.0, 35.0, true, true, false, true, 1, true)

			if Config.ProgressBars then
				exports['progressBars']:startUI((10000), Lang['pb_mining'])
			end

			-- Play Animation:
			for i = 1, 5, 1 do
				TaskPlayAnim(PlayerPedId(), anim.dict, anim.lib, 3.0, -3.0, -1, 31, 0, false, false, false)
				Citizen.Wait(2000)
			end

			-- Reward:
			local amount = math.random(Config.MiningReward.min, Config.MiningReward.max)
			TriggerServerEvent('t1ger_minerjob:miningReward', Config.DatabaseItems['stone'], amount)

			-- Update State:
			TriggerServerEvent('t1ger_minerjob:mineSpotStateSV', id, false)

			-- Clean Up:
			ClearPedTasks(player)
			FreezeEntityPosition(player, false)
			DeleteObject(object)
			plyMining = false
		else
			ShowNotifyESX(Lang['no_pickaxe'])
			plyMining = false
		end
	end, Config.DatabaseItems['pickaxe'], 1)
end

-- Create Mining Blips:
Citizen.CreateThread(function()
	for k,v in pairs(Config.Mining) do
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

-- Mining Spot State:
RegisterNetEvent('t1ger_minerjob:mineSpotStateCL')
AddEventHandler('t1ger_minerjob:mineSpotStateCL', function(id, state)
	Config.Mining[id].inUse = state
end)

local plyWashing = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Washing) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			local mk = v.marker
			if distance <= mk.drawDist and not plyWashing then
				sleep = false 
				if distance >= 1.25 and mk.enable then 
					DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3] - 0.975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
				elseif distance < 1.25 then
					DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], v.drawText)
					if IsControlJustPressed(0, v.keybind) then
						plyWashing = true
						OpenWashingFunction(k,v)
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
    end
end)

-- Function to wash stone:
function OpenWashingFunction(id,val)
	ESX.TriggerServerCallback('t1ger_minerjob:getInventoryItem', function(hasItem) 
		if hasItem then
			ESX.TriggerServerCallback('t1ger_minerjob:removeItem', function(itemRemoved)

				-- prepare for washing:
				FreezeEntityPosition(player, true)
				SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'))
				Citizen.Wait(200)

				if itemRemoved then
					if Config.ProgressBars then
						exports['progressBars']:startUI((10000), Lang['pb_washing'])
					end
					TaskStartScenarioInPlace(player, "PROP_HUMAN_BUM_BIN", 0, true)
					Citizen.Wait(10000)
					-- Reward:
					local amount = math.random(Config.WashSettings.output.min, Config.WashSettings.output.max)
					TriggerServerEvent('t1ger_minerjob:washingReward', Config.DatabaseItems['washed_stone'], amount)
				else
					ShowNotifyESX(Lang['not_enough_stone'])
				end

				-- Clean Up:
				ClearPedTasks(player)
				FreezeEntityPosition(player, false)
				plyWashing = false

			end, Config.DatabaseItems['stone'], Config.WashSettings.input)
		else
			ShowNotifyESX(Lang['no_washpan'])
			plyWashing = false
		end
	end, Config.DatabaseItems['washpan'], 1)
end

-- Create Washing Blips:
Citizen.CreateThread(function()
	for k,v in pairs(Config.Washing) do
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

local plySmelting = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true
		for k,v in pairs(Config.Smelting) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			local mk = v.marker
			if distance <= mk.drawDist and not plySmelting then
				sleep = false 
				if distance >= 1.25 and mk.enable then 
					DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3] - 0.975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
				elseif distance < 1.25 then
					DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], v.drawText)
					if IsControlJustPressed(0, v.keybind) then
						plySmelting = true
						OpenSmeltingFunction(k,v)
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
    end
end)

-- Function to smelth wash stone:
function OpenSmeltingFunction(id,val)
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer == -1 or closestDistance >= 0.7 then

		ESX.TriggerServerCallback('t1ger_minerjob:removeItem', function(itemRemoved)
			-- prepare for smelting:
			FreezeEntityPosition(player, true)
			SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'))
			Citizen.Wait(200)
			if itemRemoved then
				if Config.ProgressBars then exports['progressBars']:startUI((10000), Lang['pb_smelting']) end
				Citizen.Wait(10000)
				-- Reward:
				TriggerServerEvent('t1ger_minerjob:smeltingReward')
			else
				ShowNotifyESX(Lang['not_enough_washed_stone'])
			end
			-- Clean Up:
			ClearPedTasks(player)
			FreezeEntityPosition(player, false)
			plySmelting = false
		end, Config.DatabaseItems['washed_stone'], Config.SmeltingSettings.input)

	else
		ShowNotifyESX(Lang['player_too_close'])
		plySmelting = false
	end	
end

-- Create Smelting Blips:
Citizen.CreateThread(function()
	for k,v in pairs(Config.Smelting) do
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
