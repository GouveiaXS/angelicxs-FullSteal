ESX = nil
QBcore = nil
JobType = nil
PlayerJob = nil
PlayerGrade = nil

local isLawEnforcement = false
local DropNPC
local MissionVehicle = nil
local DropLocationNPC = false
local MissionRoute = nil
local Tracker = false
local PlayerOwned = false
local amount = 0
local onMission = false

RegisterNetEvent('angelicxs-FullSteal:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-FullSteal:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
    
        while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        CreateThread(function()
            while true do
                local playerData = ESX.GetPlayerData()
                if playerData ~= nil then
                    PlayerJob = playerData.job.name
                    PlayerGrade = playerData.job.grade
                    isLawEnforcement = LawEnforcement()
                    break
                end
                Wait(100)
            end
        end)
        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade
            isLawEnforcement = LawEnforcement()
        end)

    elseif Config.UseQBCore then

        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerJob = playerData.job.name
					PlayerGrade = playerData.job.grade.level
                    isLawEnforcement = LawEnforcement()
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade.level
            isLawEnforcement = LawEnforcement()
        end)
    end
end)

-- Events


RegisterNetEvent('angelicxs-FullSteal:RobberyCheck', function()
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then 
        TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['invehicle'], Config.LangType['error'])
        return
    end
    local OwnedVehicle, Plate = OwnedVehicleCheck()
    if Config.RequireMinimumLEO then
        if Config.UseESX then
            ESX.TriggerServerCallback('angelicxs-FullSteal:PoliceAvailable:ESX', function(cb)
                StartRobbery = cb
            end)                                    
        elseif Config.UseQBCore then
            QBCore.Functions.TriggerCallback('angelicxs-FullSteal:PoliceAvailable:QBCore', function(cb)
                StartRobbery = cb
            end)
        end
        Wait(1000)
        if StartRobbery then
            TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['startconfirm'], Config.LangType['success'])
            TriggerEvent('angelicxs-FullSteal:Start', Plate)
        else
            TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['mincops'], Config.LangType['error'])
        end
    else
        TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['startconfirm'], Config.LangType['success'])
        TriggerEvent('angelicxs-FullSteal:Start', Plate)
    end
end)

function OwnedVehicleCheck()
    local VehicleStealing = nil
    local Plate = nil
    local OwnedVehicle = 'check'
    if Config.UseESX then
        VehicleStealing = ESX.Game.GetClosestVehicle()
        local VehicleData = ESX.Game.GetVehicleProperties(VehicleStealing)
        Plate = VehicleData.plate
        ESX.TriggerServerCallback('angelicxs-FullSteal:OwnedVehicle:ESX', function(cb)
            OwnedVehicle = cb
        end, Plate) 
    elseif Config.UseQBCore then
        VehicleStealing = QBCore.Functions.GetClosestVehicle()
        local VehicleData = QBCore.Functions.GetVehicleProperties(VehicleStealing)
        Plate = VehicleData.plate
        QBCore.Functions.TriggerCallback('angelicxs-FullSteal:OwnedVehicle:QBCore', function(cb)
            OwnedVehicle = cb
        end, Plate)
    end 
    while OwnedVehicle == 'check' do Wait(10) end
    if not Plate then print('Plate Check Error') return end
    MissionVehicle = VehicleStealing
    PlayerOwned = OwnedVehicle
    return OwnedVehicle, Plate
end


RegisterNetEvent('angelicxs-FullSteal:Start',function(nature)
    if not nature then print('Abuse Attempt Detected') return end
    local data = {}
    data.plate = nature
    data.coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('angelicxs-FullSteal:Server:NotifyPolice',1,data)
    TriggerEvent('angelicxs-FullSteal:CustomDisptachFoundIt',Pos)
    TriggerEvent('angelicxs-FullSteal:FailConditions')
    Hotwire(data)
end)

