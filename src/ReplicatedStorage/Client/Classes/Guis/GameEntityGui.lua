local EchoFrame = game:GetService("ReplicatedStorage").Models.UI.EchoFrame

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
	self:_initConnections()
	return self
end

function GameEntityGui:_initConnections()
	local button = self.object.TopFrame.DeckFrame.ImageContainer.ImageButton
	button.MouseButton1Click:Connect(function()
		local deckData = self.clientPlayer:getEntity():getDeck()
		GuiEvent:Fire("CardSelectionGui", "show", deckData) --TODO: implement, maybe instead cache
	end)
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

function GameEntityGui:updateDeck(deckSize)
	self.object.TopFrame.DeckFrame.ImageContainer.ImageButton.TextLabel.Text = deckSize
end

function GameEntityGui:updateMoney(money)
	self.object.TopFrame.MoneyFrame.TextLabel.Text = money
end

function GameEntityGui:updateHealth(health, maxHealth)
	self.object.TopFrame.HealthFrame.TextLabel.Text = health.. "/" ..maxHealth
end

return GameEntityGui