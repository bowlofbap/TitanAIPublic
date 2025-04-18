local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes

local GuiEvent = ReplicatedStorage.Client.BindableEvents.GuiEvent
local Model = ReplicatedStorage.Models.NodeInstances.Shop

local ClientNodeInstance = require(Classes.ClientNode.ClientNodeInstance)
local UiEventHandler = require(Classes.ClientChestModules.UiEventHandler)

local ClientShop = setmetatable({}, {__index = ClientNodeInstance})
ClientShop.__index = ClientShop

function ClientShop.new(instanceFolder, shopData)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientShop)
	self._shopData = shopData
	self:initModel(Model, instanceFolder)
	GuiEvent:Fire("ShopGui", "loadData", shopData)
	self:bindDispatcher()
	self:bindEvents()
	return self
end

function ClientShop:bindDispatcher()
	local dispatcher = self._sequenceDispatcher
	UiEventHandler.bind(dispatcher)
end

function ClientShop:getCameraSubject()
	return self._model
end

function ClientShop:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameSyncEvent.OnClientEvent:Connect(function(sequence)
		print(sequence)
		self._sequenceDispatcher:enqueue(sequence, {instance = self, guiEvent = GuiEvent})
	end)
end 

return ClientShop
