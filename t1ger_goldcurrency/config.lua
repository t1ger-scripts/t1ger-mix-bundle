-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- General Settings:
Config.ItemWeightSystem		= false						-- Set this to true if you are using weight instead of limit.
Config.ProgressBars			= true						-- set to false to disable my progressBars and add your own in the script.
Config.UsePhoneMSG			= true						-- use phone msg instead of notifiy during job 

Config.PoliceSettings = {
	jobs = {'police', 'lspd'},													-- paste police jobs into here
	enableAlert = true,															-- enable police alerts
	blip = {enable = true, time = 30, radius = 30.0, alpha = 250, color = 5},	-- police alert blip settings
	requiredCops = 2,
}

-- Gold Job NPC
Config.JobNPC = {
	pos = {3311.26, 5176.45, 19.61, 231.39},	-- set job npc pos with heading as the [4]
	ped = 's_m_y_dealer_01',					-- model name for job npc
	scenario = 'WORLD_HUMAN_AA_SMOKE',			-- set a scenario for NPC to play
	blip = {enable = true, str = 'Gold Job NPC', sprite = 280, display = 4, scale = 0.7, color = 5},	-- blip settings
	drawText = '~y~[E]~s~ Gold Job',			-- Draw Text at NPC
	keybind = 38,								-- Key to interact
	talkSeconds = 5,							-- set time in seconds to talk
	cooldown = 24,								-- time in minutes for cooldown for doing jobs.
	jobFees = {amount = 500, dirty = false}		-- amount of money to start job, dirty to true, to use black money instead of cash.
}

Config.GoldJobs = {
	[1] = {
		pos = {2196.13, 5608.19, 53.51, 342.84},
		inUse = false,
		goons = {
			[1] = {pos = {2201.42, 5610.36, 53.53, 339.79}, ped = 'G_M_Y_Lost_02', anim = {dict = 'amb@world_human_cop_idles@female@base', lib = 'base'}, weapon = 'WEAPON_PISTOL'},
			[2] = {pos = {2194.21, 5614.47, 54.17, 271.37}, ped = 'G_M_Y_MexGang_01', anim = {dict = 'rcmme_amanda1', lib = 'stand_loop_cop'}, weapon = 'WEAPON_PISTOL'},
			[3] = {pos = {2194.11, 5608.79, 53.64, 332.48}, ped = 'G_M_Y_SalvaBoss_01', anim = {dict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base', lib = 'base'}, weapon = 'WEAPON_PISTOL'},
		},
	},
	[2] = {
		pos = {2553.55, 4673.64, 33.92, 17.77},
		inUse = false,
		goons = {
			[1] = {pos = {2549.01, 4669.23, 34.08, 4.96}, ped = 'G_M_Y_Lost_02', anim = {dict = 'amb@world_human_cop_idles@female@base', lib = 'base'}, weapon = 'WEAPON_PISTOL'},
			[2] = {pos = {2558.2, 4673.08, 34.08, 48.73}, ped = 'G_M_Y_MexGang_01', anim = {dict = 'rcmme_amanda1', lib = 'stand_loop_cop'}, weapon = 'WEAPON_PISTOL'},
			[3] = {pos = {2545.57, 4675.05, 34.01, 331.84}, ped = 'G_M_Y_SalvaBoss_01', anim = {dict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base', lib = 'base'}, weapon = 'WEAPON_PISTOL'},
		},
	},
}

Config.Delivery = {
	pos = {3333.92, 5161.19, 18.31},
	marker = {enable = true, type = 27, drawDist = 50.0, scale = {x = 2.0, y = 2.0, z = 1.0}, color = {r = 255, g = 255, b = 0, a = 100}},
	blip = {sprite = 1, color = 5, label = "Delivery", scale = 0.75, route = true}
}

Config.JobReward = {
	[1] = {item = 'goldwatch', amount = {min = 1, max = 5}, chance = 100},
	[2] = {item = 'goldbar', amount = {min = 1, max = 2}, chance = 50}
}

-- Job Vehicles Randomizer:
Config.JobVehicles = {'rumpo', 'speedo'}

-- Smeltery Locations:
Config.Smeltery = {
	[1] = {
		pos = {1109.93, -2008.24, 31.06},
		blip = {enable = true, str = 'Gold Smeltery', sprite = 618, display = 4, color = 5, scale = 0.7},
		marker = {enable = true, drawDist = 7.5, type = 27, color = {r = 255, g = 255, b = 0, a = 100}, scale = {x = 2.0, y = 2.0, z = 2.0}},
		drawText = '~r~[E]~s~ Smelt',
		keybind = 38,
	}
}

-- Smeltery Settings:
Config.SmelterySettings = {
	time = 5,		-- time in seconds to melt watches into gold bar
	input = 100,	-- required amount of watches
	output = 1		-- rewarded goldbars from input x watches
}

-- Gold Exchange Locations:
Config.Exchange = {
	[1] = {
		pos = {-113.65, 6465.58, 31.63},
		blip = {enable = true, str = 'Gold Exchange', sprite = 500, display = 4, color = 5, scale = 0.7},
		marker = {enable = true, drawDist = 5.0, type = 27, color = {r = 255, g = 255, b = 0, a = 100}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Gold Exchange',
		keybind = 38,
	}
}

-- Gold Exchange Settings:
Config.ExchangeSettings = {
	time = 5,		-- time in seconds to melt watches into gold bar
	cooldown = 48,	-- time in minutes for cooldown on exchanging gold
	input = 70,		-- required amount of gold bars to exchange into cash
	money = {
		amount = 35000,	-- amount of money to receive
		dirty = true	-- dirty cash, set to false to receive cash in hand
	}
}

-- Database Items
Config.DatabaseItems = {
	['goldwatch'] = 'goldwatch',
	['goldbar'] = 'goldbar'
}
