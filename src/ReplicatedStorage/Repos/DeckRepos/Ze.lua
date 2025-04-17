local c = require(game:GetService("ReplicatedStorage").Repos.CardRepo)
local RarityTypes = require(game:GetService("ReplicatedStorage").Enums.RarityTypes)

local repo = {
	cards = {
		c.Fireball.key, 
		c.TestDamage.key,
		c.LightningStrike.key,
		c.Toxin.key,
		c.Dominate.key,
		c.Strengthen.key,
		c.Recovery.key,
		c.TileChange.key,
		c.TileChange2.key,
		c.ZC004.key,
	}
}

function repo.getEligibleCardNames()
	return repo.cards
end

return repo
