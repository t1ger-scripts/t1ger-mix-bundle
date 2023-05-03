-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
player = nil
coords = {}
local curVehicle = nil 
local driver = nil

Citizen.CreateThread(function()
    while true do
		player = GetPlayerPed(-1)
		coords = GetEntityCoords(player)
        curVehicle = GetVehiclePedIsIn(player, false)
        driver = GetPedInVehicleSeat(curVehicle, -1)
        Citizen.Wait(500)
    end
end)

local scrap_list 	= {}
local job_NPC 		= nil
local shop_blip 	= nil
local gotCarList	= false
local scrap_NPC		= nil

-- Event to initialize chop shop:
RegisterNetEvent('t1ger_chopshop:intializeChopShop')
AddEventHandler('t1ger_chopshop:intializeChopShop', function(scrapList)
    scrap_list = scrapList
	-- Reset NPC:
    if job_NPC ~= nil then DeleteEntity(job_NPC); Citizen.Wait(250) end

	-- Create NPC:
	local cfg = Config.ChopShop.JobNPC
	LoadModel(cfg.model)
	job_NPC = CreatePed(7, GetHashKey(cfg.model), cfg.pos[1], cfg.pos[2], cfg.pos[3]-0.97, cfg.pos[4], 0, true, true)
	FreezeEntityPosition(job_NPC,true)
	SetBlockingOfNonTemporaryEvents(job_NPC, true)
	TaskStartScenarioInPlace(job_NPC, cfg.scenario, 0, false)
	SetEntityInvincible(job_NPC, true)
	SetEntityAsMissionEntity(job_NPC)

	-- Create Chop Shop Blip:
	local mk = Config.ChopShop.Blip
	if DoesBlipExist(shop_blip) then RemoveBlip(shop_blip) end
	if mk.enable then
		Citizen.CreateThread(function()
			shop_blip = AddBlipForCoord(cfg.pos[1], cfg.pos[2], cfg.pos[3])
			SetBlipSprite (shop_blip, mk.sprite)
			SetBlipDisplay(shop_blip, mk.display)
			SetBlipScale  (shop_blip, mk.scale)
			SetBlipColour (shop_blip, mk.color)
			SetBlipAsShortRange(shop_blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(mk.label)
			EndTextCommandSetBlipName(shop_blip)
		end)
	end

	gotCarList = false
end)

-- Thread to interact with Job NPC:
local interacting = false
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local sleep = true 
		if DoesEntityExist(job_NPC) then
			local NPC_coords = GetEntityCoords(job_NPC)
			local distance = GetDistanceBetweenCoords(coords, NPC_coords.x, NPC_coords.y, NPC_coords.z, false)
			if distance < 2.0 and not interacting then
				sleep = false 
				DrawText3Ds(NPC_coords.x, NPC_coords.y, NPC_coords.z, Lang['press_to_talk'])
				if IsControlJustPressed(0, Config.ChopShop.JobNPC.keybind) then
					ChopShopMainMenu()
				end
			end
			if distance > 2.0 and interacting then
				ESX.UI.Menu.CloseAll()
				interacting = false
			end
		end
		if sleep then Citizen.Wait(1000) end
	end	
end)

-- Function to talk with NPC:
function ChopShopMainMenu()
	interacting = true
	TalkWithNPC()
	local elements = {
		{label = Lang['menu_scrap_list'], value = 'scraplist'},
		{label = Lang['menu_thief_jobs'], value = 'thiefjob'}
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'chopshop_main_menu',
		{
			title    = 'Chop Shop',
			align    = 'center',
			elements = elements
		},
	function(data, menu)

		if not Config.ChopShop.Police.allowCops and isCop then
			ESX.UI.Menu.CloseAll()
			interacting = false
			return ShowNotifyESX(Lang['police_not_allowed'])
		end

		if data.current.value == 'scraplist' then
			menu.close()
			ESX.TriggerServerCallback('t1ger_chopshop:getCopsCount', function(cops) 
				if cops >= Config.ChopShop.Police.minCops then
					ESX.TriggerServerCallback('t1ger_chopshop:hasCooldown', function(cooldown)
						if not cooldown then 
							RetrieveCarList()
						end
					end, 'scrap')
				else
					ShowNotifyESX(Lang['not_enough_cops'])
				end
			end)

		elseif data.current.value == 'thiefjob' then
			ESX.TriggerServerCallback('t1ger_chopshop:hasCooldown', function(cooldown)
				if not cooldown then 
					CarThiefMainMenu()
				end
			end, 'thief')
		end

	end, function(data, menu)
		menu.close()
		interacting = false
	end)
