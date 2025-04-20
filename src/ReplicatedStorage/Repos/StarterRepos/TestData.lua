local c = require(game:GetService("ReplicatedStorage").Repos.CardRepo)


local testDeck = {
	{
		cardName = c.TileChange.key,
		amount = 1,
		upgraded = false
	},
}

local repo = {
	unitName = "Ze",
	turnEnergy = 5,
	turnMovement = 4,
	health = 50,
	deck = testDeck
}


return repo
