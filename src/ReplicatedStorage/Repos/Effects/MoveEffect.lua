local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local MoveEffect = setmetatable({}, { __index = Effect })
MoveEffect.__index = MoveEffect

--[[
args needs to be structured as :
{
	value = value
	direction = Directions.DIRECTION
}
]]

function MoveEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, MoveEffect)
	return self
end

function MoveEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	local caster = context:getCardData()
	local direction = self.effectData.direction
	for _, target in ipairs(effectTargets)  do
		gameInstance:moveTarget(caster, target, direction, self.effectData.value)
	end 
end

return MoveEffect
