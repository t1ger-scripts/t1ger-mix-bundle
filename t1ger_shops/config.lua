-------------------------------------
------- Created by T1GER#9080 -------
-------------------------------------

-- General:
Config = {
    ESX_OBJECT = 'esx:getSharedObject', -- set your shared object event in here
	Debug = true, -- allows you to restart script while in-game, otherwise u need to restart server.
    ProgressBars = true, -- set to false if you do not use progressBars or using your own
	T1GER_Deliveries = true, -- true/false whether you own or not own t1ger-shops
	BuyShopWithBank = true, -- buy shop with bank money, false = cash.
	SalePercentage = 0.75, -- sell percentage when selling a shop.
	AccountsInBank = true, -- Set to false to deposit/withdraw money into and from shop account with cash-money instead of bank-money.
	ItemWeightSystem = false, -- Set this to true if you are using weight instead of limit.
	WeaponLoadout = true, -- Set this to false if you are using weapons as items.
	BasketCommand = 'basket', -- Default command to open/view basket.
	ShelfCommand = 'shelf', -- Default command to open shelf management menu
	ItemCompatibility = true, -- If disabled, it doesnt check for type compatibility in Config.Items, meaning weapon shop owner could add bread, redgull etc.
	OrderItemPercent = 25, -- Set percent between 1 and 100 of how much of the default item price is reduced, when ordering stock.
}

-- Blip Settings:
Config.BlipSettings = {
	['normal'] = { enable = true, sprite = 52, display = 4, scale = 0.65, color = 2, name = 'Shop' },
	['weapon'] = { enable = true, sprite = 110, display = 4, scale = 0.65, color = 6, name = 'Weapon Shop' },
	['pawnshop'] = { enable = true, sprite = 59, display = 4, scale = 0.65, color = 5, name = 'Pawn Shop' }
}

-- Marker Settings:
Config.MarkerSettings = {
	['boss'] = { enable = true, drawDist = 10.0, type = 20, scale = {x = 0.35, y = 0.35, z = 0.35}, color = {r = 240, g = 52, b = 52, a = 100} },
	['cashier'] = { enable = true, drawDist = 15.0, type = 20, scale = {x = 0.30, y = 0.30, z = 0.30}, color = {r = 0, g = 200, b = 70, a = 100} },
	['shelves'] = { enable = true, drawDist = 4.0, type = 20, scale = {x = 0.30, y = 0.30, z = 0.30}, color = {r = 240, g = 52, b = 52, a = 100} },
}

-- Key Controls:
Config.KeyControls = {
	['boss_menu'] = 38,
	['buy_shop'] = 38,
	['cashier'] = 38,
	['shelf'] = 38,
	['stock'] = 47,
}

