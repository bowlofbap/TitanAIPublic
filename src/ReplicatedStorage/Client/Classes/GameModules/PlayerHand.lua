local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)

local PlayerHand = {}
PlayerHand.__index = PlayerHand


function PlayerHand.new()
	local newHand = setmetatable({}, PlayerHand)
	newHand.cards = {}
	return newHand	
end

function PlayerHand:add(card, position)
	if position then
		table.insert(self.cards, position, card)
	else
		table.insert(self.cards, card)
	end
end

function PlayerHand:remove(cardToRemove)
	for i, card in ipairs(self.cards) do
		if card == cardToRemove then
			self:_removeCard(i)	
			return true	
		end
	end
	warn("unable to find card ", cardToRemove, self.cards)
	return false
end

function PlayerHand:getAll()
	return self.cards
end

-- Remove a card by index (maintains order)
function PlayerHand:_removeCard(index)
	table.remove(self.cards, index)
end

return PlayerHand
