local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RewardsHandler = require(ServerScriptService.GameInstance.RewardsHandler)
local StateSyncBuffer = require(ServerScriptService.General.StateSyncBuffer)
local StateUpdate = require(ServerScriptService.General.StateUpdate)

local UiActions = require(ReplicatedStorage.Enums.GameInstance.UiActions)
local GameActions = require(ReplicatedStorage.Enums.GameActions)
local GameEventsTypes = require(ReplicatedStorage.Enums.GameEvents)
local GameDataRequests = require(ReplicatedStorage.Enums.GameDataRequests)
local NodeInstance = require(ServerScriptService.NodeInstance.NodeInstance)
local ChestInstance = {}
ChestInstance.__index = ChestInstance
setmetatable(ChestInstance, {__index = NodeInstance}) 

function ChestInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, ChestInstance)
	self.rewardsHandler = RewardsHandler.new()
	self.rewardsHandler:initRewards(dependencies.playerState, dependencies.echoManager, dependencies.stageData.rewards, dependencies.eventObserver, self.idGenerator)
	self.robloxPlayer = dependencies.robloxPlayer
	self.stateSyncBuffer = StateSyncBuffer.new(dependencies.robloxPlayer, self.folder.Events.ToClient.GameSyncEvent)
	self.cardRewardClaimed = false
	self:connectEvents()
	return self
end

function ChestInstance:connectEvents()
	local gameFunctions = self.folder.Functions
	local gameEvents = self.folder.Events
	gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.SELECT_CARD_REWARD then
			if not self.cardRewardClaimed then
				self.cardRewardClaimed = true
				self:fireGameEvent(GameEventsTypes.ADD_CARD, data)
			else
				warn("Card reward is already claimed for this instance")
			end
		end
	end)

	gameFunctions.GameDataRequest.OnServerInvoke = function(robloxPlayer, requestType, data)
		if requestType == GameDataRequests.OPEN_REWARD then
			return self:openReward(data)
		end
	end
end

function ChestInstance:openReward(data)
	local reward = self.rewardsHandler:retrieveReward(data.id)
	if reward then
		reward:execute()
		return true
	else
		return false
	end
end

function ChestInstance:relayEvent(eventType, data)
	if eventType == GameEventsTypes.OPENING_CARD_PACK then
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.OPEN_CARD_PACK, data))
		self.stateSyncBuffer:flush()
	end
end

function ChestInstance:start()
	local rewards = self.rewardsHandler:serializeRewards()
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.SHOW_GUI, {rewards = rewards}))
	self.stateSyncBuffer:flush()
end

function ChestInstance:connectPlayerToInstance(nodeType)
end

return ChestInstance