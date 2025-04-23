local c = require(game:GetService("ReplicatedStorage").Repos.CardRepo)

local realDeck = {
	{
		cardName = c.R001.key,
		amount = 4,
		upgraded = false
	},
	{
		cardName = c.R002.key,
		amount = 3,
		upgraded = false
	}, 
	{
		cardName = c.ZC001.key,
		amount = 1,
		upgraded = false
	}, 
}

local testDeck = {
	{
		cardName = c.R001.key,
		amount = 1,
		upgraded = false
	},
	{
		cardName = c.R002.key,
		amount = 1,
		upgraded = false
	},
	{
		cardName = c.ZC001.key,
		amount = 1,
		upgraded = false
	},
	{
		cardName = c.ZC002.key,
		amount = 1,
		upgraded = true
	}, 
	{
		cardName = c.ZC007.key,
		amount = 1,
		upgraded = false
	}, 
	{
		cardName = c.ZC013.key,
		amount = 1,
		upgraded = false
	}, 
}

local testDeck1 = {
	{
		cardName = c.TileChange.key,
		amount = 1,
		upgraded = false
	},
	{
		cardName = c.TileChange2.key,
		amount = 1,
		upgraded = false
	},
	{
		cardName = c.Toxin.key,
		amount = 1,
		upgraded = false
	},
	{
		cardName = c.TestDamage.key,
		amount = 1,
		upgraded = true
	}, 
	{
		cardName = c.ZC004.key,
		amount = 1,
		upgraded = true
	}, 
}

local repo = {
	unitName = script.Name,
	turnEnergy = 5,
	turnMovement = 4,
	health = 70,
	deck = testDeck
}


return repo
