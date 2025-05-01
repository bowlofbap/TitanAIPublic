local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums
local Classes = ReplicatedStorage.Client.Classes

local SequenceDispatcher = require(Classes.SequenceDispatcher)

local GuiService = require(ReplicatedStorage.Services.Client.GuiService)

local ClientInstanceManager = require(Classes.GameEntityModules.ClientInstanceManager)
local ClientMap = require(Classes.GameEntityModules.ClientMap)
local UiEventHandler = require(Classes.GameEntityModules.UiEventHandler)
local CameraMethods = require(Enums.CameraMethods)
local Angles = require(Enums.Angles)

local CameraBindableEvent = ReplicatedStorage.Remotes.CameraBindableEvent

local ClientGameEntity = {}
ClientGameEntity.__index = ClientGameEntity

function ClientGameEntity.new(entityFolder, mapData)
	local self = setmetatable({}, ClientGameEntity)
	self.entityFolder = entityFolder
	self.clientMap = ClientMap.new()
	self._sequenceDispatcher = SequenceDispatcher.new()
	self._instanceManager = ClientInstanceManager.new()
	self._deck = {}
	self:bindDispatcher(UiEventHandler)
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

function ClientGameEntity:bindDispatcher(eventHandler)
	eventHandler.bind(self._sequenceDispatcher)
end

function ClientGameEntity:bindEvents()
	self.entityFolder.Events.ToClient.EntityUiEvent.OnClientEvent:Connect(function(sequence)
		--print(sequence)
		self._sequenceDispatcher:enqueue(sequence, {clientEntity = self})
	end)
end

function ClientGameEntity:focusCamera(focusModel, cameraMode, cameraAngle)
	CameraBindableEvent:Fire(CameraMethods.setTarget, focusModel, cameraAngle, cameraMode)
end

function ClientGameEntity:requestAction(gameAction, data)
	local gameEvents = self.entityFolder.Events.ToServer
	gameEvents.EntityActionRequest:FireServer(gameAction, data)
end

function ClientGameEntity:invokeGuiService(guiName, guiMethod, ...)
	return GuiService:invoke(guiName, guiMethod, ...)
end

function ClientGameEntity:showOnlyGui(guiName, ...)
	GuiService:showOnly(guiName, ...)
end	

return ClientGameEntity
