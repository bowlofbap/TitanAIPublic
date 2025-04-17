local Status = require(script.Parent.Status)
local DamageTypes = require(game:GetService("ReplicatedStorage").Enums.DamageTypes)
local TargetTypes = require(game:GetService("ReplicatedStorage").Enums.TargetTypes)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local TargetHelper = require(game:GetService("ReplicatedStorage").Helpers.TargetHelper)

local DamageOverTimeStatus = setmetatable({}, { __index = Status })
DamageOverTimeStatus.__index = DamageOverTimeStatus

function DamageOverTimeStatus.new(statusType, gameInstance)
	local base = Status.new(statusType, gameInstance)
	local self = setmetatable(base, DamageOverTimeStatus)
	return self
end

function DamageOverTimeStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.END_UNIT_TURN, function(data)
		if data.unit == target and data.unit.isAlive then
			gameInstance:dealDamage(nil, { data.unit }, self.value, DamageTypes.DAMAGE_OVER_TIME)
			self:setValue(self.value-1)
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return DamageOverTimeStatus
