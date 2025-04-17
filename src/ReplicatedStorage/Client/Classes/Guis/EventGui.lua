local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)

local GameActions = require(game:GetService("ReplicatedStorage").Enums.Event.GameActions)
local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local EventResultTypes = require(game:GetService("ReplicatedStorage").Enums.Event.EventResultTypes)

local EventButton = game:GetService("ReplicatedStorage").Models.UI.Event.EventButton

local player = game:GetService("Players").LocalPlayer

local EventGui = setmetatable({}, { __index = BaseGui }) 
EventGui.__index = EventGui

function EventGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	self._waiting = false
	setmetatable(self, EventGui)
	return self
end

function EventGui:init()
	local eventData = self.clientPlayer:getCurrentInstance():getEventData()
	local mainFrame = self.object.MainFrame
	mainFrame.NameFrame.NameLabel.Text = eventData.name
	mainFrame.ImageFrame.ImageLabel.Image = eventData.image
	self:_updateDescription(eventData.description)
	for i, eventChoice in ipairs(eventData.choices) do
		local callback = function()
			if self._waiting then
				warn("Waiting for server response")
				return
			end
			if eventChoice.isCloseButton then
				self:hide()
			end
			self._waiting = true
			self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_EVENT_OPTION, {index = i})
		end
		self:_createButton(eventChoice.text, callback)
	end
end

function EventGui:_createButton(label, callback)
	local mainFrame = self.object.MainFrame
	local newButton = EventButton:Clone()
	newButton.TextLabel.Text = label
	newButton.Parent = mainFrame.TextFrame.ButtonsFrame
	newButton.MouseButton1Click:Connect(callback)
end

function EventGui:_updateDescription(label)
	local mainFrame = self.object.MainFrame
	mainFrame.TextFrame.DescriptionFrame.DescriptionLabel.Text = label
end

function EventGui:serverReply()
	self._waiting = false
end

--[[
{
	eventResultType,
	finishText
}
]]
function EventGui:update(choiceResultData)
	self:reset()
	if choiceResultData.eventResultType == EventResultTypes.END_RESULT then
		self:_updateDescription(choiceResultData.description)
		local callback = function()
			if self._waiting then
				warn("Waiting for server response")
				return
			end
			self:hide()
			self._waiting = true
			self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_END_GAME)
		end
		self:_createButton(choiceResultData.finishText, callback)
	end
end

function EventGui:reset()
	self:serverReply()
	local mainFrame = self.object.MainFrame
	local buttonsFrame = mainFrame.TextFrame.ButtonsFrame
	for _, button in ipairs(buttonsFrame:GetChildren()) do
		if button.ClassName == "ImageButton" then
			button:Destroy()
		end
	end
end

function EventGui:show()
	self:reset()
	self:init()
	self.object.Enabled = true
end

function EventGui:hide()
	self.object.Enabled = false
end

return EventGui