-- Shops
Config.Shops = {
	[1] = {owned = false, society = 'shop1', type = "normal", price = 70000, buyable = true, b_menu = {-44.14,-1749.44,29.42}, cashier = {-47.29,-1756.7,29.42}, delivery = {-40.67,-1751.6,29.42}},
	[2] = {owned = false, society = 'shop2', type = "normal", price = 70000, buyable = true, b_menu = {28.84,-1339.35,29.5}, cashier = {25.81,-1345.25,29.5}, delivery = {24.67,-1339.09,29.5}},
	[3] = {owned = false, society = 'shop3', type = "weapon", price = 100000, buyable = true, b_menu = {846.24,-1030.89,28.19}, cashier = {842.18,-1034.01,28.19}, delivery = {841.65,-1025.63,28.19}},
	[4] = {owned = false, society = 'shop4', type = "normal", price = 70000, buyable = true, b_menu = {-709.68,905.4,19.22}, cashier = {-707.32,-912.9,19.22}, delivery = {-705.08,-904.4,19.22}},
	[5] = {owned = false, society = 'shop5', type = "pawnshop", price = 80000, buyable = true, b_menu = {1125.99,-980.38,45.42}, cashier = {1135.68,-982.85,46.42}, delivery = {1130.4,-979.64,46.42}},
	[6] = {owned = false, society = 'shop6', type = "normal", price = 70000, buyable = true, b_menu = {1159.77,-315.23,69.21}, cashier = {1163.39,-322.21,69.21}, delivery = {1163.9,-313.6,69.21}},
	[7] = {owned = false, society = 'shop7', type = "normal", price = 70000, buyable = true, b_menu = {378.8,333.1,103.57}, cashier = {373.59,325.52,103.57}, delivery = {374.88,334.51,103.57}},
	[8] = {owned = false, society = 'shop8', type = "pawnshop", price = 80000, buyable = true, b_menu = {-1478.56,-375.04,39.16}, cashier = {-1487.67,-378.54,40.16}, delivery = {-1481.33,-377.97,40.16}},
	[9] = {owned = false, society = 'shop9', type = "pawnshop", price = 80000, buyable = true, b_menu = {-1220.54,-916.4,11.33}, cashier = {-1222.23,-906.82,12.33}, delivery = {-1222.86,-913.26,12.33}},
	[10] = {owned = false, society = 'shop10', type = "pawnshop", price = 80000, buyable = true, b_menu = {1394.95,3608.62,34.98}, cashier = {1392.59,3605.07,34.98}, delivery = {1387.42,3607.84,34.98}},
	[11] = {owned = false, society = 'shop11', type = "normal", price = 70000, buyable = true, b_menu = {-1828.29,797.87,138.19}, cashier = {-1821.45,793.84,138.11}, delivery = {-1825.97,801.41,138.11}},
	[12] = {owned = false, society = 'shop12', type = "normal", price = 70000, buyable = true, b_menu = {-3048.0,586.32,7.91}, cashier = {-3038.78,585.85,7.91}, delivery = {-3047.06,582.23,7.91}},
	[13] = {owned = false, society = 'shop13', type = "normal", price = 70000, buyable = true, b_menu = {-3249.82,1005.02,12.83}, cashier = {-3241.54,1001.14,12.83}, delivery = {-3250.63,1000.98,12.83}},
	[14] = {owned = false, society = 'shop14', type = "pawnshop", price = 80000, buyable = true, b_menu = {-2959.18,387.12,14.04}, cashier = {-2967.74,391.57,15.04}, delivery = {-2963.1,387.19,15.04}},
	[15] = {owned = false, society = 'shop15', type = "normal", price = 70000, buyable = true, b_menu = {545.77,2662.87,42.16}, cashier = {547.77,2671.75,42.16}, delivery = {549.89,2662.95,42.16}},
	[16] = {owned = false, society = 'shop16', type = "pawnshop", price = 80000, buyable = true, b_menu = {1169.23,2718.18,37.16}, cashier = {1165.29,2709.35,38.16}, delivery = {1169.38,2714.34,38.16}},
	[17] = {owned = false, society = 'shop17', type = "normal", price = 70000, buyable = true, b_menu = {2673.21,3287.1,55.24}, cashier = {2679.15,3280.13,55.24}, delivery = {2670.82,3283.75,55.24}},
	[18] = {owned = false, society = 'shop18', type = "normal", price = 70000, buyable = true, b_menu = {1959.9,3749.09,32.34}, cashier = {1961.42,3740.09,32.34}, delivery = {1956.12,3747.44,32.34}},
	[19] = {owned = false, society = 'shop19', type = "normal", price = 70000, buyable = true, b_menu = {1706.87,4921.07,42.06}, cashier = {1699.27,4923.54,42.06}, delivery = {1705.28,4917.2,42.07}},
	[20] = {owned = false, society = 'shop20', type = "normal", price = 70000, buyable = true, b_menu = {1735.31,6420.41,35.04}, cashier = {1728.69,6414.18,35.04}, delivery = {1731.85,6422.65,35.04}},
	[21] = {owned = false, society = 'shop21', type = "weapon", price = 100000, buyable = true, b_menu = {13.89,-1106.35,29.8}, cashier = {22.35,-1106.8,29.8}, delivery = {18.05,-1111.11,29.8}},
	[22] = {owned = false, society = 'shop22', type = "weapon", price = 100000, buyable = false, b_menu = {-666.62,-933.68,21.83}, cashier = {-662.0,-934.88,21.83}, delivery = {-661.8,-943.33,21.83}},
	[23] = {owned = false, society = 'shop23', type = "weapon", price = 100000, buyable = false, b_menu = {817.97,-2155.28,29.62}, cashier = {809.84,-2157.76,29.62}, delivery = {812.6,-2152.32,29.62}},
	[24] = {owned = false, society = 'shop24', type = "weapon", price = 100000, buyable = false, b_menu = {255.21,-46.38,69.94}, cashier = {252.48,-50.46,69.94}, delivery = {244.47,-49.97,69.94}},
	[25] = {owned = false, society = 'shop25', type = "weapon", price = 100000, buyable = false, b_menu = {2572.32,292.75,108.73}, cashier = {2567.53,293.86,108.73}, delivery = {2567.29,302.36,108.73}},
	[26] = {owned = false, society = 'shop26', type = "weapon", price = 100000, buyable = false, b_menu = {-1122.17,2696.71,18.55}, cashier = {-1117.8,2699.0,18.55}, delivery = {-1111.99,2692.91,18.55}},
	[27] = {owned = false, society = 'shop27', type = "weapon", price = 100000, buyable = false, b_menu = {1689.3,3757.76,34.71}, cashier = {1693.37,3760.3,34.71}, delivery = {1699.71,3754.64,34.71}},
	[28] = {owned = false, society = 'shop28', type = "weapon", price = 100000, buyable = false, b_menu = {-334.67,6081.79,31.45}, cashier = {-330.33,6084.49,31.45}, delivery = {-324.43,6078.36,31.45}},
}

