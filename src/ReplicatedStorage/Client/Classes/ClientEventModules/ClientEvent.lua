local localPlayer = game:GetService("Players").LocalPlayer

local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local UiActions = require(game:GetService("ReplicatedStorage").Enums.Event.UiActions)
local ClientEvents = require(game:GetService("ReplicatedStorage").Enums.ClientEvents)

local EventsRepo = require(game:GetService("ReplicatedStorage").Repos.EventsFolder.EventsRepo)

local ClientNodeInstance = require(game:GetService("ReplicatedStorage").Client.Classes.ClientNode.ClientNodeInstance)

local ClientEvent = setmetatable({}, {__index = ClientNodeInstance})
ClientEvent.__index = ClientEvent

function ClientEvent.new(instanceFolder)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientEvent)
	self._eventId = nil
	self:bindEvents()
	return self
end

function ClientEvent:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameUiEvent.OnClientEvent:Connect(function(uiAction, data)
		if uiAction == UiActions.SHOW_GUI then
			self._eventId = data.eventData.eventKey
			GuiEvent:Fire("EventGui", "show")
		elseif uiAction == UiActions.SELECT_OPTION then
			local choiceResultData = data.choiceResultData
			GuiEvent:Fire("EventGui", "update", choiceResultData)
		end
	end)
end 

function ClientEvent:getEventData()
	return EventsRepo[self._eventId]
end

return ClientEvent