function Hotwire()
    local Player = PlayerPedId()
    local Pos = GetEntityCoords(Player)
    FreezeEntityPosition(Player, true)
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Wait(10)
    end
    TaskPlayAnim(Player,"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",1.0, -1.0, -1, 49, 0, 0, 0, 0)
    RemoveAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    gamePlay()
end

function gamePlay()
    if onMission then return end
    ------------------------
    ------ GAME HERE -------
    ------------------------
    local time = 30
    local nextgame = false
    local notation = exports['ps-ui']:Scrambler(function(success)
        if success then
            amount = amount + 1
            nextgame = true
            if amount == Config.GameWins then
                nextgame = false
                amount = 0
                minigameWin()
            else
                TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['nextgame']..' '..time..' '..Config.Lang['seconds'], Config.LangType['info'])
            end
        else
            amount = 0
            minigameLose()
        end
    end, "alphanumeric", time, 0) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
    while not notation do
        Wait(1000)
        time = time-1
        if time <=0 then break end
    end
    if nextgame then
        gamePlay()
    end
    ------------------------
    ------ GAME HERE -------
    ------------------------
end

function minigameWin()
    onMission = true
    local Player = PlayerPedId()
    ClearPedTasks(Player)
    FreezeEntityPosition(Player, false)
    local EndPoint = DropOff()
    TriggerEvent('angelicxs-FullSteal:GPSRoute',EndPoint, MissionVehicle)
end

function minigameLose()
    local Player = PlayerPedId()
    MissionVehicle = nil
    ClearPedTasks(Player)
    FreezeEntityPosition(Player, false)
    TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['failgame'], Config.LangType['error'])
end

RegisterNetEvent('angelicxs-FullSteal:NotifyOwner')
AddEventHandler('angelicxs-FullSteal:NotifyOwner',function(id,plate)
    local met = false
    if Config.UseESX then
        local playerData = ESX.GetPlayerData()
        if playerData.identifier == id then 
            met = true
        end
    elseif Config.UseQBCore then
        local playerData = QBCore.Functions.GetPlayerData()
	    if playerData.citizenid == id then 
            met = true
        end
    end 
    if met then
        TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['beginstolen']..tostring(plate), Config.LangType['info'])
    end
end)

RegisterNetEvent('angelicxs-FullSteal:NotifyPolice')
AddEventHandler('angelicxs-FullSteal:NotifyPolice',function(Message, Data)
    if not Config.PoliceDispatch then
        if isLawEnforcement then
            if Message == 1 then
                local street, cross = GetStreetNameAtCoord(Data.coords.x, Data.coords.y, Data.coords.z)
                local name = GetStreetNameFromHashKey(street)
                local name2 = nil
                if cross then name2 = GetStreetNameFromHashKey(cross) end
                if name2 then name = tostring(Config.Lang['cornerof']..name..Config.Lang['and']..name2) end
                TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['failgame']..tostring(Data.plate)..Config.Lang['startlocation']..name..' '..Config.Lang['highprio'], Config.LangType['info'])
            end
        end
    end
end)

