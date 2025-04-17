local Status = {}
Status.__index = Status

function Status.new(statusType, removeFunction)
	local self = setmetatable({}, Status)
	self.statusType = statusType
	self.tickable = statusType.defaultTickable
	self.onDestroyedEvent = Instance.new("BindableEvent")
	self.onDestroyed = self.onDestroyedEvent.Event
	self._unsubscribes = {}
	self._onRemove = removeFunction
	self.value = 0
	return self
end

function Status:execute(eventObserver, playerState, deckManager, getCurrentInstance)
	warn("No execute method found in this status")
end

function Status:tick()
	if self.tickable then
		self:setValue(self.value-1)
	end
end

function Status:reapply(value)
	if not self.statusType.stackable then
		if value > self.value then
			self:setValue(value)
			return true
		end
	else 
		self:setValue(value + self.value)
		return true
	end
	warn("Nothing was done when trying to apply for status ", self)
	return false
end

function Status:destroy()
	for _, unsubscribe in ipairs(self._unsubscribes) do
		unsubscribe()
	end
	self:_onRemove()
	for key in pairs(self) do
		self[key] = nil
	end
	setmetatable(self, nil)
end

function Status:setValue(value)
	if value > 0 or (self.statusType.canBeNegative and value ~= 0) then
		self.value = value
	else
		self.value = 0
		self:destroy()
	end
end

function Status:serialize()
	return {
		statusType = self.statusType,
		tickable = self.tickable,
		value = self.value
	}
end

return Status
