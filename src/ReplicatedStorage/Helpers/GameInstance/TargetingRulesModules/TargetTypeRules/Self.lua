local TargetingUtils = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.TargetingUtils)
local ContextType = require(game:GetService("ReplicatedStorage").Helpers.GameInstance.Classes.CardExecutionContextType)

local module = {}

function module.getTargets(context: ContextType.context)
	return { context:getCaster() }
end

return module
