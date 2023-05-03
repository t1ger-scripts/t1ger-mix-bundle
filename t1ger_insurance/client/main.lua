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

local ins_menu = nil
local blip = nil
local brokers = 0

-- Thread to interact with insurance company ins_menu:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local sleep = true 
		local cfg = Config.Insurance.company
		local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cfg.pos[1], cfg.pos[2], cfg.pos[3], true) 
		if distance < cfg.loadDist then
			sleep = false
			if ins_menu ~= nil then
				distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, ins_menu.pos[1], ins_menu.pos[2], ins_menu.pos[3], true)
				while ins_menu ~= nil and distance > 2.0 do
					ins_menu = nil
					Citizen.Wait(1)
				end
				if ins_menu == nil then
					ESX.UI.Menu.CloseAll()
				end
			else
				local mk = cfg.marker
				if distance <= mk.drawDist then
					if distance > cfg.interactDist and mk.enable then 
						DrawMarker(mk.type, cfg.pos[1], cfg.pos[2], cfg.pos[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
					elseif distance < cfg.interactDist then
						DrawText3Ds(cfg.pos[1], cfg.pos[2], cfg.pos[3], Lang['insurance_menu'])
						if IsControlJustPressed(0, cfg.menuKey) then
							ins_menu = cfg
							InsuranceMainMenu()
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

-- Function for insurance main menu:
function InsuranceMainMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {
		{label = Lang['manage_insurance'], value = 'manage_insurance'},
	}
	-- Buy Menu Element:
	if Config.BuyWithOnlineBrokers then
		table.insert(elements, {label = Lang['buy_insurance'], value = 'buy_insurance'})
	else
		if brokers <= 0 then 
			table.insert(elements, {label = Lang['buy_insurance'], value = 'buy_insurance'})
		end
	end
	-- Boss Element:
	if PlayerData.job ~= nil and PlayerData.job.name == Config.Insurance.job.name then
		if PlayerData.job.grade == 1 then 
			table.insert(elements, {label = Lang['boss_menu'], value = 'boss_menu'})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_main_menu', {
		title    = Lang['menu_main_title'],
		align    = 'center',
		elements = elements
	}, function(data, menu)
		local action = data.current.value
		
		if action == 'manage_insurance' then
			ManageInsurances()
		end

		if action == 'buy_insurance' then
			BuyInsuranceMenu()
		end

		if action == 'boss_menu' then 
			OpenBossMenu()
		end

	end, function(data, menu)
		menu.close()
		ins_menu = nil
	end)
end

-- Function to buy insurance:
function BuyInsuranceMenu()
	ESX.TriggerServerCallback('t1ger_insurance:fetchVehicles', function(vehicles)
		if vehicles ~= nil and #vehicles > 0 then 
			local elements = {}
			for k,v in pairs(vehicles) do
				if not v.insurance then
					local veh_name = GetLabelText(GetDisplayNameFromVehicleModel(v.props.model))
					table.insert(elements, {label = veh_name..' ['..v.plate..']', value = v})
				end
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_buy_menu', {
				title    = Lang['buy_insurance_for_title'],
				align    = 'center',
				elements = elements
			}, function(data, menu)
				-- Confirm Menu:
				local upfront = Config.Insurance.price.upfront
				local subscription = Config.Insurance.price.payment
				if data.current.value.price ~= nil then
					upfront = math.floor((Config.Insurance.price.establish/100) * data.current.value.price)
					subscription = math.floor((Config.Insurance.price.subscription/100) * data.current.value.price)
				end
				local elements2 = {
					{label = 'Upfront: $'..upfront..' | Sub: $'..subscription..''},
					{label = Lang['button_no'], value = 'decline'},
					{label = Lang['button_yes'], value = 'confirm'}
				}
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_insurance',
					{
						title    = Lang['confirm_insurance_title'],
						align    = 'center',
						elements = elements2
					},
				function(data2, menu2)
					menu2.close()
					if data2.current.value == 'confirm' then
						TriggerServerEvent('t1ger_insurance:buyInsurance', data.current.value, upfront, subscription)
						InsuranceMainMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end, function(data, menu)
				menu.close()
			end)
		else
			ShowNotifyESX(Lang['no_veh_to_insure'])
			InsuranceMainMenu()
		end
	end)
