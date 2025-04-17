local localPlayer = game:GetService("Players").LocalPlayer

local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local UiActions = require(game:GetService("ReplicatedStorage").Enums.Rest.UiActions)
local ClientEvents = require(game:GetService("ReplicatedStorage").Enums.ClientEvents)

local ClientNodeInstance = require(game:GetService("ReplicatedStorage").Client.Classes.ClientNode.ClientNodeInstance)

local ClientRest = setmetatable({}, {__index = ClientNodeInstance})
ClientRest.__index = ClientRest

function ClientRest.new(instanceFolder)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientRest)
	self._upgradeableCardData = nil
	self.isUseable = true
	self:bindEvents()
	return self
end

function ClientRest:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameUiEvent.OnClientEvent:Connect(function(uiAction, data)
		if uiAction == UiActions.SHOW_GUI then
			self._upgradeableCardData = data.upgradeableCardData
			GuiEvent:Fire("RestGui", "show")
		elseif uiAction == UiActions.USE_INSTANCE then
			self.isUseable = false
			GuiEvent:Fire("RestGui", "disable")
		end
	end)
end 

function ClientRest:getUpgradeableCardData()
	return self._upgradeableCardData
end

return ClientRest