Config.SocietySettings = {
	withdraw  = true, -- boss can withdraw money from account
	deposit   = true, -- boss can deposit money into account
	wash      = false, -- boss can wash money
	employees = true, -- boss can manage & recruit employees
	grades    = false, -- boss can adjust all salaries for each job grade
}

Config.Society = { -- requires esx_society (set settings for what boss can do in each dealerships)
	['shop1'] = {
		-- register society:
		name = 'shop1', -- job name 
		label = 'Shop', -- job label
		account = 'society_shop1', -- society account
		datastore = 'society_shop1', -- society datastore
		inventory = 'society_shop1', -- society inventory
		boss_grade = 2, -- boss grade number to apply upon purchase
		data = {type = 'private'},
	},
	['shop2']  = { name = 'shop2', label = 'Shop', account = 'society_shop2', datastore = 'society_shop2', inventory = 'society_shop2', boss_grade = 2, data = {type = 'private'} },
	['shop3']  = { name = 'shop3', label = 'Shop', account = 'society_shop3', datastore = 'society_shop3', inventory = 'society_shop3', boss_grade = 2, data = {type = 'private'} },
	['shop4']  = { name = 'shop4', label = 'Shop', account = 'society_shop4', datastore = 'society_shop4', inventory = 'society_shop4', boss_grade = 2, data = {type = 'private'} },
	['shop5']  = { name = 'shop5', label = 'Shop', account = 'society_shop5', datastore = 'society_shop5', inventory = 'society_shop5', boss_grade = 2, data = {type = 'private'} },
	['shop6']  = { name = 'shop6', label = 'Shop', account = 'society_shop6', datastore = 'society_shop6', inventory = 'society_shop6', boss_grade = 2, data = {type = 'private'} },
	['shop7']  = { name = 'shop7', label = 'Shop', account = 'society_shop7', datastore = 'society_shop7', inventory = 'society_shop7', boss_grade = 2, data = {type = 'private'} },
	['shop8']  = { name = 'shop8', label = 'Shop', account = 'society_shop8', datastore = 'society_shop8', inventory = 'society_shop8', boss_grade = 2, data = {type = 'private'} },
	['shop9']  = { name = 'shop9', label = 'Shop', account = 'society_shop9', datastore = 'society_shop9', inventory = 'society_shop9', boss_grade = 2, data = {type = 'private'} },
	['shop10']  = { name = 'shop10', label = 'Shop', account = 'society_shop10', datastore = 'society_shop10', inventory = 'society_shop10', boss_grade = 2, data = {type = 'private'} },
	['shop11']  = { name = 'shop11', label = 'Shop', account = 'society_shop11', datastore = 'society_shop11', inventory = 'society_shop11', boss_grade = 2, data = {type = 'private'} },
	['shop12']  = { name = 'shop12', label = 'Shop', account = 'society_shop12', datastore = 'society_shop12', inventory = 'society_shop12', boss_grade = 2, data = {type = 'private'} },
	['shop13']  = { name = 'shop13', label = 'Shop', account = 'society_shop13', datastore = 'society_shop13', inventory = 'society_shop13', boss_grade = 2, data = {type = 'private'} },
	['shop14']  = { name = 'shop14', label = 'Shop', account = 'society_shop14', datastore = 'society_shop14', inventory = 'society_shop14', boss_grade = 2, data = {type = 'private'} },
	['shop15']  = { name = 'shop15', label = 'Shop', account = 'society_shop15', datastore = 'society_shop15', inventory = 'society_shop15', boss_grade = 2, data = {type = 'private'} },
	['shop16']  = { name = 'shop16', label = 'Shop', account = 'society_shop16', datastore = 'society_shop16', inventory = 'society_shop16', boss_grade = 2, data = {type = 'private'} },
	['shop17']  = { name = 'shop17', label = 'Shop', account = 'society_shop17', datastore = 'society_shop17', inventory = 'society_shop17', boss_grade = 2, data = {type = 'private'} },
	['shop18']  = { name = 'shop18', label = 'Shop', account = 'society_shop18', datastore = 'society_shop18', inventory = 'society_shop18', boss_grade = 2, data = {type = 'private'} },
	['shop19']  = { name = 'shop19', label = 'Shop', account = 'society_shop19', datastore = 'society_shop19', inventory = 'society_shop19', boss_grade = 2, data = {type = 'private'} },
	['shop20']  = { name = 'shop20', label = 'Shop', account = 'society_shop20', datastore = 'society_shop20', inventory = 'society_shop20', boss_grade = 2, data = {type = 'private'} },
	['shop21']  = { name = 'shop21', label = 'Shop', account = 'society_shop21', datastore = 'society_shop21', inventory = 'society_shop21', boss_grade = 2, data = {type = 'private'} },
	['shop22']  = { name = 'shop22', label = 'Shop', account = 'society_shop22', datastore = 'society_shop22', inventory = 'society_shop22', boss_grade = 2, data = {type = 'private'} },
	['shop23']  = { name = 'shop23', label = 'Shop', account = 'society_shop23', datastore = 'society_shop23', inventory = 'society_shop23', boss_grade = 2, data = {type = 'private'} },
	['shop24']  = { name = 'shop24', label = 'Shop', account = 'society_shop24', datastore = 'society_shop24', inventory = 'society_shop24', boss_grade = 2, data = {type = 'private'} },
	['shop25']  = { name = 'shop25', label = 'Shop', account = 'society_shop25', datastore = 'society_shop25', inventory = 'society_shop25', boss_grade = 2, data = {type = 'private'} },
	['shop26']  = { name = 'shop26', label = 'Shop', account = 'society_shop26', datastore = 'society_shop26', inventory = 'society_shop26', boss_grade = 2, data = {type = 'private'} },
	['shop27']  = { name = 'shop27', label = 'Shop', account = 'society_shop27', datastore = 'society_shop27', inventory = 'society_shop27', boss_grade = 2, data = {type = 'private'} },
	['shop28']  = { name = 'shop28', label = 'Shop', account = 'society_shop28', datastore = 'society_shop28', inventory = 'society_shop28', boss_grade = 2, data = {type = 'private'} },
}

