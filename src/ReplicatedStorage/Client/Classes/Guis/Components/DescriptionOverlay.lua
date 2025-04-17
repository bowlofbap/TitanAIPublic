local RunService = game:GetService("RunService")
local Template = game:GetService("ReplicatedStorage").Models.UI.KeywordBackground
local Player = game:GetService("Players").LocalPlayer

local DescriptionOverlay = {}
DescriptionOverlay.__index = DescriptionOverlay

function DescriptionOverlay.new()
	local self = setmetatable({}, DescriptionOverlay)
	local frame = Instance.new("Frame")
	local listLayout = Instance.new("UIListLayout")
	frame.BackgroundTransparency = 1
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = frame
	self.object = frame
	self._currentCard = nil
	self._renderConnection = nil
	self.keywordFrames = {}
	return self 
end

function DescriptionOverlay:_reset()
	for _, frame in ipairs(self.keywordFrames) do
		frame:Destroy()
	end
	if self._renderConnection then
		self._renderConnection:Disconnect()
	end
	self.keywordFrames = {}
end

function DescriptionOverlay:show(card)
	self:_reset()
	local _, keywords = card:getKeywords()
	if #keywords < 1 then
		self:hide()
		return
	end
	local model: Frame = card.model
	local size = model.AbsoluteSize
	self.object.Size = UDim2.new(0, size.X, 0, size.Y/4)
	for _, keyword in ipairs(keywords) do
		local newFrame = Template:Clone()
		newFrame.DescriptionLabel.Text = keyword.description
		newFrame.NameLabel.Text = keyword.name
		newFrame.Parent = self.object
		table.insert(self.keywordFrames, newFrame)
	end
	self.object.Visible = true
	self._currentCard = card
	local connection	
	connection = RunService.RenderStepped:Connect(function()
		local position = model.AbsolutePosition
		--self.object.Position = self.object.Position:Lerp(UDim2.new(0, position.X + size.X, 0, position.Y), 1)
		self.object.Position = UDim2.new(0, position.X + size.X, 0, position.Y + size.Y/4) 
	end)
	self._renderConnection = connection
	self.object.Parent = Player.PlayerGui.OverlayGui
end

function DescriptionOverlay:hide(card)
	if card == self._currentCard or not card then
		self.object.Visible = false
	end
end

return DescriptionOverlay 