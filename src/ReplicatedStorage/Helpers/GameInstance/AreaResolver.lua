local ContextType = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.Classes.CardExecutionContextType)
local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local AreaResolver = {}

function AreaResolver.getUnitsInRadius(primaryCoordinates, radius, context)
	local nodes = AreaResolver.getNodesInRadius(primaryCoordinates, radius, context)
	return AreaResolver.getUnitsInNodes(nodes, context)
end

function AreaResolver.getUnitsInNodes(nodes, context: ContextType.context)
	local units = {}
	local cardData = context:getCardData()
	local effectTargets = context:getTargetGroupFromCardData(cardData.effectChoice)
	for _, node in ipairs(nodes) do
		local unit = node:getOccupyingUnit()
		if unit and table.find(effectTargets, unit) then
			table.insert(units, unit)
		end
	end
	return units
end

function AreaResolver.getNodesInRadius(primaryCoordinates, radius, context: ContextType.context)
	local affectedNodes = {}
	--this is an implementation for a circular aoe. we should also consider just a square radius.
	for x = -radius, radius do
		for y = -radius, radius do
			local dx, dy = math.abs(x), math.abs(y)
			if dx + dy <= radius then
				local coord = Vector2.new(primaryCoordinates.X + x, primaryCoordinates.Y + y)
				local tile = context:getNodeAt(coord)
				if tile then
					table.insert(affectedNodes, tile)
				end
			end
		end
	end
	return affectedNodes
end

return AreaResolver