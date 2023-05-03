-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

ESX = exports['es_extended']:getSharedObject()
local BAC_table = {}
local BDC_table = {}
local anpr_table = {}

AddEventHandler('esx:playerLoaded', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    -- Get Gender:
    local data = MySQL.Sync.fetchAll('SELECT sex FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier })
    if data[1] then 
        local male = true; if data[1].sex == 'F' then male = false elseif data[1].sex == 'M' then male = true end
        TriggerClientEvent('t1ger_trafficpolicer:updateGender', xPlayer.source, male)
    end
    -- Get/Initialize BAC:
    if BAC_table[xPlayer.identifier] ~= nil then
        TriggerClientEvent('t1ger_trafficpolicer:setBAC', xPlayer.source, BAC_table[xPlayer.identifier].BAC, BAC_table[xPlayer.identifier].gram)
    else
        InitializeBAC(xPlayer)
    end
    -- Get/Initialize BDC:
    if BDC_table[xPlayer.identifier] ~= nil then
        TriggerClientEvent('t1ger_trafficpolicer:setBDC', xPlayer.source, BDC_table[xPlayer.identifier].data, BDC_table[xPlayer.identifier].onDrugs)
    else
        InitializeBDC(xPlayer)
    end
    -- Load ANPR Vehicles:
    TriggerClientEvent('t1ger_trafficpolicer:loadANPR', xPlayer.source, anpr_table)
end)

-- Lookup Player:
ESX.RegisterServerCallback('t1ger_trafficpolicer:lookupPlayer',function(source, cb, target)
    local tPlayer = ESX.GetPlayerFromId(target)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = tPlayer.identifier}, function(results)
        if results[1] then
            local data = { firstname = results[1].firstname, lastname = results[1].lastname, dob = results[1].dateofbirth, sex = results[1].sex }
            if Config.ESX_License then
                local license = MySQL.Sync.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner AND type = @type', {
                    ['@owner'] = tPlayer.identifier,
                    ['@type'] = 'driver'}
                )
                if license[1] then data.license = true else data.license = false end
            end
            cb(data)
        else
            cb(nil)
        end
    end)
end)

-- Lookup Plate/Vehicle:
ESX.RegisterServerCallback('t1ger_trafficpolicer:lookupPlate',function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT owner, plate, firstname, lastname, dateofbirth from owned_vehicles t1 INNER JOIN users t2 ON t1.owner = t2.identifier WHERE t1.plate = @plate', {
        ['@plate'] = plate},
    function(results)
        if results[1] then
            local data = {
                firstname = results[1].firstname,
                lastname = results[1].lastname,
                dob = results[1].dateofbirth,
                insurance = nil
            }
            if Config.T1GER_Insurance then
                local insurance = MySQL.Sync.fetchAll('SELECT insurance FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
                    ['@owner'] = results[1].owner,
                    ['@plate'] = results[1].plate}
                )
                if insurance[1] then data.insurance = insurance[1].insurance end
            end
            cb(data)
        else
            cb(nil)
        end
	end)
end)


RegisterServerEvent('t1ger_trafficpolicer:startDebug')
AddEventHandler('t1ger_trafficpolicer:startDebug', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    InitializeBDC(xPlayer)
    InitializeBAC(xPlayer)
end)

-- Function to initialize BAC:
function InitializeBAC(playerId)
    BAC_table[playerId.identifier] = {BAC = 0, hour = 0, gram = 0}
    TriggerClientEvent('t1ger_trafficpolicer:setBAC', playerId.source, 0, 0)
end

RegisterServerEvent('t1ger_trafficpolicer:updateBAC')
AddEventHandler('t1ger_trafficpolicer:updateBAC', function(male, gram)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Get Player Weight:
    local weight = 0; if male then weight = ((Config.Breathalyzer.weight.male * 1000) * 0.68) else weight = ((Config.Breathalyzer.weight.female * 1000) * 0.55) end

    -- Gram to Add:
    local addGram = 0 
    if BAC_table[xPlayer.identifier] ~= nil then addGram = BAC_table[xPlayer.identifier].gram end

    if gram > addGram then addGram = gram end

    -- Hours to Add:
    local addHours = 1 
    if BAC_table[xPlayer.identifier] ~= nil then
        addHours = BAC_table[xPlayer.identifier].hour + 1
    end

    -- Calculate BAC:
    local addBAC = ((addGram / weight) * 100)
    if addHours > 0 then
        addBAC = addBAC - (Config.Breathalyzer.decreaser * addHours)
        if addBAC <= 0.00 then
            BAC_table[xPlayer.identifier] = nil
            return TriggerClientEvent('t1ger_trafficpolicer:setBAC', xPlayer.source, 0, 0)
        end
    end

    -- Update Table:
    if BAC_table[xPlayer.identifier] ~= nil then
        BAC_table[xPlayer.identifier].BAC = addBAC
        BAC_table[xPlayer.identifier].hour = addHours
        BAC_table[xPlayer.identifier].gram = addGram
    else
        BAC_table[xPlayer.identifier] = {BAC = addBAC, hour = addHours, gram = addGram}
    end

    TriggerClientEvent('t1ger_trafficpolicer:setBAC', xPlayer.source, BAC_table[xPlayer.identifier].BAC, gram)
end)