RegisterNetEvent('angelicxs-FullSteal:GPSRoute',function(coords, MV)
    local Player = PlayerPedId()
    local DropPed = false
    Tracker = true
    DropLocationNPC = true
    CreateThread(function()
        while DropLocationNPC do
            Player = PlayerPedId()
            local Sleep = 1500
            local Pos = GetEntityCoords(Player)
            local Dist = #(Pos - vector3(coords.x, coords.y, coords.z))
            if Dist <= 100 and not DropPed then
                local hash = HashGrabber(Config.DropOffModel)
                DropNPC = CreatePed(1, hash, coords.x, coords.y, (coords.z-1), coords.w, false, false)
                FreezeEntityPosition(DropNPC, true)
                SetEntityInvincible(DropNPC, true)
                SetBlockingOfNonTemporaryEvents(DropNPC, true)
                TaskStartScenarioInPlace(DropNPC,'WORLD_HUMAN_CLIPBOARD', 0, false)
                SetModelAsNoLongerNeeded(hash)
                DropPed = true
                if Config.UseThirdEye then
                    exports[Config.ThirdEyeName]:AddEntityZone('DROPNPC', DropNPC, {
                        name="DROPNPC",
                        debugPoly=false,
                        useZ = true
                        }, {
                        options = {
                            {
                            icon = 'fas fa-clipboard-list',
                            label = Config.Lang['dropvehicle'], 
                            action = function()
                                TriggerEvent('angelicxs-FullSteal:Completion',coords)
                            end,
                            },
                            {
                            icon = 'fas fa-clipboard-list',
                            label = Config.Lang['keepvehicle'], 
                            action = function()
                                TriggerEvent('angelicxs-FullSteal:KeepScratch',coords)
                            end,
                            },
                            
                        },
                        distance = 2
                    })        
                end
            elseif DoesEntityExist(DropNPC) and DropPed then
                if Dist > 100 then
                    DeleteEntity(DropNPC)
                    DropPed = false
                    if Config.UseThirdEye then
                        exports[Config.ThirdEyeName]:RemoveZone('DROPNPC')
                    end
                end
            end
            Wait(Sleep)
        end
    end)
    CreateThread(function()
        if Config.Use3DText then
            while DropLocationNPC do
                Player = PlayerPedId()
                local Pos3 = GetEntityCoords(Player)
                local Dist3 = #(Pos3 - vector3(coords.x, coords.y, coords.z))
                local sleep = 2000
                if Dist3 <= 20 then
                    sleep = 500
                    if Dist3 <= 3 then
                        sleep = 0
                        DrawText3Ds(coords[1], coords[2], coords[3], Config.Lang['dropoff'])
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent('angelicxs-FullSteal:Completion',coords)
                        elseif IsControlJustReleased(0,47) then
                            TriggerEvent('angelicxs-FullSteal:KeepScratch',coords)
                        end
                    end
                end
                Wait(sleep)
            end
        end
    end)
    CreateThread(function()
        local stolen = MV
        while Tracker do
            Player = PlayerPedId()
            local Sleep = 2000
            local Pos2 = GetEntityCoords(Player)
            local DrivingVehicle = GetVehiclePedIsIn(Player, false)
            if IsPedInAnyVehicle(Player, true) then
                Sleep = 1200
                if DrivingVehicle == stolen then
                    TriggerServerEvent('angelicxs-FullSteal:Server:TrackerCoords', Pos2)
                end
            end
            Wait(Sleep)
        end		
    end)
    TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['find_dropoff'], Config.LangType['info'])
    Wait(Config.TimetoRoute*60*1000)
    TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['droppoint_given'], Config.LangType['info'])
    MissionRoute = AddBlipForCoord(coords[1], coords[2], coords[3])
    SetBlipColour(MissionRoute,5)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Config.Lang['delivery_blip'])
	EndTextCommandSetBlipName(MissionRoute)
	SetBlipRoute(MissionRoute, true)
	SetBlipRouteColour(MissionRoute, 2)
end)