end

-- Play Interaction Animation:
function TalkWithNPC()
	local cfg = Config.ChopShop.JobNPC
	LoadAnim(cfg.anim.dict)
	FreezeEntityPosition(player, true)
	TaskPlayAnim(player, cfg.anim.dict, cfg.anim.lib, 1.0, 0.5, -1, 31, 1.0, 0, 0)
	if Config.ProgressBars then 
		exports['progressBars']:startUI((cfg.anim.time), Lang['progbar_talking'])
	end
	Citizen.Wait(cfg.anim.time)
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
end

-- Function to Retrieve Car List:
function RetrieveCarList()
	local carNames = {}
	for k,v in pairs(scrap_list) do carNames[k] = v.label end
	local number = Config.ChopShop.JobNPC.name
	if not gotCarList then
		if Config.ChopShop.Settings.usePhoneMSG then
			JobNotifyMSG((Lang['get_these_cars_1']:format(table.concat(carNames, ", "))), number)
		else
			TriggerEvent('chat:addMessage', { args = {Lang['get_these_cars_2']:format(table.concat(carNames, ", "))}})
		end
		gotCarList = true	
	else
		if Config.ChopShop.Settings.usePhoneMSG then
			JobNotifyMSG((Lang['still_same_list_1']:format(table.concat(carNames, ", "))), number)
		else
			TriggerEvent('chat:addMessage', { args = {Lang['still_same_list_2']:format(table.concat(carNames, ", "))}})
		end
	end
	interacting = false
end

-- Function for car thief main menu:
function CarThiefMainMenu()
	local elements = {}
	for k,v in pairs(Config.RiskGrades) do
		if v.enable then
			local list_label = ('%s <span style="color:MediumSeaGreen;">[ $%s ]</span>'):format(v.label,v.job_fees)
			table.insert(elements, {label = list_label, name = v.label, value = v.grade, enable = v.enable, job_fees = v.job_fees, cops = v.cops, vehicles = v.vehicles})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'chopshop_select_risk_grade',
		{
			title    = 'Select Risk Grade',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		local selected = data.current
		TriggerServerEvent('t1ger_chopshop:selectRiskGrade', selected.name, selected.value, selected.job_fees, selected.cops, selected.vehicles)
		ESX.UI.Menu.CloseAll()
		interacting = false
	end, function(data, menu)
		menu.close()
	end)
end

