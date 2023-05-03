-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

fx_version 'cerulean'
games {'gta5'}
lua54 "yes"

author 'T1GER#9080'
discord 'https://discord.gg/FdHkq5q'
description 'T1GER Tow Trucker'
version '1.0.1'

client_scripts {
	'language.lua',
	'config.lua',
	'client/utils.lua',
	'client/main.lua',
	'escrow/cl.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'language.lua',
	'config.lua',
	'server/main.lua',
	'escrow/sv.lua'
}

exports {
	'IsVehicleInTowImpound',
}

escrow_ignore {
    "config.lua",
    "language.lua",
    "client/*.lua",
    "server/*.lua",
    "escrow/*.lua",
}