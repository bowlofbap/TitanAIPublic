local InstanceFolder = game:GetService("ReplicatedStorage").Models.NodeInstances.GameInstance

local NodeInstance = {}
NodeInstance.__index = NodeInstance

function NodeInstance.new(dependencies)
	local self = setmetatable({}, NodeInstance)
	local instanceFolder = InstanceFolder:Clone()
	instanceFolder.Parent = dependencies.parent
	self.robloxPlayer = dependencies.robloxPlayer
	self.mapNodeType = dependencies.mapNodeType
	self.folder = instanceFolder
	self.playerState = dependencies.playerState
	self.deckManager = dependencies.deckManager
	self.eventObserver = dependencies.eventObserver
	self.idGenerator = dependencies.idGenerator
	return self
end

function NodeInstance:Destroy()
	self.folder:Destroy()
	self.folder = nil
	self.robloxPlayer = nil
	self.mapNodeType = nil
	self.playerState = nil
	self.deckManager = nil
	self.eventObserver = nil
	self.idGenerator = nil
	setmetatable(self, nil)
end

function NodeInstance:start()
	warn("needs to be overridden")
end

function NodeInstance:connectPlayerToInstance(nodeType)
	warn("needs to be overridden")
end

function NodeInstance:getCameraSubject()
	warn("needs to be overridden")
	return nil
end

function NodeInstance:relayEvent(eventType, data)
	warn("needs to be overridden")
end

function NodeInstance:fireGameEvent(eventType, ...)
	self.eventObserver:emit(eventType, ...)
end

function NodeInstance:updateClientUi(uiAction, data)
	if not self or not self.folder then return end
	self.folder.Events.ToClient.GameUiEvent:FireClient(self.robloxPlayer, uiAction, data)
end

return NodeInstance
