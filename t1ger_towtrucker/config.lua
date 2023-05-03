-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {
	Debug = true, -- allows you to restart script while in-game, otherwise u need to restart fivem.
    ProgressBars = true, -- set to false if you do not use progressBars or using your own
	T1GER_Keys = true, -- true/false whether you own or not own t1ger-keys
	T1GER_Garage = true, -- true/false whether you own or not own t1ger-garage
	T1GER_Dealerships = true, -- true/false whether you own or not own t1ger-dealerships
	BuyWithBank = true, -- buy tow service with bank money, false = cash.
	SalePercentage = 0.75, -- Means player gets 75% in return from original paid price.
	AccountsInCash = false, -- Set to false to deposit/withdraw money into and from shop account with bank-money instead of cash money.
	PayBillsWithBank = true, -- Pay bills with bank, set to false to pay with cash.
	BillPercentToService = 25, -- Set percent value (0-100) of how much goes to service/company and how much to towtrucker player. 25 means: 25 to service, 75 to player
	InteractionMenuCmd = 'towtrucker', -- command to open towtrucking menu	
}

-- Tow Services:
Config.TowServices = {
    [1] = {
		society = 'towtrucker1', -- this must match an identifier name inside Config.Society!
		price = 25000, -- price of the company.
		owned = false, -- do not touch this!
		boss_pos = vector3(495.69,-1340.49,29.31), -- boss/purchase menu pos
		impound_pos = vector4(494.94,-1323.19,29.26,358.6), -- impound pos/data
	},
    [2] = {
		society = 'towtrucker2', -- this must match an identifier name inside Config.Society!
		price = 28000, -- price of the company.
		owned = false, -- do not touch this!
		boss_pos = vector3(384.26,-1612.72,29.29), -- boss/purchase menu pos
		impound_pos = vector4(378.23,-1614.36,29.29,226.98), -- impound pos/data
	},
}

-- Marker Settings:
Config.MarkerSettings = {
	['boss'] = { enable = true, drawDist = 7.0, type = 20, scale = {x = 0.35, y = 0.35, z = 0.35}, color = {r = 240, g = 52, b = 52, a = 100} },
	['impound'] = { enable = true, drawDist = 10.0, type = 20, scale = {x = 0.30, y = 0.30, z = 0.30}, color = {r = 0, g = 200, b = 70, a = 100} },
	['garage'] = { enable = true, drawDist = 10.0, type = 20, scale = {x = 0.30, y = 0.30, z = 0.30}, color = {r = 240, g = 52, b = 52, a = 100} },
	['dropoff'] = { enable = true, drawDist = 10.0, type = 20, scale = {x = 0.75, y = 0.75, z = 0.75}, color = {r = 240, g = 52, b = 52, a = 100} },
	
}

-- Blip Settings:
Config.BlipSettings = {
	['service'] = {enable = true, sprite = 68, display = 4, scale = 0.65, color = 2, name = "Tow Service"}
}

Config.KeyControls = {
	['service_menu'] = 38,
	['buy_service'] = 38,
	['impound_menu'] = 38,
	['garage_menu'] = 38,
	['interaction_menu'] = 167,
	['push_pickup_objs'] = 305,
	['inspect_vehicle'] = 38,
	['npc_follow'] = 38,
	['collect_cash'] = 38,
	['attach_note'] = 38,
	['use_repairkit'] = 38,
}

