local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local ClientNodeInstance = {}
ClientNodeInstance.__index = ClientNodeInstance

function ClientNodeInstance.new(instanceFolder)
	local self = setmetatable({}, ClientNodeInstance)
	self.instanceFolder = instanceFolder
	return self
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
