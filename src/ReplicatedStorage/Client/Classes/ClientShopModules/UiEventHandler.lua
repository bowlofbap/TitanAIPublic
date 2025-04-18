local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local UiActions = require(Enums.Shop.UiActions)

local UiEventDispatcher = {}

function UiEventDispatcher.bind(dispatcher)
	dispatcher:register(UiActions.SHOW_GUI, function(data, context)
		context.guiEvent:Fire(data.guiName, "show")
	end)

	dispatcher:register(UiActions.PURCHASED_CARD, function(data, context)
		context.guiEvent:Fire("ShopGui", "markItemAsBought", data.id)
	end)
end

return UiEventDispatcher
