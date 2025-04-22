local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local StatusManager = {}
StatusManager.__index =  StatusManager

function StatusManager.new()
	local self = setmetatable({}, StatusManager)
	self.statuses = {}
	return self
end

function StatusManager:add(effectType, target, eventObserver, gameInstance, deckManager, playerState)
	--[[
			{ 
				effectType = EffectTypes.TYPE, 
				statusType = StatusTypes.TYPE,
				value = VALUE,
			}
	]]
	local existingStatus = self:getStatus(effectType.statusType)
	if not existingStatus then
		local newStatusClass = game:GetService("ReplicatedStorage").Repos.Statuses[effectType.statusType.class]
		local newStatus
		local removeFunction = function()
			self:remove(newStatus)
		end
		newStatus = require(newStatusClass).new(effectType.statusType, removeFunction) --very hacky but i want it to be thread safe
		table.insert(self.statuses, newStatus)
		newStatus.value = effectType.value
		newStatus.Parent = self.frame
		newStatus:execute(target, eventObserver, gameInstance, deckManager, playerState)
		return newStatus
	else
		local reapplyStatus = existingStatus:reapply(effectType.value)
		return reapplyStatus
	end
end

function StatusManager:tryRemoveStatus(statusType, value)
	local status = self:getStatus(statusType)
	if not status then return end
	local statusNewValue = status.value - value
	status:setValue(statusNewValue)
end

function StatusManager:getStatus(statusType)
	for _, status in self.statuses do
		if status.statusType.name == statusType.name then
			return status
		end
	end
	return nil
end

function StatusManager:tick()
	--local statusCopy = Tables.shallowCopy(self.statuses)
	for _, status in self.statuses do
		if next(status) ~= nil then 
			print("ticking for ", status)
			status:tick()
		end
	end
end

function StatusManager:remove(status)
	for i, v in ipairs(self.statuses) do
		if status == v then
			table.remove(self.statuses, i)
		end
	end
	print("Removing!")
end

function StatusManager:getAllStatuses()
	return self.statuses
end

function StatusManager:serialize()
	local statuses = {}
	for _, status in ipairs(self.statuses) do
		table.insert(statuses, status:serialize())
	end
	return statuses
end


return StatusManager
