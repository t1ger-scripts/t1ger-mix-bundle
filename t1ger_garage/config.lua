-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {
    ESX_OBJECT          = 'esx:getSharedObject',    -- set your shared object event in here
	Debug				= true,						-- allows you to restart script while in-game, otherwise u need to restart fivem.
    ProgressBars        = true,                     -- set to false if you do not use progressBars or using your own
    T1GER_Keys     		= true,                     -- set to false if you dont own/use t1ger-keys.
	T1GER_Dealerships	= true,						-- set to false if you dont own/use t1ger-dealerships.
	HasFuelScript		= true,						-- true/false (check documentation for correct usage)
	UseTypeCheck		= false, 					-- set to true if u want type check when storing vehicles
}

-------------------------------
-- Normal Garages & Settings --
-------------------------------

Config.Garage = {
	Command = 'garages',	-- command to view list of garages
	UseNames = true,	-- uses the name of each garage, like this; Garage: A or Hangar: B
	StoreAnotherVehicle = false, -- Allow player B to store player A's vehicle (doesn't affect player A, car is still in his ownership and garage)
	Teleport = true, -- warp player into spawned vehicle
	Transfer = true, -- allow players to transfer vehicles from one garage to another

	Locations = { -- 
		[1] = {
			type = 'car',	-- type of vehicle (cars)
			name = 'A', -- garage name in database and blip
			pos = vector3(212.86,-797.53,30.87),	-- pos for action
			text = '~r~[E]~s~ Car Garage',	-- draw text
			dist = 2.0,	-- dist to interact
			spawn = vector4(212.86,-797.53,30.87,338.93),	-- spawn pos of vehicle
			text2 = '~r~[E]~s~ Store Car',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 0, name = 'Garage'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings
		},
		[2] = {
			type = 'aircraft',	-- type of vehicle (aircraft)
			name = 'A', -- garage name in database and blip
			pos = vector3(-981.57,-2994.91,13.95),	-- pos for action
			text = '~r~[E]~s~ Aircraft Garage',	-- draw text
			dist = 2.0,	-- dist to interact
			spawn = vector4(-981.57,-2994.91,13.95,58.58),	-- spawn pos of vehicle
			text2 = '~r~[E]~s~ Store Aircraft',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 0, name = 'Hangar'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings
		},
		[3] = {
			type = 'boat',	-- type of vehicle (boat)
			name = 'A', -- garage name in database and blip
			pos = vector3(-717.0,-1363.93,1.6),	-- pos for action
			text = '~r~[E]~s~ Boat Garage',	-- draw text
			dist = 2.0,	-- dist to interact
			spawn = vector4(-719.2,-1360.8,1.47,130.25),	-- spawn pos of vehicle
			text2 = '~r~[E]~s~ Store Boat',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 0, name = 'Harbor'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings
		},
		[4] = {
			type = 'car',	-- type of vehicle (cars)
			name = 'B',  -- garage name in database and blip
			pos = vector3(-453.76,-812.34,30.55),	-- pos for action
			text = '~r~[E]~s~ Car Garage',	-- draw text
			dist = 2.0,	-- dist to interact
			spawn = vector4(-453.76,-812.34,30.55,0.4),	-- spawn pos of vehicle
			text2 = '~r~[E]~s~ Store Car',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 0, name = 'Garage'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings
		},
	}
}

----------------------------
-- Job Garages & Settings --
----------------------------

