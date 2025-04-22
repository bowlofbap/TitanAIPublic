local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local Keywords = {
	--STATUSES--
	Block = {
		name = "Block",
		description = "Prevent damage until following turn"
	},
	Strength = {
		name = "Strength",
		description = "Increases damage dealt"
	},
	Defense = {
		name = "Defense",
		description = "Decreases damage taken",
	},
	Critical = {
		name = "Critical",
		description = "Deal "..(Constants.INSTANCE_SETTINGS.BATTLE_SETTINGS.CRITICAL_VALUE*100).."% more damage",
	},
	Vulnerable = {
		name = "Vulnerable",
		description = "Takes "..(Constants.INSTANCE_SETTINGS.BATTLE_SETTINGS.VULNERABLE_VALUE*100).."% more damage",
	},
	Decay = {
		name = "Decay",
		description = "Takes damage equal to amount at the end of the turn, reducing by 1 after",
	},
	Deplete = {
		name = "Deplete",
		description = "Removes card from combat once played"
	},
	Tile = {
		name = "Tile",
		description = "Gain effects while standing on top"
	},
	Weaken = {
		name = "Weaken",
		description = "Reduce damage dealt by "..(Constants.INSTANCE_SETTINGS.BATTLE_SETTINGS.WEAKEN_VALUE*100).."%"
	},
	Reflect = {
		name = "Reflect",
		description = "Reflects damage when hit equal to amount"
	},
	Root = {
		name = "Root",
		description = "Prevents from moving until end of turn"
	},
	Mark = {
		name = "Mark",
		description = "When unit dies, grant energy equal to amount and draw half the amount of cards."
	},
	Charge = {
		name = "Charge",
		description = "Grants energy equal to value at start of turn"
	},
	

	--TILES
	Electrocharged = {
		name = "Electrocharged",
		description = "Applies one Charge while standing on Tile"
	}
}

return Keywords
