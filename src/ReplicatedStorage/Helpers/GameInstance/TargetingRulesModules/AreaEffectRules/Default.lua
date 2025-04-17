local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local AreaResolver = require(ReplicatedStorage.Helpers.GameInstance.AreaResolver)

local module = {}

function module.getNodes(primaryTargets: table, context: ContextType.context)
	local cardData = context:getCardData()
	local areaNodes = AreaResolver.getNodesInRadius(context:getCaster().coordinates, cardData.range, context)
	return areaNodes
end

return module