Config.JobGarage = {
	Teleport = true, -- set to false to not warp player into spawned vehicle.
	Keybind = 38,	-- key bind to use job garages
	FuelLevel = 75, -- only works with spawned vehicles, not society owned.

	Locations = {
		[1] = {
			type = 'car',	-- type of vehicle (cars)
			options = 'both', -- set between 'both', 'society' and 'spawner' (spawn is just a vehicle spawner, society is owned vehicles from database, where owner is first entry of job name from below)
			jobs = {'police', 'lspd'},	-- allowed jobs
			jobKeys = 0, -- set to 1 if only player needs keys, set to 2 if all job players from those jobs needs keys. Set to 0 if u dont have t1ger-keys 
			pos = vector3(453.21,-1018.21,28.45),	-- pos for action
			text = '~r~[E]~s~ Police Car Garage',	-- draw text
			dist = 2.0,	-- dist to interact
			spawn = vector4(453.21,-1018.21,28.45,90.23),	-- spawn pos of vehicle
			text2 = '~r~[E]~s~ Store Vehicle',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 38, name = 'Police Car Garage'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 0, g = 102, b = 204, a = 100}},	-- marker settings
		},
		[2] = {
			type = 'aircraft',
			options = 'both', -- set between 'both', 'society' and 'spawner'
			jobs = {'police', 'lspd'},
			jobKeys = 0, -- set to 1 if only player needs keys, set to 2 if all job players from those jobs needs keys. Set to 0 if u dont have t1ger-keys 
			pos = vector3(449.33,-981.26,43.69),
			text = '~r~[E]~s~ Police Aircraft Garage',
			dist = 2.0,
			spawn = vector4(449.33,-981.26,43.69,93.88),
			text2 = '~r~[E]~s~ Store Aircraft',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 38, name = 'Police Aircraft Garage'},
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 0, g = 102, b = 204, a = 100}}
		},
		[3] = {
			type = 'boat',
			options = 'both', -- set between 'both', 'society' and 'spawner'
			jobs = {'police', 'lspd'},
			jobKeys = 0, -- set to 1 if only player needs keys, set to 2 if all job players from those jobs needs keys. Set to 0 if u dont have t1ger-keys 
			pos = vector3(-800.05,-1512.83,1.6),
			text = '~r~[E]~s~ Police Boat Garage',
			dist = 2.0,
			spawn = vector4(-800.73,-1507.54,1.47,108.28),
			text2 = '~r~[E]~s~ Store Boat',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 38, name = 'Police Boat Garage'},
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 0, g = 102, b = 204, a = 100}}
		},
		[4] = {
			type = 'car',
			options = 'spawner', -- set between 'both', 'society' and 'spawner'
			jobs = {'taxi'},
			jobKeys = 0, -- set to 1 if only player needs keys, set to 2 if all job players from those jobs needs keys. Set to 0 if u dont have t1ger-keys 
			pos = vector3(908.12,-176.28,74.16),
			text = '~r~[E]~s~ Taxi Garage',
			dist = 2.0,
			spawn = vector4(908.12,-176.28,74.16,239.08),
			text2 = '~r~[E]~s~ Store Taxi',	-- draw text
			blip = {enable = true, sprite = 357, scale = 0.65, color = 28, name = 'Taxi Garage'},
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 204, g = 204, b = 0, a = 100}}
		},
	}
}

Config.JobVehicles = {
	['police'] = {
		[1] = {model = 'police3', label = 'Police Cruiser', type = 'car', grade = 0}, -- add vehicle model, label, type of vehicle and grade
		[2] = {model = 'police4', label = 'Police U/M Cruiser', type = 'car', grade = 0},
		[3] = {model = 'policeb', label = 'Police Bike', type = 'car', grade = 0},
		[4] = {model = 'polmav', label = 'Police Helicopter', type = 'aircraft', grade = 0},
		[5] = {model = 'predator', label = 'Police Boat', type = 'boat', grade = 0},
	},
	['ambulance'] = {
		[1] = {model = 'ambulance', label = 'EMS Vehicle', type = 'car', grade = 0},
		[2] = {model = 'polmav', label = 'EMS Helicopter', type = 'aircraft', grade = 0},
	},
	['taxi'] = {
		[1] = {model = 'taxi', label = 'Taxi', type = 'car', grade = 0},
	},
}

-------------------------
-- Extras & Settings --
-------------------------

