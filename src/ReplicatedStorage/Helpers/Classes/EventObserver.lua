local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Object = require(ReplicatedStorage.Helpers.Classes.Object)

local EventObserver = {}
EventObserver.__index = EventObserver
setmetatable(EventObserver, {__index = Object})

function EventObserver.new()
	local self = setmetatable({}, EventObserver)
	self._listeners = {}
	self._nextId = 0
	self._silent = false
	return self
end

function EventObserver:loadLogName(name)
	self._logName = name
end

function EventObserver:silence()
	self._silent = true
end

--ensures that the callback function uses a real game instance
function EventObserver:subscribeToReal(eventName, callback, priority)
	local wrappedCallback = function(instance, ...)
		if instance:isSimulation() then
			return
		else
			callback(instance, ...)
		end
	end
	self:subscribeTo(eventName, wrappedCallback, priority)
end

function EventObserver:subscribeTo(eventName, callback, priority)
	priority = priority or 0  -- Default priority if not specified, higher priority means it gets called sooner

	self._listeners[eventName] = self._listeners[eventName] or {}

	self._nextId = self._nextId + 1
	local listenerId = self._nextId

	-- Insert listener with priority and ID
	table.insert(self._listeners[eventName], {
		id = listenerId,
		callback = callback,
		priority = priority
	})

	-- Sort listeners by descending priority
	table.sort(self._listeners[eventName], function(a, b)
		return a.priority > b.priority
	end)

	-- Unsubscribe function
	return function()
		for idx, listener in ipairs(self._listeners[eventName]) do
			if listener.id == listenerId then
				table.remove(self._listeners[eventName], idx)
				break
			end
		end
	end
end

function EventObserver:emit(eventName, instance, ...)
	self:log(eventName, nil, ...)
	local listeners = self._listeners[eventName]
	if not listeners then return end

	-- Execute callbacks in order of priority
	for _, listener in ipairs(listeners) do
		listener.callback(instance, ...)
	end
end

function EventObserver:log(eventName, prefix, ...)
	if self._silent then return end
	prefix = prefix or ""
	local printString = prefix.."[EVENT_OBSERVER]"
	if self._logName then
		printString = printString.."-[".. self._logName .."]"
	end
	print(printString, eventName, ...)
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
