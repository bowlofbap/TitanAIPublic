local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)
local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local PlayerDeck = {}
PlayerDeck.__index = PlayerDeck

function PlayerDeck.new(cards, parent)
	local self = setmetatable({}, PlayerDeck)
	self.cards = {}
	self.cardsById = {}
	--{name = card.name, id = card.Id, place = card.place}
	self:swapDeck(cards)
	return self	
end

function PlayerDeck:draw(cardId)
	local cardToRemove = self.cardsById[cardId]
	if not cardToRemove then
		warn("No card found...", cardId)
		return
	end
	
	for i, card in ipairs(self.cards) do
		if card.Id == cardId then
			table.remove(self.cards, i)
		end
	end
	self.cardsById[cardId] = nil
	return cardToRemove
end

function PlayerDeck:getCardById(id)
	return self.cardsById[id]
end

function PlayerDeck:swapDeck(newDeck)
	self.cards = {}
	self.cardsById = {}
	for _, card in ipairs(newDeck) do
		table.insert(self.cards, card)
		self.cardsById[card.Id] = card
	end
end

return PlayerDeck