Config.Extras = {
	Keybind = 38,  -- keybind to use extras
	Locations = {
		-- MRPD Parking:
		[1] = {
			pos = vector3(454.07,-1024.65,28.49),
			classes = {18, 17, 16, 15}, -- allowed classes: https://docs.fivem.net/natives/?_0x29439776AAA00A62
			text = '~r~[E]~s~ Vehicle Extras',
			blip = {enable = false, sprite = 402, scale = 0.65, color = 0, name = 'Vehicle Extra'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings
		},
		-- MRPD Roof:
		[2] = {
			pos = vector3(453.58,-992.54,43.69),
			classes = {18, 17, 16, 15}, -- allowed classes: https://docs.fivem.net/natives/?_0x29439776AAA00A62
			text = '~r~[E]~s~ Vehicle Extras',
			blip = {enable = false, sprite = 402, scale = 0.65, color = 0, name = 'Vehicle Extra'},	-- blip settings
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},	-- marker settings
		},
	}
}

-------------------------
-- Impounds & Settings --
-------------------------

Config.Impound = {
	Command = 'impound', -- Command to impound vehicles (NORMAL IMPOUND)
	Jobs = { -- Jobs that can impound vehicles with command (NORMAL IMPOUND)
		'police',
		'towtrucker',
		-- add more 'mechanic',
	},
	Seize = { -- Seize/release
		command = 'seize', -- command to seize vehicles (players cannot take out the vehicle from garage/impound)
		jobs = {'police', 'lspd'}, -- jobs that can seize/release vehicles
		pos = vector3(433.69,-1014.52,28.78), -- pos where jobs^^ can release vehicles, and players can go to an impound and get it.
		text = '~b~[E]~s~ Police Impound Register',
		keybind = 38,
		blip = {enable = true, sprite = 525, color = 38, scale = 0.65, name = 'Police Impound Register'},
		marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 0, g = 102, b = 204, a = 100}},
	},
	Fees = 500, -- impound fees to take vehicle out
	Bank = true, -- set to false to pay fees with cash
	Locations = { -- add locations for impounds where player can take out their impounded vehicles:
		[1] = {
			type = 'car',
			pos = vector3(410.02,-1638.29,29.29),
			dist = 2.0,
			keybind = 38,
			teleport = true,
			spawn = vector4(410.02,-1638.29,29.29,5.94),
			text = '~r~[E]~s~ Car Impound',
			blip = {enable = true, sprite = 68, scale = 0.65, color = 3, name = 'Car Impound'},
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}},
		},
		[2] = {
			type = 'aircraft',
			pos = vector3(-1337.45,-2713.29,13.94),
			dist = 2.0,
			keybind = 38,
			teleport = true,
			spawn = vector4(-1337.45,-2713.29,13.94,149.2),
			text = '~r~[E]~s~ Aircraft Impound',
			blip = {enable = true, sprite = 68, scale = 0.65, color = 3, name = 'Aircraft Impound'},
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}}
		},
		[3] = {
			type = 'boat',
			pos = vector3(-806.51,-1497.04,1.6),
			dist = 2.0,
			keybind = 38,
			teleport = true,
			spawn = vector4(-807.64,-1491.69,1.47,106.62),
			text = '~r~[E]~s~ Boat Impound',
			blip = {enable = true, sprite = 68, scale = 0.65, color = 3, name = 'Boat Impound'},
			marker = {enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100}}
		},
	}
}

--------------------------------
-- Private Garages & Settings --
--------------------------------
Config.EnablePrivateGarages = true -- enable or disable private garages
-- blips:
Config.PrivateGarageBlip = { enable = true, sprite = 357, display = 4, scale = 0.65, color = 3 } -- blip settings
Config.ShowBlipOwned = true -- show blip for owned garage for source player
Config.ShowBlipPlayer = true -- show blip for other player's owned garages
Config.ShowBlipPurchase = true -- show blip for purchasable garages

