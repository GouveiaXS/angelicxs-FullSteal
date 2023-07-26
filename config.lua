----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
----------------------------------------------------------------------
-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}


Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.

-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-FullSteal:CustomNotify')
AddEventHandler('angelicxs-FullSteal:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

-- Visual Preference
Config.Use3DText = true 					-- Use 3D text for NPC interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication

-- Item Requirement
Config.HotWireName = 'vin_scratcher'			-- Name of the stealing device
Config.RemoveHotWire = true					-- If true will remove Config.HotWireName upon use
Config.RemoveChance = 0					-- 0-100% Chance to remove the item on use
Config.GameWins = 4						-- Amount of times required to sucessfully beat the hack

--LEO Configuration
Config.RequireMinimumLEO = false 			-- When on will require a minimum number of LEOs to be available to start robbery
Config.RequiredNumberLEO = 2 				-- Minimum number of LEO needed for robbery to start when Config.RequireMinimumLEO = true
Config.LEOJobName = {'police','bcso'} 		-- Job name of law enforcement officers (NOW TYPE)
Config.PoliceDispatch = false 				-- If true, will turn off police messaging through notifications and ONLY use custom dispatch system (must fill event out below).
Config.VINCheck = false						-- If true, allows LEOs to check if vehicles have been scratched.
											-- ** IF Config.VINCheck = true YOU MUST ADD 'scratched' AS A COLUMN TO YOUR VEHICLES TABLE.
											------- ALTER TABLE `PLAYERTABLENAME`
											------- ADD `scratched` int(11) NOT NULL DEFAULT 0;
											-- If help is required to implement join discord.
Config.VINCommand = true					-- If true, allows / command to check VINs.
Config.VINCommandWord = 'vincheck'			-- Word used for / command to check VIN.

-- Only complete this event if Config.PoliceDispatch is true
RegisterNetEvent('angelicxs-FullSteal:CustomDisptachFoundIt')
AddEventHandler('angelicxs-FullSteal:CustomDisptachFoundIt', function(coordz)
	--DISPATCH EXPORT HERE
	-- CD_DISPATCH EXAMPLE BELOW
--[[ 	local data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = {'police', 'bcso'}, 
        coords = coordz,
        title = '10-60A - High Priority Car Theft',
        message = 'Reports of a '..data.sex..' attempting to steal a high priority vehicle near '..data.street, 
        flash = 0,
        unique_id = tostring(math.random(0000000,9999999)),
        blip = {
            sprite = 225, 
            scale = 1.2, 
            colour = 5,
            flashes = false, 
            text = '10-60A - High Priority Car Theft',
            time = (5*60*1000),
            sound = 1,
        }
    }) ]]
end)

--Inital Difficulty Configuration
Config.TimetoRoute = 0 						-- How long in minutes, until the drop off point is shown.

-- Rewards Configuration
Config.AllowKeepingVehicle = true 			-- When true will allow individuals to keep the vehicle instead of gaining rep and other rewards.
Config.AllowKeepingPlayerVehicle = false	-- If true will allow players to STEAL vehicles from each other, requires Config.AllowKeepingVehicle = true
Config.AccountMoney = 'cash' 				-- How you want the delivery paid.
Config.MoneyAmount = 5000 					-- If Config.RandomMoneyAmount = false, Amount paid out in Config.AccountMoney for a successful delivery.
Config.RandomMoneyAmount = true 			--If true, will randomly award money ammount on successful completion instead of Config.MoneyAmount.
Config.RandomMoneyAmountMin = 1000 			-- Minimum money gained on successful completion.
Config.RandomMoneyAmountMax = 10000 		-- Maximum money gained on successful completion.

--Failure Configuration
Config.NoVehicleChange = true 				-- When true (recommended), will cause robbery to fail if robber gets in a different vehicle after breaking into the mission vehicle.
Config.DamagedVehicle = true 				-- When true, allows vehicle to be badly damaged and still delivered.
Config.DamagedVehicleHealth = 0 			-- If Config.DamagedVehicle = false, sets the lowest amount of health a vehicle can have and still to be delivered.
Config.TimeLimitedEvent = true 				-- When true (recommended), enables a time limit for delivery.
Config.TimeLimit = 60 						-- If Config.TimeLimitedEvent = true, then in minutes, how long do the robbers have complete the heist before they fail.

-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

-- Drop Off NPC
Config.DropOffModel = 's_m_m_dockwork_01'
Config.DropOffSpot = {
	vector4(-526.9728, -1623.6243, 17.7979, 106.7411),	-- Scrapyard			Postal 9002
	vector4(1397.1909, 3625.6697, 35.0120, 347.3209),	-- Sandy Old Store 		Postal 3025
	vector4(-17.8897, 6199.3979, 31.2398, 33.5448), 	-- Plaeto Train Yard  	Postal 1023
}

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['itembreak'] = 'The item broke during your attempt to use it.',
	['used'] = 'Attempting to confirm solid signal connection!',
	['mincops'] = 'Not enough cop signals to hide hijacking signals in the air; aborting.',
	['startconfirm'] = 'Signal strength confirmed, beginning hack.',
	['startmessage'] = 'A vehicle with license plate ',
	['startlocation'] = ' is being stolen at ',
	['cornerof'] = 'corner of ',
	['and'] = ' and ',
	['highprio'] = 'This is a high priority theft!',
	['startlocation'] = ' is being stolen at ',
	['dropvehicle'] = 'Drop Off Vehicle.',
	['keepvehicle'] = 'Keep Vehicle!',
	['dropoff'] = 'Press ~r~[E]~w~ to drop off vehicle. \n Press ~r~[G]~w~ to keep scratch for your own.',
	['find_dropoff'] = 'Looking for a drop off point now, I will send it to you in a few minutes!',
	['droppoint_given'] = 'I found a spot, head there now!',
	['delivery_blip'] = 'Drop off location.',
	['failed_vehicleswap'] = 'Robbery failed as you got in a different vehicle.',
	['failed_timeup'] = 'Robbery failed as you took to long to deliver the vehicle.',
	['failed_damage'] = 'Robbery failed as the vehicle is too badly damaged to deliver.',
	['reward'] = 'You successfully delivered the vehicle and have been paid out.',
	['finish'] = 'I already dealt with the vehicle, get out of here!',
	['faraway'] = 'Your vehicle is too far away, bring it closer.',
	['no_scratch'] = 'You are responsible for delivery only, no way do you get to keep this.',
	['garage'] = 'The vehicle has been successfully scratched and has been delivered to your garage.',
	['vin_stolen'] = 'This VIN has been scratched off!',
	['vin_good'] = 'This VIN is clearly visable.',
	['far_vin'] = 'Not close enough to check VIN!',
	['failgame'] = 'You failed the hack!',
	['beginstolen'] = 'You vehicle with the following license plate is currently being stolen! License Plate: ',
	['seconds'] = 'seconds!',
	['nextgame'] = 'Next hack in',

}
