-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {
    ESX_OBJECT          = 'esx:getSharedObject',    -- set your shared object event in here
    ProgressBars        = true,                     -- set to false if you do not use progressBars or using your own
    T1GER_Insurance     = true,                     -- set to false if you dont own/use insurance.

    Police = {
        Jobs            = {'police', 'lspd'},       -- police job names in database
        Timer           = 5,                        -- time in minutes to fetch police count (5 min is a decent time, not suggested below) 
        EnableAlerts    = true,                     -- enable police alerts on car stealing
        AlertBlip = {                               -- police alert blip settings
            Show        = true,                     -- show blip
            Time        = 20,                       -- blip time
            Radius      = 40.0,                     -- blip radius
            Alpha       = 250,                      -- blip alpha
            Color       = 3                         -- blip color
        } 
    },

	Lock = {
		Key             = 182,                      -- key to lock/unlock cars (DEFAULT: [L]), set to 0 to disable.
		LockInt			= 2,                        -- select between 2 and 10 (10 nothing happens when u press enter vehicle key, 2 is the most common)
		UnlockInt  		= 0,						-- select between 1 or 0 for unlocked status. 
		Command 		= 'lock',					-- command to lock/unlock cars, set to '' to disable
		NPC_Lock		= true,						-- True NPC vehicles locked, set to false to unlock NPC vehicles.
		Chance			= 0,						-- % chance to enter moving vehicles
		ChanceParked	= 10,						-- % chance to enter parked vehicles (vehicles without drivers) 
	},

	Keys = {
		Command			= 'keys',					-- command to see list of keys, set to '' to disable.
		AnimDict		= 'anim@mp_player_intmenu@key_fob@',	-- lock animation dict
		AnimLib 		= 'fob_click',				-- lock animation lib
		Prop 			= 'p_car_keys_01',			-- lock animation prop
		PropPosition	= vector3(0.09,0.04,0.0),	-- pos for prop on player 
		PropRotation	= vector3(0.09,0.04,0.0),	-- pos for prop on player 
		PlaySound 		= true,						-- set to false to disable sounds when locking/unlocking
	},

	CarMenu = {
		Key				= 170,          		    -- key to open car menu (DEFAULT: [F3]), set to 0 to disable.
		Command 		= 'carmenu',				-- command to open car menu, set to '' to disable
	},

	Engine = {
		Key				= 311,          		    -- key to toggle engine on/off (DEFAULT: [K]), set to 0 to disable.
		Command 		= 'engine',					-- command to toggle engine on/off, set to '' to disable
	},

    Steal = {
        AimDist         = 20.0,                     -- dist from player to npc vehicle, to steal car
        VehSpeed        = 10.0,                     -- maximum vehicle speed of NPC car to steal (GetEntitySpeed())
        HandsUpTime     = 5000,                     -- time in ms for NPC to hold their hands up.
        Chance          = 80,                       -- % chance of NPC giving keys upon successfull threatening.
		Locked			= false,					-- Set to true if vehicle should be locked if NPC runs away, forcing player to lockpick to enter.
        ShutEngineOff   = true,                     -- shut engine off when NPC leaves car, else engine is running. (keep in player has to manu turn on engine, in case theft is successfull)
        AllowSearch     = true,                     -- allow player to /search vehicle for goods if got keys? 
        SetHotwire     	= true,                     -- require player to hotwire vehicle in case NPC run away with keys
        AnimDict     	= 'mp_common',             	-- anim dict to give keys
        AnimLib     	= 'givetake1_a',            -- anim lib to give keys
		ReportPlayer	= true,						-- set to false to not alert police when stealing npc vehicles at gunpoint
    },

    Lockpick = {
        Item            = 'lockpick',					-- paste your lockpick item name in here! (must match in database)
        Command         = 'lockpick',                   -- command to lockpick vehicle, set to '' to disable.
        Text            = Lang['progbar_lockpicking'],	-- string to use for e.g. progressBars?
        Duration        = 5000,							-- time in MS to lockpick vehicle
        Remove          = true, 						-- set to false to not remove the item on use.
        Chance          = 90,    						-- % chance to lockpick vehicles without alarms
        SetHotwire      = true,                         -- require player to hotwire the lockpicked vehicle, before he can drive.
        AllowSearch     = true,                         -- allow player to /search vehicle for goods?
        Anim = {
            Dict        = 'veh@break_in@0h@p_m_one@',	-- anim dict for lockpicking
            Lib         = 'low_force_entry_ds'			-- anim lib for lockpicking
        },
        Alarm = {
            Enable      = true,							-- enable car alarm sound & effects upon lockpicking
            Time        = 10000,						-- alarm sound duration in MS
            Chance      = 10,							-- % chance to lockpick owned vehicles equipped with an alarm
			Report		= true							-- report to owner/player of vehicle if vehicle has alarm?
        },
		Report 			= true 							-- report lockpicking to police?
    },

    Search = {
        Command         = 'search',                 	-- command to search stolen NPC cars, set to '' to disable.
        Text            = Lang['progbar_searching'],	-- progressbars text
        Duration        = 5000,                     	-- duration for search in MS
        AnimDict        = 'veh@handler@base',       	-- anim dict
        AnimLib         = 'hotwire',                	-- anim lib
        Money = {
            Chance      = 80,                       	-- chance of finding money
            MinAmount   = 100,                      	-- min amount of money
            MaxAmount   = 750,                      	-- max amount of money
            BlackMoney  = true,                     	-- receive dirty cash, else normal cash.
        },
        -- Insert item, label, chance and min/max amounts (script loops through all items listed):
        Items = {
            [1] = {item = 'weed_joint', name = 'Joint', chance = 67, amount = {min = 2, max = 4}},
            [2] = {item = 'rolling_paper', name = 'Rolling Paper', chance = 50, amount = {min = 1, max = 3}},
            [3] = {item = 'hq_scale', name = 'High Quality Scale', chance = 24, amount = {min = 1, max = 1}},
            [4] = {item = 'goldwatch', name = 'Gold Watch', chance = 90, amount = {min = 1, max = 2}},
        },
    },

    Hotwire = {
        Command         = 'hotwire',                	-- command to hotwire stolen NPC cars, , set to '' to disable.
        Text            = Lang['progbar_hotwiring'],	-- progressbars text
        Duration        = 5000,                     	-- duration for hotwire in MS
        AnimDict        = 'veh@handler@base',       	-- anim dict
        AnimLib         = 'hotwire',                	-- anim lib
        Chance          = 90,                       	-- % chance of successfull hotwiring
    },

}

