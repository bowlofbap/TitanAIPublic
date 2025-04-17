local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TargetingUtils = require(ReplicatedStorage.Helpers.GameInstance.TargetingUtils)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local AreaResolver = require(ReplicatedStorage.Helpers.GameInstance.AreaResolver)

local module = {}

function module.getTargets(context: ContextType.context)
	local cardData = context:getCardData()
	local mainCoordinates = context:getMainCoordinates()
	if not mainCoordinates then return {} end
	local primaryTargetNode = context:getNodeAt(mainCoordinates)
	local targetGroup = context:getTargetGroupFromCardData(cardData.targetChoice)
	if primaryTargetNode and primaryTargetNode:getOccupyingUnit() then
		local occupyingUnit = primaryTargetNode:getOccupyingUnit() 
		local validNodes = AreaResolver.getNodesInRadius(context:getCaster().coordinates, cardData.range, context)
		if table.find(targetGroup, occupyingUnit) then
			for _, node in ipairs(validNodes) do
				if node.coordinates == occupyingUnit.coordinates then
					return { occupyingUnit }
				end
			end
		end
	end
	return {}
end

return module
