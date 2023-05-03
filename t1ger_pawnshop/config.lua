-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

Config.ESXSHAREDOBJECT 		= 'esx:getSharedObject'		-- put your sharedobject in here.
Config.ItemWeightSystem		= false						-- Set this to true if you are using weight instead of limit.
Config.BuyWithCash			= true 						-- Buy items in pawnshop with cash, false to buy with bank balance.
Config.ReceiveCash			= true 						-- Sell items in pawnshop and receive cash, false to receive into bank balance.

Config.Pawnshops = {
	[1] = {
		pos = {412.42, 314.41, 103.02},
		blip = {enable = true, name = 'Pawn Shop', sprite = 59, display = 4, scale = 0.65, color = 5},
		marker = {enable = true, drawDist = 5.0, type = 27, color = {r = 255, g = 255, b = 0, a = 100}, scale = {x = 1.0, y = 1.0, z = 1.0}},
		drawText = '~g~[E]~s~ Pawn Shop',
		keyBind = 38
	},
	[2] = {
		pos = {182.76, -1319.38, 29.31},
		blip = {enable = true, name = 'Pawn Shop', sprite = 59, display = 4, scale = 0.65, color = 5},
		marker = {enable = true, drawDist = 5.0, type = 27, color = {r = 255, g = 255, b = 0, a = 100}, scale = {x = 1.0, y = 1.0, z = 1.0}},
		drawText = '~g~[E]~s~ Pawn Shop',
		keyBind = 38
	},
	[3] = {
		pos = {-1459.34, -413.79, 35.73},
		blip = {enable = true, name = 'Pawn Shop', sprite = 59, display = 4, scale = 0.65, color = 5},
		marker = {enable = true, drawDist = 5.0, type = 27, color = {r = 255, g = 255, b = 0, a = 100}, scale = {x = 1.0, y = 1.0, z = 1.0}},
		drawText = '~g~[E]~s~ Pawn Shop',
		keyBind = 38
	}
}

Config.Items = {
	[1] = { name = 'goldwatch', label = 'Gold Watch', buy = {enable = true, price = 1000}, sell = {enable = true, price = 500} },
	[2] = { name = 'goldbar', label = 'Gold Bar', buy = {enable = true, price = 1000}, sell = {enable = true, price = 500} },
}
