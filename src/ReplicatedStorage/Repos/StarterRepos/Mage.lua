local c = require(game:GetService("ReplicatedStorage").Repos.CardRepo)

local repo = {
	unitName = script.Name,
	turnEnergy = 5,
	turnMovement = 4,
	health = 70,
	deck = {
		{
			cardName = c.Barrier.key,
			amount = 2
		},
		{
			cardName = c.TestDamage.key,
			amount = 1
		}, 
		{
			cardName = c.Fireball.key,
			amount = 2
		}, 
		{
			cardName = c.Dominate.key,
			amount = 2
		}, 
		{
			cardName = c.LightningStrike.key,
			amount = 2
		}, 
		{
			cardName = c.Strengthen.key,
			amount = 2
		}, 
		{
			cardName = c.Recovery.key,
			amount = 2
		}, 
	},
}


return repo
