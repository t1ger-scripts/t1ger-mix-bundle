
RegisterNetEvent('t1ger_heistpreps:sendConfigCL')
AddEventHandler('t1ger_heistpreps:sendConfigCL', function(type, num, cfg)
	Config.Jobs[type][num] = cfg
end)

RegisterNetEvent('t1ger_heistpreps:sendCacheCL')
AddEventHandler('t1ger_heistpreps:sendCacheCL', function(data, type, num)
	Config.Jobs[type][num].cache = data
end)

function GetRandomJobType()
	math.randomseed(GetGameTimer())
	local type = Config.Types[math.random(1, #Config.Types)]
	return type
end

function GetRandomJobLocation(type)
	math.randomseed(GetGameTimer())
	local num = math.random(1, #Config.Jobs[type])
	local i = 1
	while Config.Jobs[type][num].inUse == true and i < 100 do
        i = i + 1
        math.randomseed(GetGameTimer())
        num = math.random(1, #Config.Jobs[type])
    end
    if i == 100 then
		return nil
    else
		return num
    end
end

function IsPhoneBoxAllowed(coords)
	local obj = 0
	for k,v in pairs(Config.PhoneBoxes) do
		obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, GetHashKey(v), false, false, false)
		if obj > 0 then
			return obj, true
		end
	end
	return obj, false
end
