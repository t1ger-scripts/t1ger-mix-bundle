-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- General Settings:
Config.ESXSHAREDOBJECT 		= 'esx:getSharedObject'		-- put your sharedobject in here.
Config.ItemWeightSystem		= false						-- Set this to true if you are using weight instead of limit.
Config.ProgressBars			= true						-- set to false to disable my progressBars and add your own in the script.
Config.HasItemLabel			= true						-- set to false if your ESX doesn't support item labels.

Config.ChopShop = {

	Settings = {
		carListAmount = 3,				-- Adjust amount of cars on the list. 3 cars are default.
		newCarListTimer = 30,			-- time in minutes until a new car list is generated.
		usePhoneMSG = true,				-- Enable to receive job msg through phone, disable to use ESX.ShowNotification or anything else you'd like
		ownedVehicles = {
			scrap = true,					-- Enable / disable scrapping owned vehicles
			delete = true					-- Enable/disable deleting owned vehicles (if t1ger-insurance = true and veh got insurance, then veh will be sent to impound)
		},
		scrap_rewards = {
			cash = {enable = true, dirty = true},		-- enable/disable cash rewards, set to false to receive normal cash
			items = {enable = true, maxItems = 3}   	-- enable item rewards, maximum amount of items to receive, e.g. 3 means, rubber, glass, plastic. Setting to 5 means two more items
		},
		jobFeesDirty = true,							-- set to false to pay job fees in cash
		cooldown = {
			thiefjob = {enable = false, timer = 24},	-- enable/disable cooldown for thiefjobs, set cooldown timer
			scrap = {enable = false, timer = 5},		-- enable/disable cooldown for thiefjobs, set cooldown timer
		},
		thiefjob = {
			headshot = true,		-- enable headshot kills in thief jobs
			alarm = true,			-- trigger car alarm in thief job
			dirty = true,			-- set to false to receive normal cash in thief jobs
			items = {enable = true, maxItems = 3},	-- enable item rewards, maximum amount of items to receive, e.g. 3 means, rubber, glass, plastic. Setting to 5 means two more items
		},
	},

	Police = {
		jobs = {'police', 'lspd'},		-- paste police jobs into here
		alert = {
			enable = true,				-- enable police alerts
			blip = {enable = true, time = 30, radius = 30.0, alpha = 250, color = 5} -- police alert blip settings
		},
		allowCops = false, 				-- allow cops scrapping / thief jobs
		minCops = 0,					-- required cops to scrap vehicles
	},

	Blip = {enable = true, sprite = 280, color = 5, label = 'Chop Shop', display = 4, scale = 0.8},	-- blip settings for chop shop

	JobNPC = {
		model = 's_m_y_xmech_02_mp', 				-- model name
		name = 'T1GER#9080', 						-- gcphone number/name display
		pos = {-469.42,-1718.28,18.69,281.9},		-- npc position
		scenario = 'WORLD_HUMAN_AA_SMOKE',			-- npc idle scenario
		keybind = 38,								-- Default: [E]  - key to interact with job npc
		anim = {
			dict = 'missheistdockssetup1ig_5@base',
			lib = 'workers_talking_base_dockworker1',
			time = 3000,								-- time in ms for anim duration
		}
	},

	ScrapNPC = {
		model = 's_m_y_xmech_02_mp', 				-- model name
		name = 'T1GER#9080',						-- gcphone number/name display
		pos = {
			start = {-465.77,-1707.58,18.8,252.19},	-- start pos of the scrap npc
			stop = {-459.98,-1712.81,18.67,240.04},	-- end pos of the scrap npc
			veh = {-457.29,-1713.84,18.64},			-- park vehicle spot
		},
		scenario = {
			idle = 'WORLD_HUMAN_AA_SMOKE',			-- idle scenario
			work = 'WORLD_HUMAN_CLIPBOARD'			-- work scenario
		},
		timer = {toCar = 6, inspect = 4, back = 5},	-- time taken to car, to inspect and to return,
		marker = {drawDist = 35.0, type = 20, scale = {x = 0.9, y = 0.9, z = 0.9}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings for scrap npc
		keybind = 38,								-- Default: [E]  - key to scrap vehicle / interact with NPC
	},

}

-- Scrap Vehicles for Car List:
Config.ScrapVehicles = {
	[1] = {label = "Prairie", hash = -1450650718, price = 850},
	[2] = {label = "Ingot", hash = -1289722222, price = 650},
	[3] = {label = "Tailgater", hash = -1008861746, price = 950},
	[4] = {label = "F620", hash = -591610296, price = 1250},
	[5] = {label = "Jester", hash = -1297672541, price = 1650},
	[6] = {label = "Massacro", hash = -142942670, price = 1950},
	[7] = {label = "Sultan", hash = 970598228, price = 1000},
	[8] = {label = "Turismo R", hash = 408192225, price = 2200},
	[9] = {label = "Emperor", hash = -685276541, price = 450},
	[10] = {label = "Blista", hash = -344943009, price = 750},
	[11] = {label = "Exemplar", hash = -5153954, price = 1150}
}

-- Materials:
Config.Materials = {
	[1] = {label = "Rubber", item = "rubber", chance = 40, amount = {min = 1, max = 3}},
	[2] = {label = "Scrap Metal", item = "scrap_metal", chance = 70, amount = {min = 5, max = 9}},
	[3] = {label = "Electric Scrap", item = "electric_scrap", chance = 50, amount = {min = 2, max = 7}},
	[4] = {label = "Plastic", item = "plastic", chance = 89, amount = {min = 4, max = 9}},
	[5] = {label = "Glass", item = "glass", chance = 35, amount = {min = 2, max = 3}},
	[6] = {label = "Aluminium", item = "aluminium", chance = 62, amount = {min = 1, max = 6}},
	[7] = {label = "Copper", item = "copper", chance = 45, amount = {min = 2, max = 4}},
	[8] = {label = "Steel", item = "steel", chance = 30, amount = {min = 1, max = 3}}
}

-- Thief Job Risk Grades:
Config.RiskGrades = {
	[1] = { -- Risk Grade 1 --
		grade = 1, label = 'Low', enable = true, job_fees = 500, cops = 0, 		-- only edit label, enable, job_fees and required cops.
		vehicles = {
			[1] = { name = "Prairie", hash = -1450650718, payout = 2350 },		-- add vehicle name, hash and payout.
			[2] = { name = "Ingot", hash = -1289722222, payout = 1950 },
			[3] = { name = "Stratum", hash = 1723137093, payout = 1700 },
		}, 
	},
	[2] = { -- Risk Grade 2 --
		grade = 2, label = 'Medium', enable = true, job_fees = 2000, cops = 1, 
		vehicles = {
			[1] = { name = "Tailgater", hash = -1008861746, payout = 4350 },
			[2] = { name = "Exemplar", hash = -5153954, payout = 2950 },
			[3] = { name = "F620", hash = -591610296, payout = 2350 },
		}, 
	},
	[3] = { -- Risk Grade 3 --
		grade = 3, label = 'High', enable = true, job_fees = 5000, cops = 2, 
		vehicles = {
			[1] = { name = "Jester", hash = -1297672541, payout = 8350 },
			[2] = { name = "Carbonizzare", hash = 2072687711, payout = 7950 },
			[3] = { name = "Massacro", hash = -142942670, payout = 7350 },
		}, 
	},
}

Config.ThiefJobs = {
	[1] = {
		pos = {331.94,-1241.59,30.59,184.36},
		inUse = false,
		goons_spawned = false,
		veh_spawned = false,
		player = false,
		goons = {
			[1] = {
				pos = {335.86,-1245.18,30.59,159.67},
				ped = 's_m_y_dealer_01',
				anim = {dict = 'amb@world_human_cop_idles@female@base', lib = {'base'}},
				weapon = {[1] = 'WEAPON_UNARMED', [2] = 'WEAPON_BAT', [3] = 'WEAPON_PISTOL'},
				armour = 100, accuracy = 60,
			},
			[2] = {
				pos = {327.07,-1244.57,30.57,244.12},
				ped = 's_m_y_dealer_01',
				anim = {dict = 'rcmme_amanda1', lib = {'stand_loop_cop'}},
				weapon = {[1] = 'WEAPON_UNARMED', [2] = 'WEAPON_KNIFE', [3] = 'WEAPON_PISTOL'},
				armour = 75, accuracy = 90,
			},
		},
		blip = {sprite = 1, color = 5, label = "Car Thief Job", scale = 0.7, route = true},
	},
	[2] = {
		pos = {492.77,-524.46,24.75,170.15},
		inUse = false,
		goons_spawned = false,
		veh_spawned = false,
		player = false,
		goons = {
			[1] = {
				pos = {487.49,-529.21,24.75,219.07},
				ped = 's_m_y_dealer_01',
				anim = {dict = 'amb@world_human_cop_idles@female@base', lib = {'base'}},
				weapon = {[1] = 'WEAPON_UNARMED', [2] = 'WEAPON_BAT', [3] = 'WEAPON_PISTOL'},
				armour = 100, accuracy = 60,
			},
			[2] = {
				pos = {496.24,-528.87,24.75,145.44},
				ped = 's_m_y_dealer_01',
				anim = {dict = 'rcmme_amanda1', lib = {'stand_loop_cop'}},
				weapon = {[1] = 'WEAPON_UNARMED', [2] = 'WEAPON_KNIFE', [3] = 'WEAPON_PISTOL'},
				armour = 75, accuracy = 90,
			},
		},
		blip = {sprite = 1, color = 5, label = "Car Thief Job", scale = 0.7, route = true},
	}
}
