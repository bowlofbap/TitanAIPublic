local localPlayer = game:GetService("Players").LocalPlayer

local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local UiActions = require(game:GetService("ReplicatedStorage").Enums.GameInstance.UiActions)

local ClientNodeInstance = require(game:GetService("ReplicatedStorage").Client.Classes.ClientNode.ClientNodeInstance)

local ClientChest = setmetatable({}, {__index = ClientNodeInstance})
ClientChest.__index = ClientChest

function ClientChest.new(instanceFolder)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientChest)
	self:bindEvents()
	return self
end

function ClientChest:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameUiEvent.OnClientEvent:Connect(function(uiAction, data)
		if uiAction == UiActions.SHOW_GUI then
			GuiEvent:Fire("BattleVictoryGui", "show", data.rewards)
		elseif uiAction == UiActions.OPEN_CARD_PACK then
			GuiEvent:Fire("CardPackGui", "show", data)
		end
	end)
end 

return ClientChest
