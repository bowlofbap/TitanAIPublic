local Status = require(script.Parent.Status)
local DamageTypes = require(game:GetService("ReplicatedStorage").Enums.DamageTypes)
local StatusTypes = require(game:GetService("ReplicatedStorage").Enums.StatusTypes)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local CustomStatus = setmetatable({}, { __index = Status })
CustomStatus.__index = CustomStatus

function CustomStatus.new(statusType, gameInstance)
	local base = Status.new(statusType, gameInstance)
	local self = setmetatable(base, CustomStatus)
	return self
end

function CustomStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(data)
		if data.source == target and data.target.isAlive and data.damageType == DamageTypes.DIRECT then
			gameInstance:applyStatus(target, {data.target}, StatusTypes[self.statusType.targetStatusKey], self.value)
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return CustomStatus
