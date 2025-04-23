local HandLayoutManager = {}
HandLayoutManager.__index = HandLayoutManager

function HandLayoutManager.new(battleGui)
	local self = setmetatable({}, HandLayoutManager)

	self._battleGui = battleGui
	self._cards = {}
	return self
end

function HandLayoutManager:addCard(card)
	table.insert(self._cards, card)
	card.Parent = self._battleGui.CardsFrame
	self:updateLayout()
end

function HandLayoutManager:discardCard(card)
	self:removeCard(card)
	card.Parent = self._battleGui.HoldingFrame
	self:updateLayout()
end

function HandLayoutManager:removeCard(card)
	for i, c in ipairs(self._cards) do
		if c == card then
			table.remove(self._cards, i)
			break
		end
	end
	card.Parent = self._battleGui.HoldingFrame
	self:updateLayout()
end

function HandLayoutManager:updateLayout()
	local count = #self._cards
	local spacing = 120
	local startX = -((count - 1) * spacing) / 2

	for index, card in ipairs(self._cards) do
		local xOffset = startX + (index - 1) * spacing
		local pos = UDim2.new(0.5, xOffset, 1, -150)

		card.ZIndex = 10 + index

		if card.isHovered then
			pos = pos - UDim2.new(0, 0, 0, 120)
			card.ZIndex = 100
		end

		card:moveTo(pos)
	end
end

return HandLayoutManager