Config.WhitelistCars = {
    [1] = {model = GetHashKey('police3'), job = {"police", "ambulance"}},
    [2] = {model = GetHashKey('ambulance'), job = {"ambulance"}},
    [3] = {model = GetHashKey('police4'), job = {"police"}},
}

Config.LockSmith = {
    pos = vector3(170.18,-1799.42,29.32),   -- posto open menu
    key = 38,                               -- key to open menu
    text = Lang['draw_locksmith'],          -- draw text 

    price = 300,                            -- price to register a key
    bank = true,                            -- pay in bank money, false is normal cash

    marker = { enable = true, drawDist = 10.0, type = 20, scale = vector3(0.5,0.5,0.5), color = {r = 240, g = 52, b = 52, a = 100} },
    blip = { enable = true, sprite = 134, color = 1, label = Lang['blip_locksmith'], scale = 1.0, display = 4 },
}

Config.AlarmShop = {
    pos = vector3(-194.48,-834.61,30.74),   -- pos to open menu
    key = 38,                               -- key to open menu
    text = Lang['draw_alarmshop'],          -- draw text 

    needKey = true,                         -- set to false to allow players to buy alarms without having a registered key
    bank = true,                            -- pay in bank money, false is normal cash
    price = 10,                             -- prices is based on % of vehicle price, where 10 means 10% of vehicle price

	alertBlip = {                           -- player alert blip settings
		Show        = true,             	-- show blip
		Time        = 20,               	-- blip time
		Radius      = 40.0,             	-- blip radius
		Alpha       = 250,              	-- blip alpha
		Color       = 6                		-- blip color
	}, 

    marker = { enable = true, drawDist = 10.0, type = 20, scale = vector3(0.5,0.5,0.5), color = {r = 0, g = 200, b = 70, a = 100} },
    blip = { enable = true, sprite = 459, color = 3, label = Lang['blip_alarmshop'], scale = 0.7, display = 4 }
}

