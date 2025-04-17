local EventObserver = {}
EventObserver.__index = EventObserver

function EventObserver.new()
	local self = setmetatable({}, EventObserver)
	self._listeners = {}
	self._nextId = 0
	return self
end

function EventObserver:subscribeTo(eventName, callback)
	self._listeners[eventName] = self._listeners[eventName] or {}
	local listenerId = self._nextId + 1
	self._nextId = listenerId

	-- Store the callback with its ID
	self._listeners[eventName][listenerId] = callback

	-- Return a function to unsubscribe this specific listener
	return function()
		self._listeners[eventName][listenerId] = nil
	end
end

function EventObserver:emit(eventName, ...)
	print(eventName, ...)
	local listeners = self._listeners[eventName]
	if not listeners then return end

	for id, callback in pairs(listeners) do
		callback(...)
	end
end

-- Optional: Explicitly unsubscribe by ID (alternative to the cleanup function)
function EventObserver:off(eventName, listenerId)
	if self._listeners[eventName] then
		self._listeners[eventName][listenerId] = nil
	end
end

function EventObserver:destroy()
	for eventName, listeners in pairs(self._listeners) do
		table.clear(listeners)
	end
	table.clear(self._listeners)

	-- Remove the metatable
	setmetatable(self, nil)
end

return EventObserver