Config.PrivateGarageMarker = { enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100} } -- marker settings
Config.LoadDist = 10 -- load distance
Config.InteractDist = 2.5 -- interact distance
Config.InteractKey = 38 -- key to enter/leave garage
Config.BuyGarageWithBank = true -- pay pvt garage with bank money, else normal cash
Config.SellPercent = 0.75 -- Means player gets 75% in return from original paid price.

-- do not touch this
Config.GarageShells = {
	['garage_small'] = GetHashKey('shell_garages'), 
	['garage_medium'] = GetHashKey('shell_garagem'), 
	['garage_large'] = GetHashKey('shell_garagel'), 
}

-- add more garages or changes coordinates
Config.PrivateGarages = {
	[1] = { pos = {-811.01,806.07,202.18}, h = 19.92, prop = 'garage_medium', price = 10000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[2] = { pos = {-851.28,788.69,191.73}, h = 188.51, prop = 'garage_medium', price = 10000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[3] = { pos = {-904.57,781.17,186.32}, h = 189.47, prop = 'garage_large', price = 20000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[4] = { pos = {-956.73,802.04,177.72}, h = 1.8, prop = 'garage_large', price = 20000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[5] = { pos = {-1002.26,784.79,171.46}, h = 112.48, prop = 'garage_large', price = 20000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[6] = { pos = {-964.82,763.23,175.43}, h = 227.8, prop = 'garage_small', price = 5000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[7] = { pos = {-2587.74,1931.1,167.3}, h = 270.99, prop = 'garage_large', price = 250000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	[8] = { pos = {-1096.47,360.05,68.53}, h = 2.79, prop = 'garage_medium', price = 50000, cache = {}, owned = false --[[do not touch cache & owned state]] },
	-- [9] = add more garages
}

-- do not touch these offsets unless you 100% know what u are doing!!!
Config.Offsets = {
	['garage_small'] = {
		entrance = {0.0, -5.0, 0.0-0.975},
		heading = 1.39,
		veh = {
			[1] = {pos = {2.0, 0.0, 0.0}, heading = 181.59},
			[2] = {pos = {-2.0, 0.0, 0.0}, heading = 181.59},
		},
	},
	['garage_medium'] = {
		entrance = {0.0, -7.0, 0.0-0.975},
		heading = 0.67,
		veh = {
			[1] = {pos = {-4.97, -3.24, 0.0}, heading = 0.86},
			[2] = {pos = {0.0, -3.24, 0.0}, heading = 0.86},
			[3] = {pos = {4.97, -3.24, 0.0}, heading = 0.86},
			[4] = {pos = {-4.97, 3.24, 0.0}, heading = 180.0},
			[5] = {pos = {0.0, 3.24, 0.0}, heading = 180.0},
			[6] = {pos = {4.97, 3.24, 0.0}, heading = 180.0},
		},
	},
	['garage_large'] = {
		entrance = {0.0, -16.31, 0.0-0.975},
		heading = 0.55,
		veh = {
			[1] = {pos = {4.77, -10.0, 0.0}, heading = 91.0},
			[2] = {pos = {4.77, -5.5, 0.0}, heading = 91.0},
			[3] = {pos = {4.77, -1.0, 0.0}, heading = 91.0},
			[4] = {pos = {4.77, 3.5, 0.0}, heading = 91.0},
			[5] = {pos = {4.77, 8.0, 0.0}, heading = 91.0},
			[6] = {pos = {-4.77, -10.0, 0.0}, heading = 272.26},
			[7] = {pos = {-4.77, -5.5, 0.0}, heading = 272.26},
			[8] = {pos = {-4.77, -1.0, 0.0}, heading = 272.26},
			[9] = {pos = {-4.77, 3.5, 0.0}, heading = 272.26},
			[10] = {pos = {-4.77, 8.0, 0.0}, heading = 272.26},
		},
	},
}
