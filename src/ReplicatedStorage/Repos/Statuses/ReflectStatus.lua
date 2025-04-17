local Status = require(script.Parent.Status)
local DamageTypes = require(game:GetService("ReplicatedStorage").Enums.DamageTypes)
local TargetTypes = require(game:GetService("ReplicatedStorage").Enums.TargetTypes)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local ReflectStatus = setmetatable({}, { __index = Status })
ReflectStatus.__index = ReflectStatus

function ReflectStatus.new(statusType, gameInstance)
	local base = Status.new(statusType, gameInstance)
	local self = setmetatable(base, ReflectStatus)
	return self
end

function ReflectStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(data)
		if data.target == target and target.isAlive and data.damageType == DamageTypes.DIRECT then
			gameInstance:dealDamage(target, { data.source }, self.value, DamageTypes.REFLECT)
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return ReflectStatus
