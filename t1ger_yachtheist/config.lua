-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- General Settings:
Config.ProgressBars			= true						-- set to false to disable my progressBars and add your own in the script.

-- Police Settings:
Config.PoliceSettings = {
	jobs = {'police', 'lspd'},				-- paste police jobs into here
	enableAlert = true,						-- enable police alerts
	requiredCops = 2 						-- required cops to start heist
}

-- General Config
Config.ChanceToKeepDrill = 25			-- set chance in % of keeping drill after successfull drill finish.
Config.EnablePlayerMoneyBag = false		-- enable/disable wearing a bag after cash animation
Config.CooldownTimer = 10				-- set cooldown time in minutes after yacht has been secured

-- Yacht Settings:
Config.Yacht = {
	blip = {enable = true, str = Lang['yacht_blip'], display = 4, sprite = 108, color = 5, scale = 0.65},
	cooldown = false,
	terminal = {pos = {-2030.77, -1038.22, 2.56}, activated = false},
	keypad = {pos = {-2069.70, -1020.03, 5.88}, hacked = false},
	vault = {pos = {-2069.28, -1019.33, 5.88}, model = -2050208642},
	trolley = {pos = {-2069.44, -1021.35, 5.88, 75.73}, grabbing = false, taken = false},
	goons = {
		[1] = {pos = {-2077.05, -1021.92, 5.88, 307.71}, ped = 'G_M_Y_Lost_02', anim = {dict = 'amb@world_human_cop_idles@female@base', lib = 'base'}, weapon = 'WEAPON_PISTOL'},
		[2] = {pos = {-2077.48, -1016.60, 5.88, 243.91}, ped = 'G_M_Y_MexGang_01', anim = {dict = 'rcmme_amanda1', lib = 'stand_loop_cop'}, weapon = 'WEAPON_PISTOL'},
		[3] = {pos = {-2071.25, -1020.63, 5.88, 5.57}, ped = 'G_M_Y_SalvaBoss_01', anim = {dict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base', lib = 'base'}, weapon = 'WEAPON_PISTOL'}
	}
}

-- Safes in the yacht:
Config.Safes = {
	[1] = { pos = {-2068.18,-1018.28,5.88}, anim_pos = {-2068.37, -1019.08, 5.88, 345.14}, robbed = false, failed = false },
	[2] = { pos = {-2066.84,-1020.25,5.88}, anim_pos = {-2067.58, -1020.14, 5.88, 251.83}, robbed = false, failed = false },
}

-- Safe rewards:
Config.VaultRewards = {
	money = {
		dirtyCash = true,		-- set to false to receive normal cash
		min = 15,				-- this value is multiplied with 1000 in script, so 15 means 15.000$
		max = 30				-- this value is multiplied with 1000 in script, so 30 means 30.000$
	},
	items = {
		[1] = { item = "goldbar", chance = 65, min = 1, max = 3},
		[2] = { item = "goldwatch", chance = 85, min = 15, max = 20},
		[3] = { item = "goldnecklace", chance = 40, min = 10, max = 14},
		[4] = { item = "diamond", chance = 25, min = 1, max = 2}
	},
	trolley = {
		dirtyCash = true,		-- set to false to receive normal cash
		min = 1000,				-- min amount per cash pile
		max = 3000				-- max amount per cash pile
	}
}

-- Config Database ITems:
Config.DatabaseItems = {
	['hackerDevice'] = 'hackerDevice',
	['drill'] = 'drill',
}
