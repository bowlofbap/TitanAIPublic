local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)
local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent
local GameActions = require(game:GetService("ReplicatedStorage").Enums.GameActions)
local GamePhases = require(game:GetService("ReplicatedStorage").Enums.GamePhases)
local DescriptionOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.DescriptionOverlay)
local CardInfoOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.CardInfoOverlay)
local TweenService = game:GetService("TweenService")

local player = game:GetService("Players").LocalPlayer

local BattleGui = setmetatable({}, { __index = BaseGui }) 
BattleGui.__index = BattleGui

local i = 0
function BattleGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, BattleGui)
	self._overlay = DescriptionOverlay.new(self.object)
	self._cardInfoOverlay = CardInfoOverlay.new(self.object)
	return self
end

--called from the client player once the game starts
function BattleGui:updateConnections()
	self.object.TurnButtonFrame.TextButton.MouseButton1Click:Connect(function()
		local success = self.clientPlayer:getEntity():getCurrentInstance():requestGameAction(GameActions.END_TURN)
		if success then
			print("success")
			--TODO: indicate whatever
		end
	end)
	self.object.DeckFrame.Button.MouseButton1Click:Connect(function()
		local cards = {}
		local deckCards = self.clientPlayer:getEntity():getCurrentInstance().playerDeck.cards
		for _, card in ipairs(deckCards) do
			table.insert(cards, {id = card.id, cardData = card.data, upgrade = card.upgraded})
		end
		GuiEvent:Fire("CardSelectionGui", "show", cards)
	end)
	
	self.object.DiscardFrame.Button.MouseButton1Click:Connect(function()
		local cards = {}
		local deckCards = self.clientPlayer:getEntity():getCurrentInstance().playerDiscard.cards
		for _, card in ipairs(deckCards) do
			table.insert(cards, {id = card.id, cardData = card.data, upgraded = card.upgraded})
		end
		GuiEvent:Fire("CardSelectionGui", "show", cards)
	end)
end

function BattleGui:changePhase(data)
	local button = self.object.TurnButtonFrame.TextButton
	if data.phase == GamePhases.ENEMY_TURN then
		button.Active = false
		button.Text = data.phase
		button.Parent.BackgroundTransparency = 0.5
	elseif data.phase == GamePhases.PLAYER_TURN then
		button.Active = true
		button.Text = data.phase
		button.Parent.BackgroundTransparency = 0
	end
end

function BattleGui:updateFrames(updateData)
	for propertyToUpdateName, data in pairs(updateData) do
		local frame = self.object[propertyToUpdateName.."Frame"]
		if propertyToUpdateName == "Energy" or propertyToUpdateName == "Movement" then
			frame.Label.Text = data.currentValue.."/"..data.turnValue
		elseif propertyToUpdateName == "Deck" or propertyToUpdateName == "Discard" then
			frame.Label.Text = data.value
		end
	end
end

function BattleGui:getDeckScreenPosition()
	-- Convert deck position to screen space coordinates
	local deckFrame = self.object.DeckFrame
	local parent = deckFrame.Parent
	local parentSize = parent.AbsoluteSize

	return UDim2.new(
		(deckFrame.AbsolutePosition.X + deckFrame.AbsoluteSize.X/2) / parentSize.X,
		0,
		(deckFrame.AbsolutePosition.Y + deckFrame.AbsoluteSize.Y/2) / parentSize.Y,
		0
	)
end

function BattleGui:addCard(cardModel)
	local TweenService = game:GetService("TweenService")

	-- Store initial deck position first
	cardModel.Parent = self.object.CardsFrame
	cardModel.AnchorPoint = Vector2.new(0.5, 1)
	cardModel.Position = self:getDeckScreenPosition() -- Start position
	cardModel.Rotation = -30 -- Initial rotation
	cardModel.Visible = true
	cardModel.ZIndex = 20 -- Higher than other cards during animation

	-- Force immediate layout update to get target position
	self:updateCardPositions(false) -- Skip animation for all cards
	local targetPos = cardModel.Position
	local targetRot = cardModel.Rotation

	-- Reset to deck position before animating
	cardModel.Position = self:getDeckScreenPosition()
	cardModel.Rotation = -30

	-- Animate just the new card
	local tween = TweenService:Create(cardModel, TweenInfo.new(0.22, Enum.EasingStyle.Linear), {
		Position = targetPos,
		Rotation = targetRot,
		ZIndex = 1 -- Reset to normal after animation
	})

	-- After new card animation, update others
	tween.Completed:Connect(function()
		self:updateCardPositions(false, cardModel:GetAttribute("Id")) -- Animate others except new card
	end)

	tween:Play()
end

