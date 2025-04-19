local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes

local GuiEvent = ReplicatedStorage.Client.BindableEvents.GuiEvent
local Model = ReplicatedStorage.Models.NodeInstances.Event
local EventsRepo = require(ReplicatedStorage.Repos.EventsFolder.EventsRepo)

local UiEventHandler = require(Classes.ClientEventModules.UiEventHandler)
local ClientNodeInstance = require(Classes.ClientNode.ClientNodeInstance)

local ClientEvent = setmetatable({}, {__index = ClientNodeInstance})
ClientEvent.__index = ClientEvent

function ClientEvent.new(instanceFolder)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientEvent)
	self._eventId = nil
	self:initModel(Model, instanceFolder)
	self:bindDispatcher(UiEventHandler)
	self:bindEvents()
	return self
end

function ClientEvent:getCameraSubject()
	return self._model
end

function ClientEvent:getEventData()
	return EventsRepo[self._eventId]
end

return ClientEvent
