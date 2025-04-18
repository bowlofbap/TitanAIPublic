local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local UiActions = require(Enums.Rest.UiActions)

local UiEventDispatcher = {}

function UiEventDispatcher.bind(dispatcher)
	dispatcher:register(UiActions.SHOW_GUI, function(data, context)
		context.instance._upgradeableCardData = data.upgradeableCardData
		context.guiEvent:Fire("RestGui", "show")
	end)

	dispatcher:register(UiActions.USE_INSTANCE, function(data, context)
		context.isUseable = false
		context.guiEvent:Fire("RestGui", "disable")
	end)
end

return UiEventDispatcher
