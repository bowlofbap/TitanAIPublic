local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local DamageEffect = setmetatable({}, { __index = Effect })
DamageEffect.__index = DamageEffect

--[[
args needs to be structured as :
{
	value = value
}
]]

function DamageEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, DamageEffect)
	return self
end

function DamageEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	gameInstance:dealDamage(context:getCaster(), effectTargets, self.effectData.value, self.effectData.damageType)
end

return DamageEffect
 