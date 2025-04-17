local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local AreaResolver = require(ReplicatedStorage.Helpers.GameInstance.AreaResolver)

local module = {}

function module.getNodes(primaryTargets: table, context: ContextType.context)
	local cardData = context:getCardData()
	local radius = cardData.radius or 0
	local allNodes = {}
	
	local casterCoords = context:getCaster().coordinates
	for x = 1, cardData.range do
		local newNodeCoords = casterCoords + Vector2.new(x, 0)
		local node = context:getNodeAt(newNodeCoords)
		if node then
			table.insert(allNodes, node)
			if node:getOccupyingUnit() then
				break
			end
		end
	end

	return allNodes
end

return module