-- Event to request breathalyzer test:
RegisterServerEvent('t1ger_trafficpolicer:requestBreathalyzerTest')
AddEventHandler('t1ger_trafficpolicer:requestBreathalyzerTest', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)
    TriggerClientEvent('t1ger_trafficpolicer:acceptBreathalyzerTest', tPlayer.source, xPlayer.source)
end)

-- Event to send Breathalyzer test results:
RegisterServerEvent('t1ger_trafficpolicer:sendBreathalyzerTest')
AddEventHandler('t1ger_trafficpolicer:sendBreathalyzerTest', function(target, provided, BAC)
    local xPlayer = ESX.GetPlayerFromId(target)
    if provided then
        TriggerClientEvent('t1ger_trafficpolicer:getBreathalyzerTestResults', xPlayer.source, BAC)
    else
        TriggerClientEvent('t1ger_trafficpolicer:notify', xPlayer.source, Lang['rejected_bac_test'])
    end
end)

-- Function to initialize BDC:
function InitializeBDC(playerId)
    local dataSV = {}
    for i = 1, #Config.DrugSwab.labels do
        dataSV[Config.DrugSwab.labels[i]] = {drug = Config.DrugSwab.labels[i], duration = 0, result = false}
    end
    BDC_table[playerId.identifier] = {data = dataSV, onDrugs = false}
    TriggerClientEvent('t1ger_trafficpolicer:setBDC', playerId.source, BDC_table[playerId.identifier].data, BDC_table[playerId.identifier].onDrugs)
end

-- Event to update BDC:
RegisterServerEvent('t1ger_trafficpolicer:updateBDC')
AddEventHandler('t1ger_trafficpolicer:updateBDC', function(table)
    local xPlayer = ESX.GetPlayerFromId(source)
    local state = false
    for i = 1, #Config.DrugSwab.labels do
        if table[Config.DrugSwab.labels[i]].duration > 0 then
            table[Config.DrugSwab.labels[i]].duration = table[Config.DrugSwab.labels[i]].duration - Config.DrugSwab.decreaser
            table[Config.DrugSwab.labels[i]].result = true 
            state = true
            -- extra check for zero:
            if table[Config.DrugSwab.labels[i]].duration <= 0 then
                table[Config.DrugSwab.labels[i]].duration = 0
                table[Config.DrugSwab.labels[i]].result = false  
            end
        elseif table[Config.DrugSwab.labels[i]].duration <= 0 then
            table[Config.DrugSwab.labels[i]].duration = 0
            table[Config.DrugSwab.labels[i]].result = false 
        end
	end
    -- Update Table:
    if BDC_table[xPlayer.identifier] ~= nil then
        BDC_table[xPlayer.identifier].data = table
        BDC_table[xPlayer.identifier].onDrugs = state
    else
        BDC_table[xPlayer.identifier] = {data = table, onDrugs = state}
    end
    TriggerClientEvent('t1ger_trafficpolicer:setBDC', xPlayer.source, BDC_table[xPlayer.identifier].data, BDC_table[xPlayer.identifier].onDrugs)
end)

-- Event to request BDC test:
RegisterServerEvent('t1ger_trafficpolicer:requestDrugSwabTest')
AddEventHandler('t1ger_trafficpolicer:requestDrugSwabTest', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)
    TriggerClientEvent('t1ger_trafficpolicer:acceptDrugSwabTest', tPlayer.source, xPlayer.source)
end)

-- Event to send BDC test:
RegisterServerEvent('t1ger_trafficpolicer:sendDrugSwabTest')
AddEventHandler('t1ger_trafficpolicer:sendDrugSwabTest', function(target, provided, onDrugs, BDC)
    local xPlayer = ESX.GetPlayerFromId(target)
    if provided then 
        TriggerClientEvent('t1ger_trafficpolicer:getDrugSwabTestResults', xPlayer.source, BDC)
    else
        TriggerClientEvent('t1ger_trafficpolicer:notify', xPlayer.source, Lang['rejected_bdc_test'])
    end
end)

-- ## CITATIONS ## --
RegisterServerEvent('t1ger_trafficpolicer:sendCitation')
AddEventHandler('t1ger_trafficpolicer:sendCitation', function(target, fine, table, note)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)
    TriggerClientEvent('t1ger_trafficpolicer:receiveCitation', tPlayer.source, tPlayer, xPlayer, fine, table, note)
end)

