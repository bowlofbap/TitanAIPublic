--The different types of effects that can be made into classes, definition is case-sensitive as it uses the values to pull from the Effects folder

local EffectTypes = {
	MOVE = "MoveEffect",
	DAMAGE = "DamageEffect",
	HEAL = "HealEffect",
	DRAW = "DrawEffect",
	STATUS = "StatusEffect",
	BLOCK = "BlockEffect",
	DEPLETE = "DepleteEffect",
	NODE_CHANGE = "NodeChangeEffect",
	DEPLOY = "DeployEffect",
	CUSTOM = "CustomEffect",
	GRANT_ENERGY = "GrantEnergyEffect",
	GRANT_MOVEMENT = "GrantMovementEffect",
}

return EffectTypes
