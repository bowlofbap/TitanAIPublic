local EventsRepo = require(game:GetService("ReplicatedStorage").Repos.EventsFolder.EventsRepo)

local selector = {}

function selector.getEventId(dependencies)
	local validEventIds = {}
	for eventId, event in pairs(EventsRepo) do
		if dependencies.playerState:getVisitedEvents()[eventId] then continue end
		if not event.validLevels[dependencies.playerState.level] then continue end
		table.insert(validEventIds, eventId)
	end
	if #validEventIds > 0 then
		return validEventIds[math.random(#validEventIds)]
	end
	warn("No more events to select")
end

return selector
