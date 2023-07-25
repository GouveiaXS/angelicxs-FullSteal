ESX = nil
QBcore = nil

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-FullSteal:OwnedVehicle:ESX',function(source, cb, plate)
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate,
            }, function (result)
                TriggerClientEvent('angelicxs-FullSteal:NotifyOwner',-1,result.owner, plate)
                cb(result)
        end)
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-FullSteal:OwnedVehicle:QBCore', function(source, cb, plate)
        MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = @plate', {
            ['@plate'] = plate,
            }, function (result)
                TriggerClientEvent('angelicxs-FullSteal:NotifyOwner',-1,result.citizenid, plate)
                cb(result)
        end)
    end)
end


--- Are LEOs Available

if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-FullSteal:PoliceAvailable:ESX',function(source,cb)
        local xPlayers = ESX.GetPlayers()
        local cops = 0

        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            for i = 1, #Config.LEOJobName do
                if xPlayer.job.name == Config.LEOJobName[i] then
                    cops = cops + 1
                end
            end
        end
        
        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-FullSteal:PoliceAvailable:QBCore', function(source, cb)
        local cops = 0
        local players = QBCore.Functions.GetQBPlayers()
        for k, v in pairs(players) do
            for i = 1, #Config.LEOJobName do
                if v.PlayerData.job.name == Config.LEOJobName[i] then
                    cops = cops + 1
                end
            end
        end

        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
end

-- VIN Scratch Checker

RegisterServerEvent('angelicxs-FullSteal:Server:CheckVIN')
AddEventHandler('angelicxs-FullSteal:Server:CheckVIN', function(plate)
    local src = source
    local stolen = 0
    if Config.UseESX then
        MySQL.Async.fetchAll('SELECT scratched FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate,
            }, function (result)
            local owner = table.unpack(result)
            if owner ~= nil then 
                if owner.scratched == 1 then
                    stolen = 1
                end
            else 
                stolen = 0
            end
        end)
    elseif Config.UseQBCore then
        MySQL.Async.fetchAll('SELECT scratched FROM player_vehicles WHERE plate = @plate', {
            ['@plate'] = plate,
            }, function (result)
            local owner = table.unpack(result)
            if owner ~= nil then 
                if owner.scratched == 1 then
                    stolen = 1
                end
            else 
                stolen = 0
            end
        end)
    end 
    TriggerClientEvent('angelicxs-FullSteal:CheckVINConfirmation', src, stolen)
end)

--- Rewards
RegisterServerEvent('angelicxs-FullSteal:Server:KeepPlayerScratch')
AddEventHandler('angelicxs-FullSteal:Server:KeepPlayerScratch', function(VehiclePlate, src)
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        MySQL.Async.execute('UPDATE owned_vehicles SET owner = @owner WHERE plate = @plate', {
            ['@owner']   = xPlayer.identifier,
            ['@plate']   = plate,
            }, function(rowsChanged)
            if Config.VINCheck then
                MySQL.Async.execute('UPDATE owned_vehicles SET scratched = 1 WHERE plate @plate',
                {['@plate'] = plate, }, function (rowsChanged) end)
            end
        end)
    elseif Config.UseQBCore then
        local pData = QBCore.Functions.GetPlayer(src)
        MySQL.Async.execute('UPDATE player_vehicles SET citizenid = @citizenid WHERE plate = @plate', {
            ['@citizenid'] = pData.PlayerData.citizenid,
            ['@plate'] = plate,
            }, function (rowsChanged)
            if Config.VINCheck then
                MySQL.Async.execute('UPDATE player_vehicles SET scratched = 1 WHERE plate @plate',
                {['@plate'] = plate, }, function (rowsChanged) end)
            end
        end)
    end
end)

