local ScreenTransitionTypes = require(game:GetService("ReplicatedStorage").Enums.Client.ScreenTransitionTypes)

local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)

local TweenService = game:GetService("TweenService")

local player = game:GetService("Players").LocalPlayer

local TransitionGui = setmetatable({}, { __index = BaseGui }) 
TransitionGui.__index = TransitionGui

function TransitionGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, TransitionGui)
	
	local currentTween = nil
	local currentTweenEvent = nil

	return self
end

function TransitionGui:cancelCurrentTween()
	if self.currentTween then
		self.currentTween:Cancel()
	end
	if self.currentConnection then
		self.currentConnection:Disconnect()
		self.currentConnection = nil
	end
	self.currentTween = nil
end

function TransitionGui:show(transitionType)
	self:cancelCurrentTween()
	self.object.Enabled = true
	self.object.Frame.BackgroundTransparency = 1  -- Start from transparent
	if transitionType == ScreenTransitionTypes.INSTANT then
		self.object.Frame.BackgroundTransparency = 0
	elseif transitionType == ScreenTransitionTypes.FADE then
		local tween = TweenService:Create(self.object.Frame, TweenInfo.new(0.3), {
			BackgroundTransparency = 0
		})
		self.currentTween = tween
		tween:Play()
	end
end

function TransitionGui:hide(transitionType)
	self:cancelCurrentTween()

	if transitionType == ScreenTransitionTypes.INSTANT then
		self.object.Frame.BackgroundTransparency = 1
		self.object.Enabled = false
	elseif transitionType == ScreenTransitionTypes.FADE then
		local tween = TweenService:Create(self.object.Frame, TweenInfo.new(0.3), {
			BackgroundTransparency = 1
		})

		self.currentConnection = tween.Completed:Connect(function()
			self.currentConnection:Disconnect()
			self.object.Enabled = false
			self.currentConnection = nil  -- Clean up after completion
		end)

		self.currentTween = tween
		tween:Play()
	end
end

return TransitionGui