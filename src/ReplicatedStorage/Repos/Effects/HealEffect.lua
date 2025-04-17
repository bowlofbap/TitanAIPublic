local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local HealEffect = setmetatable({}, { __index = Effect })
HealEffect.__index = HealEffect

--[[
args needs to be structured as :
{
	value = value
}
]]

function HealEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, HealEffect)
	return self
end

function HealEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	gameInstance:applyHeal(context:getCaster(), effectTargets, self.effectData.value)
end

return HealEffect
