local Deck = require(game:GetService("ServerScriptService").GameInstance.Deck)
local Discard = require(game:GetService("ServerScriptService").GameInstance.Discard)
local Hand = require(game:GetService("ServerScriptService").GameInstance.Hand)

local GamePlayer = {}
GamePlayer.__index = GamePlayer

function GamePlayer.new(robloxPlayer, playerState, deckData, idGenerator)
	local self = setmetatable({}, GamePlayer)
	self.robloxPlayer = robloxPlayer
	self.turnCards = playerState.handSize
	self.energy = playerState.turnEnergy
	self.movement = playerState.turnMovement
	self.turnEnergy = playerState.turnEnergy
	self.turnMovement = playerState.turnMovement
	self.unit = nil
	self.discard = Discard.new()
	self.hand = Hand.new()
	self.deck = Deck.new(deckData, idGenerator)
	self.executingCard = false
	return self
end

--returns the new card and also if the deck had to be shuffled or not
function GamePlayer:draw()
	local drawnCard = self.deck:draw()
	if drawnCard then
		self.hand:add(drawnCard)
		return drawnCard
	else
		warn("couldn't draw card")
		return nil
	end
end

function GamePlayer:resetDeck()
	local discardCards = self.discard:getAll()
	for _, card in discardCards do
		self.discard:remove(card)
		self.deck:add(card)
	end
	self.deck:shuffle()
end

function GamePlayer:grantEnergy(value)
	self.energy += value
end

function GamePlayer:replenishEnergy()
	if self.energy < self.turnEnergy then
		self.energy = self.turnEnergy
	end
end

function GamePlayer:replenishMovement()
	local currentMovement = self.movement
	if self.movement < self.turnMovement then
		self:gainMovement(self.turnMovement)
		if self.movement > self.turnMovement then
			self.movement = self.turnMovement
		end
	end
	return self.movement - currentMovement
end

function GamePlayer:gainMovement(value)
	self.movement += value
	return value
end

function GamePlayer:canPlayCard(cardToPlay)
	if cardToPlay.cardData.cost > self.energy then 
		return false, "Not enough energy"
	end
	if self.executingCard then
		return false, "Executing card"
	end
	return true
end

function GamePlayer:canEndTurn()
	if self.executingCard then
		return false, "Executing card"
	end
	return true
end

function GamePlayer:canMove()
	if self.movement <= 0 then 
		return false, "Not enough movement points"
	end
	if self.executingCard then
		return false, "executing card"
	end
	return true
end

function GamePlayer:payMovementCost()
	self.movement -= 1
	if self.movement < 0 then
		self.movement = 0
	end
end

function GamePlayer:discardCard(card)
	self.hand:remove(card)
	self.discard:add(card)
end

function GamePlayer:payCost(card)
	--add hook here for the card if there are more things to pay costs for, like health
	local cardCost = card.cardData.cost
	self.energy -= cardCost
	return cardCost
end

function GamePlayer:getHand()
	return self.hand.cards
end

return GamePlayer
