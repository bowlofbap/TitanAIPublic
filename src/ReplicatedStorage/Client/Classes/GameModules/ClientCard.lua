local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardUi = ReplicatedStorage.Models.UI.Card
local TextProcessor = require(ReplicatedStorage.Helpers.TextProcessor)
local EffectTypes = require(ReplicatedStorage.Enums.EffectTypes)
local TargetTypes = require(ReplicatedStorage.Enums.TargetTypes)
local CardAnimations = ReplicatedStorage.Client.CardAnimations
local CardTypes = require(ReplicatedStorage.Enums.CardTypes)

local ClientCard = {}
ClientCard.__index = ClientCard

--[[
data comes in as
{
	name: name
	id: id
}
]]

local changeableProperties = {
	Parent = true,
	Name = true,
	Position = true,
	Rotation = true,
	AnchorPoint = true,
	ZIndex = true,
	Size = true
}

function ClientCard.new(data, cardId, upgraded)
	local self = setmetatable({}, ClientCard)
	self.model = CardUi:Clone()
	self.data = data
	local stringName = self.data.stringName
	local cost = self.data.cost
	local range = self.data.range
	local description = self.data.description
	self.model:SetAttribute("Id", cardId)
	
	self._indicatorAnimation = nil
	self.isHovered = false
	self._hoverConnection = nil --used for the connection of the card itself
	self._leaveConnection = nil
	self._onHoverEnter = nil --used to hold the functions for the hover connections
	self._onHoverLeave = nil
	
	if upgraded then
		self.upgraded = true
		stringName = stringName .. "+"
		if data.upgradeDescription then
			description = data.upgradeDescription
		end
	end
	
	self.model.TransparencyGroup.NameFrame.Label.Text = stringName
	self.model.TransparencyGroup.ImageFrame.ImageLabel.Image = self.data.image
	self.model.TransparencyGroup.NameBackground.ImageColor3 = data.rarity.color
	self.model.EnergyFrame.Label.Text = cost
	self.model.RangeFrame.Label.Text = range
	self.description = description
	
	if self.data.range == 0 then
		self.model.RangeFrame.Visible = false
	end
	
	if self.data.cardType == CardTypes.DEPLOY then
		self.model.HealthFrame.Label.Text = self.data.effects[1].health
		self.model.HealthFrame.Visible = true
	end
	
	self.baseProperties = {
		Rotation = nil,
		Position = nil,
		ZIndex = nil,
	}

	local mt = {
		__index = function(table, key)
			if changeableProperties[key] or key == "AbsoluteSize" then
				return self.model[key]
			elseif key == "Id" then
				return self.model:GetAttribute("Id")
			else
				return ClientCard[key]
			end
		end,
		__newindex = function(table, key, value)
			if changeableProperties[key] then
				self:_onPropertyChanged(key, value)
			elseif key == "Id" then
				self:_onAttributeChanged(key, value)
			else
				rawset(self, key, value) 
			end
		end
	}
	setmetatable(self, mt) 
	
	self:updateTextAndKeywords()
	return self
end

function ClientCard:adjustTransparency(value)
	self.model.TransparencyGroup.GroupTransparency = value
	for _, descendant in ipairs(self.model:GetDescendants()) do
		if descendant:IsA("GuiObject") and descendant:GetAttribute("AdjustableTransparency") then
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				descendant.TextTransparency = value
			end

			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				descendant.ImageTransparency = value
			end
		end
	end
end

function ClientCard:updateBaseProperties(position, rotation, zindex)
	if position then
		self.baseProperties.Position = position
	end
	if rotation then
		self.baseProperties.Rotation = rotation
	end
	if zindex then
		self.baseProperties.ZIndex = zindex
	end
end

--shouldn't do any logic on the client side
function ClientCard:isDepletable()
	for _, effectData in ipairs(self.data.effects) do
		if effectData.effectType == EffectTypes.DEPLETE then
			if effectData.upgrade and not self.upgraded then return false end
			if effectData.removeOnUpgrade and self.upgraded then return false end
			return true
		end
	end
	return false
end

function ClientCard:isDraggable()
	return not (self.data.targetType == TargetTypes.SELECT_UNIT or self.data.targetType == TargetTypes.SELECT_NODE)
end

function ClientCard:playAnimationAndWait(context)
	local animationClassName = self.data.animationClass
	if animationClassName then
		local animateFunction = CardAnimations:FindFirstChild(animationClassName)
		return require(animateFunction).play(context)
	else
		warn("No animation for card ", self)
	end
end

