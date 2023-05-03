-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

fx_version 'cerulean'
games {'gta5'}
lua54 "yes"

author 'T1GER#9080'
discord 'https://discord.gg/FdHkq5q'
description 'T1GER Garage'
version '1.0.6'

client_scripts {
	'language.lua',
	'config.lua',
	'client/main.lua',
	'client/utils.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'language.lua',
	'config.lua',
	'server/main.lua'
}

exports {
	'SetVehicleImpounded',
}

escrow_ignore {
    "config.lua",
    "language.lua",
    "client/*.lua",
    "server/*.lua",
}