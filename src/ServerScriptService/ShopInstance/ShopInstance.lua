local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ShopManager = require(ServerScriptService.ShopInstance.ShopManager)
local StateSyncBuffer = require(ServerScriptService.General.StateSyncBuffer)
local StateUpdate = require(ServerScriptService.General.StateUpdate)

local UiActions = require(ReplicatedStorage.Enums.Shop.UiActions)
local GameActions = require(ReplicatedStorage.Enums.Shop.GameActions)
local GameEventsTypes = require(ReplicatedStorage.Enums.GameEvents)

local NodeInstance = require(ServerScriptService.NodeInstance.NodeInstance)
local ShopInstance = {}
ShopInstance.__index = ShopInstance
setmetatable(ShopInstance, {__index = NodeInstance}) 

function ShopInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, ShopInstance)
	self.playerState = dependencies.playerState
	self.shopManager = ShopManager.new(dependencies.playerState, dependencies.idGenerator)
	self.stateSyncBuffer = StateSyncBuffer.new(dependencies.robloxPlayer, self.folder.Events.ToClient.GameSyncEvent)
	self.robloxPlayer = dependencies.robloxPlayer
	self:connectEvents()
	return self
end

function ShopInstance:connectEvents()
	local gameEvents = self.folder.Events

	local c1 = gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.REQUEST_END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.REQUEST_PURCHASE then
			self:requestPurchase(data)
		end
	end)
end

function ShopInstance:requestPurchase(data)
	local purchaseId = data.id
	local success, cardData, cost = self.shopManager:tryPurchase(purchaseId, self.playerState)
	if success then
		self:fireGameEvent(GameEventsTypes.CHANGE_MONEY, {moneyChange = cost * -1})
		self:fireGameEvent(GameEventsTypes.ADD_CARD, cardData)
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.PURCHASED_CARD, {id = purchaseId}))
		self.stateSyncBuffer:flush()
	end
	return success, cardData, cost
end

function ShopInstance:getCameraSubject()
	return self.model
end

function ShopInstance:start()
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.SHOW_GUI, {guiName = "ShopGui"}))
	self.stateSyncBuffer:flush()
end

function ShopInstance:connectPlayerToInstance(nodeType)
	local shopData = self.shopManager:serialize()
	self:fireGameEvent(GameEventsTypes.CONNECT_TO_INSTANCE, {
		nodeType = nodeType, 
		folder = self.folder, 
		args = {
			shopData
		}
	})
end

return ShopInstance