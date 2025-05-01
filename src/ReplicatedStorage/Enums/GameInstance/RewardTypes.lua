local EchoRarityTypes = require(game:GetService("ReplicatedStorage").Enums.EchoRarityTypes)
local CardRarityTypes = require(game:GetService("ReplicatedStorage").Enums.RarityTypes)

local types = {
	MONEY_SMALL = {
		class = "Money",
		label = "Currency",
		min = 10,
		max = 20,
		image = ""
	},
	MONEY_MEDIUM = {
		class = "Money",
		label = "Currency",
		min = 25,
		max = 35,
		image = ""
	},
	MONEY_LARGE = {
		class = "Money",
		label = "Currency",
		min = 100,
		max = 110,
		image = ""
	},
	CARDS_BASIC = {
		class = "Cards",
		label = "Add a card to your deck",
		rarity = CardRarityTypes.COMMON,
		image = "",
		upgradeChance = 10
	},
	CARDS_RARE = {
		class = "Cards",
		label = "Add an uncommon card to your deck",
		rarity = CardRarityTypes.RARE,
		image = "",
		upgradeChance = 25
	},
	CARDS_LEGENDARY = {
		class = "Cards",
		label = "Add a Rare card to your deck",
		rarity = CardRarityTypes.LEGENDARY,
		image = "",
		upgradeChance = 0
	},
	ECHO_COMMON = {
		class = "Echo",
		label = "Obtain a new common Echo",
		rarity = EchoRarityTypes.COMMON,
		image = "",
	},
	ECHO_RARE = {
		class = "Echo",
		label = "Obtain a new rare Echo",
		rarity = EchoRarityTypes.RARE,
		image = "",
	},
	ECHO_LEGENDARY = {
		class = "Echo",
		label = "Obtain a new legendary Echo",
		rarity = EchoRarityTypes.LEGENDARY,
		image = "",
	},
	--[[
	POTION = {
		label = "",
		image = ""
	},]]
}

return types

