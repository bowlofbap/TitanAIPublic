local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local UiActions = require(Enums.Event.UiActions)

local UiEventDispatcher = {}

function UiEventDispatcher.bind(dispatcher)
	dispatcher:register(UiActions.SHOW_GUI, function(data, context)
		context.instance._eventId = data.eventData.eventKey
		context.guiEvent:Fire("EventGui", "show")
	end)

	dispatcher:register(UiActions.SELECT_OPTION, function(data, context)
		local choiceResultData = data.choiceResultData
		context.guiEvent:Fire("EventGui", "update", choiceResultData)
	end)
end

return UiEventDispatcher
