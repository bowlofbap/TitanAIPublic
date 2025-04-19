local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes

local Constants = require(ReplicatedStorage.Helpers.Constants)
local SequenceDispatcher = require(Classes.SequenceDispatcher)
local GuiEvent = ReplicatedStorage.Client.BindableEvents.GuiEvent

local ClientNodeInstance = {}
ClientNodeInstance.__index = ClientNodeInstance

function ClientNodeInstance.new(instanceFolder)
	local self = setmetatable({}, ClientNodeInstance)
	self._sequenceDispatcher = SequenceDispatcher.new()
	self.instanceFolder = instanceFolder
	return self
end

function ClientNodeInstance:bindDispatcher(eventHandler)
	local dispatcher = self._sequenceDispatcher
	eventHandler.bind(dispatcher)
end

function ClientNodeInstance:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameSyncEvent.OnClientEvent:Connect(function(sequence)
		print(sequence)
		self._sequenceDispatcher:enqueue(sequence, {instance = self, guiEvent = GuiEvent})
	end)
end 

function ClientNodeInstance:destroy()
	setmetatable(self, nil)
end

function ClientNodeInstance:getCameraSubject()
	warn("Method must be overridden")
	return nil
end

function ClientNodeInstance:initModel(model, instanceFolder)
	self._model = model:Clone()
	local centerPosition = Constants.INSTANCE_SETTINGS.INSTANCE_POSITION
	self._model:PivotTo(CFrame.new(centerPosition))
	self._model.Parent = instanceFolder
end

function ClientNodeInstance:requestGameAction(gameAction, data)
	local gameEvents = self.instanceFolder.Events.ToServer
	gameEvents.GameActionRequest:FireServer(gameAction, data)
end

function ClientNodeInstance:requestGameData(gameDataRequest, data)
	local response = self.instanceFolder.Functions.GameDataRequest:InvokeServer(gameDataRequest, data)
	return response
end

return ClientNodeInstance
