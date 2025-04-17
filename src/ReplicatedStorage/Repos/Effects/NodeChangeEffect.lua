local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local NodeChangeEffect = setmetatable({}, { __index = Effect })
NodeChangeEffect.__index = NodeChangeEffect

function NodeChangeEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, NodeChangeEffect)
	return self
end

function NodeChangeEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	for _, node in ipairs(effectTargets) do
		gameInstance:changeNodeType(node, self.effectData.value)
	end
end

return NodeChangeEffect
