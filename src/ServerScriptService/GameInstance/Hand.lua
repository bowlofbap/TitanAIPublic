local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local Hand = {}
Hand.__index =  Hand

function Hand.new()
	local newHand = {}
	setmetatable(newHand, Hand)
	newHand.cards = {}
	newHand.cardById = {}
	return newHand
end

function Hand:add(card)
	local n = #self.cards
	local newCard = card
	table.insert(self.cards, newCard)
	self.cardById[card.id] = card
end

function Hand:remove(card)
	for i, c in ipairs(self.cards) do
		if (c == card) then
			self.cardById[card.id] = nil
			table.remove(self.cards, i)
			return true
		end
	end
	return false
end

function Hand:getCardById(id)
	return self.cardById[id]
end

--returns a shallow copy
function Hand:getCards()
	return Tables.shallowCopy(self.cards)
end

--to send up to client
function Hand:toTable()
	local t = {}
	for _, card in ipairs(self.cards) do
		table.insert(t, {name = card.name, id = card.id})
	end	
	return t
end

return Hand
