local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local TargetingRules = require(ReplicatedStorage.Helpers.GameInstance.TargetingRules)

local TargetTypes = require(game:GetService("ReplicatedStorage").Enums.TargetTypes)
local TargetChoices = require(game:GetService("ReplicatedStorage").Enums.TargetChoices)

local CustomEffect = setmetatable({}, { __index = Effect })
CustomEffect.__index = CustomEffect

function CustomEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, CustomEffect)
	return self
end

function CustomEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	gameInstance:applyStatus(context:getCaster(), effectTargets, self.effectData.debuffData)
	
	local adjustments = {
		targetType = TargetTypes.SELF, 
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY
	}
	
	local altData = self:getAltData(context:getCardData(), adjustments)
	local targets, targetIds, nodes, nodeIds = TargetHelper.getTargets(context:getCaster(), gameInstance, altData, nil, TargetTypes.SELF)
	gameInstance:applyStatus(context:getCaster(), targets, self.effectData.buffData)
end

return CustomEffect
