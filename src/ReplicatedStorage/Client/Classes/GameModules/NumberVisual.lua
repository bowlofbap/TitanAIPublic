local TweenService = game:GetService("TweenService")

local NumberTypes = require(game:GetService("ReplicatedStorage").Enums.GameInstance.NumberTypes)

local NumberVisual = {}
NumberVisual.__index = NumberVisual

function NumberVisual.new(value, numberType, unit)
	local self = setmetatable({}, NumberVisual)
	self._value = value
	self._numberType = numberType
	self._unit = unit

	local DamageNumberTemplate = Instance.new("BillboardGui")
	DamageNumberTemplate.Name = "DamageNumber"
	DamageNumberTemplate.AlwaysOnTop = true
	DamageNumberTemplate.Size = UDim2.new(4, 0, 2, 0) -- Adjust based on text size
	DamageNumberTemplate.StudsOffset = Vector3.new(0, 2, 0.1) -- Start above the head
	DamageNumberTemplate.Enabled = false

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = self._value
	TextLabel.TextColor3 = self._numberType.COLOR
	TextLabel.TextStrokeTransparency = 0.3
	TextLabel.BackgroundTransparency = 1
	TextLabel.Font = Enum.Font.Fantasy
	TextLabel.TextSize = 120
	TextLabel.Parent = DamageNumberTemplate
	self._gui = DamageNumberTemplate
	return self
end

function NumberVisual:play()
	self._gui.Enabled = true
	local head = self._unit:getBoneFromName("Head")
	if not head then return end
	self._gui.Parent = head

	-- Arc animation: move upward, then curve down
	local startOffset = Vector3.new(0, 0, 0.1) -- Start position
	local endOffset = Vector3.new(0, -3, 0.1) -- End position (below)
	if self._numberType == NumberTypes.SHIELD_DAMAGE then
		endOffset = Vector3.new(0, 3, 0.1) -- End position (below)
	end
	local midOffset = Vector3.new(math.random(-1, 1), 3, 0) -- Random horizontal arc

	-- Tween the position using a quadratic curve (ease-in-out)
	local tweenInfo = TweenInfo.new(
		.6, -- Duration (seconds)
		Enum.EasingStyle.Quad, -- Easing style
		Enum.EasingDirection.Out
	)

	-- Animate StudsOffset (arc motion)
	local movementTween = TweenService:Create(self._gui,tweenInfo,
		{
			StudsOffset = endOffset,
		}
	)
	
	-- Animate StudsOffset (arc motion)
	local transparencyTween = TweenService:Create(self._gui.TextLabel,tweenInfo,
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	)

	-- Start the animation and destroy the GUI afterward
	movementTween:Play()
	transparencyTween:Play()
	movementTween.Completed:Connect(function()
		self._gui:Destroy()
	end)
end

return NumberVisual
