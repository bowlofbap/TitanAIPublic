local RunService = game:GetService("RunService")
local ClientCard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientCard)
local DescriptionOverlay = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.Components.DescriptionOverlay)

local CardInfoOverlay = {}
CardInfoOverlay.__index = CardInfoOverlay

function CardInfoOverlay.new(parent)
	local self = setmetatable({}, CardInfoOverlay)
	self._currentCard = nil
	self._parent = parent
	self._renderConnection = nil
	return self 
end

function CardInfoOverlay:_reset()
	if self._currentCard then
		self._currentCard:Destroy()
		self._currentCard = nil
	end
	if self._renderConnection then
		self._renderConnection:Disconnect()
	end
end

function CardInfoOverlay:show(data, position: UDim2)
	if not self._currentCard then
		local newCard = ClientCard.new(data.data, data.cardId, data.upgraded)
		newCard.model.UISizeConstraint:Destroy()
		newCard.Parent = self._parent
		newCard.Size = UDim2.new(.1, 0, 1, 0)
		newCard.Position = UDim2.new(0, position.X.Offset - newCard.model.AbsoluteSize.X/2, 0, position.Y.Offset)
		newCard:adjustTransparency(0.1)
		self._currentCard = newCard
		
		local connection	
		local startTime = tick()
		connection = RunService.RenderStepped:Connect(function()
			local diffTime = tick() - startTime
			print(diffTime)
			if diffTime >= .3 then
				newCard:adjustTransparency(0.3)
				connection:Disconnect()
				self._renderConnection = nil
			end
		end)
		self._renderConnection = connection
	end
end

function CardInfoOverlay:hide()
	self:_reset()
end

return CardInfoOverlay 