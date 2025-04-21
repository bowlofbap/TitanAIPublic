local StatusTypes = {}

StatusTypes = {
	STRENGTH_BUFF = {
		name = "Strength Up", 
		image="rbxassetid://78494366360008",
		defaultTickable = false,
		stackable = true,
		class = "Status",
		isBuff = true,
		canBeNegative = true
	},
	STRENGHT_DOWN = {
		name = "Strength Down", 
		image="rbxassetid://78494366360008",
		defaultTickable = false,
		stackable = true,
		class = "StatusDownStatus",
		targetStatusKey = "STRENGTH_BUFF",
		isBuff = false,
		canBeNegative = true
	},
	CRITICAL_BUFF = {
		name = "Critical Up", 
		image="rbxassetid://127917076852203",
		defaultTickable = true,
		stackable = false,
		class = "Status",
		isBuff = true,
	},
	BLOCK_BUFF = {
		name = "Block Up", 
		image="rbxassetid://104176188352001",
		defaultTickable = false,
		stackable = true,
		class = "Status",
		isBuff = true,
	},
	DEFENSE_UP = {
		name = "Defense Up", 
		image="rbxassetid://104176188352001",
		defaultTickable = false,
		stackable = true,
		class = "Status",
		isBuff = true,
	},
	VULNERABLE_DEBUFF = {
		name = "", 
		image="rbxassetid://131659253579094",
		defaultTickable = true,
		stackable = false,
		class = "Status",
		isBuff = true,
	},
	HEAL_DEBUFF = {
		name = "", 
		image="",
		defaultTickable = true,
		stackable = false,
		class = "Status",
		isBuff = false,
	},
	DAMAGE_OVER_TIME = {
		name = "Damage Over Time", 
		image="rbxassetid://132976116226311",
		defaultTickable = false, --doesn't tick, but the execute effect ticks it down itself
		stackable = true,
		class = "DamageOverTimeStatus",
		isBuff = false,
	},
	WEAKEN_DEBUFF = {
		name = "Weaken", 
		image="rbxassetid://132976116226311",
		defaultTickable = true, 
		stackable = true,
		class = "Status",
		isBuff = false,
	},
	REFLECT_BUFF = {
		name = "Reflect", 
		image="",
		defaultTickable = false, 
		stackable = true,
		class = "ReflectStatus",
		isBuff = true,
	},
	REFLECT_DOWN = {
		name = "Reflect Down", 
		image="rbxassetid://78494366360008",
		defaultTickable = false,
		stackable = true,
		class = "StatusDownDelayStatus",
		targetStatusKey = "REFLECT_BUFF",
		isBuff = false,
		canBeNegative = true
	},
	ROOT_DEBUFF = {
		name = "Root", 
		image="",
		defaultTickable = true, 
		stackable = false,
		class = "Status",
		isBuff = false,
	},
	
	--[[CUSTOM EFFECTS]]--
	OVERLOAD_BUFF = {
		name = "Overload", 
		image="",
		defaultTickable = true, 
		stackable = false,
		class = "Status",
		isBuff = false,
	}
}
return StatusTypes