RegisterServerEvent('t1ger_trafficpolicer:payCitation')
AddEventHandler('t1ger_trafficpolicer:payCitation', function(data, pay)
    local paid = false
    local officer = ESX.GetPlayerFromId(data.officer.source)
    local offender = ESX.GetPlayerFromId(data.offender.source)
    if pay then
        if offender.getAccount('bank').money >= data.fine then
            offender.removeAccountMoney('bank', data.fine)
            TriggerClientEvent('t1ger_trafficpolicer:notify', offender.source, Lang['citiation_signed1'])
            TriggerClientEvent('t1ger_trafficpolicer:notify', officer.source, Lang['citiation_signed2'])
        else
            TriggerClientEvent('t1ger_trafficpolicer:notify', offender.source, Lang['citiation_no_money1'])
            TriggerClientEvent('t1ger_trafficpolicer:notify', officer.source, Lang['citiation_no_money2'])
        end
    else
        TriggerClientEvent('t1ger_trafficpolicer:notify', offender.source, Lang['citiation_not_signed1'])
        TriggerClientEvent('t1ger_trafficpolicer:notify', officer.source, Lang['citiation_not_signed2'])
    end
    -- Insert into Database:
    local offences = json.encode(data.offences)
    MySQL.Async.execute('INSERT INTO t1ger_citations (officer, offender, fine, offences, note, paid) VALUES (@officer, @offender, @fine, @offences, @note, @paid)', {
        ['@officer'] = data.offender.identifier,
        ['@offender'] = data.officer.identifier,
        ['@fine'] = data.fine,
        ['@offences'] = offences,
        ['@note'] = data.note,
        ['@paid'] = pay
    })
end)


-- ## ANPR/ALPR SYSTEM ## --

-- Load ANPR Vehicles:
Citizen.CreateThread(function()
    Citizen.Wait(1000)
	MySQL.Async.fetchAll('SELECT * FROM t1ger_anpr', {}, function(results)
        if #results > 0 then
            for i = 1, #results do
                anpr_table[results[i].plate] = {
                    identifier = results[i].identifier,
                    plate = results[i].plate,
                    stolen = results[i].stolen,
                    bolo = results[i].bolo,
                    warrant = results[i].warrant,
                    owner = results[i].owner
                }
                if Config.T1GER_Insurance then
                    local insurance = MySQL.Sync.fetchAll('SELECT insurance FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
                        ['@owner'] = results[i].identifier,
                        ['@plate'] = results[i].plate}
                    )
                    if insurance[1] then anpr_table[results[i].plate].insurance = insurance[1].insurance end
                end
            end
            TriggerClientEvent('t1ger_trafficpolicer:loadANPR', -1, anpr_table)
        end
    end)
end)

-- Update ANPR Table:
RegisterServerEvent('t1ger_trafficpolicer:updateANPR')
AddEventHandler('t1ger_trafficpolicer:updateANPR', function(plate, type, state)
    local updated = false
    if anpr_table[plate] ~= nil then
        if type == Config.ANPR.args.stolen then
            anpr_table[plate].stolen = state
        elseif type == Config.ANPR.args.bolo then 
            anpr_table[plate].bolo = state
        end
        updated = true
    else
        if type == Config.ANPR.args.stolen then
            anpr_table[plate] = { plate = plate, stolen = state, bolo = false }
        elseif type == Config.ANPR.args.bolo then 
            anpr_table[plate] = { plate = plate, stolen = false, bolo = state }
        end
        local data = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', { ['@plate'] = plate})
        if data[1] then anpr_table[plate].identifier = data[1].owner end
        if Config.T1GER_Insurance then anpr_table[plate].insurance = data[1].insurance end
        MySQL.Async.fetchAll('SELECT owner, plate, firstname, lastname from owned_vehicles t1 INNER JOIN users t2 ON t1.owner = t2.identifier WHERE t1.plate = @plate', {
            ['@plate'] = plate},
        function(data)
            if data[1] then
                local info = {
                    firstname = data[1].firstname,
                    lastname = data[1].lastname
                }
                local owner = json.encode(info)
                anpr_table[plate].owner = owner
                MySQL.Async.execute('INSERT INTO t1ger_anpr (identifier, plate, stolen, bolo, owner) VALUES (@identifier, @plate, @stolen, @bolo, @owner)', {
                    ['@identifier'] = anpr_table[plate].identifier,
                    ['@plate'] = anpr_table[plate].plate,
                    ['@stolen'] = anpr_table[plate].stolen,
                    ['@bolo'] = anpr_table[plate].bolo,
                    ['@owner'] = owner
                })
                updated = true
            end
        end)
    end
    while not updated do
        Wait(10)
    end
    TriggerClientEvent('t1ger_trafficpolicer:loadANPR', -1, anpr_table)
end)


-- ## DB SYNC ## --

-- Function to Save the Data:
function UpdateDatabaseData()
    if anpr_table ~= nil then
        for k,v in pairs(anpr_table) do
            if #anpr_table[k] ~= nil then 
                MySQL.Async.execute('UPDATE t1ger_anpr SET `stolen` = @stolen, `bolo` = @bolo WHERE plate = @plate', {
                    ['@plate'] = anpr_table[k].plate,
                    ['@stolen'] = anpr_table[k].stolen,
                    ['@bolo'] = anpr_table[k].bolo
                })
            end
        end
    end
end

-- Function to run the database sync:
function StartDatabaseSync()
    function SaveData()
        UpdateDatabaseData()
        RconPrint('[SAVED ANPR] All Rows')
        SetTimeout(Config.ANPR.syncDelay * 60 * 1000, SaveData)
    end

    SetTimeout(Config.ANPR.syncDelay * 60 * 1000, SaveData)
end
StartDatabaseSync()
