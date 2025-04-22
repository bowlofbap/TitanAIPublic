local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local CardUtils = require(ReplicatedStorage.Helpers.CardUtils)
local CardAttributeTags = require(ReplicatedStorage.Enums.CardAttributeTags)

local module = {}

function module.getTargets(context: ContextType.context)
	-- if CardUtils.hasTag(context:getCardData(), CardAttributeTags.TARGETS_TILE) then
	-- 	return context:getNodeAt(context:getCaster().coordinates)
	-- end
	return { context:getCaster() }
end

return module
