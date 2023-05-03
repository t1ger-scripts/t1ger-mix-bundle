-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

Config.Debug = true								-- set this to false when u are done testing etc., and putting files in live server.

-- General Settings:
Config.ESXSHAREDOBJECT = 'esx:getSharedObject'	-- set your shared object event in here
Config.ESX_License = true 						-- set this to false if you don't own esx_license (required to show drivers license on PED-LOOKUP)
Config.ProgressBars = true						-- set to false if you have installed my version of progressBars.
Config.T1GER_Insurance = true					-- set to false if you don't own t1ger_insurance
Config.T1GER_Garage = true 						-- set to false if you don't own t1ger_garage (this is required to update impound state on owned vehicles in garage)
Config.T1GER_Keys = true 						-- set to false if you don't own t1ger_keys (this is required to update unlocked state of vehicle)
Config.Jobs = {'police', 'police2'}				-- which police jobs should have access to the features.
Config.BarricadeSystem = false 					-- set to true if u own Marcus' Barricade System (read bottom of README)

-- Menu Settings:
Config.Command = 'traffic'						-- command to use traffic policer menu	
Config.Keybind = 56								-- keybind to open traffic policer menu [DEFAULT: F9]	

-- Player Lookup:
Config.PlayerLookup = {
	delay = 3,									-- time in seconds for dispatch to process the plate check and return results
	notify = {									-- Advanced Notification Settings:
		title = 'Dispatch',
		subtitle = 'Person Check Results',
		iconType = 7,
		textureDict = 'CHAR_CALL911',
		textureName = 'CHAR_CALL911',
		showInBrief = true
	}
}

-- Plate Lookup:
Config.PlateLookup = {
	dist = 40.0,								-- distance from player pos to a vehicle
	delay = 5,									-- time in seconds for dispatch to process the plate check and return results
	notify = {									-- Advanced Notification Settings:
		title = 'Dispatch',
		subtitle = 'Plate Check Results',
		iconType = 7,
		textureDict = 'CHAR_CALL911',
		textureName = 'CHAR_CALL911',
		showInBrief = true
	},
	npc_veh = {
		chance = 75,						-- chance less than this value gives unregistered, means 75% chance for unregistered and 25% chance for stolen
		unreg = '~r~Unregistered~s~',
		stolen = '~r~Stolen~s~'
	},
	insurance = 'Insurance: %s'				-- Requires t1ger_insurance script, shows Insurance: Yes or Insurance: No
}

-- Impound Vehicle:
Config.ImpoundVehicle = {
	dist = 2.0,  							-- distance to a vehicle
	drawText = {
		dist = 2.0,							-- distance to draw text visible
		str = Lang['impound_veh'],			-- draw text 
		keybind = 38,						-- DEFAULT KEY: [E]
		interactDist = 1.0					-- distance to key press works
	},
	freeze = true,							-- freeze while using animation
	scenario = 'CODE_HUMAN_MEDIC_TEND_TO_DEAD',
	progressBar = {
		timer = 4000,
		text = Lang['pb_impouding']
	}
}

