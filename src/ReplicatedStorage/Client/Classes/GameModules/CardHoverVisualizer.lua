local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TargetingRules = require(ReplicatedStorage.Helpers.GameInstance.TargetingRules) 
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local CardHoverVisualizer = {
	_highlightedRangeNodes = {},
	_highlightedAreaEffectNodes = {},
	_highlightedUnitNodes = {}
}

function CardHoverVisualizer.visualizeCardEffect(context: ContextType.context)
	CardHoverVisualizer.reset()
	local primaryTargets = TargetingRules.getValidTargets(context)
	local inRangeNodes = TargetingRules.getInRangeNodes(primaryTargets, context)
	local effectAreaNodes = TargetingRules.getEffectAreaNodes(primaryTargets, context)
	local effectTargets = TargetingRules.getEffectTargets(primaryTargets, context)
	
	local highlightedUnitNodes = {}

	for _, node in ipairs(inRangeNodes) do
		node:toggleHighlight(true)
	end
	
	for _, node in ipairs(effectAreaNodes) do
		node:toggleRadiusIndicator(true)
	end

	for _, unit in ipairs(effectTargets) do
		local node = context:getNodeAt(unit.coordinates)
		node:toggleUnitTarget(true)
		table.insert(highlightedUnitNodes, node)
	end
	CardHoverVisualizer._highlightedRangeNodes = inRangeNodes
	CardHoverVisualizer._highlightedAreaEffectNodes = effectAreaNodes
	CardHoverVisualizer._highlightedUnitNodes = highlightedUnitNodes
end

function CardHoverVisualizer.reset()
	for _, node in ipairs(CardHoverVisualizer._highlightedRangeNodes) do
		node:toggleHighlight(false)
	end
	
	for _, node in ipairs(CardHoverVisualizer._highlightedAreaEffectNodes) do
		node:toggleRadiusIndicator(false)
	end
	
	for _, node in ipairs(CardHoverVisualizer._highlightedUnitNodes) do
		node:toggleUnitTarget(false)
	end
end

return CardHoverVisualizer