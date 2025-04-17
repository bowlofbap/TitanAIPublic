local EntityCard = require(game:GetService("ServerScriptService").GameEntity.EntityCard)

local DeckManager = {}
DeckManager.__index =  DeckManager

--[[
cardData = {
	{
		amount = x,
		cardName = name,
		upgraded = bool
	}
}
]]
function DeckManager.new(deckData, idGenerator)
	local self = setmetatable({}, DeckManager)
	self.idGenerator = idGenerator
	self._cards = {}
	self:init(deckData)
	return self
end

function DeckManager:destroy()
	self.idGenerator = nil
	for _, card in pairs(self._cards) do
		card:destroy()
	end
end

function DeckManager:_createNewCardFromName(cardData)
	local id = self.idGenerator:gen()
	local entityCard = EntityCard.new(cardData.cardName, cardData.upgraded, id)
	self._cards[id] = entityCard
end

--[[
data = {
	cardData = cardData,
	id = id,
	upgraded = upgraded
}
]]
function DeckManager:_createNewCard(data)
	local entityCard = EntityCard.new(data.cardData.key, data.cardData.upgraded, data.id)
	self._cards[data.id] = entityCard
	return entityCard
end

function DeckManager:init(deckData)
	for _, cardData in ipairs(deckData) do
		for i = 1, cardData.amount do
			self:_createNewCardFromName(cardData)
		end
	end
end

function DeckManager:getCardById(id)
	if self._cards[id] then
		return self._cards[id]
	end
	warn("No card found with id ", id)
	return nil
end

function DeckManager:upgradeCardById(id)
	local card = self:getCardById(id)
	if not card.upgraded then
		card:upgrade()
		return card
	end
	warn("Card was already upgraded", card)
	return card
end

function DeckManager:getUpgradeableCardData() 
	local cards = {}
	for id, card in pairs(self._cards) do
		if not card.upgraded then
			table.insert(cards, card:serialize())
		end
	end
	return cards
end

function DeckManager:getPlayableDeck()
	local cards = {}
	for id, card in pairs(self._cards) do
		table.insert(cards, card)
	end
	return cards
end

function DeckManager:addCard(data)
	return self:_createNewCard(data)
end

function DeckManager:serialize()
	local deck = {}
	for id, card in pairs(self._cards) do
		table.insert(deck, card:serialize())
	end
	return deck
end

return DeckManager