-- Event to browse through available locations:
RegisterNetEvent('t1ger_chopshop:BrowseAvailableJobs')
AddEventHandler('t1ger_chopshop:BrowseAvailableJobs',function(spot, grade, car)
	local id = math.random(1,#Config.ThiefJobs)
	local currentID = spot
	while Config.ThiefJobs[id].inUse and currentID < 100 do
		currentID = currentID + 1
		id = math.random(1,#Config.ThiefJobs)
	end
	if currentID == 100 then
		ShowNotifyESX(Lang['no_jobs_available'])
	else
		CarThiefJob(id, grade, car)
	end	
end)

local job_veh = nil
local goons = {}
local veh_lockpicked = false
local thiefjob_done = false
local scrappingCar = false
local inspectingCar = false
local carInspected = false
local carScrapped = false
local end_thiefJob = false
local veh_health = 0

-- Event for the job:
function CarThiefJob(id, grade, car)
	local job = Config.ThiefJobs[id]
	-- send message:
	local number = Config.ChopShop.JobNPC.name
	if Config.ChopShop.Settings.usePhoneMSG then
		JobNotifyMSG((Lang['steal_the_car']:format(car.name)), number)
	else
		ShowNotifyESX((Lang['steal_the_car']):format(car.name))
	end
	-- update config state:
	job.inUse = true
	TriggerServerEvent('t1ger_chopshop:syncDataSV', Config.ThiefJobs)
	-- create job blip:
	local thief_blip = CreateThiefJobBlip(job)
	-- thread:
	end_thiefJob = false
	while true do
		Citizen.Wait(1)
		local sleep = true 
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, job.pos[1], job.pos[2], job.pos[3], false)
		if distance < 150.0 then
			sleep = false 
			-- Spawn Job Vehicle:
			if distance < 100.0 and not job.veh_spawned then
				ClearAreaOfVehicles(job.pos[1], job.pos[2], job.pos[3], 10.0, false, false, false, false, false)
				job_veh = CreateJobVehicle(car.hash, job.pos)
				job.veh_spawned = true
				TriggerServerEvent('t1ger_chopshop:syncDataSV', Config.ThiefJobs)
			end
			-- Spawn Goons:
			if grade == 2 or grade == 3 then
				if distance < 100.0 and not job.goons_spawned then
					ClearAreaOfPeds(job.pos[1], job.pos[2], job.pos[3], 10.0, 1)
					SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
					AddRelationshipGroup('JobNPCs')
					for i = 1, #job.goons do
						goons[i] = CreateJobPed(job.goons[i], grade)
					end
					job.goons_spawned = true
					TriggerServerEvent('t1ger_chopshop:syncDataSV', Config.ThiefJobs)
				end
			end
			-- Activate NPC's:
			if distance < 60.0 and job.goons_spawned and not job.player then
				SetPedRelationshipGroupHash(player, GetHashKey("PLAYER"))
				AddRelationshipGroup('JobNPCs')
				for i = 1, #goons do 
					ClearPedTasksImmediately(goons[i])
					TaskCombatPed(goons[i], player, 0, 16)
					if Config.ChopShop.Settings.thiefjob.headshot then SetPedSuffersCriticalHits(goons[i], true) else SetPedSuffersCriticalHits(goons[i], false) end
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
				job.player = true
				TriggerServerEvent('t1ger_chopshop:syncDataSV', Config.ThiefJobs)
			end
			-- Lockpick Vehicle:
			local veh_pos = GetEntityCoords(job_veh) 
			local veh_dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, veh_pos.x, veh_pos.y, veh_pos.z, false)
			if veh_dist < 2.5 and not veh_lockpicked then
				DrawText3Ds(veh_pos.x, veh_pos.y, veh_pos.z, Lang['veh_lockpick'])
				if IsControlJustPressed(0, 47) then 
					LockpickJobVehicle(job)
					DrawJobVehHealth(job_veh)
					if DoesBlipExist(thief_blip) then RemoveBlip(thief_blip) end
				end
			end
			if veh_lockpicked then
				sleep = true
			end
		end
		-- End Job if these are true:
		if job.veh_spawned then
			if not DoesEntityExist(job_veh) then
				if not scrappingCar then
					end_thiefJob = true
					if Config.ChopShop.Settings.usePhoneMSG then JobNotifyMSG((Lang['car_is_taken']), number) else ShowNotifyESX(Lang['car_is_taken']) end
				end
			end
		end
		if veh_lockpicked and DoesEntityExist(job_veh) then
			local veh_pos = GetEntityCoords(job_veh)
			if GetDistanceBetweenCoords(coords, veh_pos.x, veh_pos.y, veh_pos.z, false) > 50.0 then 
				end_thiefJob = true
				if Config.ChopShop.Settings.usePhoneMSG then JobNotifyMSG(Lang['too_far_from_veh'], number) else ShowNotifyESX(Lang['too_far_from_veh']) end	
			end
		end
		-- end job:
		if end_thiefJob then 
			if thiefjob_done then 
				TriggerServerEvent('t1ger_chopshop:JobCompleteSV', car.payout, veh_health)
				if Config.ChopShop.Settings.usePhoneMSG then JobNotifyMSG(Lang['job_complete'], number) else ShowNotifyESX(Lang['job_complete']) end
			end
			thiefjob_done = false
			-- reset config data:
			Config.ThiefJobs[id].inUse = false
			Config.ThiefJobs[id].goons_spawned = false
			Config.ThiefJobs[id].veh_spawned = false
			Config.ThiefJobs[id].player = false
			TriggerServerEvent('t1ger_chopshop:syncDataSV', Config.ThiefJobs)
			Citizen.Wait(500)
			-- job vehicle:
			DeleteVehicle(job_veh)
			job_veh = nil
			-- blip:
			if DoesBlipExist(thief_blip) then RemoveBlip(thief_blip) end 
			thief_blip = nil
			-- goons:
			local i = 0
			for k,v in pairs(Config.ThiefJobs[id].goons) do
				if DoesEntityExist(goons[i]) then
					DeleteEntity(goons[i])
				end
				i = i +1
			end
			goons = {}
			veh_lockpicked = false
			end_thiefJob = false
			veh_health = 0
			break
		end
		if sleep then
			Citizen.Wait(1000)
		end
	end
