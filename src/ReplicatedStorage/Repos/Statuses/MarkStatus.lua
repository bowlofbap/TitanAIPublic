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
	local unsubscribe = eventObserver:subscribeTo(GameEvents.DEATH, function(data)
		if data.unit == target and data.unit.Team == "Game" then
			gameInstance:grantEnergy(gameInstance.player.unit, self.value)
			gameInstance:drawCards(math.floor(self.value/2))
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return CustomStatus
