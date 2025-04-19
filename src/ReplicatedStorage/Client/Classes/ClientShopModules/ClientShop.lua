local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes

local Model = ReplicatedStorage.Models.NodeInstances.Shop

local ClientNodeInstance = require(Classes.ClientNode.ClientNodeInstance)
local UiEventHandler = require(Classes.ClientShopModules.UiEventHandler)
local SequenceDispatcher = require(Classes.SequenceDispatcher)

local ClientShop = setmetatable({}, {__index = ClientNodeInstance})
ClientShop.__index = ClientShop

function ClientShop.new(instanceFolder, shopData)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientShop)
	self._shopData = shopData
	self:initModel(Model, instanceFolder)
	self._sequenceDispatcher = SequenceDispatcher.new()
	self:bindDispatcher(UiEventHandler)
	self:bindEvents()
	return self
end

function ClientShop:getCameraSubject()
	return self._model
end

return ClientShop
