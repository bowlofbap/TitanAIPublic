local TargetingUtils = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.TargetingUtils)
local ContextType = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.Classes.CardExecutionContextType)

local module = {}

function module.getTargets(context: ContextType.context)
	local radius = context:getCardData().range
	local primaryCoordinates = context:getCaster().coordinates
	local closestTarget = TargetingUtils.getClosestTarget(primaryCoordinates, radius, context)
	return { closestTarget }
end

return module
