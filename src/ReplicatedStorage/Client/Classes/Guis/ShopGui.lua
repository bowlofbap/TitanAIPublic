local GameActions = require(game:GetService("ReplicatedStorage").Enums.Shop.GameActions)
local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)
local ShopCardFrame = game:GetService("ReplicatedStorage").Models.UI.Shop.CardShopFrame
local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)
local DescriptionOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.DescriptionOverlay)

local CardRepo = require(game:GetService("ReplicatedStorage").Repos.CardRepo)

local player = game:GetService("Players").LocalPlayer

local CARD_SIZE_BASE =  UDim2.new(1, 0, 0.8, 0)
local CARD_SIZE_HOVER =  UDim2.new(1, 0, 1, 0)

local ShopGui = setmetatable({}, { __index = BaseGui }) 
ShopGui.__index = ShopGui

function ShopGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, ShopGui)
	self.items = {}
	self._overlay = DescriptionOverlay.new()
	self:init()
	return self
end

function ShopGui:init()
	self.object.CloseFrame.TextButton.MouseButton1Click:Connect(function()
		self:hide()
		self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_END_GAME)
	end)
end

function ShopGui:markItemAsBought(id)
	if not self.items[id] then
		warn("No item for id ".. id.." was found")
		return
	end
	self.items[id].card.model.PurchasedFrame.BackgroundTransparency = 0.3
	self.items[id].purchased = true
end

function ShopGui:loadData(shopData)
	local shopFrame = self.object.ContainerFrame.ShopFrame
	local shopData = shopData.cardData
	local numCards = #shopData
	if numCards == 0 then return end
	for _, data in ipairs(shopData) do
		local shopCardFrame = ShopCardFrame:Clone()
		shopCardFrame.Parent = shopFrame.ShopFrame1
		shopCardFrame.PriceFrame.TextLabel.Text = data.cost
		local newCard = ClientCard.new(data.cardData, data.id, data.upgraded)
		newCard.Parent = shopCardFrame.CardButton
		newCard.model.UISizeConstraint:Destroy()
		newCard.AnchorPoint = Vector2.new(.5, 1)
		newCard.Position = UDim2.new(0.5, 0, 1, 0)
		newCard.Size = CARD_SIZE_BASE
		local shopTable = {card = newCard, purchased = false}
		shopCardFrame.CardButton.MouseButton1Click:Connect(function()
			self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_PURCHASE, {id = data.id})
		end)
		
		local function onEnter()
			if shopTable.purchased then return end
			newCard:changeSize(CARD_SIZE_HOVER, false)
			self._overlay:show(newCard)
		end
		
		local function onLeave()
			newCard:changeSize(CARD_SIZE_BASE, true)
			self._overlay:hide(newCard)
		end
		
		newCard:setHoverCallbacks(onEnter, onLeave)
		newCard:enableHover()
		
		local purchasedFrame = Instance.new("Frame") --TODO this will be different once assets are created for purchase
		purchasedFrame.Size = UDim2.new(1, 0, 1, 0)
		purchasedFrame.Name = "PurchasedFrame"
		purchasedFrame.Parent = newCard.model
		purchasedFrame.BackgroundTransparency = 1
		purchasedFrame.ZIndex = 3
		self.items[data.id] = shopTable
	end
end

function ShopGui:reset()
	for id, shopTable in pairs(self.items) do
		shopTable.card:Destroy()
	end
	for _, frame in ipairs(self.object.ContainerFrame.ShopFrame.ShopFrame1:GetChildren()) do
		if frame.ClassName == "Frame" then
			frame:Destroy()
		end
	end
	self.items = {}
end

function ShopGui:show(data)
	self.object.Enabled = true
end

function ShopGui:hide()
	self:reset()
	self.object.Enabled = false
end

return ShopGui