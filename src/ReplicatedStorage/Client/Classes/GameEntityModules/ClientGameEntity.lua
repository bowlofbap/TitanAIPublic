local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums
local Classes = ReplicatedStorage.Client.Classes

local SequenceDispatcher = require(Classes.SequenceDispatcher)

local ClientInstanceManager = require(Classes.GameEntityModules.ClientInstanceManager)
local ClientMap = require(Classes.GameEntityModules.ClientMap)
local UiEventHandler = require(Classes.GameEntityModules.UiEventHandler)

local EventBusTypes = require(Enums.Client.EventBusTypes)
local EntityUIActions = require(Enums.Entity.EntityUiActions)
local ScreenTransitionTypes = require(Enums.Client.ScreenTransitionTypes)
local CameraMethods = require(Enums.CameraMethods)
local Angles = require(Enums.Angles)
local EntityActions = require(Enums.Entity.EntityActions)

local EventBus = require(ReplicatedStorage.Helpers.EventBus)
local CameraBindableEvent = ReplicatedStorage.Remotes.CameraBindableEvent
local GuiEvent = ReplicatedStorage.Client.BindableEvents.GuiEvent


local ClientGameEntity = {}
ClientGameEntity.__index = ClientGameEntity

function ClientGameEntity.new(entityFolder, mapData)
	local self = setmetatable({}, ClientGameEntity)
	self.entityFolder = entityFolder
	self.clientMap = ClientMap.new()
	self.sequenceDispatcher = SequenceDispatcher.new()
	self._instanceManager = ClientInstanceManager.new()
	self._deck = {}
	self:bindDispatcher()
	self:bindEvents()
	return self
end

function ClientGameEntity:connectToInstance(data)
	local nodeType = data.nodeType
	local instanceFolder = data.folder
	return self._instanceManager:connectToInstance(nodeType, instanceFolder, table.unpack(data.args))
end

function ClientGameEntity:getCurrentInstance()
	return self._instanceManager:getCurrentInstance()
end

function ClientGameEntity:disconnectFromInstance()
	self._instanceManager:disconnectFromInstance()
end

function ClientGameEntity:destroy()
	setmetatable(self, nil)
end

function ClientGameEntity:setDeck(data)
	self._deck = data
end

function ClientGameEntity:getDeck()
	return self._deck
end

function ClientGameEntity:bindDispatcher()
	UiEventHandler.bind(self.sequenceDispatcher)
end

function ClientGameEntity:bindEvents()
	self.entityFolder.Events.ToClient.EntityUiEvent.OnClientEvent:Connect(function(sequence)
		print(sequence)
		self.sequenceDispatcher:enqueue(sequence, {clientEntity = self, guiEvent = GuiEvent})
	end)
end

function ClientGameEntity:focusCamera(focusModel, cameraMode)
	CameraBindableEvent:Fire(CameraMethods.setTarget, focusModel, Angles.SLIGHT_TOP_DOWN, cameraMode)
end

function ClientGameEntity:requestAction(gameAction, data)
	local gameEvents = self.entityFolder.Events.ToServer
	gameEvents.EntityActionRequest:FireServer(gameAction, data)
end

return ClientGameEntity
