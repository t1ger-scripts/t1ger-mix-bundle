function InitializeTowTrucker()
	Citizen.Wait(1000)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_towtrucker', {}, function(results)
		if next(results) then
			for i = 1, #results do
				local data = {
					identifier = results[i].identifier,
					id = results[i].id,
					name = results[i].name,
					impound = nil or json.decode(results[i].impound)
				}
				towServices[results[i].id] = data
				Config.TowServices[results[i].id].owned = true
				Config.TowServices[results[i].id].data = data
				Citizen.Wait(5)
			end
		end
	end)
	RconPrint('T1GER Tow Trucker Initialized\n')
end

function UpdateTowServices(num, val, state, name, identify)
    if state ~= nil then 
        if state then
            towServices[num] = { identifier = identify, id = num, name = name }
        else
			for i = 1, #towServices do
				if towServices[i].id == num then
					towServices[i] = nil
					break
				end
			end
        end
        Config.TowServices[num].owned = state
    else
        if name ~= nil then 
            for k,v in pairs(towServices) do
                if v.id == num then
                    v.name = name
                    MySQL.Async.execute('UPDATE t1ger_towtrucker SET name = @name WHERE id = @id', {
                        ['@name'] = name,
                        ['@id'] = num
                    })
                    break
                end
            end
        end
    end
    TriggerClientEvent('t1ger_towtrucker:syncTowServices', -1, towServices, Config.TowServices)
end

RegisterServerEvent('t1ger_towtrucker:debugSV')
AddEventHandler('t1ger_towtrucker:debugSV', function()
    SetupTowServices(source)
end)

function T1GER_Trim(value)
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end