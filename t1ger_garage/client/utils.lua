-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
ESX = exports['es_extended']:getSharedObject()
PlayerData 	= {}

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
RegisterNetEvent('t1ger_garage:notify')
AddEventHandler('t1ger_garage:notify', function(msg)
	ESX.ShowNotification(msg)
end)

-- Advanced Notification
RegisterNetEvent('t1ger_garage:notifyAdvanced')
AddEventHandler('t1ger_garage:notifyAdvanced', function(sender, subject, msg, textureDict, iconType)
	ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, false, false, false)
end)


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

-- Function for Display Veh 3D text:
function T1GER_DrawDisplay(x,y,z, text)
	local boolean, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
	local scale = (1/dist)*2
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
	if boolean then
		SetTextScale(0.0*scale, 0.35*scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

-- Create Blip:
function T1GER_CreateBlip(position, mk, id)
	local blip, pos = nil, position
	if mk.enable then
		blip = AddBlipForCoord(pos.x, pos.y, pos.z)
		SetBlipSprite(blip, mk.sprite)
		SetBlipScale(blip, mk.scale)
		SetBlipColour(blip, mk.color)
		SetBlipDisplay(blip, 4)
		SetBlipAsShortRange(blip, true)
		-- blip name:
		BeginTextCommandSetBlipName('STRING')
		if id ~= nil then 
			AddTextComponentString(mk.name..': '..id)
		else
			AddTextComponentString(mk.name)
		end
		EndTextCommandSetBlipName(blip)
	end
	return blip
end

function T1GER_DeleteVehicle(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
	DeleteEntity(vehicle)
end

function T1GER_GetControlOfEntity(entity)
	local netTime = 15
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) and netTime > 0 do 
		NetworkRequestControlOfEntity(entity)
		Citizen.Wait(1)
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

-- Round
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Trim:
function T1GER_Trim(value)
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

-- Create ped
function T1GER_CreatePed(type, model, x, y, z, heading)
	T1GER_LoadModel(model)
	local NPC = CreatePed(type, GetHashKey(model), x, y, z, heading, true, true)
	SetEntityAsMissionEntity(NPC)
	return NPC
end

-- Comma Function:
function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end