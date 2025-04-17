local EchoFrame = game:GetService("ReplicatedStorage").Models.UI.EchoFrame

local TextProcessor = require(game:GetService("ReplicatedStorage").Helpers.TextProcessor)

local EntityDataRequests = require(game:GetService("ReplicatedStorage").Enums.Entity.EntityDataRequests)
local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)

local TweenService = game:GetService("TweenService")

local player = game:GetService("Players").LocalPlayer

local GameEntityGui = setmetatable({}, { __index = BaseGui }) 
GameEntityGui.__index = GameEntityGui

function GameEntityGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, GameEntityGui)
	self._echoFrames = {}
	return self
end
--[[
we could break this out into its own object..
Echo.data = {
	stringName = "Energize",
	description = "Gain {value} Max Health at the start of combat",
	image = "rbxassetid://78494366360008",
	value = 5,
	countable = false
}--]]

function GameEntityGui:reset()
	for _, frame in ipairs(self.object.EchoesFrame:GetChildren()) do
		if frame.ClassName == "Frame" then
			frame:Destroy()
		end
	end
end

function GameEntityGui:updateEchoCount(id, count)
	local frame = self._echoFrames[id]
	if not frame then
		warn("Frame for id doesnt exist")
		return
	end
	frame.ImageLabel.CountLabel.Text = count
	if count == 0 then
		frame.ImageLabel.CountLabel.Visible = false
	else
		frame.ImageLabel.CountLabel.Visible = true
	end
end

--TODO: potentially make an echo its own object?
function GameEntityGui:addEcho(data)
	local newFrame = EchoFrame:Clone()
	newFrame.ImageLabel.Image = data.echoData.image
	newFrame.ImageLabel.Size = UDim2.new(.6, 0, .6, 0)
	newFrame.Parent = self.object.EchoesFrame
	local labelFrame = self.object.EchoLabelFrame
	local tweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local growTween = TweenService:Create(newFrame.ImageLabel, tweenInfo, {Size = UDim2.new(.9, 0, .9, 0)})
	local shrinkTween = TweenService:Create(newFrame.ImageLabel, tweenInfo, {Size = UDim2.new(.6, 0, .6, 0)})
	
	newFrame.ImageLabel.MouseEnter:Connect(function()
		labelFrame.NameLabel.Text = data.echoData.stringName
		local description = data.echoData.description
		description = TextProcessor.ProcessKeyWords(description)
		description = TextProcessor.ProcessText(description, data.echoData)
		labelFrame.DescriptionLabel.Text = description
		
		labelFrame.Position = UDim2.new(0, newFrame.AbsolutePosition.X+65, 0, newFrame.AbsolutePosition.Y+65) --TODO: hardcoded, we should move this out later
		labelFrame.Visible = true
		growTween:Play()
	end)

	newFrame.ImageLabel.MouseLeave:Connect(function()
		labelFrame.Visible = false
		shrinkTween:Play()
	end)
	self._echoFrames[data.id] = newFrame
end

return GameEntityGui