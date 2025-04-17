local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)

local PlayerDiscard = {}
PlayerDiscard.__index = PlayerDiscard


function PlayerDiscard.new()
	local self = setmetatable({}, PlayerDiscard)
	self.cards = {}
	return self	
end

function PlayerDiscard:add(card, position)
	if position then
		table.insert(self.cards, position, card)
	else
		table.insert(self.cards, card)
	end
end

-- Remove a card by index (maintains order)
function PlayerDiscard:_removeCard(index)
	table.remove(self.cards, index)
end

function PlayerDiscard:swapDiscard(cards)
	self.cards = cards
end

function PlayerDiscard:remove(cardToRemove)
	for i, card in ipairs(self.cards) do
		if card == cardToRemove then
			self:_removeCard(i)	
			return true	
		end
	end
	warn("unable to find card ".. cardToRemove, self.cards)
	return false
end

return PlayerDiscard
