local Status = require(script.Parent.Status)
local DamageTypes = require(game:GetService("ReplicatedStorage").Enums.DamageTypes)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local CustomStatus = setmetatable({}, { __index = Status })
CustomStatus.__index = CustomStatus

function CustomStatus.new(statusType, gameInstance)
	local base = Status.new(statusType, gameInstance)
	local self = setmetatable(base, CustomStatus)
	return self
end

function CustomStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.BEFORE_MOVE, function(data)
		if data.target == target then
			data.moveData.canMove = false
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return CustomStatus
