-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {
    ESX_OBJECT = 'esx:getSharedObject', -- set your shared object event in here
	Debug = true, -- allows you to restart script while in-game, otherwise u need to restart fivem.
    ProgressBars = true, -- set to false if you do not use progressBars or using your own
	T1GER_Keys = true, -- true/false whether you own or not own t1ger-keys
	T1GER_Shops = true, -- true/false whether you own or not own t1ger-shops
	BuyWithBank = true, -- buy company with bank money, false = cash.
	SalePercentage = 0.75, -- 
	CertificatePrice = 15000, -- Set price to purchase certificate
	DepositInBank = true, -- set to false to pay vehicle deposit with cash money
	DamagePercent = 5, -- if job veh body health is decreased more than 5%, then no payout for that specific delivery.
	DepositDamage = 10, -- if vehicle is damaged more than x %, then deposit is not returned.
	AddLevelAmount = 2, -- Set amount of levels added upon completing a job
}

Config.Companies = {
	[1] = {
		society = 'delivery1', -- this must match an identifier name inside Config.Society!
		price = 125000, -- price of the company.
		owned = false, -- do not touch this!
		menu = vector3(-456.95,-2753.43,6.0), -- menu pos
		spawn = vector4(-447.78,-2752.48,6.0,44.5), -- pos for veh spawn
		trailerSpawn = vector4(-455.47,-2732.51,6.0,225.12), -- pos to spawn trailer

		refill = {
			pos = vector3(-461.94,-2744.51,6.0), -- refill pos
			marker = {dist = 10.0, type = 27, scale = {x=3.0,y=3.0,z=1.0}, color = {r=220,g=60,b=60,a=100}}, -- refill marker
		},

		cargo = {
			pos = {
				[1] = vector3(-463.09,-2748.91,6.0),
				[2] = vector3(-465.1,-2747.12,6.0),
				[3] = vector3(-465.09,-2751.86,6.0),
				[4] = vector3(-467.06,-2749.3,6.0),
				[5] = vector3(-467.04,-2746.15,6.0),
			},
			marker = {dist = 15.0, type = 20, scale = {x=0.3,y=0.3,z=0.3}, color = {r=220,g=60,b=60,a=100}}, -- cargo marker
		},

		forklift = {
			model = 'forklift', -- forklift model
			pos = vector4(-460.56,-2744.66,6.0,48.77),
		},
	},
	[2] = {
		society = 'delivery2', -- this must match an identifier name inside Config.Society!
		price = 115000, -- price of the company.
		owned = false, -- do not touch this!
		menu = vector3(-297.55,-2599.26,6.2), -- menu pos
		spawn = vector4(-304.61,-2599.87,6.0,136.67), -- pos for veh spawn
		trailerSpawn = vector4(-319.42,-2603.78,6.0,136.49), -- pos to spawn trailer

		refill = {
			pos = vector3(-288.16,-2593.52,6.0), -- refill pos
			marker = {dist = 10.0, type = 27, scale = {x=3.0,y=3.0,z=1.0}, color = {r=220,g=60,b=60,a=100}}, -- refill marker
		},

		cargo = {
			pos = {
				[1] = vector3(-288.17,-2599.62,6.0),
				[2] = vector3(-290.12,-2601.57,6.03),
				[3] = vector3(-291.68,-2603.45,6.03),
				[4] = vector3(-290.6,-2597.05,6.0),
				[5] = vector3(-292.67,-2594.93,6.0),
			},
			marker = {dist = 15.0, type = 20, scale = {x=0.3,y=0.3,z=0.3}, color = {r=220,g=60,b=60,a=100}}, -- cargo marker
		},

		forklift = {
			model = 'forklift', -- forklift model
			pos = vector4(-297.82,-2593.84,6.0,45.55),
		},
	},
}

-- Blip Settings:
Config.BlipSettings = {
	['company'] = { enable = true, sprite = 477, display = 4, scale = 0.60, color = 0, name = "Delivery Company" },
}
-- Marker Settings:
Config.MarkerSettings = {
	['menu'] = { enable = true, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100} },
	['delivery'] = { enable = true, type = 2, scale = {x = 0.35, y = 0.35, z = 0.35}, color = {r = 220, g = 60, b = 60, a = 100} },
}