-- Unlock Vehicle:
Config.UnlockVehicle = {
	dist = 2.0, 							-- distance to a vehicle
	drawText = {
		dist = 2.0,							-- distance to draw text visible
		str = Lang['unlock_veh'],			-- draw text 
		keybind = 38,						-- DEFAULT KEY: [E]
		interactDist = 1.0					-- distance to key press works
	},
	freeze = true,							-- freeze while using animation
	anim = {dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', lib = 'machinic_loop_mechandplayer'},
	progressBar = {
		timer = 3000,
		text = Lang['pb_unlocking']
	}
}

-- Seize Vehicle [requires t1ger_garage]:
Config.SeizeVehicle = {
	dist = 2.0, 							-- distance to a vehicle
	drawText = {
		dist = 2.0,							-- distance to draw text visible
		str = Lang['seize_veh'],			-- draw text 
		keybind = 38,						-- DEFAULT KEY: [E]
		interactDist = 1.0					-- distance to key press works
	},
	freeze = true,							-- freeze while using animation
	anim = {dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', lib = 'machinic_loop_mechandplayer'},
	progressBar = {
		timer = 3000,
		text = Lang['pb_seizing']
	}
}

-- Breathalyzer:
Config.Breathalyzer = {
	weight = {male = 80, female = 70},		-- set default weight for male/female in kg. [1 kg = 2.20462262 lbs]
	decreaser = 0.005,						-- BAC% value is reduced with this amount for every IRL 2 minutes (2 min = 1 hour in-game)
	tick = 2,								-- set tick for how often it should update and send data to the server. Default is 2 minute, which equals to 1 hour in-game (perfect for BAC calculations.)
	limit = 0.08,							-- set legal limit for BAC%, turns red in notification when exceeded.
	anim = {dict = 'weapons@first_person@aim_rng@generic@projectile@shared@core', lib = 'idlerng_med'},
	progressBar = {
		timer = 4000,
		text = Lang['pb_breathalyzer']
	},
	notify = {									-- Advanced Notification Settings:
		title = 'Breathalyzer',
		subtitle = '~y~Estimated BAC Results~s~',
		iconType = 7,
		textureDict = 'CHAR_BLOCKED',
		textureName = 'CHAR_BLOCKED',
		showInBrief = true
	},
}

-- Drug Swab:
Config.DrugSwab = {
	labels = {
		'Cannabis',
		'Cocaine',
		'Meth'
	},				-- add all your labels used for drugs in here, it's important they match whatever label u add in the triggerclientevent inside the usable item.
					--U can use same label for multiple drugs as well.

	decreaser = 1,	-- set value which drug duration is decreased with for every tick (DEFAULT is 2 min = 1 hour-ingame)
	tick = 2,		-- set tick for how often it should update and send data to the server. Default is 2 minute, which equals to 1 hour in-game (perfect for BAC calculations.)
	anim = {dict = 'weapons@first_person@aim_rng@generic@projectile@shared@core', lib = 'idlerng_med'},
	progressBar = {
		timer = 4000,
		text = Lang['pb_drugswab']
	},
	notify = {									-- Advanced Notification Settings:
		title = 'Drug Swab Kit',
		subtitle = '~y~Narcotic Test Results~s~',
		iconType = 7,
		textureDict = 'DIA_DEALER',
		textureName = 'DIA_DEALER',
		showInBrief = true
	},
	result = {negative = '~g~Negative~s~', positive = '~r~Positive~s~'}
}

Config.ANPR = {
	command = {
		enable = true,
		str = 'anpr'				-- command to activate/deactivate ANPR
	},
	keybind = {
		enable = true,
		key = 168					-- keybind to activate/deactivate ANPR 
	},	
	args = {
		stolen = 'stolen',			-- arg to set stolen state
		bolo = 'bolo',				-- arg to set bolo state
	},
	whitelist = {					-- vehicles which ANPR works in
		'POLICE', 'POLICE2', 'POLICE3', 'POLICE4'
	},
	radius = 3.0,					-- Raycast Radius 
	range = 100.0,					-- Front End Range for ANPR
	notify = {						-- Advanced Notification Settings:
		title = 'ANPR System',
		iconType = 6,
		textureDict = 'DIA_CAMCREW',
		textureName = 'DIA_CAMCREW',
		showInBrief = true
	},
	hitSound = {
		dict = 'PIN_BUTTON',
		lib = 'ATM_SOUNDS',
		count = 3,				-- count in the loop, how many times should it play?
		delay = 200				-- delay in ms between the PlaySoundFrontend calls
	},
	labels = {					-- Add label text for each value, this is the message shown in the advanced notification when a hit is found
		stolen = 'Stolen',
		bolo = 'BOLO',
		uninsured = 'Uninsured'
	},
	sound = {
		activate = {dict = 'THERMAL_VISION_GOGGLES_ON_MASTER', lib = ''},
		deactivate = {dict = 'THERMAL_VISION_GOGGLES_OFF_MASTER', lib = ''}
	},
	syncDelay = 2 -- time in minutes to updates rows in database table
}

Config.Citations = {
	['Public'] = {
		[1] = {offence = 'Contempt of Cop', amount = 200, added = false},
		[2] = {offence = 'Disorderly Conduct', amount = 800, added = false},
		[3] = {offence = 'Dog without Leash', amount = 100, added = false},
		[4] = {offence = 'Illegal Campfire', amount = 2000, added = false},
		[5] = {offence = 'Illegal Camping', amount = 1000, added = false},
		[6] = {offence = 'Illegal Dumping', amount = 2500, added = false},
		[7] = {offence = 'Illegal Protesting', amount = 1000, added = false},
		[8] = {offence = 'Jaywalking', amount = 500, added = false},
		[9] = {offence = 'Littering', amount = 1000, added = false},
		[10] = {offence = 'Loitering', amount = 100, added = false},
		[11] = {offence = 'Mischief', amount = 3500, added = false},
		[12] = {offence = 'Public Exposure', amount = 1000, added = false},
		[13] = {offence = 'Public Intoxication', amount = 1000, added = false},
		[14] = {offence = 'Public Urination', amount = 1000, added = false},
		[15] = {offence = 'Spraying Graffiti', amount = 7000, added = false},
		[16] = {offence = 'Trespassing', amount = 1000, added = false}
	},
	['Speeding'] = {
		[1] = {offence = 'Speeding (1-15)', amount = 215, added = false},
		[2] = {offence = 'Speeding (Between 16-25)', amount = 360, added = false},
		[3] = {offence = 'Speeding (Over 26+)', amount = 480, added = false}
	},
	['Operation'] = {
		[1] = {offence = 'Littering on Highway', amount = 500, added = false},
		[2] = {offence = 'Earplugs Covering Both Ears', amount = 200, added = false},
		[3] = {offence = 'Driving without Helmet', amount = 200, added = false},
		[4] = {offence = 'Driving in a Bus Lane', amount = 200, added = false},
		[5] = {offence = 'Train Track Trespassing', amount = 6000, added = false},
		[6] = {offence = 'Improper Lane Change', amount = 100, added = false},
		[7] = {offence = 'Improper Passing', amount = 150, added = false},
		[8] = {offence = 'Improper Turn', amount = 250, added = false},
		[9] = {offence = 'Unsafe Operation on Highway', amount = 250, added = false},
		[10] = {offence = 'Violation of Right of Way', amount = 150, added = false},
		[11] = {offence = 'Careless Driving', amount = 200, added = false},
		[12] = {offence = 'Following too Closely', amount = 300, added = false},
		[13] = {offence = 'Crossing a Double Yellow', amount = 250, added = false},
		[14] = {offence = 'Crossing a Center Divider', amount = 150, added = false},
		[15] = {offence = 'Crossing a Median', amount = 150, added = false},
		[16] = {offence = 'Crossing a Gore', amount = 150, added = false},
		[17] = {offence = 'Failure to Signal', amount = 300, added = false},
		[18] = {offence = 'Failure to Yield', amount = 300, added = false},
		[19] = {offence = 'Failure to Stop', amount = 300, added = false},
		[20] = {offence = 'Failure to Yield for a Pedestrian', amount = 300, added = false},
		[21] = {offence = 'Using a Cellphone', amount = 250, added = false},
		[22] = {offence = 'Driving on the Shoulder', amount = 150, added = false},
		[23] = {offence = 'Using a Cellphone', amount = 250, added = false},
		[24] = {offence = 'At Fault in an Accident', amount = 300, added = false},
		[25] = {offence = 'Failure to Stop at a Traffic Signal', amount = 500, added = false}
	},
	['Operation (Arrestable)'] = {
		[1] = {offence = 'Speeding (Over 100)', amount = 1000, added = false},
		[2] = {offence = 'Driving Wrong Way', amount = 400, added = false},
		[3] = {offence = 'Street Racing', amount = 3000, added = false},
		[4] = {offence = 'Reckless Driving', amount = 1000, added = false},
		[5] = {offence = 'Leaving the Scene of an Accident', amount = 2500, added = false},
		[6] = {offence = 'Driving While License Suspended', amount = 400, added = false},
		[7] = {offence = 'Driving While License Revoked', amount = 400, added = false},
		[8] = {offence = 'Driving Under the Influence', amount = 1500, added = false}
	},
	['Parking Violations'] = {
		[1] = {offence = 'Block Access to Disabled Space', amount = 500, added = false},
		[2] = {offence = 'Curb Parking', amount = 75, added = false},
		[3] = {offence = 'Double-Parking', amount = 85, added = false},
		[4] = {offence = 'Parked in Opposite Direction of Traffic', amount = 90, added = false},
		[5] = {offence = 'Parked on Designated Disabled Space', amount = 500, added = false},
		[6] = {offence = 'Parking (Un)loading Zone', amount = 550, added = false},
		[7] = {offence = 'Parking in front of Fire Hydrants', amount = 150, added = false},
		[8] = {offence = 'Parking Near a Fire Station Driveway', amount = 85, added = false},
		[9] = {offence = 'Parking Blocking Excavation', amount = 100, added = false},
		[10] = {offence = 'Parking Blocking a Driveway', amount = 100, added = false},
		[11] = {offence = 'Parking on an Intersection', amount = 100, added = false},
		[12] = {offence = 'Parking Near Sidewalk Access Ramp', amount = 495, added = false},
		[13] = {offence = 'Parking No-Parking Zone', amount = 750, added = false},
		[14] = {offence = 'Parking On or Blocking Crosswalk', amount = 100, added = false},
		[15] = {offence = 'Parking Posted Fire Lane', amount = 150, added = false},
		[16] = {offence = 'Parking Upon Bridge', amount = 85, added = false},
		[17] = {offence = 'Parking Upon or Near Railroad Track', amount = 100, added = false},
		[18] = {offence = 'Parking in Bike Lane', amount = 75, added = false},
		[19] = {offence = 'Parking in Tube or Tunnel', amount = 85, added = false},
		[20] = {offence = 'Parking on Left on One-Way Street', amount = 85, added = false},
		[21] = {offence = 'Parking on Sidewalk', amount = 90, added = false}
	},
	['Equipment'] = {
		[1] = {offence = 'Failure to Display License Plates', amount = 300, added = false},
		[2] = {offence = 'Failure to Secure a Load', amount = 175, added = false},
		[3] = {offence = 'Unroadworthy Vehicle', amount = 1000, added = false},
		[4] = {offence = 'Safety Belt Violation', amount = 150, added = false},
		[5] = {offence = 'Lighting Violation', amount = 100, added = false},
		[6] = {offence = 'Neon / Underglow Lighting', amount = 450, added = false},
		[7] = {offence = 'Unlawful Material on Windows', amount = 180, added = false},
		[8] = {offence = 'Broken Tail Light (Right)', amount = 250, added = false},
		[9] = {offence = 'Broken Tail Light (Left)', amount = 250, added = false},
		[10] = {offence = 'Broken Headlight (Right)', amount = 250, added = false},
		[11] = {offence = 'Broken Headlight (Left)', amount = 250, added = false},
		[12] = {offence = 'Broken Windshield', amount = 500, added = false},
		[13] = {offence = 'Broken Windows', amount = 250, added = false},
		[14] = {offence = 'Broken Engine', amount = 250, added = false}
	},
	['Documentation'] = {
		[1] = {offence = 'Driving without License', amount = 1000, added = false},
		[2] = {offence = 'Driving without Registration', amount = 500, added = false},
		[3] = {offence = 'Driving without Insurance', amount = 1800, added = false},
		[4] = {offence = 'Failure to Present Insurance', amount = 800, added = false},
		[5] = {offence = 'Failure to Present Registration', amount = 250, added = false},
		[6] = {offence = 'Expired Insurance', amount = 250, added = false},
		[7] = {offence = 'Expired Registration', amount = 250, added = false},
		[8] = {offence = 'Expired Drivers License', amount = 250, added = false},
		[9] = {offence = 'Expired Vehicle Tag', amount = 250, added = false}
	},
}