-- Shop Items:
Config.Items = {
	{label = "Water", item = "water", type = {"normal"}, price = 10},
	{label = "Energy Drink", item = "redgull", type = {"normal"}, price = 75},
	{label = "Pisswasser", item = "pisswasser", type = {"normal"}, price = 50},
	{label = "Sandwich", item = "sandwich", type = {"normal"}, price = 10},
	{label = "Bread", item = "bread", type = {"normal"}, price = 10},
	{label = "Donut", item = "donut", type = {"normal"}, price = 10},
	{label = "Tacos", item = "tacos", type = {"normal"}, price = 10},
	{label = "Repairkit", item = "repairkit", type = {"normal", "pawnshop"}, price = 250},
	{label = "Lockpick", item = "lockpick", type = {"pawnshop"}, price = 200},
	{label = "Umbrella", item = "umbrella", type = {"normal"}, price = 100},
	{label = "Binoculars", item = "binoculars", type = {"normal"}, price = 100},
	{label = "Oxygen Mask", item = "oxygenmask", type = {"normal", "pawnshop"}, price = 300},
	{label = "Handcuffs", item = "handcuffs", type = {"normal", "pawnshop"}, price = 300},
	{label = "Pistol", item = "WEAPON_PISTOL", str_match = "weapon", type = {"weapon"}, price = 1500},
	{label = "SNS Pistol", item = "WEAPON_SNSPISTOL", str_match = "weapon", type = {"weapon"}, price = 2000},
	{label = "AP Pistol", item = "WEAPON_APPISTOL", str_match = "weapon", type = {"weapon"}, price = 4000},
	{label = "Pistol. 50", item = "WEAPON_PISTOL50", str_match = "weapon", type = {"weapon"}, price = 6000},
	{label = "Mini SMG", item = "WEAPON_MINISMG", str_match = "weapon", type = {"weapon"}, price = 5000},
	{label = "Micro SMG", item = "WEAPON_MICROSMG", str_match = "weapon", type = {"weapon"}, price = 6000},
	{label = "SMG", item = "WEAPON_SMG", str_match = "weapon", type = {"weapon"}, price = 7000},
	{label = "Assault Rifle", item = "WEAPON_ASSAULTRIFLE", str_match = "weapon", type = {"weapon"}, price = 12000},
	{label = "Carbine Rifle", item = "WEAPON_CARBINERIFLE", str_match = "weapon", type = {"weapon"}, price = 15000},
	{label = "Pistol Ammo", item = "pistol_ammo", ammo_type = 1950175060, str_match = "ammo", type = {"weapon"}, price = 25},
	{label = "SMG Ammo", item = "smg_ammo", ammo_type = 1820140472, str_match = "ammo", type = {"weapon"}, price = 50},
	{label = "Rifle Ammo", item = "rifle_ammo", ammo_type = 218444191, str_match = "ammo", type = {"weapon"}, price = 100},
	{label = "Shotgun Ammo", item = "shotgun_ammo", ammo_type = -1878508229, str_match = "ammo", type = {"weapon"}, price = 150},
	{label = "Body Armor", item = "bulletproof", type = {"weapon"}, price = 5000},
}

Config.AmmoTypes = {
	[1] = {label = "Pistol Ammo", hash = 1950175060},
	[2] = {label = "SMG Ammo", hash = 1820140472},
	[3] = {label = "Shotgun Ammo", hash = -1878508229},
	[4] = {label = "Rifle Ammo", hash = 218444191},
}