Config.Society = { -- requires esx_society (set settings for what boss can do in each dealerships)
	['delivery1'] = {
		-- register society:
		name = 'delivery1', -- job name 
		label = 'Delivery Job', -- job label
		account = 'society_delivery1', -- society account
		datastore = 'society_delivery1', -- society datastore
		inventory = 'society_delivery1', -- society inventory
		boss_grade = 1, -- boss grade number to apply upon purchase
		data = {type = 'private'},
		-- settings:
		withdraw  = true, -- boss can withdraw money from account
		deposit   = true, -- boss can deposit money into account
		wash      = false, -- boss can wash money
		employees = true, -- boss can manage & recruit employees
		grades    = false -- boss can adjust all salaries for each job grade
	},
	['delivery2']  = {
		-- register society:
		name = 'delivery2', -- job name 
		label = 'Delivery Job', -- job label
		account = 'society_delivery2', -- society account
		datastore = 'society_delivery2', -- society datastore
		inventory = 'society_delivery2', -- society inventory
		boss_grade = 1, -- boss grade number to apply upon purchase
		data = {type = 'private'},
		-- settings:
		withdraw  = true, -- boss can withdraw money from account
		deposit   = true, -- boss can deposit money into account
		wash      = false, -- boss can wash money
		employees = true, -- boss can manage & recruit employees
		grades    = false -- boss can adjust all salaries for each job grade
	},
}

Config.JobValues = {
	[1] = {
		label = "Low", level = 0, certificate = false,
		vehicles = {
			[1] = {name = "Surfer 2", model = "surfer2", deposit = 500},
			[2] = {name = "Speedo", model = "speedo", deposit = 1000},
			[3] = {name = "Burrito 3", model = "burrito3", deposit = 1500},
			[4] = {name = "Rumpo", model = "rumpo", deposit = 2000}
		}
	},
	[2] = {
		label = "Medium", level = 20, certificate = false,
		vehicles = {
			[1] = {name = "Boxville 2", model = "boxville2", deposit = 1500},
			[2] = {name = "Boxville 4", model = "boxville4", deposit = 3000}
		}
	},
	[3] = {
		label = "High", level = 50, certificate = true,
		vehicles = { 
			[1] = {name = "Hauler", model = "hauler", deposit = 1500},
			[2] = {name = "Packer", model = "packer", deposit = 3000},
			[3] = {name = "Phantom", model = "phantom", deposit = 4500},
		}
	},
	[4] = { -- DO NOT TOUCH ID NUMBER OF THIS!!!!
		label = "Shops", level = 0, certificate = false,
		vehicles = { 
			[1] = {name = "Speedo", model = "speedo", deposit = 1000},
			[2] = {name = "Burrito 3", model = "burrito3", deposit = 1500},
			[3] = {name = "Boxville 2", model = "boxville2", deposit = 2500},
			[4] = {name = "Boxville 4", model = "boxville4", deposit = 3000},
		}
	},
}

Config.KeyControls = {
	['company_menu'] = 38,
	['buy_company'] = 38,
	['fill_up_trailer'] = 38,
	['park_forklift'] = 47,
	['take_forklift'] = 47,
	['deliver_pallet'] = 38,
	['return_vehicle'] = 38,
	['put_pallet_in_trailer'] = 38,
	['fill_up_vehicle'] = 38,
	['take_parcel'] = 38,
	['deliver_parcel'] = 47,
	['pick_up_parcel'] = 38,
	['parcel_in_veh'] = 38,
}

-- Reward Settings:
Config.Reward = { 
	min = 250,
	max = 500, 
	valueAddition = { [1] = 5, [2] = 15, [3] = 50, [4] = 50 }	-- adds x% to the math.random(min,max), where 1, 2, 3 are levels
}

Config.ParcelProp = "prop_cs_cardbox_01"		-- set prop type for low value jobs
Config.LowValueJobs = {
	[1] = {pos = vector3(85.63,-1959.32,21.12), done = false},
	[2] = {pos = vector3(-14.09,-1442.06,31.1), done = false},
	[3] = {pos = vector3(334.67,-2057.93,20.94), done = false},
	[4] = {pos = vector3(479.67,-1736.01,29.15), done = false},
	[5] = {pos = vector3(-1075.48,-1645.37,4.5), done = false},
	[6] = {pos = vector3(-1132.46,-1455.88,4.87), done = false},
	[7] = {pos = vector3(-951.8,-1078.59,2.15), done = false},
	[8] = {pos = vector3(-911.93,-1511.76,5.02), done = false},
	[9] = {pos = vector3(-1112.03,-902.51,3.6), done = false},
	[10] = {pos = vector3(976.25,-580.07,59.64), done = false},
	[11] = {pos = vector3(1303.06,-527.99,71.46), done = false}
}

