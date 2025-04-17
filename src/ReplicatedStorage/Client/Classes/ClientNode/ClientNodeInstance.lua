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

function ClientNodeInstance:requestGameAction(gameAction, data)
	local gameEvents = self.instanceFolder.Events.ToServer
	gameEvents.GameActionRequest:FireServer(gameAction, data)
end

function ClientNodeInstance:requestGameData(gameDataRequest, data)
	local response = self.instanceFolder.Functions.GameDataRequest:InvokeServer(gameDataRequest, data)
	return response
end

return ClientNodeInstance
