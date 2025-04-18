local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local UiActions = require(Enums.GameInstance.UiActions)

local UiEventDispatcher = {}

function UiEventDispatcher.bind(dispatcher)
	dispatcher:register(UiActions.SHOW_GUI, function(data, context)
		context.guiEvent:Fire("BattleVictoryGui", "show", data.rewards)
	end)

	dispatcher:register(UiActions.OPEN_CARD_PACK, function(data, context)
		context.guiEvent:Fire("CardPackGui", "show", data)
	end)
end

return UiEventDispatcher
