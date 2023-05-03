-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

Config.ESXSHAREDOBJECT 		= "esx:getSharedObject"		-- ESX Shared Object (only change incase you are using anti-cheats or custom triggers).
Config.VehiclesTable 		= 'owned_vehicles'			-- database table name for your player owned vehicles.
Config.BuyWithOnlineBrokers = true						-- set to false to prevent players from buying insurance, when brokers are online.
Config.HasModelNameInTable 	= true						-- set to false if u dont have model column in your owned_vehicles table, displaying the model name of the vehicle.

Config.Insurance = {

	job = {
		name = 'insurance',				-- change only if u have changed the job name in database,
		sync_time = 1,					-- timer in minutes to fetch online brokers and send to all clients, don't go below 1.
		society = {						-- requires esx_society
			withdraw  = true,			-- boss can withdraw money from account
			deposit   = true,			-- boss can deposit money into account
			wash      = false,			-- boss can wash money
			employees = true,			-- boss can manage & recruit employees
			grades    = false			-- boss can adjust all salaries for each job grade
		},
		menu = {
			keybind = 167,
			command = 'insurance',
		}
	},

	company = {
		pos = {-291.38,-429.7,30.24},
		menuKey = 38,
		loadDist = 10,
		interactDist = 1.5,
		marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.5, y = 0.5, z = 0.5}, color = {r = 240, g = 52, b = 52, a = 100}},
		blip = {enable = true, sprite = 523, color = 3, label = "Insurance", scale = 0.75, display = 4}
	},

	price = {
		establish = 20,					-- percentage of vehicle price in upfront amount for the insurance agreement.
		subscription = 3,				-- percentage of vehicle price as payment every x salary clicks.

		-- if not having model name in database, then below fixed amounts are used:
		upfront = 2000,					-- fixed price to establish an insurance agreement
		payment = 150					-- fixed price as payment every x salary clicks.
	},
	
	paper = {
		keyToHidePaper = 177			-- DEFAULT BACKSPACE, ESX, RIGHTMOUSE - set key control to hide insurance paper, when it's opened
	}

}