Config.Society = { -- requires esx_society (set settings for what boss can do in each dealerships)
	['towtrucker1'] = {
		-- register society:
		name = 'towtrucker1', -- job name 
		label = 'Tow Trucker', -- job label
		account = 'society_towtrucker1', -- society account
		datastore = 'society_towtrucker1', -- society datastore
		inventory = 'society_towtrucker1', -- society inventory
		boss_grade = 2, -- boss grade number to apply upon purchase
		data = {type = 'private'},
		-- settings:
		withdraw  = true, -- boss can withdraw money from account
		deposit   = true, -- boss can deposit money into account
		wash      = false, -- boss can wash money
		employees = true, -- boss can manage & recruit employees
		grades    = false -- boss can adjust all salaries for each job grade
	},
	['towtrucker2']  = {
		-- register society:
		name = 'towtrucker2', -- job name 
		label = 'Tow Trucker', -- job label
		account = 'society_towtrucker2', -- society account
		datastore = 'society_towtrucker2', -- society datastore
		inventory = 'society_towtrucker2', -- society inventory
		boss_grade = 2, -- boss grade number to apply upon purchase
		data = {type = 'private'},
		-- settings:
		withdraw  = true, -- boss can withdraw money from account
		deposit   = true, -- boss can deposit money into account
		wash      = false, -- boss can wash money
		employees = true, -- boss can manage & recruit employees
		grades    = false -- boss can adjust all salaries for each job grade
	},
}

-- Garage Spawner:
Config.TowServiceGarage = {
	[1] = { -- id of the tow service
		enable = true, -- enable vehicle spawner
		pos = vector4(491.16,-1332.86,29.33,306.81), -- pos to interact
		teleport = true, -- tp into vehicle
		fuel = 100.0, -- set fuel level
		vehicles = { -- vehicles
			[1] = {label = 'Flatbed', model = 'flatbed', grade = 0},
			[2] = {label = 'Tow Truck #1', model = 'towtruck', grade = 1},
			[3] = {label = 'Tow Truck #2', model = 'towtruck2', grade = 1}
		},
	},
	[2] = { -- id of the tow service
		enable = true, -- enable vehicle spawner
		pos = vector4(390.0,-1620.54,29.29,316.87), -- pos to interact
		teleport = true, -- tp into vehicle
		fuel = 100.0, -- set fuel level
		vehicles = { -- vehicles:
			[1] = {label = 'Flatbed', model = 'flatbed', grade = 0},
			[2] = {label = 'Tow Truck #1', model = 'towtruck', grade = 1},
			[3] = {label = 'Tow Truck #2', model = 'towtruck2', grade = 1}
		},
	}
}

