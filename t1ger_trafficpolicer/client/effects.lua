-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
local male = true			-- dont touch this, it updates automatically when xPlayer loaded server side.

-- Thread for BAC:
local BAC = 0
local alcohol_gram = 0
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		local sleep = true
		if alcohol_gram > 0 then 
			sleep = false
			TriggerServerEvent('t1ger_trafficpolicer:updateBAC', male, alcohol_gram)
			Citizen.Wait(Config.Breathalyzer.tick * 60000)
		end
		if sleep then Citizen.Wait(2000) end
	end
end)

-- Event to set BAC level:
RegisterNetEvent('t1ger_trafficpolicer:setBAC')
AddEventHandler('t1ger_trafficpolicer:setBAC', function(bac, gram)
	BAC = bac
	alcohol_gram = gram
end)

-- Event to accept/deny breathalyzer test:
RegisterNetEvent('t1ger_trafficpolicer:acceptBreathalyzerTest')
AddEventHandler('t1ger_trafficpolicer:acceptBreathalyzerTest', function(newTarget)
	local elements = {
		{ label = Lang['button_yes'], value = 'yes', send = true },
		{ label = Lang['button_no'], value = 'no', send = false },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'provide_bac_test',
		{
			title    = Lang['provide_bac_test'],
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		TriggerServerEvent('t1ger_trafficpolicer:sendBreathalyzerTest', newTarget, data.current.send, BAC)
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end)

-- Get Breathalyzer Test Results:
RegisterNetEvent('t1ger_trafficpolicer:getBreathalyzerTestResults')
AddEventHandler('t1ger_trafficpolicer:getBreathalyzerTestResults', function(data)
	local cfg = Config.Breathalyzer
	LoadAnim(cfg.anim.dict)
	TaskPlayAnim(player, cfg.anim.dict, cfg.anim.lib, 1.0, -1, cfg.progressBar.timer, 50, 0, false, false, false)
	if Config.ProgressBars then 
		exports['progressBars']:startUI(cfg.progressBar.timer, cfg.progressBar.text)
	end
	Citizen.Wait(cfg.progressBar.timer)
	ClearPedTasks(player)
	local bac_lvl = '~g~'..round(data,2)..'%~s~'
	if data > cfg.limit then bac_lvl = '~r~'..round(data,2)..'%~s~' end
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName((Lang['breathalyzer_result']):format(bac_lvl, cfg.limit))
	EndTextCommandThefeedPostMessagetext(cfg.notify.textureDict, cfg.notify.textureName, false, 7, cfg.notify.title, cfg.notify.subtitle)
	EndTextCommandThefeedPostTicker(false, cfg.notify.showInBrief)
end)

-- Event to handle alcohol items:
RegisterNetEvent('t1ger_trafficpolicer:useAlcohol')
AddEventHandler('t1ger_trafficpolicer:useAlcohol', function(value)
	alcohol_gram = alcohol_gram + value
end)

-- Thread for BDC:
local BDC = {}
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		local sleep = true
		if onDrugs then
			sleep = false
			TriggerServerEvent('t1ger_trafficpolicer:updateBDC', BDC)
			Citizen.Wait(Config.DrugSwab.tick * 60000)
		end
		if sleep then Citizen.Wait(2000) end
	end
end)

-- Event to set BDC:
RegisterNetEvent('t1ger_trafficpolicer:setBDC')
AddEventHandler('t1ger_trafficpolicer:setBDC', function(table, state)
	BDC = table
	onDrugs = state
end)

-- Event to accept drug swab test:
RegisterNetEvent('t1ger_trafficpolicer:acceptDrugSwabTest')
AddEventHandler('t1ger_trafficpolicer:acceptDrugSwabTest', function(newTarget)
	local elements = {
		{ label = Lang['button_yes'], value = 'yes', send = true },
		{ label = Lang['button_no'], value = 'no', send = false },
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'accept_drug_swab_test',
		{
			title    = Lang['provide_bdc_test'],
			align    = 'center',
			elements = elements
		},
	function(data, menu)
		TriggerServerEvent('t1ger_trafficpolicer:sendDrugSwabTest', newTarget, data.current.send, onDrugs, BDC)
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end)

-- Get Drug Swab Test Results:
RegisterNetEvent('t1ger_trafficpolicer:getDrugSwabTestResults')
AddEventHandler('t1ger_trafficpolicer:getDrugSwabTestResults', function(data)
	local cfg = Config.DrugSwab
	LoadAnim(cfg.anim.dict)
	TaskPlayAnim(player, cfg.anim.dict, cfg.anim.lib, 1.0, -1, cfg.progressBar.timer, 50, 0, false, false, false)
	if Config.ProgressBars then 
		exports['progressBars']:startUI(cfg.progressBar.timer, cfg.progressBar.text)
	end
	Citizen.Wait(cfg.progressBar.timer)
	ClearPedTasks(player)
	local array = {}
	for k,v in pairs(data) do
		if v.result then
			local result = cfg.result.negative; if v.result then result = cfg.result.positive end;
			local string = v.drug..': '..result
			table.insert(array, string)
		end
	end
	local notifyString = Lang['drugswab_no_result']
	if #array > 0 then notifyString = table.concat(array,"\n") end
	RequestStreamedTextureDict(cfg.notify.textureDict)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(notifyString)
	EndTextCommandThefeedPostMessagetext(cfg.notify.textureDict, cfg.notify.textureName, false, 7, cfg.notify.title, cfg.notify.subtitle)
	EndTextCommandThefeedPostTicker(false, true)
end)


-- Event to handle drug items:
RegisterNetEvent('t1ger_trafficpolicer:useDrug')
AddEventHandler('t1ger_trafficpolicer:useDrug', function(drugSV, durationSV)
	if BDC[drugSV] ~= nil then 
		BDC[drugSV].duration = BDC[drugSV].duration + durationSV
		BDC[drugSV].result = true
	end
	onDrugs = true
end)

-- Get Gender:
RegisterNetEvent('t1ger_trafficpolicer:updateGender')
AddEventHandler('t1ger_trafficpolicer:updateGender', function(state)
	male = state
end)