local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local BlockEffect = setmetatable({}, { __index = Effect })
BlockEffect.__index = BlockEffect

--[[
args needs to be structured as :
{
	value = value
}
]]

function BlockEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, BlockEffect)
	return self
end

function BlockEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	gameInstance:applyBlock(context:getCaster(), effectTargets, self.effectData.value)
end

return BlockEffect