RegisterNetEvent('angelicxs-FullSteal:FailConditions', function()
    local forcefail = false
    CreateThread(function()
        if Config.NoVehicleChange then
            while DoesEntityExist(MissionVehicle) do
                local Player = PlayerPedId()
                if IsPedInAnyVehicle(Player, true) then
                    local DrivingVehicle = GetVehiclePedIsIn(Player, false)
                    if DrivingVehicle ~= 0 then
                        if DrivingVehicle ~= MissionVehicle then
                            TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['failed_vehicleswap'], Config.LangType['error'])
                            TriggerEvent('angelicxs-FullSteal:ResetHeist')
                            forcefail = true
                            onMission = false
                            break
                        end
                    end
                end
            Wait(1000)
            end
        end
    end)
    CreateThread(function()
        if not Config.DamagedVehicle then
            while DoesEntityExist(MissionVehicle) do
                local Player = PlayerPedId()
                local DrivingVehicle = GetVehiclePedIsIn(Player, false)
                if DrivingVehicle ~= 0 then
                    if DrivingVehicle ~= MissionVehicle then
                        local health = GetVehicleBodyHealth(Model)
                        if health <= Config.DamagedVehicleHealth then
                            TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['failed_damage'], Config.LangType['error'])
                            TriggerEvent('angelicxs-FullSteal:ResetHeist')
                            forcefail = true
                            onMission = false
                            break
                        end
                    end
                end
                Wait(500)
            end
        end
    end)
    CreateThread(function()
        if Config.TimeLimitedEvent then
            local TimeLimit = Config.TimeLimit * 60
            while TimeLimit >= 0 do
                Wait(1000)
                TimeLimit = TimeLimit - 1
                if TimeLimit <= 0 then
                    TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['failed_timeup'], Config.LangType['error'])
                    TriggerEvent('angelicxs-FullSteal:ResetHeist')
                    onMission = false
                    forcefail = true
                    break
                elseif forcefail then
                    break
                end
            end
        end
    end)
end)

RegisterNetEvent('angelicxs-FullSteal:TrackingVehicle')
AddEventHandler('angelicxs-FullSteal:TrackingVehicle', function(targetCoords)
	if isLawEnforcement then		
		local Alpha = 160
		local TrackerDevice = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, 50.0)
		SetBlipHighDetail(TrackerDevice, true)
		SetBlipColour(TrackerDevice, 1)
		SetBlipAlpha(TrackerDevice, Alpha)
		SetBlipAsShortRange(TrackerDevice, true)
		while Alpha ~= 0 do
			Wait(50)
			Alpha = Alpha - 1
			SetBlipAlpha(TrackerDevice, Alpha)
			if Alpha == 0 then
				RemoveBlip(TrackerDevice)
				return
			end
		end		
	end
end)

RegisterNetEvent('angelicxs-FullSteal:Completion',function(coords)
    local Player = PlayerPedId()
    local Vehicle = GetVehiclePedIsIn(Player, true)
    local Dist = #(GetEntityCoords(Vehicle) - vector3(coords.x, coords.y, coords.z))
    if Dist <= 15 and DoesEntityExist(MissionVehicle) then
        onMission = false
        RemoveBlip(MissionRoute)
        DeleteVehicle(MissionVehicle)
        TriggerServerEvent('angelicxs-FullSteal:Server:Completion')
        TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['reward'], Config.LangType['success'])
        TriggerEvent('angelicxs-FullSteal:ResetHeist')
        if Config.UseThirdEye then
            exports[Config.ThirdEyeName]:RemoveZone('DROPNPC')
        end
        SetEntityAsNoLongerNeeded(DropNPC)
    elseif Dist <= 15 and not DoesEntityExist(MissionVehicle) then
        TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['finish'], Config.LangType['error'])
    else
        TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['faraway'], Config.LangType['error'])
    end 
end)

RegisterNetEvent('angelicxs-FullSteal:KeepScratch',function(coords)
    local Player = PlayerPedId()
    local Vehicle = GetVehiclePedIsIn(Player, true)
    local Dist = #(GetEntityCoords(Vehicle) - vector3(coords.x, coords.y, coords.z))
    if not Config.AllowKeepingPlayerVehicle and PlayerOwned or not Config.AllowKeepingVehicle then
        TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['no_scratch'], Config.LangType['error'])
        return
    end
    if Dist <= 15 and DoesEntityExist(MissionVehicle) then
        if Config.UseESX then
            local VehiclePlate = ESX.Game.GetVehicleProperties(MissionVehicle)
            TriggerServerEvent('angelicxs-FullSteal:Server:KeepScratch', VehiclePlate, PlayerOwned)
        elseif Config.UseQBCore then
            local VehiclePlate = QBCore.Functions.GetVehicleProperties(MissionVehicle)
            TriggerServerEvent('angelicxs-FullSteal:Server:KeepScratch', VehiclePlate, PlayerOwned)
        end
        RemoveBlip(MissionRoute)
        DeleteVehicle(MissionVehicle)
        onMission = false
        TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['garage'], Config.LangType['success'])
        TriggerEvent('angelicxs-FullSteal:ResetHeist')
        if Config.UseThirdEye then
            exports[Config.ThirdEyeName]:RemoveZone('DROPNPC')
        end
        SetEntityAsNoLongerNeeded(DropNPC)
    else
        TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['faraway'], Config.LangType['error'])
    end 
