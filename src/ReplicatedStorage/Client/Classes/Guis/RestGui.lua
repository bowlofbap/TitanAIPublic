local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)

local GameActions = require(game:GetService("ReplicatedStorage").Enums.Rest.GameActions)
local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent

local player = game:GetService("Players").LocalPlayer

local ShopGui = setmetatable({}, { __index = BaseGui }) 
ShopGui.__index = ShopGui

function ShopGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, ShopGui)
	self:init()
	return self
end

function ShopGui:init()
	self.object.CloseFrame.TextButton.MouseButton1Click:Connect(function()
		self:hide()
		self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_END_GAME)
	end)

	self.object.RestFrame.TextButton.MouseButton1Click:Connect(function()
		if not self.clientPlayer:getCurrentInstance().isUseable then return end
		self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_REST)
	end)
	
	self.object.UpgradeFrame.TextButton.MouseButton1Click:Connect(function()
		if not self.clientPlayer:getCurrentInstance().isUseable then return end
		local upgradeableCardData = self.clientPlayer:getCurrentInstance():getUpgradeableCardData()
		local upgradeFunction = function(cardId)
			self.clientPlayer:getCurrentInstance():requestGameAction(GameActions.REQUEST_UPGRADE, cardId)
		end
		GuiEvent:Fire("CardSelectionGui", "show", upgradeableCardData, upgradeFunction)
	end)
end

function ShopGui:enable()
	self.object.RestFrame.BackgroundTransparency = 0
	self.object.UpgradeFrame.BackgroundTransparency = 0
end

function ShopGui:disable()
	self.object.RestFrame.BackgroundTransparency = .6
	self.object.UpgradeFrame.BackgroundTransparency = .6
	GuiEvent:Fire("CardSelectionGui", "hide")
end

function ShopGui:show()
	self:enable()
	self.object.Enabled = true
end
return ShopGui