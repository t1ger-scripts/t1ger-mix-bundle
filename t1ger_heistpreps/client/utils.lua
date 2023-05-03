-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
ESX = exports['es_extended']:getSharedObject()
PlayerData = {}

Citizen.CreateThread(function()
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

-- Notification
RegisterNetEvent('t1ger_heistpreps:notify')
AddEventHandler('t1ger_heistpreps:notify', function(msg)
	ESX.ShowNotification(msg)
end)

-- Advanced Notification
RegisterNetEvent('t1ger_heistpreps:notifyAdvanced')
AddEventHandler('t1ger_heistpreps:notifyAdvanced', function(sender, subject, msg, textureDict, iconType)
	ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, false, false, false)
end)

-- Police Notification
RegisterNetEvent('t1ger_heistpreps:notifyCops')
AddEventHandler('t1ger_heistpreps:notifyCops', function(targetCoords, msg)
	local alert = msg:format(GetStreetNameFromHashKey(GetStreetNameAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)))
	TriggerEvent('chat:addMessage', { args = {'^5 Dispatch: '.. alert}})
	-- blip
	local cfg = Config.AlertBlip
	if cfg.Show then
		local alpha = cfg.Alpha
		local blip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, cfg.Radius)
		SetBlipHighDetail(blip, true)
		SetBlipColour(blip, cfg.Color)
		SetBlipAlpha(blip, alpha)
		SetBlipAsShortRange(blip, true)
		while alpha ~= 0 do
			Citizen.Wait(cfg.Time * 4)
			alpha = alpha - 1
			SetBlipAlpha(blip, alpha)
			if alpha == 0 then
				RemoveBlip(blip)
				return
			end
		end
	end
end)

function T1GER_DrawTxt(x, y, z, text)
	local boolean, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.32, 0.32); SetTextFont(4); SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING"); SetTextCentre(1); AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text) / 500)
    DrawRect(_x, (_y + 0.0125), (0.015 + factor), 0.03, 0, 0, 0, 80)
end

function T1GER_GetControlOfEntity(entity)
	local netTime = 15
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) and netTime > 0 do 
		NetworkRequestControlOfEntity(entity)
		Citizen.Wait(100)
		netTime = netTime -1
	end
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

-- Function to Display Help Text:
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Round Fnction:
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Comma Function:
function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