end

-- Function to lockpick job vehicle:
function LockpickJobVehicle(job)
	local anim_dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
	local anim_lib = "machinic_loop_mechandplayer"
	LoadAnim(anim_dict)
	if Config.ChopShop.Police.alert.enable then AlertPoliceFunction() end
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(250)
	FreezeEntityPosition(player, true)
	TaskPlayAnim(player, anim_dict, anim_lib, 3.0, 1.0, -1, 31, 0, 0, 0)
	-- Car Alarm:
	if Config.ChopShop.Settings.thiefjob.alarm then
		SetVehicleAlarm(job_veh, true)
		SetVehicleAlarmTimeLeft(job_veh, (25 * 1000))
		StartVehicleAlarm(job_veh)
	end
	if Config.ProgressBars then 
		exports['progressBars']:startUI((5 * 1000), Lang['progbar_lockpick'])
	end
	Citizen.Wait(5 * 1000)
	ClearPedTasks(player)
	FreezeEntityPosition(player, false)
	veh_lockpicked = true
	SetVehicleDoorsLockedForAllPlayers(job_veh, false)
	local number = Config.ChopShop.JobNPC.name
	if Config.ChopShop.Settings.usePhoneMSG then JobNotifyMSG(Lang['deliver_veh_msg'], number) else ShowNotifyESX(Lang['deliver_veh_msg']) end
end

-- Function to draw job vehicle health:
function DrawJobVehHealth(job_veh)
    Citizen.CreateThread(function()
        while veh_lockpicked and not scrappingCar do
            Citizen.Wait(1)
            veh_health = (GetEntityHealth(job_veh)/10)
            DrawVehHealthUtils(veh_health)
        end
    end)
end

-- Function for job blip in progress:
function CreateThiefJobBlip(job)
	local mk = job.blip
	local thief_blip = AddBlipForCoord(job.pos[1],job.pos[2],job.pos[3])
	SetBlipSprite(thief_blip, mk.sprite)
	SetBlipColour(thief_blip, mk.color)
	AddTextEntry('MYBLIP', mk.label)
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(thief_blip)
	SetBlipScale(thief_blip, mk.scale)
	SetBlipAsShortRange(thief_blip, true)
	if mk.route then
		SetBlipRoute(thief_blip, true)
		SetBlipRouteColour(thief_blip, mk.color)
	end
	return thief_blip
end

-- Function to create job vehicle:
function CreateJobVehicle(model, pos)
	LoadModel(model)
    local vehicle = CreateVehicle(model, pos[1], pos[2], pos[3], pos[4], true, false)
    SetVehicleNeedsToBeHotwired(vehicle, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
    SetVehicleIsStolen(vehicle, false)
    SetVehicleIsWanted(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleFuelLevel(vehicle, 80.0)
    DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
    return vehicle
end

-- Function to create job ped(s):
function CreateJobPed(goon, job_grade)
    LoadModel(goon.ped)
    local NPC = CreatePed(4, GetHashKey(goon.ped), goon.pos[1], goon.pos[2], goon.pos[3], goon.pos[4], false, true)
    NetworkRegisterEntityAsNetworked(NPC)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(NPC), true)
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(NPC), true)
    SetPedCanSwitchWeapon(NPC, true)
    SetPedArmour(NPC, goon.armour)
    SetPedAccuracy(NPC, goon.accuracy)
    SetEntityInvincible(NPC, false)
    SetEntityVisible(NPC, true)
    SetEntityAsMissionEntity(NPC)
    LoadAnim(goon.anim.dict)
    TaskPlayAnim(NPC, goon.anim.dict, goon.anim.lib, 8.0, -8, -1, 49, 0, 0, 0, 0)
    GiveWeaponToPed(NPC, GetHashKey(goon.weapon[job_grade]), 255, false, false)
    SetPedDropsWeaponsWhenDead(NPC, false)
    SetPedCombatAttributes(NPC, false)
    SetPedFleeAttributes(NPC, 0, false)
    SetPedEnableWeaponBlocking(NPC, true)
    SetPedRelationshipGroupHash(NPC, GetHashKey("JobNPCs"))	
    TaskGuardCurrentPosition(NPC, 15.0, 15.0, 1)
    return NPC
end

-- Event to sync config data:
RegisterNetEvent('t1ger_chopshop:syncDataCL')
AddEventHandler('t1ger_chopshop:syncDataCL',function(data)
    Config.ThiefJobs = data
end)

