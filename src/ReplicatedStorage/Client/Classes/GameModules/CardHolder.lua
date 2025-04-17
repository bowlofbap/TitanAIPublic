local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)
local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent
local DescriptionOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.DescriptionOverlay)

local CardHolder = {}
CardHolder.__index = CardHolder

function CardHolder.new(deckData, parent, handLayoutManager)
	local self = setmetatable({}, CardHolder)
	self.cards = {}
	self.cardsById = {}
	self._descriptionOverlay = DescriptionOverlay.new()
	--{name = card.card.name, id = card.card.id, place = card.place}
	for _, data in ipairs(deckData) do
		local newCard = ClientCard.new(data.cardData, data.id, data.upgraded)
		newCard.Name = data.cardData.key
		newCard.Parent = parent
		local function onEnter()
			newCard.isHovered = true
			self._descriptionOverlay:show(newCard)
			handLayoutManager:updateLayout()
		end
		
		local function onLeave()
			newCard.isHovered = false	
			self._descriptionOverlay:hide(newCard)
			handLayoutManager:updateLayout()
		end
		newCard:setHoverCallbacks(onEnter, onLeave)
		
		table.insert(self.cards, newCard)
		self.cardsById[data.id] = newCard
	end
	return self	
end

function CardHolder:removeCardById(cardId)
	for i, card in ipairs(self.cards) do
		if card.Id == cardId then
			table.remove(self.cards, i)
			self.cardsById[cardId] = nil
		end
	end
end

function CardHolder:getCardById(id)
	return self.cardsById[id]
end

function CardHolder:getAllCards()
	return self.cards
end

return CardHolder
