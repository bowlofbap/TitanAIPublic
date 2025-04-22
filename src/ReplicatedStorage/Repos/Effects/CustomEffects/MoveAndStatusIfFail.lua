local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local DirectionHelper = require(ReplicatedStorage.Helpers.GameInstance.DirectionHelper)

local CustomEffect = setmetatable({}, { __index = Effect })
CustomEffect.__index = CustomEffect

function CustomEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, CustomEffect)
	return self
end

function CustomEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
    for _, target in ipairs(effectTargets) do
        local direction = DirectionHelper.processDirection(self.effectData.direction, target, context:getCaster())
        local success = gameInstance:moveTarget(context:getCaster(), target, direction, self.effectData.value)
        if not success then
            gameInstance:applyStatus(context:getCaster(), {target}, self.effectData.statusType, self.effectData.value)
        end
    end
end

return CustomEffect
