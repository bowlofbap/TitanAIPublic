local EventContext = {}
EventContext.__index = EventContext

function EventContext.new(eventObserver, deckManager, playerState, mapNodeType)
	local self = setmetatable({}, EventContext)
	self.eventObserver = eventObserver
	self.deckManager = deckManager
	self.playerState = playerState
	self.mapNodeType = mapNodeType
	return self
end

return EventContext