-- Thread to scrap vehicle:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true
		local scrapCFG = Config.ChopShop.ScrapNPC
		local mk = scrapCFG.marker
		local distance = GetDistanceBetweenCoords(coords, scrapCFG.pos.veh[1], scrapCFG.pos.veh[2], scrapCFG.pos.veh[3], true)
		-- close to chop shop:
		if distance < mk.drawDist then
			local carHash = GetEntityModel(curVehicle)
			if isInsideScrapCar(carHash) or (isInsideThiefJobCar(carHash) and veh_lockpicked) then
				sleep = false
				-- Draw Marker: 
				if distance > 2.0 then
					DrawMarker(mk.type, scrapCFG.pos.veh[1], scrapCFG.pos.veh[2], scrapCFG.pos.veh[3], 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
				end
				-- Create Scrap NPC:
				if scrap_NPC == nil then
					LoadModel(scrapCFG.model)
					scrap_NPC = CreatePed(4, scrapCFG.model, scrapCFG.pos.start[1], scrapCFG.pos.start[2], scrapCFG.pos.start[3]-0.975, scrapCFG.pos.start[4], false)
					FreezeEntityPosition(scrap_NPC, true)
					SetEntityInvincible(scrap_NPC, true)
					SetBlockingOfNonTemporaryEvents(scrap_NPC, true)
					TaskStartScenarioInPlace(scrap_NPC, scrapCFG.scenario.idle, 0, false)
				end
				-- Inspect Scrap Vehicle:
				if distance < 2.0 and not scrappingCar then
					DrawText3Ds(scrapCFG.pos.veh[1], scrapCFG.pos.veh[2], scrapCFG.pos.veh[3], Lang['press_to_scrap'])
					if IsControlJustPressed(0, scrapCFG.keybind) then
						InspectScrapVehicle()
					end
				end
			end
		end
		-- Delete Scrap NPC:
		if distance > mk.drawDist and scrap_NPC ~= nil then
			DeleteEntity(scrap_NPC)
			scrap_NPC = nil
		end
		-- Scrap the vehicle & get rewards:
		if carInspected and not carScrapped then
			local npc_coords = GetEntityCoords(scrap_NPC)
			local npc_dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, npc_coords.x, npc_coords.y, npc_coords.z, false)
			if npc_dist < 6.0 then
				sleep = false 
				DrawText3Ds(npc_coords.x, npc_coords.y, npc_coords.z, Lang['press_to_receive_cash'])
				if IsControlJustPressed(0, scrapCFG.keybind) then
					if npc_dist <= 2.0 then
						ScrapVehicle()
					else
						ShowNotifyESX(Lang['move_closer_interact'])
					end
				end
			end
		end
		if sleep then Citizen.Wait(1000) end
	end
end)

-- Function to scrap vehicle & reward:
function ScrapVehicle()
	carScrapped = true
	local scrapCFG = Config.ChopShop.ScrapNPC
	local scrap_vehicle = GetClosestVehicle(scrapCFG.pos.veh[1], scrapCFG.pos.veh[2], scrapCFG.pos.veh[3], 5.0, 0, 70)
	-- Trigger Reward:
	if job_veh ~= nil or veh_lockpicked then
		thiefjob_done = true
	else 
		-- (Delete Owned Vehicle):
		local plate = GetVehicleNumberPlateText(scrap_vehicle):gsub("^%s*(.-)%s*$", "%1")
		if Config.ChopShop.Settings.ownedVehicles.delete then
			ESX.TriggerServerCallback('t1ger_chopshop:isVehicleOwned', function(owned)
				if owned then
					TriggerServerEvent('t1ger_chopshop:deleteOwnedVehicle', plate)
				end
			end, plate)
		end
		-- reward:
		local data = GetScrapVehicleDetails(GetEntityModel(scrap_vehicle))
		TriggerServerEvent('t1ger_chopshop:getPayment', data, round(GetEntityHealth(scrap_vehicle)/10, 0))
		if Config.ChopShop.Settings.usePhoneMSG then
			JobNotifyMSG(Lang['car_delivered_1'], scrapCFG.name)
		else
			TriggerEvent('chat:addMessage', { args = {Lang['car_delivered_2']}})
		end
	end
	-- Reset & Stop:
	DeleteEntity(scrap_vehicle)
	DeleteVehicle(scrap_vehicle)
	FreezeEntityPosition(scrap_NPC, false)
	SetBlockingOfNonTemporaryEvents(scrap_NPC, true)
	SetEntityInvincible(scrap_NPC, true)
	TaskGoToCoordAnyMeans(scrap_NPC, scrapCFG.pos.start[1], scrapCFG.pos.start[2], scrapCFG.pos.start[3], 1.0, 0, 0, 786603, 0xbf800000)
	SetEntityHeading(scrap_NPC, scrapCFG.pos.start[4])
	Citizen.Wait(scrapCFG.timer.back * 1000)
	DeleteEntity(scrap_NPC)
	inspectingCar = false
	scrappingCar = false
	carInspected = false
	curVehicle = nil
	scrap_NPC = nil
	carScrapped	= false
