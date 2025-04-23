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
    local selectedCardIds = context:getExtraData().selectedCardIds
    for _, id in ipairs(selectedCardIds) do
        local card = gameInstance.player.hand:getCardById(id)
        gameInstance:discardCard(card)
    end
end

return CustomEffect
