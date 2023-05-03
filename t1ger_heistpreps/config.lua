-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {
    ESX_OBJECT = 'esx:getSharedObject', -- set your shared object event in here
    ProgressBars = true, -- set to false if you do not use progressBars or using your own
	T1GER_Keys = true, -- set to false if you do not own t1ger-keys
	RequestJobCommand = 'prep', -- command to request heist prep jobs/missions.
	DataCrackMinigame = true, -- set to false if not using this, see readme for link
	LockpickingMinigame = true, -- set to false if not using this or using other. see readme for link

	Blips = {
		['hacking'] = {enable = true, sprite = 363, display = 4, scale = 0.65, color = 5, name = "Hacking Heist Preparation"},
		['drills'] = {enable = true, sprite = 363, display = 4, scale = 0.65, color = 5, name = "Drills Heist Preparation"},
		['thermite'] = {enable = true, sprite = 1, display = 4, scale = 0.75, color = 1, name = "Thermal Heist Preparation"},
		['explosives'] = {enable = true, sprite = 363, display = 4, scale = 0.65, color = 5, name = "Explosives Heist Prepartion"},
		['keycard'] = {enable = true, sprite = 363, display = 4, scale = 0.65, color = 5, name = "Keycard Heist Prepartion"},
		['truck'] = {enable = true, sprite = 67, display = 4, scale = 0.65, color = 3, name = "Searchable Bank Truck"},
	},

	KeyControls = {
		['pickup_device'] = 38,
		['decrypt_device'] = 38,
		['collect_device'] = 38,
		['search_crate'] = 38,
		['search_c_trunk'] = 38,
		['collect_explosive_case'] = 38,
		['place_explosive_case'] = 38,
		['unlock_explosive_case'] = 38,
		['search_bank_ped'] = 38,
		['unlock_bank_truck'] = 38
	},
	
	PhoneBoxes = {'prop_phonebox_01a','prop_phonebox_01b','prop_phonebox_01c','prop_phonebox_02','prop_phonebox_03','prop_phonebox_04'},

	Types = {'hacking','drills','thermite','explosives','keycard'},

	AlertJobs = {'police', 'lspd'},
	AlertBlip = { Show = true, Time = 20, Radius = 50.0, Alpha = 250, Color = 3 },

	Jobs = {

		['drills'] = {
			[1] = {
				location = vector3(-161.31,-1084.48,42.13),
				inUse = false,
				model = 'gr_prop_gr_2s_drillcrate_01a',
				item = {name = 'drill', amount = 1},
				lootableCrates = 2, -- amount of the below crates where players can find loot.
				crates = { -- exact coords where the prop should spawn, make sure to find correct Z coords or prop will be floating.
					[1] = {
						pos = {-189.79,-1105.55,17.715},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-182.45,-1108.76,18.69,61.29}, weapon = 'WEAPON_CROWBAR', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					},
					[2] = {
						pos = {-156.57,-1058.41,17.715},
						npc = {
							[1] = {model = 's_m_y_construct_01', pos = {-159.16,-1066.61,18.69,355.17}, weapon = 'WEAPON_BAT', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					},
					[3] = {
						pos = {-157.67,-1100.55,12.144},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-150.76,-1103.3,13.12,55.35}, weapon = 'WEAPON_CROWBAR', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					},
					[4] = {
						pos = {-128.46,-1100.44,35.164},
						npc = {
							[1] = {model = 's_m_y_construct_01', pos = {-133.8,-1105.31,36.14,303.47}, weapon = 'WEAPON_BAT', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					},
					[5] = {
						pos = {-179.18,-1078.03,41.164},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-173.6,-1073.47,42.14,119.8}, weapon = 'WEAPON_CROWBAR', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					},
					[6] = {
						pos = {-169.55,-1055.17,35.164},
						npc = {
							[1] = {model = 's_m_y_construct_01', pos = {-164.12,-1050.44,36.14,120.79}, weapon = 'WEAPON_BAT', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					},
					[7] = {
						pos = {-184.83,-1107.67,29.164},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-184.79,-1099.27,30.14,176.76}, weapon = 'WEAPON_CROWBAR', scenario = 'WORLD_HUMAN_CONST_DRILL'},
						}
					}
				},
				cache = {}
			},
			[2] = {
				location = vector3(-459.98,-923.04,29.39),
				inUse = false,
				model = 'gr_prop_gr_2s_drillcrate_01a',
				item = {name = 'drill', amount = 1},
				lootableCrates = 2, -- amount of the below crates where players can find loot.
				crates = { -- exact coords where the prop should spawn, make sure to find correct Z coords or prop will be floating.
					[1] = {
						pos = {-442.75,-925.78,28.39},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-443.88,-919.31,29.39,196.87}, chance = 50, weapon = 'WEAPON_CROWBAR'},
						}
					},
					[2] = {
						pos = {-447.52,-944.11,28.39},
						npc = {
							[1] = {model = 's_m_y_construct_01', pos = {-453.91,-946.17,29.39,291.52}, chance = 50, weapon = 'WEAPON_BAT'},
						}
					},
					[3] = {
						pos = {-445.28,-963.95,24.9},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-441.73,-968.55,25.9,41.56}, chance = 50, weapon = 'WEAPON_CROWBAR'},
						}
					},
					[4] = {
						pos = {-457.38,-933.01,37.68},
						npc = {
							[1] = {model = 's_m_y_construct_01', pos = {-464.07,-937.37,38.68,295.88}, chance = 50, weapon = 'WEAPON_BAT'},
						}
					},
					[5] = {
						pos = {-453.83,-880.57,46.98},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-451.95,-887.35,47.98,15.7}, chance = 50, weapon = 'WEAPON_CROWBAR'},
						}
					},
					[6] = {
						pos = {-470.88,-951.69,46.98},
						npc = {
							[1] = {model = 's_m_y_construct_01', pos = {-467.57,-955.85,47.98,29.78}, chance = 50, weapon = 'WEAPON_BAT'},
						}
					},
					[7] = {
						pos = {-454.17,-934.71,22.66},
						npc = {
							[1] = {model = 's_m_y_construct_02', pos = {-449.14,-939.24,23.66,66.51}, chance = 50, weapon = 'WEAPON_CROWBAR'},
						}
					}
				},
				cache = {}
			},
		},

		['hacking'] = {
			[1] = {
				location = vector3(-1082.0,-260.37,37.81),
				inUse = false,
				model = 'h4_prop_h4_card_hack_01a',
				spawn = {
					{-1081.42,-245.74,37.67},
					{-1091.39,-258.339,37.214},
					{-1067.15,-244.399,43.919},
					{-1051.049,-242.789,43.93},
					{-1060.90,-247.63,43.93}
				},
				item = {
					[1] = {name = 'eHackingDevice', amount = 1},
					[2] = {name = 'dHackingDevice', amount = 1}
				},
				decrypt = {
					pos = vector4(-1053.8,-230.72,44.02,235.8),
					time = 2, -- time in minutes
					difficulty = 3, -- range from 2 to 5.
				},
				cache = {}
			},
			[2] = {
				location = vector3(1274.6,-1720.97,54.68),
				inUse = false,
				model = 'h4_prop_h4_card_hack_01a',
				spawn = { -- exact coords where the prop should spawn, make sure to find correct Z coords or prop will be floating.
					{1276.209,-1712.729,54.431},
					{1272.619,-1710.77,54.575},
					{1271.11,-1710.3,54.71},
					{1272.65,-1709.63,54.82},
					{1276.41,-1710.76,54.489}
				},
				item = {
					[1] = {name = 'eHackingDevice', amount = 1},
					[2] = {name = 'dHackingDevice', amount = 1}
				},
				decrypt = {
					pos = vector4(1272.11,-1711.66,54.77,15.2),
					time = 2, -- time in minutes
					difficulty = 3, -- range from 2 to 5.
				},
				cache = {}
			},
		},

		['thermite'] = {
			[1] = {
				location = vector4(-1373.75,244.48,59.53,142.23),
				inUse = false,
				vehicle = 'baller6',
				agents = {
					[1] = {model = 'mp_m_securoguard_01', seat = -1, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
					[2] = {model = 'mp_m_securoguard_01', seat = 0, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
					[3] = {model = 'mp_m_securoguard_01', seat = 1, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
					[4] = {model = 'mp_m_securoguard_01', seat = 2, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
				},
				item = {name = 'thermite', amount = 2},
				stopLocation = vector4(-1196.84,-1532.86,4.42,122.76),
				cache = {}
			},
			[2] = {
				location = vector4(1044.62,-2402.03,29.77,353.95),
				inUse = false,
				vehicle = 'baller6',
				agents = {
					[1] = {model = 'mp_m_securoguard_01', seat = -1, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
					[2] = {model = 'mp_m_securoguard_01', seat = 0, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
					[3] = {model = 'mp_m_securoguard_01', seat = 1, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
					[4] = {model = 'mp_m_securoguard_01', seat = 2, weapon = 'WEAPON_COMBATPISTOL', armour = 100, accuracy = 100, criticalHits = false},
				},
				item = {name = 'thermite', amount = 2},
				stopLocation = vector4(-651.73,-1767.7,24.49,305.57),
				cache = {}
			}
		},

		['explosives'] = {
			[1] = {
				location = vector3(1822.74,-2946.53,-40.31), -- job location
				inUse = false,
				model = 'prop_idol_case_02',
				offset = {bone = 28422, pos = {0.05,0.0,0.0}, rot = {0.0,35.0,-90.0}},
				spawn = {
					vector3(1829.12,-2917.22,-36.53),
					vector3(1790.99,-2957.0,-43.11),
					vector3(1843.48,-2974.2,-54.08),
					vector3(1863.01,-2938.66,-46.85),
					vector3(1860.7,-2946.21,-44.05),
					vector3(1824.61,-2947.16,-44.74),
				},
				shore = vector3(1766.71,-2700.7,1.96),
				item = {name = 'explosive', amount = 1},
				cache = {}
			},
			[2] = {
				location = vector3(-2837.19,-501.46,-35.55), -- job location
				inUse = false,
				model = 'prop_idol_case_02',
				offset = {bone = 28422, pos = {0.05,0.0,0.0}, rot = {0.0,35.0,-90.0}},
				spawn = {
					vector3(-2835.57,-472.43,-34.45),
					vector3(-2848.16,-480.59,-59.08),
					vector3(-2864.06,-510.44,-65.21),
					vector3(-2833.96,-544.74,-48.01),
					vector3(-2844.51,-457.57,-19.54),
					vector3(-2831.47,-500.38,-46.99),
				},
				shore = vector3(-2626.02,-179.66,6.21),
				item = {name = 'explosive', amount = 1},
				cache = {}
			}
			
		},

		['keycard'] = {

			[1] = {
				location = vector4(288.52,-1601.33,31.27,200.0), -- job location
				inUse = false,
				model = 'ig_bankman',
				npc = vector4(305.93,-1609.48,30.53,67.0),
				item = {
					[1] = {name = 'master_truckkeys', amount = 1},
					[2] = {name = 'mazebank_card', amount = 1}
				},
				keycards = 2, -- amount of key cards to be obtained in total, cannot exceed truck location count below
				vehicle = 'stockade',
				spawns = {
					[1] = { pos = vector4(-20.06,-705.84,32.34,161.01) },
					[2] = { pos = vector4(310.38,261.02,104.94,277.39) },
					[3] = { pos = vector4(868.88,-2335.27,30.35,355.39) },
					[4] = { pos = vector4(-1293.14,-808.37,17.58,130.15) },
				},
				cache = {}
			},
			[2] = {
				location = vector4(-535.42,-219.17,37.65,208.93), -- job location
				inUse = false,
				model = 'ig_bankman',
				npc = vector4(-510.33,-227.27,36.55,201.71),
				item = {
					[1] = {name = 'master_truckkeys', amount = 1},
					[2] = {name = 'mazebank_card', amount = 1}
				},
				keycards = 2, -- amount of key cards to be obtained in total, cannot exceed truck location count below
				vehicle = 'stockade',
				spawns = {
					[1] = { pos = vector4(-20.06,-705.84,32.34,161.01) },
					[2] = { pos = vector4(310.38,261.02,104.94,277.39) },
					[3] = { pos = vector4(868.88,-2335.27,30.35,355.39) },
					[4] = { pos = vector4(-1293.14,-808.37,17.58,130.15) },
				},
				cache = {}
			},

		},

	},

}
