local eventsRepo = require(game:GetService("ReplicatedStorage").Repos.EventsFolder.EventsRepo)

local BaseEvent = {}
BaseEvent.__index = BaseEvent

function BaseEvent.new(eventKey)
	local self = setmetatable({}, BaseEvent)
	self.eventData = eventsRepo[eventKey]
	self.eventKey = eventKey
	return self
end

function BaseEvent:getChoicesData(context)
	local data = {}
	for i, _ in ipairs(self.eventData.choices) do
		data[i] = self:checkOptionData(i, context)
	end
	return data
end

function BaseEvent:checkOptionData(index, context)
	local choice = self.eventData.choices[index]
	if choice.requirement then
		return choice.requirement(context)
	else
		return true
	end
end

function BaseEvent:executeEvent(index, context)
	return self.eventData.choices[index].execute(context)
end

function BaseEvent:serialize()
	return {
		eventKey = self.eventKey,
		eventData = self.eventData
	}
end

return BaseEvent
