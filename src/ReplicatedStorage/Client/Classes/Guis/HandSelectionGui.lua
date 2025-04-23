local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)
local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)
local DescriptionOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.DescriptionOverlay)

local player = game:GetService("Players").LocalPlayer

local CardSelectionGui = setmetatable({}, { __index = BaseGui }) 
CardSelectionGui.__index = CardSelectionGui

SETTINGS = {
	BASE_SIZE = UDim2.new(.98, 0, .98, 0),
	HOVER_SIZE = UDim2.new(1.1, 0, 1.1, 0)
}

function CardSelectionGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, CardSelectionGui)
	self.cards = {}
	self._overlay = DescriptionOverlay.new()
	self:init()
	self._callback = nil
	self._selectedCards = {}
	return self
end

function CardSelectionGui:init()
	self.object.CancelButton.MouseButton1Click:Connect(function()
		self:hide()
		self._callback()
	end)
end

function CardSelectionGui:clickSelect(card)
	if table.find(self._selectedCards, card) then
		self:removeFromSelection(card)
	else
		self:addToSelection(card)
	end
end

function CardSelectionGui:addToSelection(card)
	table.insert(self._selectedCards, card)
	self:moveCardsToPosition()
end

function CardSelectionGui:removeFromSelection(card)
	table.insert(self._selectedCards, card)
	self:moveCardsToPosition()
end

function CardSelectionGui:moveCardsToPosition()
	for _, card in ipairs(self._selectedCards) do

	end
end

function CardSelectionGui:show(cardsData, callback)
	self._callback = callback
	self.object.Enabled = true
end

function CardSelectionGui:hide()
	self.object.Enabled = false
end

return CardSelectionGui