end

-- Function to manage insurances:
function ManageInsurances()
	ESX.TriggerServerCallback('t1ger_insurance:fetchVehicles', function(vehicles)
		if vehicles ~= nil and #vehicles > 0 then 
			local elements = {}
			for k,v in pairs(vehicles) do
				if v.insurance then
					local veh_name = GetLabelText(GetDisplayNameFromVehicleModel(v.props.model))
					table.insert(elements, {label = veh_name..' ['..v.plate..']', value = v})
				end
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_manage_menu', {
				title    = Lang['ins_manage_title'],
				align    = 'center',
				elements = elements
			}, function(data, menu)
				-- Confirm Menu:
				local upfront = Config.Insurance.price.upfront
				local subscription = Config.Insurance.price.payment
				if data.current.value.price ~= nil then 
					upfront = math.floor((Config.Insurance.price.establish/100) * data.current.value.price)
					subscription = math.floor((Config.Insurance.price.subscription/100) * data.current.value.price)
				end
				local elements2 = {
					{label = 'Upfront: $'..upfront..' | Sub: $'..subscription..''},
					{label = Lang['cancel_insurance'], value = 'cancel_insurance'},
					{label = Lang['button_return'], value = 'return'}
				}
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_cancel_ins',
					{
						title    = 'Plate: '..data.current.value.plate,
						align    = 'center',
						elements = elements2
					},
				function(data2, menu2)
					menu2.close()
					if data2.current.value == 'cancel_insurance' then
						TriggerServerEvent('t1ger_insurance:cancelInsurance', data.current.value, upfront, subscription)
						InsuranceMainMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end, function(data, menu)
				menu.close()
			end)
		else
			ShowNotifyESX(Lang['no_insured_vehicles'])
			InsuranceMainMenu()
		end
	end)
end

-- Boss Main Menu:
function OpenBossMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_boss_menu',
		{
			title    = Lang['boss_main_title'],
			align    = 'center',
			elements = {
				{ label = Lang['boss_actions'], value = 'boss_actions' },
				{ label = Lang['account_balance'], value = 'get_balance' }
			}
		},
	function(data, menu)
		if data.current.value == 'boss_actions' then
			local cfg = Config.Insurance.job.society
			TriggerEvent('esx_society:openBossMenu', Config.Insurance.job.name, function(data, menu)
				menu.close()
			end, {withdraw = cfg.withdraw, deposit = cfg.deposit, wash = cfg.wash, employees = cfg.employees, grades = cfg.grades})
		elseif data.current.value == 'get_balance' then
			ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(amount)
				ShowNotifyESX(Lang['get_account_balance']:format(comma_value(amount)))
			end, Config.Insurance.job.name)
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- Command to open Insurance Job Menu:
RegisterCommand(Config.Insurance.job.menu.command, function(source, args)
	InsuranceInteractionMenu()
end, false)

-- Thread to handle hotkey for Insurance Job Menu:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0, Config.Insurance.job.menu.keybind) then if isPlayerJobAllowed() then InsuranceInteractionMenu() end end
	end
end)