Config.MedValueJobs = {
	[1] = {
		name = "Clothing",
		prop = "prop_tshirt_box_01",
		deliveries = {
			[1] = {pos = vector3(79.34,-1389.52,29.38), done = false},
			[2] = {pos = vector3(-1198.24,-774.43,17.32), done = false},
			[3] = {pos = vector3(421.83,-809.75,29.49), done = false},
			[4] = {pos = vector3(-1456.23,-234.61,49.8), done = false},
			[5] = {pos = vector3(-3169.31,1052.05,20.86), done = false},
			[6] = {pos = vector3(-1096.36,2710.0,19.11), done = false},
			[7] = {pos = vector3(616.91,2754.84,42.09), done = false},
			[8] = {pos = vector3(126.58,-215.31,54.56), done = false},
		},
	},
	[2] = {
		name = "Liquor",
		prop = "prop_crate_11e",
		deliveries = {
			[1] = {pos = vector3(-56.64,-1750.96,29.42), done = false},
			[2] = {pos = vector3(33.64,-1346.68,29.5), done = false},
			[3] = {pos = vector3(-1487.03,-383.3,40.16), done = false},
			[4] = {pos = vector3(1137.89,-978.62,46.42), done = false},
			[5] = {pos = vector3(-1227.16,-906.51,12.33), done = false},
			[6] = {pos = vector3(381.54,324.29,103.57), done = false},
			[7] = {pos = vector3(1169.23,2706.28,38.16), done = false},
			[8] = {pos = vector3(539.92,2670.01,42.16), done = false},
		},
	},
}

Config.HighValueJobs = {
	[1] = {
		name = "Liquor",
		trailer = "Trailers2",
		prop = "prop_boxpile_06a",
		route = {
			[1] = {pos = vector4(-306.35,-2714.35,6.0,314.45), pallet = {pickup = vector4(-313.6,-2717.76,6.0,226.09), drop_off = vector3(-306.9,-2728.23,6.0)}, done = false},
			[2] = {pos = vector4(-201.63,-2390.17,6.0,269.95), pallet = {pickup = vector4(-203.16,-2394.94,6.0,89.49), drop_off = vector3(-211.23,-2385.75,6.0)}, done = false},
			[3] = {pos = vector4(-536.15,-2841.45,6.0,19.78), pallet = {pickup = vector4(-527.42,-2840.9,6.0,119.35), drop_off = vector3(-536.44,-2849.78,6.01)}, done = false},
			[4] = {pos = vector4(58.26,-2529.96,6.01,328.5), pallet = {pickup = vector4(60.87,-2534.63,6.0,61.36), drop_off = vector3(49.01,-2531.46,6.01)}, done = false},
			[5] = {pos = vector4(-161.28,-2659.04,6.0,271.15), pallet = {pickup = vector4(-164.27,-2664.0,6.0,359.45), drop_off = vector3(-168.86,-2654.88,6.0)}, done = false},
		},
	},
	[2] = {
		name = "Groceries",
		trailer = "Trailers2",
		prop = "prop_boxpile_06a",
		route = {
			[1] = {pos = vector4(-306.35,-2714.35,6.0,314.45), pallet = {pickup = vector4(-313.6,-2717.76,6.0,226.09), drop_off = vector3(-306.9,-2728.23,6.0)}, done = false},
			[2] = {pos = vector4(-201.63,-2390.17,6.0,269.95), pallet = {pickup = vector4(-203.16,-2394.94,6.0,89.49), drop_off = vector3(-211.23,-2385.75,6.0)}, done = false},
			[3] = {pos = vector4(-536.15,-2841.45,6.0,19.78), pallet = {pickup = vector4(-527.42,-2840.9,6.0,119.35), drop_off = vector3(-536.44,-2849.78,6.01)}, done = false},
			[4] = {pos = vector4(58.26,-2529.96,6.01,328.5), pallet = {pickup = vector4(60.87,-2534.63,6.0,61.36), drop_off = vector3(49.01,-2531.46,6.01)}, done = false},
			[5] = {pos = vector4(-161.28,-2659.04,6.0,271.15), pallet = {pickup = vector4(-164.27,-2664.0,6.0,359.45), drop_off = vector3(-168.86,-2654.88,6.0)}, done = false},
		},
	},
}
