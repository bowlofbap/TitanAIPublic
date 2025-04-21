local Status = require(script.Parent.Status)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local StatusTypes = require(game:GetService("ReplicatedStorage").Enums.StatusTypes)

local CustomStatus = setmetatable({}, { __index = Status })
CustomStatus.__index = CustomStatus

--[[
args needs to be structured as :
{
	value = value
	direction = Directions.DIRECTION
}
]]

function CustomStatus.new(statusType, gameInstance)
	local base = Status.new(statusType, gameInstance)
	local self = setmetatable(base, CustomStatus)
	return self
end

--removes the status at the start of the unit's turn
function CustomStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.START_UNIT_TURN, function(data)
		if data.unit == target and data.unit.isAlive then
			local savedValue = self.value
			local removingStatus = StatusTypes[self.statusType.targetStatusKey]
			self:setValue(0)
			gameInstance:removeStatus({target}, removingStatus, savedValue)
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return CustomStatus
