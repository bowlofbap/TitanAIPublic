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
	return self
end

function CardSelectionGui:init()
	self.object.CloseFrame.TextButton.MouseButton1Click:Connect(function()
		self:hide()
	end)
end

function CardSelectionGui:updateCardPositions(cardsData, callback)
	local scrollingFrame = self.object.ContainerFrame.ScrollingFrame
	local numCards = #cardsData
	if numCards == 0 then return end
	local rows = math.ceil(numCards/5)
	scrollingFrame.UIGridLayout.CellSize = UDim2.new(.15, 0, 1/rows, 0)
	scrollingFrame.UIPadding.PaddingBottom = UDim.new(0, 20 * rows)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, rows-1, 0)
	
	for _, data in ipairs(cardsData) do
		local button = Instance.new("TextButton")
		button.Text = ""
		button.BackgroundTransparency = 1
		button.Parent = scrollingFrame
		
		local newCard = ClientCard.new(data.cardData, data.id, data.upgraded)
		newCard.Parent = button
		newCard.model.UISizeConstraint:Destroy()
		newCard.model.UIAspectRatioConstraint.Parent = button
		newCard.Size = SETTINGS.BASE_SIZE
		newCard.AnchorPoint = Vector2.new(.5, .5)
		newCard.Position = UDim2.new(.5, 0, .5, 0)
		local function onEnter()
			newCard:changeSize(SETTINGS.HOVER_SIZE, false)
			self._overlay:show(newCard)
		end
		
		local function onLeave()
			newCard:changeSize(SETTINGS.BASE_SIZE, true)
			self._overlay:hide(newCard)
		end
		newCard:setHoverCallbacks(onEnter, onLeave)
		newCard:enableHover()
		
		
		if callback then
			button.MouseButton1Click:Connect(function()
				callback(data.id)
			end)
		end
		
		table.insert(self.cards, button)
	end
end

function CardSelectionGui:reset()
	for _, card in ipairs(self.cards) do
		card:Destroy()
	end
	self.cards = {}
end

function CardSelectionGui:show(cardsData, callback)
	if self.clientPlayer:getCurrentInstance() and self.clientPlayer:getCurrentInstance().isPaused then 
		self.clientPlayer:getCurrentInstance().isPaused.Value = true
	end
	self:reset()
	self:updateCardPositions(cardsData, callback)
	self.object.Enabled = true
end

function CardSelectionGui:hide()
	if self.clientPlayer:getCurrentInstance() and self.clientPlayer:getCurrentInstance().isPaused then
		self.clientPlayer:getCurrentInstance().isPaused.Value = false
	end
	self.object.Enabled = false
end

return CardSelectionGui