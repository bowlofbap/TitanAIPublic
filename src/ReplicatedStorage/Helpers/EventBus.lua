--TODO: rename, should be client event bus

local EventBus = {
	_subscribers = {},
	_queue = {}
}

-- Subscribe: Returns a token with a Disconnect method
function EventBus:Subscribe(eventType, callback)
	self._subscribers[eventType] = self._subscribers[eventType] or {}
	table.insert(self._subscribers[eventType], callback)

	-- Return a token with a Disconnect method
	return {
		eventType = eventType,
		callback = callback,
		Disconnect = function(self)
			EventBus:Unsubscribe(self)
		end
	}
end

-- New method to remove a subscription
function EventBus:Unsubscribe(subscription)
	local eventType = subscription.eventType
	local callback = subscription.callback

	if self._subscribers[eventType] then
		-- Iterate backward to avoid skipping elements
		for i = #self._subscribers[eventType], 1, -1 do
			if self._subscribers[eventType][i] == callback then
				table.remove(self._subscribers[eventType], i)
			end
		end

		-- Clean up empty eventType entries
		if #self._subscribers[eventType] == 0 then
			self._subscribers[eventType] = nil
		end
	end
end

function EventBus:Publish(eventType, ...)
	table.insert(self._queue, { type = eventType, args = { ... } })
end

game:GetService("RunService").Heartbeat:Connect(function()
	for _, event in ipairs(EventBus._queue) do
		for _, callback in ipairs(EventBus._subscribers[event.type] or {}) do
			callback(unpack(event.args))
		end
	end
	EventBus._queue = {}
end)

return EventBus