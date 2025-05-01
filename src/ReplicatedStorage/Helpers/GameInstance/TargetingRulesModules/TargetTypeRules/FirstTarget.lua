local TargetingUtils = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.TargetingUtils)
local ContextType = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.Classes.CardExecutionContextType)

local module = {}

function module.getTargets(context: ContextType.context)
	local targetsInLine = TargetingUtils.getTargetsInLine(context)
	if #targetsInLine > 0 then
		return { targetsInLine[1] }
	end
	warn("No targets within range")
	return targetsInLine
end

return module
