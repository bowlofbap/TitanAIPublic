local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes

local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent
local Model = ReplicatedStorage.Models.NodeInstances.Rest

local UiEventHandler = require(Classes.ClientRestModules.UiEventHandler)
local SequenceDispatcher = require(Classes.SequenceDispatcher)
local ClientNodeInstance = require(game:GetService("ReplicatedStorage").Client.Classes.ClientNode.ClientNodeInstance)

local ClientRest = setmetatable({}, {__index = ClientNodeInstance})
ClientRest.__index = ClientRest

function ClientRest.new(instanceFolder)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientRest)
	self._upgradeableCardData = nil
	self.isUseable = true
	self._sequenceDispatcher = SequenceDispatcher.new()
	self:initModel(Model, instanceFolder)
	self:bindDispatcher()
	self:bindEvents()
	return self
end

function ClientRest:bindDispatcher()
	local dispatcher = self._sequenceDispatcher
	UiEventHandler.bind(dispatcher)
end

function ClientRest:getCameraSubject()
	return self._model
end

function ClientRest:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameSyncEvent.OnClientEvent:Connect(function(sequence)
		print(sequence)
		self._sequenceDispatcher:enqueue(sequence, {instance = self, guiEvent = GuiEvent})
	end)
end 

function ClientRest:getUpgradeableCardData()
	return self._upgradeableCardData
end

return ClientRest
