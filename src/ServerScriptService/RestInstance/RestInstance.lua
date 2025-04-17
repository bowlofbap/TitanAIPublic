local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local RestModel = game:GetService("ReplicatedStorage").Models.NodeInstances.Rest

local UiActions = require(game:GetService("ReplicatedStorage").Enums.Rest.UiActions)
local GameActions = require(game:GetService("ReplicatedStorage").Enums.Rest.GameActions)
local GameEventsTypes = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local NodeInstance = require(game:GetService("ServerScriptService").NodeInstance.NodeInstance)
local RestInstance = {}
RestInstance.__index = RestInstance
setmetatable(RestInstance, {__index = NodeInstance}) 

function RestInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, RestInstance)
	local chestSize = dependencies.stageData.chestSize
	self.model = RestModel:Clone()
	self.model:SetPrimaryPartCFrame(CFrame.new(dependencies.centerPosition))
	self.model.Parent = self.folder
	self.robloxPlayer = dependencies.robloxPlayer
	self.used = false
	self:connectEvents()
	return self
end

function RestInstance:connectEvents()
	local gameFunctions = self.folder.Functions
	local gameEvents = self.folder.Events
	local c1 = gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.REQUEST_END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.REQUEST_REST then
			if not self.used then
				self.used = true
				self:fireGameEvent(GameEventsTypes.PLAYER_HEALTH_HURT_HEAL, {value = Constants.INSTANCE_SETTINGS.REST_SETTINGS.HEAL_VALUE})
				self:updateClientUi(UiActions.USE_INSTANCE)
			else
				warn("Rest has already been used")
			end
		elseif action == GameActions.REQUEST_UPGRADE then
			if not self.used then
				self.used = true
				self:fireGameEvent(GameEventsTypes.UPGRADE_CARD, {cardId = data})
				self:updateClientUi(UiActions.USE_INSTANCE)
			end
		end
	end)
end

function RestInstance:getCameraSubject()
	return self.model
end

function RestInstance:start()
	self:updateClientUi(UiActions.SHOW_GUI, {upgradeableCardData = self.deckManager:getUpgradeableCardData()}) --instead of sending upgrade card data here, we can make it as a remotefunction from the client
end

function RestInstance:connectPlayerToInstance(nodeType)
	ConnectToGame:FireClient(self.robloxPlayer, nodeType, self.folder)
end

return RestInstance