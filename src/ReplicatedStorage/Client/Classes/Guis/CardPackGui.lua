local GameActions = require(game:GetService("ReplicatedStorage").Enums.GameActions)
local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)
local CardButton = game:GetService("ReplicatedStorage").Models.UI.CardPack.CardButton
local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)
local DescriptionOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.DescriptionOverlay)
local TweenService = game:GetService("TweenService")

local CardRepo = require(game:GetService("ReplicatedStorage").Repos.CardRepo)

local player = game:GetService("Players").LocalPlayer

local CARD_SIZE_BASE =  UDim2.new(1, 0, 0.65, 0)
local CARD_SIZE_HOVER =  UDim2.new(1, 0, 0.9, 0)

local CardPackGui = setmetatable({}, { __index = BaseGui }) 
CardPackGui.__index = CardPackGui

function CardPackGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, CardPackGui)
	self.cards = {}
	self._overlay = DescriptionOverlay.new()
	self:init()
	return self
end

function CardPackGui:init()
	self.object.ContainerFrame.SkipButton.MouseButton1Click:Connect(function()
		self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.SELECT_CARD_REWARD, nil)
		self:hide()
		self._overlay:hide()
	end)
end

function CardPackGui:loadData(packData)
	local cardsFrame = self.object.ContainerFrame.CardsFrame
	local cardData = packData.cardData
	local numCards = #cardData
	if numCards == 0 then return end
	for _, data in ipairs(cardData) do
		local button = CardButton:Clone()
		button.Parent = cardsFrame
		local newCard = ClientCard.new(data.cardData, data.id)
		newCard.Parent = button
		newCard.AnchorPoint = Vector2.new(.5, .5)
		newCard.Position = UDim2.new(0.5, 0, .5, 0)
		newCard.Size = CARD_SIZE_BASE
		button.MouseButton1Click:Connect(function()
			self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.SELECT_CARD_REWARD, {id = data.id, cardData = data.cardData, upgraded = data.upgraded})
			self:hide()
			self._overlay:hide(newCard)
		end)
		button.MouseEnter:Connect(function()
			newCard:changeSize(CARD_SIZE_HOVER, false)
			self._overlay:show(newCard)
		end)
		button.MouseLeave:Connect(function()
			newCard:changeSize(CARD_SIZE_BASE, true)
			self._overlay:hide(newCard)
		end)
		self.cards[data.id] = newCard
	end
end

function CardPackGui:reset()
	for id, card in pairs(self.cards) do
		card:Destroy()
	end
	for _, frame in ipairs(self.object.ContainerFrame.CardsFrame:GetChildren()) do
		if frame.ClassName == CardButton.ClassName then
			frame:Destroy()
		end
	end
	self.cards = {}
end

function CardPackGui:show(data)
	self:reset()
	self:loadData(data)
	self.object.Enabled = true
end

function CardPackGui:hide()
	self.object.Enabled = false
end

return CardPackGui