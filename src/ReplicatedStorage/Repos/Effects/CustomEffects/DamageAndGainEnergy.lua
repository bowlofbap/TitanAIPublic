local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local CustomEffect = setmetatable({}, { __index = Effect })
CustomEffect.__index = CustomEffect

function CustomEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, CustomEffect)
	return self
end

function CustomEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	gameInstance:dealDamage(context:getCaster(), effectTargets, self.effectData.value, self.effectData.damageType)
    if #effectTargets >= self.effectData.minTargets then
        gameInstance:grantEnergy(context:getCaster(), self.effectData.energyGained)
    end
end

return CustomEffect