RegisterServerEvent('angelicxs-FullSteal:Server:KeepScratch')
AddEventHandler('angelicxs-FullSteal:Server:KeepScratch', function(VehiclePlate, PlayerOwned)
    if PlayerOwned then
        local src = source
        TriggerEvent('angelicxs-FullSteal:Server:KeepPlayerScratch', VehiclePlate, src)
        return
    end
    if Config.VINCheck then
        if Config.UseESX then
            local xPlayer = ESX.GetPlayerFromId(source)
            MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, scratched) VALUES (@owner, @plate, @vehicle, @scratched)', {
                ['@owner']   = xPlayer.identifier,
                ['@plate']   = VehiclePlate.plate,
                ['@vehicle'] = json.encode(VehiclePlate),
                ['@scratched'] = 1
                }, function(rowsChanged)
            end)
        elseif Config.UseQBCore then
            local vehicle = VehiclePlate
            local pData = QBCore.Functions.GetPlayer(source)
            local cid = pData.PlayerData.citizenid
            local plate = PlateQBGen()
            MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage, scratched) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state, @garage, @scratched)', {
                ['@license'] = pData.PlayerData.license,
                ['@citizenid'] = cid,
                ['@vehicle'] = VehiclePlate.model,
                ['@hash'] = GetHashKey(VehiclePlate.model),
                ['@mods'] = '{}',
                ['@plate'] = plate,
                ['@state'] = 1,
                ['@garage'] = "pillboxgarage",
                ['@scratched'] = 1
                }, function(rowsChanged)
            end)
        end
    else
        if Config.UseESX then
            local xPlayer = ESX.GetPlayerFromId(source)
            MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
                ['@owner']   = xPlayer.identifier,
                ['@plate']   = VehiclePlate.plate,
                ['@vehicle'] = json.encode(VehiclePlate)
                }, function(rowsChanged)
            end)
        elseif Config.UseQBCore then
            local vehicle = VehiclePlate
            local pData = QBCore.Functions.GetPlayer(source)
            local cid = pData.PlayerData.citizenid
            local plate = PlateQBGen()
            MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state, @garage)', {
                ['@license'] = pData.PlayerData.license,
                ['@citizenid'] = cid,
                ['@vehicle'] = VehiclePlate.model,
                ['@hash'] = GetHashKey(VehiclePlate.model),
                ['@mods'] = '{}',
                ['@plate'] = plate,
                ['@state'] = 1,
                ['@garage'] = "pillboxgarage"
                }, function(rowsChanged)
            end)
        end
    end
end)

RegisterServerEvent('angelicxs-FullSteal:Server:Completion')
AddEventHandler('angelicxs-FullSteal:Server:Completion', function()
    local funds = Config.MoneyAmount
    if Config.RandomMoneyAmount then
        funds = (math.random(Config.RandomMoneyAmountMin, Config.RandomMoneyAmountMax))
    end
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.addAccountMoney(Config.AccountMoney,funds)
    elseif Config.UseQBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddMoney(Config.AccountMoney, funds)
    end
end)

-- Global Syncs

RegisterServerEvent('angelicxs-FullSteal:Server:NotifyPolice')
AddEventHandler('angelicxs-FullSteal:Server:NotifyPolice', function(msg,data)
	TriggerClientEvent('angelicxs-FullSteal:NotifyPolice',-1,msg,data)
end)

RegisterServerEvent('angelicxs-FullSteal:Server:TrackerCoords')
AddEventHandler('angelicxs-FullSteal:Server:TrackerCoords', function(coords)
	TriggerClientEvent('angelicxs-FullSteal:TrackingVehicle',-1,coords)
end)

if Config.UseESX then
	ESX.RegisterUsableItem(Config.HotWireName, function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
        if Config.RemoveHotWire then
            local chance = math.random(0,100)
            if chance <= Config.RemoveChance then
		        xPlayer.removeInventoryItem(Config.HotWireName, 1)
                TriggerClientEvent('angelicxs-FullSteal:Notify',source, Config.Lang['itembreak'], Config.LangType['info'])
                return
            end
        end
        TriggerClientEvent('angelicxs-FullSteal:Notify',source, Config.Lang['used'], Config.LangType['success'])
        TriggerClientEvent('angelicxs-FullSteal:RobberyCheck', source)       
	end)
elseif Config.UseQBCore then
    function PlateQBGen()
        local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
        local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
        if result then
            return PlateQBGen()
        else
            return plate:upper()
        end
    end
    QBCore.Functions.CreateUseableItem(Config.HotWireName, function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if Config.RemoveHotWire then
            local chance = math.random(0,100)
            if chance <= Config.RemoveChance then
                Player.Functions.RemoveItem(Config.HotWireName, 1,item.slot)
                TriggerClientEvent('angelicxs-FullSteal:Notify',source, Config.Lang['itembreak'], Config.LangType['info'])
                return
            end
        end
        TriggerClientEvent('angelicxs-FullSteal:Notify',source, Config.Lang['used'], Config.LangType['success'])
        TriggerClientEvent('angelicxs-FullSteal:RobberyCheck', source)       
    end)
end
