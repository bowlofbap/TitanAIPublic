local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local StatusEffect = setmetatable({}, { __index = Effect })
StatusEffect.__index = StatusEffect

function StatusEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, StatusEffect)
	return self
end

function StatusEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	gameInstance:applyStatus(context:getCaster(), effectTargets, self.effectData.statusType, self.effectData.value)
end

return StatusEffect
