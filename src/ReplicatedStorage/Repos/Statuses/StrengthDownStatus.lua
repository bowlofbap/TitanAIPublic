local Status = require(script.Parent.Status)
local DamageTypes = require(game:GetService("ReplicatedStorage").Enums.DamageTypes)
local TargetTypes = require(game:GetService("ReplicatedStorage").Enums.TargetTypes)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local StatusTypes = require(game:GetService("ReplicatedStorage").Enums.StatusTypes)

local TargetHelper = require(game:GetService("ReplicatedStorage").Helpers.TargetHelper)

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

function CustomStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.END_UNIT_TURN, function(data)
		if data.unit == target and data.unit.isAlive then
			local savedValue = self.value
			self:setValue(0)
			gameInstance:removeStatus({target}, StatusTypes.STRENGTH_BUFF, savedValue)
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end

return CustomStatus