end)
	

RegisterNetEvent('angelicxs-FullSteal:ResetHeist')
AddEventHandler('angelicxs-FullSteal:ResetHeist', function(mv)
    if MissionVehicle ~= nil then
        MissionVehicle = nil
    end
    if MissionRoute ~= nil then
        RemoveBlip(MissionRoute)
        MissionRoute = nil
    end
    DropLocationNPC = false
    Tracker = false
    onMission = false
end)

RegisterNetEvent('angelicxs-FullSteal:CheckVIN',function()
    if isLawEnforcement then
        local Player = PlayerPedId()
        local PlayerCoods = GetEntityCoords(Player)
        if Config.UseESX then
            local VehicleData = ESX.Game.GetClosestVehicle()
            local dist = #(PlayerCoods - GetEntityCoords(VehicleData))
            if dist <= 3 then
                local VehiclePlate = ESX.Game.GetVehicleProperties(VehicleData)
                TriggerServerEvent('angelicxs-FullSteal:Server:CheckVIN', VehiclePlate.plate)
            else
                TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['far_vin'],Config.LangType['info'])
            end
        elseif Config.UseQBCore then
            local VehicleData = QBCore.Functions.GetClosestVehicle()
            local dist = #(PlayerCoods - GetEntityCoords(VehicleData))
            if dist <= 3 then
                local plate = QBCore.Functions.GetPlate(VehicleData)
                TriggerServerEvent('angelicxs-FullSteal:Server:CheckVIN', plate)
            else
                TriggerEvent('angelicxs-FullSteal:Notify',Config.Lang['far_vin'],Config.LangType['info'])
            end
        end
    end
end)

RegisterNetEvent('angelicxs-FullSteal:CheckVINConfirmation')
AddEventHandler('angelicxs-FullSteal:CheckVINConfirmation', function(result)
    if result == 1 then
        TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['vin_stolen'], Config.LangType['error'])
    else
        TriggerEvent('angelicxs-FullSteal:Notify', Config.Lang['vin_good'], Config.LangType['success'])
    end
end)

CreateThread(function()
    if Config.VINCheck then
        if Config.VINCommand then
            RegisterCommand(Config.VINCommandWord, function()
                TriggerEvent('angelicxs-FullSteal:CheckVIN')
            end)
        end
        if Config.UseThirdEye then
            exports[Config.ThirdEyeName]:AddGlobalVehicle({
                options = {
                    {
                        event = "angelicxs-FullSteal:CheckVIN",
                        icon = "fa-solid fa-arrows-to-eye",
                        label = "Check VIN Status",
                        job = Config.LEOJobName,
                    },
                },
                distance = 2,
            })
        end
    end
end)


-- Functions

function LawEnforcement()
    for i = 1, #Config.LEOJobName do
        if PlayerJob == Config.LEOJobName[i] then
            return true
        end
    end
    return false
end

function DropOff()
    local List = Config.DropOffSpot
    local Number = 0

    local Selection = math.random(1, #List)
    for i = 1, #List do
        local Destination = List[i]
        Number = Number + 1
        if Number == Selection then
            Number = 0
            return Destination
        end
    end
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

-- 3D Text Functionality
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        TriggerEvent('angelicxs-FullSteal:ResetHeist')
    end
end)