Config.VehicleColors = {
	[1] = "Metallic Graphite Black",
	[2] = "Metallic Black Steal",
	[3] = "Metallic Dark Silver",
	[4] = "Metallic Silver",
	[5] = "Metallic Blue Silver",
	[6] = "Metallic Steel Gray",
	[7] = "Metallic Shadow Silver",
	[8] = "Metallic Stone Silver",
	[9] = "Metallic Midnight Silver",
	[10] = "Metallic Gun Metal",
	[11] = "Metallic Anthracite Grey",
	[12] = "Matte Black",
	[13] = "Matte Gray",
	[14] = "Matte Light Grey",
	[15] = "Util Black",
	[16] = "Util Black Poly",
	[17] = "Util Dark silver",
	[18] = "Util Silver",
	[19] = "Util Gun Metal",
	[20] = "Util Shadow Silver",
	[21] = "Worn Black",
	[22] = "Worn Graphite",
	[23] = "Worn Silver Grey",
	[24] = "Worn Silver",
	[25] = "Worn Blue Silver",
	[26] = "Worn Shadow Silver",
	[27] = "Metallic Red",
	[28] = "Metallic Torino Red",
	[29] = "Metallic Formula Red",
	[30] = "Metallic Blaze Red",
	[31] = "Metallic Graceful Red",
	[32] = "Metallic Garnet Red",
	[33] = "Metallic Desert Red",
	[34] = "Metallic Cabernet Red",
	[35] = "Metallic Candy Red",
	[36] = "Metallic Sunrise Orange",
	[37] = "Metallic Classic Gold",
	[38] = "Metallic Orange",
	[39] = "Matte Red",
	[40] = "Matte Dark Red",
	[41] = "Matte Orange",
	[42] = "Matte Yellow",
	[43] = "Util Red",
	[44] = "Util Bright Red",
	[45] = "Util Garnet Red",
	[46] = "Worn Red",
	[47] = "Worn Golden Red",
	[48] = "Worn Dark Red",
	[49] = "Metallic Dark Green",
	[50] = "Metallic Racing Green",
	[51] = "Metallic Sea Green",
	[52] = "Metallic Olive Green",
	[53] = "Metallic Green",
	[54] = "Metallic Gasoline Blue Green",
	[55] = "Matte Lime Green",
	[56] = "Util Dark Green",
	[57] = "Util Green",
	[58] = "Worn Dark Green",
	[59] = "Worn Green",
	[60] = "Worn Sea Wash",
	[61] = "Metallic Midnight Blue",
	[62] = "Metallic Dark Blue",
	[63] = "Metallic Saxony Blue",
	[64] = "Metallic Blue",
	[65] = "Metallic Mariner Blue",
	[66] = "Metallic Harbor Blue",
	[67] = "Metallic Diamond Blue",
	[68] = "Metallic Surf Blue",
	[69] = "Metallic Nautical Blue",
	[70] = "Metallic Bright Blue",
	[71] = "Metallic Purple Blue",
	[72] = "Metallic Spinnaker Blue",
	[73] = "Metallic Ultra Blue",
	[74] = "Metallic Bright Blue",
	[75] = "Util Dark Blue",
	[76] = "Util Midnight Blue",
	[77] = "Util Blue",
	[78] = "Util Sea Foam Blue",
	[79] = "Uil Lightning blue",
	[80] = "Util Maui Blue Poly",
	[81] = "Util Bright Blue",
	[82] = "Matte Dark Blue",
	[83] = "Matte Blue",
	[84] = "Matte Midnight Blue",
	[85] = "Worn Dark blue",
	[86] = "Worn Blue",
	[87] = "Worn Light blue",
	[88] = "Metallic Taxi Yellow",
	[89] = "Metallic Race Yellow",
	[90] = "Metallic Bronze",
	[91] = "Metallic Yellow Bird",
	[92] = "Metallic Lime",
	[93] = "Metallic Champagne",
	[94] = "Metallic Pueblo Beige",
	[95] = "Metallic Dark Ivory",
	[96] = "Metallic Choco Brown",
	[97] = "Metallic Golden Brown",
	[98] = "Metallic Light Brown",
	[99] = "Metallic Straw Beige",
	[100] = "Metallic Moss Brown",
	[101] = "Metallic Biston Brown",
	[102] = "Metallic Beechwood",
	[103] = "Metallic Dark Beechwood",
	[104] = "Metallic Choco Orange",
	[105] = "Metallic Beach Sand",
	[106] = "Metallic Sun Bleeched Sand",
	[107] = "Metallic Cream",
	[108] = "Util Brown",
	[109] = "Util Medium Brown",
	[110] = "Util Light Brown",
	[111] = "Metallic White",
	[112] = "Metallic Frost White",
	[113] = "Worn Honey Beige",
	[114] = "Worn Brown",
	[115] = "Worn Dark Brown",
	[116] = "Worn straw beige",
	[117] = "Brushed Steel",
	[118] = "Brushed Black steel",
	[119] = "Brushed Aluminium",
	[120] = "Chrome",
	[121] = "Worn Off White",
	[122] = "Util Off White",
	[123] = "Worn Orange",
	[124] = "Worn Light Orange",
	[125] = "Metallic Securicor Green",
	[126] = "Worn Taxi Yellow",
	[127] = "police car blue",
	[128] = "Matte Green",
	[129] = "Matte Brown",
	[130] = "Worn Orange",
	[131] = "Matte White",
	[132] = "Worn White",
	[133] = "Worn Olive Army Green",
	[134] = "Pure White",
	[135] = "Hot Pink",
	[136] = "Salmon pink",
	[137] = "Metallic Vermillion Pink",
	[138] = "Orange",
	[139] = "Green",
	[140] = "Blue",
	[141] = "Mettalic Black Blue",
	[142] = "Metallic Black Purple",
	[143] = "Metallic Black Red",
	[144] = "hunter green",
	[145] = "Metallic Purple",
	[146] = "Metaillic V Dark Blue",
	[147] = "MODSHOP BLACK1",
	[148] = "Matte Purple",
	[149] = "Matte Dark Purple",
	[150] = "Metallic Lava Red",
	[151] = "Matte Forest Green",
	[152] = "Matte Olive Drab",
	[153] = "Matte Desert Brown",
	[154] = "Matte Desert Tan",
	[155] = "Matte Foilage Green",
	[156] = "DEFAULT ALLOY COLOR",
	[157] = "Epsilon Blue",
	[158] = "Unknown",
}