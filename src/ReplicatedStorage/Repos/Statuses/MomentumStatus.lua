local Status = require(script.Parent.Status)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local CustomStatus = setmetatable({}, { __index = Status })
CustomStatus.__index = CustomStatus

function CustomStatus.new(statusType, gameInstance)
	local base = Status.new(statusType, gameInstance)
	local self = setmetatable(base, CustomStatus)
	return self
end

function CustomStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.SPEND_ENERGY, function(data)
		if data.source == target and data.value > 0 then
			gameInstance:grantMovementPoints(target, self.value)
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return CustomStatus
