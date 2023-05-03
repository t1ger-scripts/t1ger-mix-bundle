-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

ESX = exports['es_extended']:getSharedObject()
PlayerData 	= {}

-- Police Notify:
isCop = false
local streetName
local _

Citizen.CreateThread(function()
	PlayerData = ESX.GetPlayerData()
	isCop = IsPlayerJobCop()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	isCop = IsPlayerJobCop()
end)

-- [[ ESX SHOW ADVANCED NOTIFICATION ]] --
RegisterNetEvent('t1ger_goldcurrency:ShowAdvancedNotifyESX')
AddEventHandler('t1ger_goldcurrency:ShowAdvancedNotifyESX', function(title, subject, msg, icon, iconType)
	ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
	-- If you want to switch ESX.ShowNotification with something else:
	-- 1) Comment out the function
	-- 2) add your own
	
end)

-- [[ ESX SHOW NOTIFICATION ]] --
RegisterNetEvent('t1ger_goldcurrency:ShowNotifyESX')
AddEventHandler('t1ger_goldcurrency:ShowNotifyESX', function(msg)
	ShowNotifyESX(msg)
end)

function ShowNotifyESX(msg)
	ESX.ShowNotification(msg)
	-- If you want to switch ESX.ShowNotification with something else:
	-- 1) Comment out the function
	-- 2) add your own
end

function AlertPoliceFunction()
	local label = Lang['police_notify']
	TriggerServerEvent('t1ger_goldcurrency:PoliceNotifySV', GetEntityCoords(GetPlayerPed(-1)), streetName, label)
	-- If you want to use your own alert:
	-- 1) Comment out the 'TriggerServerEvent('t1ger_carthief:OutlawNotifySV',GetEntityCoords(PlayerPedId()),streetName)'
	-- 2) replace whatever even you use to trigger your alert.
end

RegisterNetEvent('t1ger_goldcurrency:PoliceNotifyCL')
AddEventHandler('t1ger_goldcurrency:PoliceNotifyCL', function(alert)
	if isCop then
		TriggerEvent('chat:addMessage', { args = {(Lang['dispatch_name']).. alert}})
	end
end)

-- [[ PHONE MESSAGES ]] --
function JobNotifyMSG(msg)
	local phoneNr = "T1GER#9080"
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
	ShowNotifyESX(Lang['new_msg_from']:format(phoneNr))
	TriggerServerEvent('gcPhone:sendMessage', phoneNr, msg)
	-- If you use GCPhone and have not changed in it, do not touch this!
	-- If you use another phone or customized gcphone functions etc:
	-- 1) Edit the TriggerServerEvent to your likings
end

-- Thread for Police Notify
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		streetName,_ = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
		streetName = GetStreetNameFromHashKey(streetName)
	end
end)

RegisterNetEvent('t1ger_goldcurrency:PoliceNotifyBlip')
AddEventHandler('t1ger_goldcurrency:PoliceNotifyBlip', function(targetCoords)
	if isCop and Config.PoliceSettings.blip.enable then 
		local alpha = Config.PoliceSettings.blip.alpha
		local alertBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.PoliceSettings.blip.radius)
		SetBlipHighDetail(alertBlip, true)
		SetBlipColour(alertBlip, Config.PoliceSettings.blip.color)
		SetBlipAlpha(alertBlip, alpha)
		SetBlipAsShortRange(alertBlip, true)
		while alpha ~= 0 do
			Citizen.Wait(Config.PoliceSettings.blip.time * 4)
			alpha = alpha - 1
			SetBlipAlpha(alertBlip, alpha)
			if alpha == 0 then
				RemoveBlip(alertBlip)
				return
			end
		end
	end
end)

-- Is Player A cop?
function IsPlayerJobCop()	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	for k,v in pairs(Config.PoliceSettings.jobs) do
		if PlayerData.job.name == v then return true end
	end
	return false
end

-- Function for 3D text:
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end

-- Load Anim
function LoadAnim(animDict)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(10) end
end

-- Load Model:
function LoadModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do Citizen.Wait(10) end
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

-- Function to return key str:
function KeyString(input)
	local keyStr = GetControlInstructionalButton(0, input, true):gsub('t_', '')
	return keyStr
end