-- function to open job menu:
function InsuranceInteractionMenu()
	local elements = {
		{label = 'View Insurance', value = 'view_insurance'},
		{label = 'Show Insurance', value = 'show_insurance'},
	}
	if PlayerData.job ~= nil then
		if PlayerData.job.name == 'police' or PlayerData.job.name == 'insurance' then 
			table.insert(elements, {label = 'Check Insurance', value = 'check_insurance'})
		end
		if PlayerData.job.name == 'insurance' then 
			table.insert(elements, {label = 'Sell Insurance', value = 'sell_insurance'})
			table.insert(elements, {label = 'Cancel Insurance', value = 'cancel_insurance'})
		end
	end
	-- MENU: 
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_interaction_menu',
		{
			title    = 'Insurance Interaction',
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		local action = data.current.value

		-- View Insurance Paper to yourself:
		if action == 'view_insurance' then 
			menu.close()
			local plate = OpenPlateDialog()
			local target = GetPlayerServerId(PlayerId())
			TriggerServerEvent('t1ger_insurance:openInsurancePaperSV', target, target, plate)
		end

		-- Show Insurance Paper to closest player:
		if action == 'show_insurance' then 
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestDistance <= 2.0 and closestPlayer ~= -1 then
				menu.close()
				local target = GetPlayerServerId(closestPlayer)
				local plyID = GetPlayerServerId(PlayerId())
				local plate = OpenPlateDialog()
				TriggerServerEvent('t1ger_insurance:openInsurancePaperSV', plyID, target, plate)
			else
				ShowNotifyESX(Lang['no_players_nearby'])
			end
		end

		-- Check insurance status on a vehicle:
		if action == 'check_insurance' then
			menu.close()
			TriggerEvent('t1ger_insurance:lookupVehicleInsurance')
		end

		-- Sell insurance to player as broker:
		if action == 'sell_insurance' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestDistance <= 2.0 and closestPlayer ~= -1 then
				menu.close()
				local target = GetPlayerServerId(closestPlayer)
				local plate = OpenPlateDialog()
				ESX.TriggerServerCallback('t1ger_insurance:getVehiclePlate', function(vehicle) 
					if vehicle then
						if vehicle.insurance then
							ShowNotifyESX(Lang['veh_has_insurance'])
							InsuranceInteractionMenu()
						else
							local upfront = Config.Insurance.price.upfront
							local subscription = Config.Insurance.price.payment
							if vehicle.model ~= nil then -- calculate price based on vehicle price:
								ESX.TriggerServerCallback('t1ger_insurance:getVehiclePrice', function(price) 
									if price then 
										upfront = math.floor((Config.Insurance.price.establish/100) * price)
										subscription = math.floor((Config.Insurance.price.subscription/100) * price)
									end
								end, vehicle.model)
							end
							TriggerServerEvent('t1ger_insurance:sendSellConfirmation', upfront, subscription, plate, target)
							ShowNotifyESX(Lang['wait_for_target'])
						end
					end
				end, plate)
			else
				ShowNotifyESX(Lang['no_players_nearby'])
			end
		end

		-- Cancel insurance from player as broker:
		if action == 'cancel_insurance' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestDistance <= 2.0 and closestPlayer ~= -1 then
				menu.close()
				local target = GetPlayerServerId(closestPlayer)
				local plate = OpenPlateDialog()
				ESX.TriggerServerCallback('t1ger_insurance:getVehiclePlate', function(vehicle) 
					if vehicle then
						if vehicle.insurance then
							TriggerServerEvent('t1ger_insurance:sendCancelConfirmation', plate, target)
							ShowNotifyESX(Lang['wait_for_target'])
						else
							ShowNotifyESX(Lang['veh_has_no_insurance'])
							InsuranceInteractionMenu()
						end
					end
				end, plate)
			else
				ShowNotifyESX(Lang['no_players_nearby'])
			end
		end

	end, function(data, menu)
		menu.close()
	end)
end

-- Event to check vehicle insurance state based on plate:
RegisterNetEvent('t1ger_insurance:lookupVehicleInsurance')
AddEventHandler('t1ger_insurance:lookupVehicleInsurance', function()
	local plate = OpenPlateDialog()
	ESX.TriggerServerCallback('t1ger_insurance:getVehiclePlate', function(vehicle) 
		if vehicle then
			local status = '~r~invalid~s~'
			if vehicle.insurance then 
				status = '~g~valid~s~'
			end
			local text = '\nPlate: ~b~'..plate..'~s~\nInsurance: '..status
			AdvanedNotify(plate, status, 'CHAR_MP_MORS_MUTUAL', 'Insurance', 'Vehicle Insurance Results', true, text)
		end
	end, plate)
end)

