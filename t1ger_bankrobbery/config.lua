-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {
	Debug = false, -- allows you to restart script while in-game, otherwise u need to restart fivem.
    ProgressBars = true, -- set to false if you do not use progressBars or using your own
	PoliceJobs = {"police", "lspd"}, -- Jobs that can't do bankrobberies etc, but can secure the banks.
	FetchJobs = 60, -- timer in seconds to fetch online players from each dealership jobs
	CashInDirty = true, -- safe rewards in dirty (black_money) or normal cash?
	AlertBlip = { Show = true, Time = 20, Radius = 50.0, Alpha = 250, Color = 3 }
}

Config.Banks = {
	[1] = {
		name = 'Pacific Standard Public Deposit Bank',
		blip = {enable = true, name = "Bank | Pacific Standard Public Deposit", pos = vector3(231.67,214.91,106.28), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 4,
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(262.35,223.03,106.78), text = {[1] = '~r~[E]~s~ Hack Keypad Terminal', [2] = '~y~[G]~s~ Use Access Card'} , hacked = false},
			['vault'] = {pos = vector3(252.81,228.49,102.08), text = {[1] = '~r~[E]~s~ Hack Vault Terminal', [2] = '~y~[G]~s~ Use Access Card'}, hacked = false},
		},

		doors = {
			['terminal'] = {pos = vector3(262.2,222.52,106.43), model = 746855201, heading = 250.0, setHeading = 250.0, freeze = true}, -- cell door to enter stairs leading down to main vault
			['vault'] = {pos = vector3(253.76,225.25,101.88), model = 961976194, heading = 160.0, setHeading = 160.0, count = 380, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(260.86,210.45,110.43), model = 964838196, heading = 70.0, setHeading = 70.0, freeze = true, action = 'lockpick', offset = vector3(-1.2,0.0,0.0)}, -- office desk door
			['cell'] = {pos = vector3(251.86,221.07,101.83), model = -1508355822, heading = 160.40, setHeading = 160.40, freeze = true, action = 'thermite', offset = vector3(-1.19,0.0,-0.02)}, -- 1st celldoor after main vault
			['cell2'] = {pos = vector3(261.3,214.51,101.83), model = -1508355822, heading = 250.0, setHeading = 250.0, freeze = true, action = 'thermite', offset = vector3(-1.19,-0.0,-0.02)} -- 2nd celldoor to access the other safes
		},

		safes = {
			[1] = {
				pos = vector3(258.64,218.83,101.68), anim = vector4(258.4535,218.0434,101.6834,340.15), robbed = false, failed = false,
				requireDoor = 'cell',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[2] = {
				pos = vector3(260.95,217.98,101.68), anim = vector4(260.6777,217.1929,101.6834,335.23), robbed = false, failed = false,
				requireDoor = 'cell',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(256.98,214.13,101.68), anim = vector4(257.2587,214.9102,101.6834,158.06), robbed = false, failed = false,
				requireDoor = 'cell',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(259.22,213.33,101.68), anim = vector4(259.4739,214.1086,101.6834,159.97), robbed = false, failed = false,
				requireDoor = 'cell',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(263.38,216.98,101.68), anim = vector4(263.1836,216.3488,101.68,342.95), robbed = false, failed = false,
				requireDoor = 'cell2',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[6] = {
				pos = vector3(265.20,216.35,101.68), anim = vector4(265.049,215.6598,101.68,344.45), robbed = false, failed = false,
				requireDoor = 'cell2',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[7] = {
				pos = vector3(266.82,214.62,101.68), anim = vector4(266.2266,214.8334,101.68,247.95), robbed = false, failed = false,
				requireDoor = 'cell2',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[8] = {
				pos = vector3(265.98,212.38,101.68), anim = vector4(265.467,212.5886,101.68,253.22), robbed = false, failed = false,
				requireDoor = 'cell2',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[9] = {
				pos = vector3(263.75,211.76,101.68), anim = vector4(263.988,212.3554,101.68,158.84), robbed = false, failed = false,
				requireDoor = 'cell2',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[10] = {
				pos = vector3(261.58,212.67,101.68), anim = vector4(261.7706,213.2954,101.68,158.96), robbed = false, failed = false,
				requireDoor = 'cell2',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},

		powerBox = {
			pos = vector3(255.50,227.14,151.63), -- pos
			anim = vector4(255.22,226.35,151.63,339.25), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},
		
		pettyCash = {
			[1] = {pos = vector3(242.64,226.22,106.29), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(247.76,224.27,106.29), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(252.88,222.43,106.29), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		crackSafe = {
			pos = vector3(264.22, 207.50, 109.39), -- obj pos
			heading = 250.0, -- obj heading
			anim = vector3(263.93, 208.21, 110.29), -- anim pos
			model = 'bkr_prop_biker_safedoor_01a', -- obj model
			combinations = {	-- set amount of locks to crack
				[1] = {min = 0, max = 30},	-- min 0 and max 99 
				[2] = {min = 50, max = 99},	-- min 0 and max 99 
				-- add more if u want..
			},
			reward = {
				items = {
					{name = 'accesscard', amount = {min = 1, max = 1}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 70},
					{name = 'goldwatch', amount = {min = 3, max = 6}, chance = 50},
					-- add more items here 
				},
				cash = {enable = true, min = 2000, max = 10000}
			},
			cracked = false  -- do not touch!
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
	[2] = {
		name = 'Blaine County Savings Bank',
		blip = {enable = true, name = 'Bank | Blaine County Savings Bank', pos = vector3(-110.94,6462.53,31.64), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 3,
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(-105.9,6472.11,31.9), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(-105.51,6475.23,32.0), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: +110.0
			['terminal'] = {pos = vector3(-105.81,6475.62,31.63), model = 1309269072, heading = 314.58, setHeading = 314.58, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(-104.6,6473.44,31.8), model = -1185205679, heading = 45.0, setHeading = 45.0, count = 270, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(-108.91,6469.11,31.91), model = -1184592117, heading = 45.0, setHeading = 45.0, freeze = true, action = 'lockpick', offset = vector3(-0.95,0.0,-0.20)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(-102.59,6475.23,31.62), anim = vector4(-103.16,6475.82,31.65,220.24), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[2] = {
				pos = vector3(-103.08,6478.67,31.62), anim = vector4(-103.67,6478.08,31.62,318.58), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(-106.88,6478.35,31.62), anim = vector4(-106.21,6477.68,31.62,43.00), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(-107.31,6473.15,31.62), anim = vector4(-106.80,6473.85,31.62,137.65), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(-107.99,6475.83,31.62), anim = vector4(-107.32,6475.31,31.62,48.86), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},

		powerBox = {
			pos = vector3(-109.45,6483.29,31.47), -- pos
			anim = vector4(-110.0,6483.8,31.47,224.89), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		pettyCash = {
			[1] = {pos = vector3(-113.64,6471.93,31.63), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(-112.32,6470.57,31.63), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(-111.27,6469.51,31.63), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},

	},
	[3] = {
		name = 'Fleeca Bank [Legion Square]', -- name of the bank
		blip = {enable = true, name = 'Bank | Fleeca Bank [Legion Square]', pos = vector3(150.87,-1037.16,29.34), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 2, -- required cops
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(147.35,-1046.24,29.37), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(148.52,-1046.57,29.60), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: -100.0
			['terminal'] = {pos = vector3(150.29,-1047.63,29.67), model = -1591004109, heading = 159.85, setHeading = 159.85, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(148.03,-1044.36,29.51), model = 2121050683, heading = 249.85, setHeading = 249.85, count = 250, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(145.42,-1041.81,29.64), model = -131754413, heading = 249.85, setHeading = 249.85, freeze = true, action = 'lockpick', offset = vector3(-0.9,0.0,-0.15)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(146.48,-1048.44,29.34), anim = vector4(147.2295,-1048.66,29.34,68.84), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000},
			},
			[2] = {
				pos = vector3(148.10,-1051.24,29.34), anim = vector4(148.39,-1050.35,29.34,155.65), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(150.77,-1050.02,29.34), anim = vector4(150.18,-1049.77,29.34,249.98), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(149.78,-1044.55,29.34), anim = vector4(149.68,-1045.26,29.34,342.73), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(151.52,-1046.76,29.34), anim = vector4(150.79,-1046.51,29.34,247.81), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},
		
		pettyCash = {
			[1] = {pos = vector3(151.13,-1042.27,29.37), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(149.7,-1041.73,29.37), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(148.08,-1041.10,29.37), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		powerBox = {
			pos = vector3(135.60,-1046.45,29.63), -- pos
			anim = vector4(135.34,-1047.09,29.15,340.60), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
	[4] = {
		name = 'Fleeca Bank [Alta]', -- name of the bank
		blip = {enable = true, name = 'Bank | Fleeca Bank [Alta]', pos = vector3(315.32,-275.55,53.92), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 2, -- required cops
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(311.69,-284.55,54.16), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(312.87,-284.99,54.39), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: -100.0
			['terminal'] = {pos = vector3(314.62,-285.99,54.46), model = -1591004109, heading = 159.86, setHeading = 159.86, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(312.36,-282.73,54.3), model = 2121050683, heading = 249.86, setHeading = 249.86, count = 250, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(309.75,-280.18,54.44), model = -131754413, heading = 249.86, setHeading = 249.86, freeze = true, action = 'lockpick', offset = vector3(-0.9,0.0,-0.15)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(310.70,-286.80,54.14), anim = vector4(311.61,-287.09,54.14,68.98), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000},
			},
			[2] = {
				pos = vector3(312.50,-289.59,54.14), anim = vector4(312.75,-288.71,54.14,159.08), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(315.26,-288.29,54.14), anim = vector4(314.47,-288.13,54.14,253.56), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(314.25,-282.97,54.14), anim = vector4(313.95,-283.62,54.14,342.52), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(315.86,-285.01,54.14), anim = vector4(315.11,-284.78,54.14,248.85), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},
		
		pettyCash = {
			[1] = {pos = vector3(315.42,-280.56,54.17), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(313.7,-279.89,54.17), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(312.08,-279.37,54.17), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		powerBox = {
			pos = vector3(258.66,-308.09,49.65), -- pos
			anim = vector4(258.92,-307.33,49.65,162.16), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
	[5] = {
		name = 'Fleeca Bank [Burton]', -- name of the bank
		blip = {enable = true, name = 'Bank | Fleeca Bank [Burton]', pos = vector3(-349.89,-46.44,49.04), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 2, -- required cops
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(-353.52,-55.47,49.20), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(-352.22,-55.77,49.23), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: -100.0
			['terminal'] = {pos = vector3(-350.41,-56.8,49.33), model = -1591004109, heading = 160.85, setHeading = 160.85, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(-352.74,-53.57,49.18), model = 2121050683, heading = 250.85, setHeading = 250.85, count = 250, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(-355.39,-51.07,49.31), model = -131754413, heading = 250.85, setHeading = 250.85, freeze = true, action = 'lockpick', offset = vector3(-0.9,0.0,-0.15)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(-354.30,-57.70,49.014), anim = vector4(-353.41,-57.87,49.01,68.58), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000},
			},
			[2] = {
				pos = vector3(-352.51,-60.42,49.01), anim = vector4(-352.19,-59.51,49.01,159.24), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(-349.62,-59.11,49.01), anim = vector4(-350.49,-58.94,49.01,254.33), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(-350.79,-53.70,49.01), anim = vector4(-351.06,-54.45,49.01,344.00), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(-349.29,-55.90,49.01), anim = vector4(-349.98,-55.67,49.01,247.43), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},
		
		pettyCash = {
			[1] = {pos = vector3(-349.61,-51.40,49.05), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(-351.3,-50.80,49.05), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(-353.09,-50.20,49.05), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		powerBox = {
			pos = vector3(-355.77,-50.22,54.42), -- pos
			anim = vector4(-356.54,-49.91,54.42,249.03), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
	[6] = {
		name = 'Fleeca Bank [Rockford Hills]', -- name of the bank
		blip = {enable = true, name = 'Bank | Fleeca Bank [Rockford Hills]', pos = vector3(-1214.44,-327.5,37.67), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 2, -- required cops
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(-1210.49,-336.44,37.98), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(-1209.30,-335.73, 37.97), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: -100.0
			['terminal'] = {pos = vector3(-1207.33,-335.13,38.08), model = -1591004109, heading = 206.86, setHeading = 206.86, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(-1211.26,-334.56,37.92), model = 2121050683, heading = 296.86, setHeading = 296.86, count = 250, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(-1214.91,-334.73,38.06), model = -131754413, heading = 296.86, setHeading = 296.86, freeze = true, action = 'lockpick', offset = vector3(-0.9,0.0,-0.15)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(-1209.45,-33.47,37.75), anim = vector4(-1208.60,-338.02,37.75,115.56), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000},
			},
			[2] = {
				pos = vector3(-1206.10,-339.15,37.75), anim = vector4(-1206.62,-338.35,37.75,206.15), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(-1205.04,-336.19,37.75), anim = vector4(-1205.82,-336.71,37.75,299.26), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(-1209.89,-333.40,37.75), anim = vector4(-1209.52,-333.93,37.75,26.24), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(-1207.25,-333.54,37.75), anim = vector4(-1207.78,-333.99,37.75,298.41), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},
		
		pettyCash = {
			[1] = {pos = vector3(-1210.58,-330.75,37.78), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(-1211.99,-331.45,37.78), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(-1213.63,-332.28,37.78), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		powerBox = {
			pos = vector3(-1217.14,-332.99,42.12), -- pos
			anim = vector4(-1216.5,-332.63,42.12,119.32), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
	[7] = {
		name = 'Fleeca Bank [Great Ocean Highway]', -- name of the bank
		blip = {enable = true, name = 'Bank | Fleeca Bank [Great Ocean Highway]', pos = vector3(-2966.28,483.01,15.69), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 2, -- required cops
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(-2956.55,482.1,15.99), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(-2956.44,483.35, 15.87), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: -100.0
			['terminal'] = {pos = vector3(-2956.12,485.42,16.00), model = -1591004109, heading = 267.54, setHeading = 267.54, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(-2958.54,482.27,15.84), model = -63539571, heading = 357.54, setHeading = 357.54, count = 250, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(-2960.18,479.01,15.97), model = -131754413, heading = 357.54, setHeading = 357.54, freeze = true, action = 'lockpick', offset = vector3(-0.9,0.0,-0.15)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(-2954.138,481.9888,15.6753), anim = vector4(-2954.136,482.8257,15.67532,174.28), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000},
			},
			[2] = {
				pos = vector3(-2952.124,484.4436,15.67539), anim = vector4(-2952.935,484.3697,15.67539,263.67), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(-2954.121,486.7845,15.67542), anim = vector4(-2954.104,485.9754,15.6754,355.06), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(-2958.85,484.0662,15.6753), anim = vector4(-2958.034,484.128,15.6753,89.17), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(-2957.4,486.2582,15.67534), anim = vector4(-2957.432,485.405,15.67534,354.07), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},
		
		pettyCash = {
			[1] = {pos = vector3(-2961.43,484.62,15.73), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(-2961.52,482.99,15.73), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(-2961.59,481.25,15.73), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		powerBox = {
			pos = vector3(-2948.05,481.05,15.44), -- pos
			anim = vector4(-2947.25,480.95,15.26,90.32), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
	[8] = {
		name = 'Fleeca Bank [Grand Senora Desert]', -- name of the bank
		blip = {enable = true, name = 'Bank | Fleeca Bank [Grand Senora Desert]', pos = vector3(1175.13,2703.09,38.17), display = 4, sprite = 431, color = 5, scale = 0.7},
		police = 2, -- required cops
		inUse = false, -- do not touch!

		keypads = {
			['start'] = {pos = vector3(1175.64,2712.85,38.30), text = '~r~[E]~s~ Hack Keypad Terminal', hacked = false},
			['vault'] = {pos = vector3(1174.37,2712.85,38.26), text = '~r~[E]~s~ Hack Vault Terminal', hacked = false},
		},

		doors = { -- heading on open: -100.0
			['terminal'] = {pos = vector3(1172.29,2713.15,38.39), model = -1591004109, heading = 0.0, setHeading = 0.0, freeze = true}, -- cell door to enter safes
			['vault'] = {pos = vector3(1175.54,2710.86,38.23), model = 2121050683, heading = 90.0, setHeading = 90.0, count = 250, freeze = true}, -- vault main door
			['desk'] = {pos = vector3(1178.87,2709.36,38.36), model = -131754413, heading = 90.0, setHeading = 90.0, freeze = true, action = 'lockpick', offset = vector3(-0.9,0.0,-0.15)}, -- 1st celldoor after main vault
		},

		safes = {
			[1] = {
				pos = vector3(1175.63,2715.20,38.06), anim = vector4(1174.72,2715.25,38.06,266.26), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 60},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000},
			},
			[2] = {
				pos = vector3(1173.12,2717.20,38.06), anim = vector4(1173.09,2716.30,38.06,356.55), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[3] = {
				pos = vector3(1170.81,2715.17,38.06), anim = vector4(1171.68,2715.19,38.06,87.71), robbed = false, failed = false,
				requireHack = 'vault',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[4] = {
				pos = vector3(1173.77,2710.36,38.06), anim = vector4(1173.77,2711.24,38.06,180.11), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
			[5] = {
				pos = vector3(1171.36,2711.88,38.06), anim = vector4(1172.23,2711.84,38.06,88.92), robbed = false, failed = false,
				requireHack = 'start',
				items = {
					{name = 'goldwatch', amount = {min = 2, max = 4}, chance = 100},
					{name = 'goldbar', amount = {min = 1, max = 2}, chance = 30},
					-- add more items here 
				},
				cash = {enable = true, min = 5000, max = 20000}
			},
		},
		
		pettyCash = {
			[1] = {pos = vector3(1173.16,2707.86,38.11), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[2] = {pos = vector3(1174.9,2707.87,38.11), robbed = false, reward = {dirty = true, min = 2000, max = 5000}},
			[3] = {pos = vector3(1176.59,2707.86,38.11), robbed = false, reward = {dirty = true, min = 2000, max = 5000}}, 
		},

		powerBox = {
			pos = vector3(1158.18,2708.96,37.98), -- pos
			anim = vector4(1157.47,2708.92,37.98,269.46), -- anim pos & heading
			disabled = false, -- do not touch!
			freeTime = 60, -- time in seconds before police is alerted
			hackAdd = {enable = true, time = 30}, -- extra time added upon successful hacking
		},

		reqItems = { -- required items for pacific & settings:
			['hacking'] = { -- do not touch ID's
				{name = 'hackerDevice', amount = 1, remove = true, chance = 50}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['accesscard'] = { -- do not touch ID's
				{name = 'accesscard', amount = 1, remove = true, chance = 95}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['thermite'] = { -- do not touch ID's
				{name = 'thermite', amount = 1, remove = true, chance = 100}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['lockpick'] = { -- do not touch ID's
				{name = 'lockpick', amount = 1, remove = true, chance = 80}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['drilling'] = { -- do not touch ID's
				{name = 'drill', amount = 1, remove = true, chance = 90}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			},
			['powerbox'] = { -- do not touch ID's
				{name = 'hammerwirecutter', amount = 1, remove = true, chance = 75}, -- item name, amount required, remove/not remove, chance to remove in %.
				-- add more items with same layout if u want
			}
		},
	},
}

Config.RequireItem = {
	['hacking'] = { -- action id do not change!
		require = true, -- require this item upon action?
		name = 'hackerDevice', -- item name
		amount = 1, -- amount required
		remove = true, -- remove item upon usage
	},
	['accesscard'] = { -- action id do not change!
		require = true, -- require this item upon action?
		name = 'accesscard', -- item name
		amount = 1, -- amount required
		remove = true, -- remove item upon usage
	},
	['thermite'] = { -- action id do not change!
		require = true, -- require this item upon action?
		name = 'thermite', -- item name
		amount = 1, -- amount required
		remove = true, -- remove item upon usage
	},
	['lockpick'] = { -- action id do not change!
		require = true, -- require this item upon action?
		name = 'lockpick', -- item name
		amount = 1, -- amount required
		remove = true, -- remove item upon usage
	},
	['drilling'] = { -- action id do not change!
		require = true, -- require this item upon action?
		name = 'drill', -- item name
		amount = 1, -- amount required
		remove = false, -- remove item upon usage
	},
	['powerbox'] = { -- action id do not change!
		require = true, -- require this item upon action?
		name = 'hammerwirecutter', -- item name
		amount = 1, -- amount required
		remove = true, -- remove item upon usage
	},
}

Config.KeyControls = {
    ['hack_terminal'] = 38,
    ['hack_vault'] = 38,
    ['use_accesscard'] = 47,
    ['door_action'] = 38,
    ['drill_start'] = 38,
    ['drill_stop'] = 214,
    ['crack_safe'] = 38,
    ['powerbox'] = 38,
    ['petty_cash'] = 38,
    ['reset_bank'] = 47,
}

-- Camera Interaction Buttons:
Config.CamLeft = 174	-- Arrow Left
Config.CamRight = 175	-- Arrow Right
Config.CamUp = 172		-- Arrow Up
Config.CamDown = 173	-- Arrow Down
Config.CamExit = 178	-- DEL

Config.Camera = {
	[1] = {pos = {153.15,-1042.05,29.37}, heading = 44.32, name = 'Fleeca Bank [Legion Square] Cam #1'},
	[2] = {pos = {143.1,-1042.76,29.37}, heading = 235.08, name = 'Fleeca Bank [Legion Square] Cam #2'},
	[3] = {pos = {149.73,-1051.26,29.35}, heading = 16.87, name = 'Fleeca Bank [Legion Square] Cam #3'},
	--
	[4] = {pos = {317.63,-280.51,54.16}, heading = 46.96, name = 'Fleeca Bank [Alta] Cam #1'},
	[5] = {pos = {307.43,-281.14,54.16}, heading = 229.91, name = 'Fleeca Bank [Alta] Cam #2'},
	[6] = {pos = {314.07,-289.63,54.14}, heading = 24.06, name = 'Fleeca Bank [Alta] Cam #3'},
	--
	[7] = {pos = {-347.51,-51.26,49.04}, heading = 44.82, name = 'Fleeca Bank [Burton] Cam #1'},
	[8] = {pos = {-357.61,-51.92,49.04}, heading = 230.92, name = 'Fleeca Bank [Burton] Cam #2'},
	[9] = {pos = {-350.91,-60.51,49.01}, heading = 28.09, name = 'Fleeca Bank [Burton] Cam #3'},
	--
	[10] = {pos = {-1209.33,-329.2,37.78}, heading = 83.18, name = 'Fleeca Bank [Rockford Hills] Cam #1'},
	[11] = {pos = {-1215.84,-336.86,37.78}, heading = 270.99, name = 'Fleeca Bank [Rockford Hills] Cam #2'},
	[12] = {pos = {-1205.0,-338.07,37.76}, heading = 66.41, name = 'Fleeca Bank [Rockford Hills] Cam #3'},
	--
	[13] = {pos = {1171.39,2706.91,38.09}, heading = 243.26, name = 'Fleeca Bank [Grand Senora Desert] Cam #1'},
	[14] = {pos = {1180.68,2710.88,38.09}, heading = 63.94, name = 'Fleeca Bank [Grand Senora Desert] Cam #2'},
	[15] = {pos = {1171.55,2716.84,38.07}, heading = 226.04, name = 'Fleeca Bank [Grand Senora Desert] Cam #3'},
	--
	[16] = {pos = {-2962.26,486.62,15.7}, heading = 158.82, name = 'Fleeca Bank [Great Ocean Highway] Cam #1'},
	[17] = {pos = {-2958.7,477.21,15.7}, heading = 341.95, name = 'Fleeca Bank [Great Ocean Highway] Cam #2'},
	[18] = {pos = {-2952.44,485.95,15.68}, heading = 134.42, name = 'Fleeca Bank [Great Ocean Highway] Cam #3'},
	--
	[19] = {pos = {-108.86,6461.75,31.63}, heading = 357.17, name = 'Blaine County Savings Bank Cam #1'},
	[20] = {pos = {-103.91,6466.68,31.63}, heading = 89.7, name = 'Blaine County Savings Bank Cam #2'},
	[21] = {pos = {-102.28,6468.39,31.63}, heading = 29.87, name = 'Blaine County Savings Bank Cam #3'},
	[22] = {pos = {-104.54,6479.56,31.63}, heading = 176.15, name = 'Blaine County Savings Bank Cam #4'},
	--
	[23] = {pos = {233.11,221.94,106.29}, heading = 207.24, name = 'Pacific Standard Bank Cam #1'},
	[24] = {pos = {241.76,214.98,106.29}, heading = 283.2, name = 'Pacific Standard Bank Cam #2'},
	[25] = {pos = {258.99,204.19,110.29}, heading = 320.66, name = 'Pacific Standard Bank Cam #3'},
	[26] = {pos = {252.48,229.25,106.29}, heading = 157.75, name = 'Pacific Standard Bank Cam #4'},
	[27] = {pos = {252.0,225.43,101.68}, heading = 271.93, name = 'Pacific Standard Bank Cam #5'},
	--
}
