-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

fx_version 'cerulean'
games {'gta5'}
lua54 "yes"

author 'T1GER#9080'
discord 'https://discord.gg/FdHkq5q'
description 'T1GER Insurance'
version '2.0.0'

ui_page 'html/index.html'

client_scripts {
	'language.lua',
	'config.lua',
	'client/utils.lua',
	'client/main.lua'
}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'language.lua',
	'config.lua',
	'server/main.lua'
}

files {
	'html/index.html',
	'html/assets/css/*.css',
	'html/assets/js/*.js',
	'html/assets/images/*.png'
}

escrow_ignore {
    "config.lua",
    "language.lua",
    "client/*.lua",
    "server/*.lua",
}