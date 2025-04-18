local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes
local GuiEvent = ReplicatedStorage.Client.BindableEvents.GuiEvent
local Model = ReplicatedStorage.Models.NodeInstances.Chest

local ClientNodeInstance = require(Classes.ClientNode.ClientNodeInstance)
local SequenceDispatcher = require(Classes.SequenceDispatcher)
local UiEventHandler = require(Classes.ClientChestModules.UiEventHandler)

local ClientChest = setmetatable({}, {__index = ClientNodeInstance})
ClientChest.__index = ClientChest

function ClientChest.new(instanceFolder)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientChest)
	self:initModel(Model, instanceFolder)
	self._sequenceDispatcher = SequenceDispatcher.new()
	self:bindDispatcher()
	self:bindEvents()
	return self
end

function ClientChest:bindDispatcher()
	local dispatcher = self._sequenceDispatcher
	UiEventHandler.bind(dispatcher)
end

function ClientChest:getCameraSubject()
	return self._model
end

function ClientChest:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameSyncEvent.OnClientEvent:Connect(function(sequence)
		print(sequence)
		self._sequenceDispatcher:enqueue(sequence, {instance = self, guiEvent = GuiEvent})
	end)
end 

return ClientChest