-- Impound Vehicle:
Config.ImpoundVehicle = {
	dist = 2.0,  							-- distance to a vehicle
	drawText = {
		dist = 4.0,							-- distance to draw text visible
		str = Lang['draw_impound_veh'],			-- draw text 
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
		dist = 4.0,							-- distance to draw text visible
		str = Lang['draw_unlock_veh'],			-- draw text 
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

-- Flip Vehicle:
Config.FlipVehicle = {
	dist = 2.0, 							-- distance to a vehicle
	drawText = {
		dist = 4.0,							-- distance to draw text visible
		str = Lang['draw_flip_veh'],				-- draw text 
		keybind = 38,						-- DEFAULT KEY: [E]
		interactDist = 1.0					-- distance to key press works
	},
	freeze = true,							-- freeze while using animation
	scenario = 'CODE_HUMAN_MEDIC_TEND_TO_DEAD',
	progressBar = {
		timer = 3000,
		text = Lang['pb_flipping']
	}
}

-- Push Vehicle:
Config.PushVehicle = {
	dist = 2.0, 							-- distance to a vehicle
	drawText = {
		dist = 4.0,							-- distance to draw text visible
		str1 = Lang['draw_push_veh'],		-- draw text 
		str2 = Lang['draw_cancel_push'],	-- draw text 
		interactDist = 1.2					-- distance to key press works
	},
	pushKey = 21,							--  DEFAULT KEY: [LEFT SHIFT]
	stopKey = 177,							--  DEFAULT KEY: [BACKSPACE]
	leftKey = 34,							--  DEFAULT KEY: [A]
	rightKey = 35,							--  DEFAULT KEY: [D]
	anim = {dict = 'missfinale_c2ig_11', lib = 'pushcar_offcliff_m'},
}

-- Tow attach/detach Vehicles:
Config.FlatbedTowing = {
	trucks = {
		['flatbed'] = {offset = {0.0, -2.0, 0.8}, boneIndex_name = 'bodyshell'}
	},
	command = 'tow',
	drawText = {
		attach = Lang['draw_attach_veh'],
		detach = Lang['draw_detach_veh'],
		dist = 5.0
	},
	attachKey = 38, -- default E
	detachKey = 47, -- default G
	interactDist = 1.1,
	marker = {drawDist = 10.0, type = 20, scale = {x = 0.50, y = 0.50, z = 0.50}, color = {r = 240, g = 52, b = 52, a = 100}},
	blacklisted = {'flatbed', 'towtruck', 'cargobob'} -- vehicles that cannot be attached to flatbed
}

-- Prop Emotes:
Config.PropEmotes = {
	["prop_roadcone02a"] = {label = "Road Cone", model = "prop_roadcone02a", bone = 28422, pos = {0.6,-0.15,-0.1}, rot = {315.0,288.0,0.0}},
	["prop_tool_box_04"] = {label = "Tool Box", model = "prop_tool_box_04", bone = 28422, pos = {0.4,-0.1,-0.1}, rot = {315.0,288.0,0.0}},
	["prop_consign_02a"] = {label = "Con Sign", model = "prop_consign_02a", bone = 28422, pos = {0.0,0.2,-1.05}, rot = {-195.0,-180.0,180.0}},
	["prop_mp_barrier_02b"] = {label = "Road Barrier", model = "prop_mp_barrier_02b", bone = 28422, pos = {0.0,0.2,-1.05}, rot = {-195.0,-180.0,180.0}},
}

Config.RepairKit = {
	enable = true, -- enable/disable this
	label = 'Repair Kit', -- item label
	itemName = 'repairkit', -- item name in DB
	duration = 5000, -- time in ms
	progbar = 'USING REPAIR KIT', -- progress bar text
	setEngine = 400.0, -- value to set the engine at
}

Config.JobTypes = {'illegally_parked', 'break_downs'}

Config.TowTruckerJobs = {

	TravelDistance = 2500.0, -- Set maximum travel distance from ply coords to NPC job location.
	
	-- Vehicle scrambler for npc jobs:
	JobVehicles = {"sultan", "blista", "glendale", "exemplar"},

	['illegally_parked'] = {
		[1] = { pos = {-365.83,-668.26,31.32,267.21}, inUse = false, dropoff = {401.54,-1632.64,29.29}, payout = {min = 250, max = 400}},
		[2] = { pos = {-142.18,-1370.68,29.34,119.72}, inUse = false, dropoff = {401.54,-1632.64,29.29}, payout = {min = 250, max = 400}},
		[3] = { pos = {249.11,-1000.3,29.16,340.96}, inUse = false, dropoff = {401.54,-1632.64,29.29}, payout = {min = 250, max = 400}},
	},

	['break_downs'] = {
		[1] = { pos = {932.04,-62.5,78.76,85.98}, npc_pos = {931.58,-59.92,78.76,135.83}, inUse = false, ped = "s_m_y_dealer_01", dropoff = {-366.25,-124.89,38.7}, payout = {min = 250, max = 400}},
		[2] = { pos = {99.43,247.17,108.19,66.33}, npc_pos = {97.83,250.58,108.38,177.98}, inUse = false, ped = "s_m_y_dealer_01", dropoff = {-218.37,-1296.19,31.3}, payout = {min = 250, max = 400}},
		[3] = { pos = {167.33,-1460.1,29.14,138.45}, npc_pos = {171.92,-1458.62,29.24,126.2}, inUse = false, ped = "s_m_y_dealer_01", dropoff = {716.32,-1080.13,22.28}, payout = {min = 250, max = 400}},
	}
}
