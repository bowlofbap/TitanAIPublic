local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)
local localPlayer = game:GetService("Players").LocalPlayer

local PlayerDeck = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.PlayerDeck)
local PlayerHand = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.PlayerHand)
local PlayerDiscard = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.PlayerDiscard)
local CardHolder = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.CardHolder)

local GuiEvent = game:GetService("ReplicatedStorage").Client.BindableEvents.GuiEvent
local GuiFunction = game:GetService("ReplicatedStorage").Client.BindableFunctions.GuiFunction

local UiActions = require(game:GetService("ReplicatedStorage").Enums.Shop.UiActions)
local ClientEvents = require(game:GetService("ReplicatedStorage").Enums.ClientEvents)
local GameDataRequests = require(game:GetService("ReplicatedStorage").Enums.GameDataRequests)
local GameResults = require(game:GetService("ReplicatedStorage").Enums.GameResults)

local ClientNodeInstance = require(game:GetService("ReplicatedStorage").Client.Classes.ClientNode.ClientNodeInstance)

local ClientShop = setmetatable({}, {__index = ClientNodeInstance})
ClientShop.__index = ClientShop

function ClientShop.new(instanceFolder, shopData)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientShop)
	self.shopData = shopData
	local battleGui = GuiFunction:Invoke("ShopGui", "get")
	GuiEvent:Fire("ShopGui", "loadData", shopData)
	self:bindEvents()
	return self
end

function ClientShop:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameUiEvent.OnClientEvent:Connect(function(uiAction, data)
		if uiAction == UiActions.SHOW_GUI then
			GuiEvent:Fire("ShopGui", "show")
		elseif uiAction == UiActions.PURCHASED_CARD then
			GuiEvent:Fire("ShopGui", "markItemAsBought", data.id)
		end
	end)
end 

return ClientShop
