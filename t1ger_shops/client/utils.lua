-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
ESX = exports['es_extended']:getSharedObject()
PlayerData = {}

Citizen.CreateThread(function()
	PlayerData = ESX.GetPlayerData()
	if Config.Debug then
		Citizen.Wait(2000)
		TriggerServerEvent('t1ger_shops:debugSV')
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	for i = 1, #Config.Shops do
		local shopsJob = Config.Society[Config.Shops[i].society].name
		if PlayerData.job.name == shopsJob then
			TriggerEvent('t1ger_shops:setShopID', i)
			break
		else
			if i == #Config.Shops then
				TriggerEvent('t1ger_shops:setShopID', 0)
				break
			end
		end
	end
end)

-- Notification
RegisterNetEvent('t1ger_shops:notify')
AddEventHandler('t1ger_shops:notify', function(msg)
	ESX.ShowNotification(msg)
end)

-- Advanced Notification
RegisterNetEvent('t1ger_shops:notifyAdvanced')
AddEventHandler('t1ger_shops:notifyAdvanced', function(sender, subject, msg, textureDict, iconType)
	ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, false, false, false)
end)

-- Draw 3D Text:
function T1GER_DrawTxt(x, y, z, text)
	local boolean, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.32, 0.32); SetTextFont(4); SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING"); SetTextCentre(1); AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text) / 500)
    DrawRect(_x, (_y + 0.0125), (0.015 + factor), 0.03, 0, 0, 0, 80)
end

-- Load Anim
function T1GER_LoadAnim(animDict)
	RequestAnimDict(animDict); while not HasAnimDictLoaded(animDict) do Citizen.Wait(1) end
end

-- Load Model
function T1GER_LoadModel(model)
	RequestModel(model); while not HasModelLoaded(model) do Citizen.Wait(1) end
end

function T1GER_isJob(name)
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	if PlayerData.job.name == name then
		return true
	end
	return false
end

function T1GER_GetJob(table)
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	for k,v in pairs(table) do
		if PlayerData.job.name == v then
			return true
		end
	end
	return false
end

-- Round function
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Comma function
function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