function BattleGui:calculateCardPosition(totalCards, index)
	local centerIndex = math.ceil(totalCards / 2)
	local maxAngle = 20
	local maxSpread = 0.5
	local verticalOffset = 30

	local normalizedPosition = (index - centerIndex) / math.max(1, totalCards)
	local xScale = 0.5 + (normalizedPosition * maxSpread)
	local rotation = normalizedPosition * maxAngle
	local yOffset = math.abs(normalizedPosition) * verticalOffset

	return UDim2.new(xScale, 0, 1, 100 + yOffset), rotation
end


function BattleGui:updateCardPositions(skipAnimation, exceptionId)
	--[[
	local cards = self.clientPlayer:getEntity():getCurrentInstance().playerHand.cards
	local cardCount = #cards
	for i, cardData in ipairs(cards) do
		if exceptionId and cardData.Id == exceptionId then continue end
		if cardData._isDragging then continue end
		local card = cardData.model

		local targetPos, targetRot = self:calculateCardPosition(cardCount, i)
		cardData:updateBaseProperties(targetPos, targetRot, i)

		if not skipAnimation then
			if card.Position ~= targetPos or card.Rotation ~= targetRot then
				local tween = TweenService:Create(card, TweenInfo.new(0.3), {
					Position = targetPos,
					Rotation = targetRot,
					ZIndex = cardData.baseProperties.ZIndex
				})
				tween:Play()
			end
		else
			card.Position = targetPos
			card.Rotation = targetRot
			card.ZIndex = cardData.baseProperties.ZIndex
		end
	end]]
end

function BattleGui:playCard(cardId)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(cardId)
	local cardModel = card.model
	self:updateCardPositions()
	local duration = .22
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local screenSize = workspace.CurrentCamera.ViewportSize
	local centerPos = UDim2.new(.5, 0, 0.5,  cardModel.AbsoluteSize.Y/4)
	local tween = TweenService:Create(cardModel, tweenInfo, { Position = centerPos, Rotation = 0})
	tween:Play()
end

function BattleGui:depleteCard(cardId)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(cardId)
	self.clientPlayer:getEntity():getCurrentInstance().cardHolder:removeCardById(cardId)
	local completed = card:fadeOut(.3)
	completed:Connect(function()
		card:Destroy()
	end)
end

function BattleGui:deployUnit(cardId)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(cardId)
	card.Parent = self.object.HoldingFrame
end

function BattleGui:discardCard(card)
	local discardFrame = self.object.DiscardFrame
	-- Ensure the card is set up for proper rotation
	card.AnchorPoint = Vector2.new(0.5, 0.5) -- Center anchor for rotation
	card.Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset, card.Position.Y.Scale, card.Position.Y.Offset)

	-- Get positions in screen space
	local cardAbsolutePos = card.AbsolutePosition
	local discardAbsolutePos = discardFrame.AbsolutePosition

	-- Calculate direction vector
	local direction = discardAbsolutePos - cardAbsolutePos
	local rotationAngle = math.deg(math.atan2(direction.Y, direction.X)) + 90

	-- Calculate target position relative to discard frame's parent
	local parent = discardFrame.Parent
	local discardPosition = discardFrame.Position
	local targetPosition = discardPosition

	-- Create tween properties
	local tweenInfo = TweenInfo.new(
		0.5, -- Duration
		Enum.EasingStyle.Quad, -- Easing style
		Enum.EasingDirection.Out, -- Easing direction
		0, -- Repeat count
		false -- No reverse
	)

	local tweenProperties = {
		Position = targetPosition,
		Rotation = rotationAngle,
	}

	-- Create and play the tween
	local cardTween = TweenService:Create(card, tweenInfo, tweenProperties)
	cardTween:Play()
	
	cardTween.Completed:Connect(function()
		card.Parent = self.object.HoldingFrame
	end)

	self:updateCardPositions()
end

function BattleGui:showOverlay(cardId)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(cardId)
	self._overlay:show(card)
end

function BattleGui:hideOverlay(cardId)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(cardId)
	self._overlay:hide(card)
end

function BattleGui:hoverCard(id)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(id)
	card.Position = UDim2.new(card.Position.X.Scale, 0, card.Position.Y.Scale, 0)
	card.ZIndex = 99
	card.Rotation = 0
	self:showOverlay(id)
end

function BattleGui:unhoverCard(id)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(id)
	card.Position = card.baseProperties.Position
	card.Rotation = card.baseProperties.Rotation
	card.ZIndex = card.baseProperties.ZIndex
	self:hideOverlay(id)	
end

function BattleGui:showCardInfo(cardId, position)
	local card = self.clientPlayer:getEntity():getCurrentInstance().cardHolder:getCardById(cardId)
	self._cardInfoOverlay:show(card:serialize(), position)
end

function BattleGui:hideCardInfo()
	self._cardInfoOverlay:hide()
end

function BattleGui:reset()
	self.object.CardsFrame:ClearAllChildren()
end

return BattleGui