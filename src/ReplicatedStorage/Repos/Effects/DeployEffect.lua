local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local DeployEffect = setmetatable({}, { __index = Effect })
DeployEffect.__index = DeployEffect

--[[
args needs to be structured as :
{
	value = value
}
]]

function DeployEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, DeployEffect)
	return self
end

function DeployEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context, card)
	gameInstance:deployUnit(context:getCaster(), effectTargets, self.effectData, card)
end

return DeployEffect
