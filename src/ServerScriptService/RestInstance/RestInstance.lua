local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Enums = ReplicatedStorage.Enums

local Constants = require(ReplicatedStorage.Helpers.Constants)
local StateSyncBuffer = require(ServerScriptService.General.StateSyncBuffer)
local StateUpdate = require(ServerScriptService.General.StateUpdate)

local UiActions = require(Enums.Rest.UiActions)
local GameActions = require(Enums.Rest.GameActions)
local GameEventsTypes = require(Enums.GameEvents)

local NodeInstance = require(ServerScriptService.NodeInstance.NodeInstance)
local RestInstance = {}
RestInstance.__index = RestInstance
setmetatable(RestInstance, {__index = NodeInstance}) 

function RestInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, RestInstance)
	self.robloxPlayer = dependencies.robloxPlayer
	self.stateSyncBuffer = StateSyncBuffer.new(dependencies.robloxPlayer, self.folder.Events.ToClient.GameSyncEvent)
	self._used = false
	self:connectEvents()
	return self
end

function RestInstance:connectEvents()
	local gameEvents = self.folder.Events
	gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.REQUEST_END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.REQUEST_REST then
			self:requestRest(data)
		elseif action == GameActions.REQUEST_UPGRADE then
			self:requestUpgrade(data)
		end
	end)
end

function RestInstance:requestRest(data)
	if not self._used then
		self._used = true
		self:fireGameEvent(GameEventsTypes.PLAYER_HEALTH_HURT_HEAL, {value = Constants.INSTANCE_SETTINGS.REST_SETTINGS.HEAL_VALUE})
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.USE_INSTANCE, {}))
		self.stateSyncBuffer:flush()
	else
		warn("Rest has already been used")
	end
end

function RestInstance:requestUpgrade(data)
	if not self._used then
		self._used = true
		self:fireGameEvent(GameEventsTypes.UPGRADE_CARD, {cardId = data})
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.USE_INSTANCE, {}))
		self.stateSyncBuffer:flush()
	else
		warn("Rest has already been used")
	end
end

function RestInstance:getCameraSubject()
	return self.model
end

function RestInstance:start()
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.SHOW_GUI, {upgradeableCardData = self.deckManager:getUpgradeableCardData()}))
	self.stateSyncBuffer:flush()
end

function RestInstance:connectPlayerToInstance(nodeType)
	self:fireGameEvent(GameEventsTypes.CONNECT_TO_INSTANCE, {
		nodeType = nodeType, 
		folder = self.folder, 
		args = {
		}
	})
end

return RestInstance