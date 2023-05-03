function T1GER_GetClosestVehicle(pos, radius)
    local closestVeh = StartShapeTestCapsule(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, radius, 10, player, 7)
    local a, b, c, d, entityHit = GetShapeTestResult(closestVeh)
	local tick = 15
	while entityHit == 0 and tick > 0 do 
		tick = tick - 1
		closestVeh = StartShapeTestCapsule(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, radius, 10, player, 7)
		local a1, b1, c1, d1, entityHit2 = GetShapeTestResult(closestVeh)
		if entityHit2 ~= 0 and IsEntityAVehicle(entityHit2) then
			entityHit = entityHit2
			break
		end
		Citizen.Wait(1)
	end
    return entityHit
end

function GetVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, player, 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function IsVehicleTowTruck(entity)
	local bool = false
	for k,v in pairs(Config.FlatbedTowing.trucks) do
		if GetHashKey(k) == GetEntityModel(entity) then
			bool = true 
			break
		end
	end
	return bool
end

function VehicleIsBlacklisted(entity)
	local bool = false 
	for k,v in pairs(Config.FlatbedTowing.blacklisted) do
		if GetHashKey(k) == GetEntityModel(entity) then
			bool = true 
			break
		end
	end
	return bool
end