function ClientCard:runHoverFunction() -- we have these manual functiosn that can be called externally because sometimes we want to simulate a hover without going through the mouseEnter function (aka when we're in battle because for some reason roblxo doesn't allow input sinking)
	if self._onHoverEnter then self:_onHoverEnter() end
end

function ClientCard:runHoverLeaveFunction()
	if self._onHoverLeave then self:_onHoverLeave() end
end

function ClientCard:setHoverCallbacks(onEnter:(()->())?, onLeave:(()->())?)
	self._onHoverEnter = onEnter
	self._onHoverLeave = onLeave
end

function ClientCard:enableHover()
	if self._hoverConnection then return end

	self._hoverConnection = self.model.MouseEnter:Connect(function()
		self:runHoverFunction()
	end)

	self._leaveConnection = self.model.MouseLeave:Connect(function()
		self:runHoverLeaveFunction()
	end)
end

function ClientCard:disableHover()
	if self._hoverConnection then
		self._hoverConnection:Disconnect()
		self._hoverConnection = nil
	end
	if self._leaveConnection then
		self._leaveConnection:Disconnect()
		self._leaveConnection = nil
	end
end

function ClientCard:isPlayable()
	return true
end

function ClientCard:showPlayable()
	if self._indicatorAnimation then return end
	local indicatorContainer = self.model.IndicatorContainer
	local uiGradient = indicatorContainer.IndicatorFrame:WaitForChild("UIGradient")

	local RunService = game:GetService("RunService")

	local shimmerSpeed = 1.75
	local offset = -1

	self._indicatorAnimation = RunService.RenderStepped:Connect(function(dt)
		offset = offset + dt * shimmerSpeed
		if offset > 1 then
			offset = -1
		end

		uiGradient.Offset = Vector2.new(offset, 0)
	end)
	indicatorContainer.Visible = true
end

function ClientCard:hidePlayable()
	if not self._indicatorAnimation then return end
	local indicatorContainer = self.model.IndicatorContainer
	indicatorContainer.Visible = false
	self._indicatorAnimation:Disconnect()
	self._indicatorAnimation = nil
end

function ClientCard:updateTextAndKeywords()
	local description, keywords = self:getKeywords()
	description = TextProcessor.ProcessText(description, self.data)
	self.model.TransparencyGroup.DescriptionFrame.Label.Text = description
end

function ClientCard:getKeywords()
	local description = self.description
	local keywords 
	if self:isDepletable() then
		description = TextProcessor.AddDepleteText(description, self)
	end
	description, keywords = TextProcessor.ProcessKeyWords(description, self.data)
	--TODO: join the data.extrakeywords table as well
	return description, keywords
end

function ClientCard:fadeOut(duration)
	local root = self.model
	local completedEvent = Instance.new("BindableEvent")

	-- Recursive collection of GUI objects
	local targets = {}
	local function gatherObjects(obj)
		if obj:IsA("GuiObject") then
			table.insert(targets, obj)
		end
		for _, child in ipairs(obj:GetChildren()) do
			gatherObjects(child)
		end
	end
	gatherObjects(root)

	-- Create tween info
	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	-- Track completed tweens
	local tweensCompleted = 0
	local totalTweens = #targets

	local function handleTweenCompletion()
		tweensCompleted += 1
		if tweensCompleted == totalTweens then
			completedEvent:Fire()
			completedEvent:Destroy()
		end
	end

	local tweenGoals = {
		Frame = {
			BackgroundTransparency = 1,
		},
		TextLabel = {
			BackgroundTransparency = 1,
			TextTransparency = 1,
			TextStrokeTransparency = 1
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			ImageTransparency = 1,
		},
	}
	-- Create and play tweens
	for _, guiObject in ipairs(targets) do
		local tween = TweenService:Create(guiObject, tweenInfo, tweenGoals[guiObject.ClassName])

		tween.Completed:Connect(handleTweenCompletion)
		tween:Play()
	end

	return completedEvent.Event
end

function ClientCard:changeSize(size, doTween)
	if doTween then
		local tweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local shrinkTween = TweenService:Create(self.model, tweenInfo, {Size = size})
		return shrinkTween:Play()
	else
		self.model.Size = size
	end
end

function ClientCard:Destroy()
	self.model:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

function ClientCard:_onPropertyChanged(key, value)
	self.model[key] = value
end

function ClientCard:_onAttributeChanged(key, value)
	self.model:SetAttribute(key, value)
end

function ClientCard:serialize()
	return {
		data = self.data, 
		id = self.Id, 
		upgraded = self.upgraded 
	}
end

return ClientCard
