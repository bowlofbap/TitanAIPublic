local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local Tables = require(ReplicatedStorage.Helpers.Tables)

local Effect = {}
Effect.__index = Effect

-- The Effect class stores the effect type and general arguments
function Effect.new(effectData)
	local self = setmetatable({}, Effect)
	self.effectData = effectData
	return self
end

function Effect:getAltData(cardData, adjustments)
	local altData = Tables.deepCopy(cardData)
	for key, value in pairs(adjustments) do
		if altData[key] then
			altData[key] = value
		else
			warn("Key "..key.." doesn't exist")
		end
	end
	return altData
end

-- This is a generic apply method, but it's expected to be overridden in derived classes.
function Effect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	error("Apply method must be overridden in a derived class.")
end

return Effect
