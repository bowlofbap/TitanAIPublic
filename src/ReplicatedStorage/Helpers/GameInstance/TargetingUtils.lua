local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local AreaResolver = require(ReplicatedStorage.Helpers.GameInstance.AreaResolver)

local utils = {}

function utils.getTargetsInLine(context: ContextType.context)
	local targetsInLine = {}
	local cardData = context:getCardData()
	local caster = context:getCaster()
	local range = cardData.range
	local targetGroup = context:getTargetGroupFromCardData(cardData.targetChoice)
	for _, target in ipairs(targetGroup) do
		if target.coordinates.Y == caster.coordinates.Y then
			if math.abs(target.coordinates.X - caster.coordinates.X) <= range or range == 0 then
				local distance = math.abs(target.coordinates.X - caster.coordinates.X)
				table.insert(targetsInLine, {
					target = target,
					distance = math.abs(distance)
				})
			end
		end
	end
	-- Sort by proximity to caster (closest first)
	table.sort(targetsInLine, function(a, b)
		return a.distance < b.distance
	end)
	
	local sortedTargets = {}
	for _, entry in ipairs(targetsInLine) do
		table.insert(sortedTargets, entry.target)
	end

	return sortedTargets
end

function utils.getClosestTarget(primaryCoordinates, radius, context: ContextType.context)
	local validTargets = AreaResolver.getUnitsInRadius(primaryCoordinates, radius, context)
	local closestTarget = nil
	for _, target in ipairs(validTargets) do
		if not closestTarget or (primaryCoordinates - target.coordinates).magnitude < (primaryCoordinates - closestTarget.coordinates).magnitude then
			closestTarget = target
		end
	end
	return closestTarget
end

return utils
