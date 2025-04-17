local ShopManager = require(game:GetService("ServerScriptService").ShopInstance.ShopManager)

local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local ShopModel = game:GetService("ReplicatedStorage").Models.NodeInstances.Shop

local UiActions = require(game:GetService("ReplicatedStorage").Enums.Shop.UiActions)
local GameActions = require(game:GetService("ReplicatedStorage").Enums.Shop.GameActions)
local GameEventsTypes = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local NodeInstance = require(game:GetService("ServerScriptService").NodeInstance.NodeInstance)
local ShopInstance = {}
ShopInstance.__index = ShopInstance
setmetatable(ShopInstance, {__index = NodeInstance}) 

function ShopInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, ShopInstance)
	self.model = ShopModel:Clone()
	self.model:SetPrimaryPartCFrame(CFrame.new(dependencies.centerPosition))
	self.model.Parent = self.folder
	self.playerState = dependencies.playerState
	self.shopManager = ShopManager.new(dependencies.playerState, dependencies.idGenerator)
	self.robloxPlayer = dependencies.robloxPlayer
	self:connectEvents()
	return self
end

function ShopInstance:connectEvents()
	local gameFunctions = self.folder.Functions
	local gameEvents = self.folder.Events

	local c1 = gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.REQUEST_END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.REQUEST_PURCHASE then
			local purchaseId = data.id
			local cardData, cost = self.shopManager:tryPurchase(purchaseId, self.playerState)
			if cardData then
				self.playerState:spendMoney(cost)
				self:fireGameEvent(GameEventsTypes.ADD_CARD, cardData)
				self:updateClientUi(UiActions.PURCHASED_CARD, {id = purchaseId})
			end
		end
	end)
end

function ShopInstance:getCameraSubject()
	return self.model
end

function ShopInstance:start()
	local shopData = self.shopManager:serialize()
	self:updateClientUi(UiActions.SHOW_GUI, "ShopGui")
end

function ShopInstance:connectPlayerToInstance(nodeType)
	local shopData = self.shopManager:serialize()
	ConnectToGame:FireClient(self.robloxPlayer, nodeType, self.folder, {cardData = shopData}) --send the data in a sorted format for the deck
end

return ShopInstance