-- Event to confirm buying an insurance from broker:
RegisterNetEvent('t1ger_insurance:buyInsuranceConfirmation')
AddEventHandler('t1ger_insurance:buyInsuranceConfirmation', function(plate, upfront, subscription, target)						
	local elements = {
		{label = 'Upfront: $'..upfront..' | Sub: $'..subscription..''},
		{label = Lang['button_no'], value = 'decline'},
		{label = Lang['button_yes'], value = 'confirm'}
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_insurance',
		{
			title    = Lang['confirm_insurance_title'],
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		menu.close()
		TriggerServerEvent('t1ger_insurance:sellInsurance', plate, target, upfront, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end)

-- Event to confirm buying an insurance from broker:
RegisterNetEvent('t1ger_insurance:cancelInsuranceConfirmation')
AddEventHandler('t1ger_insurance:cancelInsuranceConfirmation', function(plate, target)						
	local elements = {
		{label = Lang['button_return'], value = 'return'},
		{label = Lang['cancel_insurance'], value = 'cancel_insurance'},
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_cancel_ins',
		{
			title    = 'Plate: '..plate,
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		menu.close()
		TriggerServerEvent('t1ger_insurance:deleteInsurance', plate, target, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end)

-- Function to enter plate in ESX Menu Dialog:
function OpenPlateDialog()
	local license_plate = nil
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'insurance_plate_dialog', {
		title = 'Enter License Plate'
	},
	function(data, menu)
		local plate = tostring(data.value)
		if plate == nil or plate == '' then
			ShowNotifyESX(Lang['invalid_plate'])
		else
			menu.close()
			license_plate = plate
		end
	end, function(data, menu)
		menu.close()
	end)
	while license_plate == nil do 
		Wait(100)
	end
	return license_plate
end

local open_insurance = false
RegisterNetEvent('t1ger_insurance:openInsurancePaperCL')
AddEventHandler('t1ger_insurance:openInsurancePaperCL', function(info, plate)
	open_insurance = true
	SendNUIMessage({ action = "open", array = info, plate = plate })
end)

-- Thread to handle insurance paper key
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustReleased(0, Config.Insurance.paper.keyToHidePaper) and open_insurance then
			SendNUIMessage({
				action = "close"
			})
			open_insurance = false
		end
	end
end)

-- Event to auto-pay bills:
RegisterNetEvent('t1ger_insurance:getInsuranceBill')
AddEventHandler('t1ger_insurance:getInsuranceBill', function()
	local insurance_bill = 0
	ESX.TriggerServerCallback('t1ger_insurance:fetchVehicles', function(vehicles) 
		if vehicles ~= nil and #vehicles > 0 then
			for k,v in pairs(vehicles) do
				if v.insurance then
					local bill = Config.Insurance.price.payment
					if v.model ~= nil and v.price ~= nil then 
						bill = math.floor((Config.Insurance.price.subscription/100) * v.price)
					end
					insurance_bill = insurance_bill + bill
				end
			end
			if insurance_bill > 0 then 
				TriggerServerEvent('t1ger_insurance:payInsuranceBill', insurance_bill)
			end
		end
	end)
end)

-- Function to create blip on map:
function CreateInsuranceBlip()
	local cfg = Config.Insurance.company
	if cfg.blip.enable then
		local mk = cfg.blip
		blip = AddBlipForCoord(cfg.pos[1], cfg.pos[2], cfg.pos[3])
		SetBlipSprite (blip, mk.sprite)
		SetBlipDisplay(blip, mk.display)
		SetBlipScale  (blip, mk.scale)
		SetBlipColour (blip, mk.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(mk.label)
		EndTextCommandSetBlipName(blip)
	end
end

-- Update broker count locally on setJob:
function JobUpdateBrokerCount()
	brokers = brokers + 1
end

-- Event to open main menu:
RegisterNetEvent('t1ger_insurance:openMenu')
AddEventHandler('t1ger_insurance:openMenu', function()
	InsuranceMainMenu()
end)

-- Event to update online broker count:
RegisterNetEvent('t1ger_insurance:updateBrokerCount')
AddEventHandler('t1ger_insurance:updateBrokerCount', function(count)
	brokers = count
end)

-- Display Advanced Notification:
function AdvanedNotify(plate, status, char, title, subtitle, brief, text)
	RequestStreamedTextureDict(char)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostMessagetext(char, char, false, 7, title, subtitle)
	EndTextCommandThefeedPostTicker(false, brief)
end

-- Check if Player has Police Job:
function isPlayerJobAllowed()	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	if PlayerData.job.name == Config.Insurance.job.name then
		return true
	end
	return false
end
