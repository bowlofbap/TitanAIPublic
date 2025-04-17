local Card = require(game:GetService("ServerScriptService").GameInstance.Card)
local Deck = {}
Deck.__index =  Deck

function Deck.new(entityCards, idGenerator)
	local newDeck = {}
	setmetatable(newDeck, Deck)
	newDeck.cards = {}
	newDeck.cardByRef = {}
	newDeck.idGenerator = idGenerator
	newDeck:init(entityCards)
	return newDeck
end

--converts to a table of names and ids to send up to client
function Deck:serialize(hasPlace)
	local t = {}
	for i, card in ipairs(self.cards) do
		if hasPlace then
			table.insert(t, {cardData = card.cardData, id = card.id, upgraded = card.upgraded, place = i})
		else
			table.insert(t, {cardData = card.cardData, upgraded = card.upgraded, id = card.id})
		end
	end	
	return t
end

function Deck:getCardById(id)
	return self.cardByRef[id].card --fail gracefully
end

function Deck:canDraw()
	if #self.cards <= 0 then return false end
	return true
end

--the cards will come in an unordered table, so we will fake an order with ids and a lookup table
function Deck:init(entityCards)
	for _, entityCard in ipairs(entityCards) do
		local newCard = Card.new(entityCard)
		self:add(newCard)
	end
end

function Deck:shuffle()
	for i = #self.cards, 2, -1 do
		local j = math.random(1, i)
		self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
	end
	return self.cards
end

function Deck:draw()
	if not self:canDraw() then return nil end
	local card = table.remove(self.cards)
	return card
end

function Deck:add(card)
	self.cardByRef[card.id] = card
	table.insert(self.cards, card)
end

function Deck:remove(removeCard)
	for i, card in ipairs(self.cards) do
		if card == removeCard then
			table.remove(self.cards, i)
			self.cardsByRef[card.id] = nil
			return card
		end
	end
	return nil
end

function Deck:scry(n)
	local cards = {}
	--return all cards in deck if less than amount of cards to scry
	if #self.cards < n then
		return self.cards
	end
	for i = 1, n do
		local scryPlace = #self.cards - i + 1
		local card = self.cards[scryPlace].card
		table.insert(cards, card)
	end
	return cards
end

return Deck
