local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local Discard = {}
Discard.__index =  Discard

function Discard.new(cards)
	local newDiscard = {}
	setmetatable(newDiscard, Discard)
	newDiscard.cards = {}
	newDiscard.cardById = {} --lookup table so we can easily do the equivalent of cards[4]. 
	
	return newDiscard
end

function Discard:toTable()
	local t = {}
	for i, card in ipairs(self.cards) do
		table.insert(t, {name = card.name, id = card.id})
	end	
	return t
end

--the cards will come in an unordered table, so we will fake an order with ids and a lookup table
function Discard:add(card)
	local n = #self.cards
	table.insert(self.cards, card)
	self.cardById[card.id] = card
end

function Discard:remove(card)
	for i = 1, #self.cards do
		local c = self.cards[#self.cards-i+1]
		if c == card then
--			print("removed", c)
			self.cardById[card.id] = nil
			return table.remove(self.cards, #self.cards-i+1)
		end
	end
	warn("No card to remove", card)
	return nil
end

function Discard:getCardById(id)
	return self.cardById[id]
end

function Discard:getAll()
	return Tables.shallowCopy(self.cards)
end

return Discard
