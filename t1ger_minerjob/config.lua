-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- General Settings:
Config.ItemWeightSystem		= false						-- Set this to true if you are using weight instead of limit.
Config.ProgressBars			= true						-- set to false to disable my progressBars and add your own in the script.

-- Mining Spots:
Config.Mining = {
	[1] = {
		pos = {2972.12, 2841.38, 46.02},
		inUse = false,
		blip = {enable = true, str = 'Mine Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 7.5, type = 27, color = {r = 30, g = 139, b = 195, a = 170}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Mine',
		keybind = 38,
	},
	[2] = {
		pos = {2973.16, 2837.92, 45.69},
		inUse = false,
		blip = {enable = true, str = 'Mine Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 7.5, type = 27, color = {r = 30, g = 139, b = 195, a = 170}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Mine',
		keybind = 38,
	},
	[3] = {
		pos = {2974.26, 2834.10, 45.74},
		inUse = false,
		blip = {enable = true, str = 'Mine Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 7.5, type = 27, color = {r = 30, g = 139, b = 195, a = 170}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Mine',
		keybind = 38,
	},
	[4] = {
		pos = {2958.47, 2851.04, 47.44},
		inUse = false,
		blip = {enable = true, str = 'Mine Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 7.5, type = 27, color = {r = 30, g = 139, b = 195, a = 170}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Mine',
		keybind = 38,
	}
}

-- Mining Reward Settings:
Config.MiningReward = {min = 1, max = 5}

-- Washing Spots:
Config.Washing = {
	[1] = {
		pos = {1966.86, 536.98, 160.92},
		blip = {enable = true, str = 'Washing Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 15.0, type = 27, color = {r = 30, g = 139, b = 195, a = 170}, scale = {x = 2.5, y = 2.5, z = 2.5}},
		drawText = '~r~[E]~s~ Wash Stone',
		keybind = 38,
	},
	[2] = {
		pos = {1994.04, 562.95, 161.38},
		blip = {enable = true, str = 'Washing Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 15.0, type = 27, color = {r = 30, g = 139, b = 195, a = 170}, scale = {x = 2.5, y = 2.5, z = 2.5}},
		drawText = '~r~[E]~s~ Wash Stone',
		keybind = 38,
	}
}

-- Wash Settings & Rewards
Config.WashSettings = {
	input = 10,				-- required stone to wash
	output = {
		min = 8,			-- minimum output of washed stone
		max = 10			-- maximum output of washed stone
	}
}

-- Smelting Spots:
Config.Smelting = {
	[1] = {
		pos = {1088.08, -2001.52, 30.87},
		blip = {enable = true, str = 'Smelting Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 12.0, type = 27, color = {r = 240, g = 52, b = 52, a = 100}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Smelt',
		keybind = 38,
	},
	[2] = {
		pos = {1088.51, -2005.12, 31.15},
		blip = {enable = true, str = 'Smelting Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 12.0, type = 27, color = {r = 240, g = 52, b = 52, a = 100}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Smelt',
		keybind = 38,
	},
	[3] = {
		pos = {1084.61, -2001.91, 31.40},
		blip = {enable = true, str = 'Smelting Spot', sprite = 365, display = 4, color = 5, scale = 0.65},
		marker = {enable = true, drawDist = 12.0, type = 27, color = {r = 240, g = 52, b = 52, a = 100}, scale = {x = 1.25, y = 1.25, z = 1.25}},
		drawText = '~r~[E]~s~ Smelt',
		keybind = 38,
	}
}

-- Smelting Settings & Reward:
Config.SmeltingSettings = {
	input = 10,
	reward = {
		[1] = {item = 'uncut_diamond', chance = 10, amount = {min = 1, max = 2}},
		[2] = {item = 'uncut_rubbies', chance = 10, amount = {min = 1, max = 2}},
		[3] = {item = 'gold', chance = 25, amount = {min = 2, max = 4}},
		[4] = {item = 'silver', chance = 25, amount = {min = 2, max = 4}},
		[5] = {item = 'copper', chance = 50, amount = {min = 3, max = 5}},
		[6] = {item = 'iron_ore', chance = 100, amount = {min = 6, max = 10}}
	}
}

-- Config Database ITems:
Config.DatabaseItems = {
	['pickaxe'] = 'pickaxe',
	['stone'] = 'stone',
	['washpan'] = 'washpan',
	['washed_stone'] = 'washed_stone',
	['uncut_diamond'] = 'uncut_diamond',
	['uncut_rubbies'] = 'uncut_rubbies',
	['gold'] = 'gold',
	['silver'] = 'silver',
	['copper'] = 'copper',
	['iron_ore'] = 'iron_ore'
}
