local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TargetingUtils = require(ReplicatedStorage.Helpers.GameInstance.TargetingUtils)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local AreaResolver = require(ReplicatedStorage.Helpers.GameInstance.AreaResolver)
local CardUtils = require(ReplicatedStorage.Helpers.CardUtils)

local CardAttributeTags = require(ReplicatedStorage.Enums.CardAttributeTags)

local module = {}

function module.getTargets(context: ContextType.context)
	local cardData = context:getCardData()
	local mainCoordinates = context:getMainCoordinates()
	if not mainCoordinates then return {} end
	local primaryTargetNode = context:getNodeAt(mainCoordinates)
	if primaryTargetNode then
		local validNodes = AreaResolver.getNodesInRadius(context:getCaster().coordinates, cardData.range, context)
		if table.find(validNodes, primaryTargetNode) and (not CardUtils.hasTag(cardData, CardAttributeTags.REQUIRES_EMPTY_NODE) or not primaryTargetNode:getOccupyingUnit()) then
			return { primaryTargetNode }
		end
	end
	return {}
end

return module