end

-- Function to inspect vehicle:
function InspectScrapVehicle()
	local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
	local checked = false
	local can_scrap, checked = CanScrapVehicle(plate)
	while not checked do Wait(100) end
	if can_scrap then
		local scrapCFG = Config.ChopShop.ScrapNPC
		-- Check if Driver:
		if driver then 
			SetEntityAsMissionEntity(curVehicle, true)
			SetVehicleForwardSpeed(curVehicle, 0)
			SetVehicleEngineOn(curVehicle, false, false, true)
			if IsPedInAnyVehicle(player, true) then
				TaskLeaveVehicle(player, curVehicle, 4160)
				SetVehicleDoorsLockedForAllPlayers(curVehicle, true)
			end
			Citizen.Wait(250)
			FreezeEntityPosition(curVehicle, true)
		else
			return ShowNotifyESX(Lang['must_be_driver'])
		end
		scrappingCar = true 
		-- Inspect Car:
		if scrap_NPC ~= nil and not inspectingCar then
			FreezeEntityPosition(scrap_NPC, false)
			SetBlockingOfNonTemporaryEvents(scrap_NPC, true)
			SetEntityInvincible(scrap_NPC, true)
			TaskGoToCoordAnyMeans(scrap_NPC, scrapCFG.pos.stop[1], scrapCFG.pos.stop[2], scrapCFG.pos.stop[3], 1.0, 0, 0, 786603, 0xbf800000)
			SetEntityHeading(scrap_NPC, scrapCFG.pos.stop[4])
			Citizen.Wait(scrapCFG.timer.toCar * 1000)
			inspectingCar = true
		end	
		--Car Inspected:
		if scrap_NPC ~= nil and inspectingCar and not carInspected then	
			FreezeEntityPosition(scrap_NPC, true)
			SetEntityHeading(scrap_NPC, scrapCFG.pos.stop[4])
			SetBlockingOfNonTemporaryEvents(scrap_NPC, true)
			TaskStartScenarioInPlace(scrap_NPC, scrapCFG.scenario.work, 0, false)
			Citizen.Wait(scrapCFG.timer.inspect * 1000)
			carInspected = true
		end
	end
end

-- Check if inside a car from the car-list:
function isInsideScrapCar(hashkey)
	if hashkey == 0 then return false end
    for k,v in pairs(scrap_list) do
        if hashkey == v.hash then
            return true
        end
        if k == #scrap_list then
            return false
        end
    end
end

-- Check if inside a car from the current thief job:
function isInsideThiefJobCar(hashkey)
	if hashkey == 0 then return false end
	if hashkey == GetEntityModel(job_veh) then 
		return true 
	end
end

-- function to check if vehicle can be scrapped:
function CanScrapVehicle(plate)
	local canScrapVeh = false
	if job_veh ~= nil then return true, true end
	if Config.ChopShop.Settings.ownedVehicles.scrap then
		canScrapVeh = true 
	else
		ESX.TriggerServerCallback('t1ger_chopshop:isVehicleOwned', function(owned)
			if owned then canScrapVeh = false else canScrapVeh = true end
		end, plate)
	end
	return canScrapVeh, true
end

-- Get the  current scrap vehicle:
function GetScrapVehicleDetails(hashkey)
    local data = {}
    for k,v in pairs(scrap_list) do
        if hashkey == v.hash then
            data = {label = v.label, hash = v.hash, price = v.price}
            return data
        end
    end
end

AddEventHandler('esx:onPlayerDeath', function(data)
	end_thiefJob = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

RegisterCommand('carthief_cancel', function(source, args)
	end_thiefJob = true
	ShowNotifyESX(Lang['cancel_job'])
end, false)