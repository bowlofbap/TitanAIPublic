local RewardsHandler = require(game:GetService("ServerScriptService").GameInstance.RewardsHandler)

local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local ChestModel = game:GetService("ReplicatedStorage").Models.NodeInstances.Chest

local UiActions = require(game:GetService("ReplicatedStorage").Enums.GameInstance.UiActions)
local GameActions = require(game:GetService("ReplicatedStorage").Enums.GameActions)
local GameEventsTypes = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local GameDataRequests = require(game:GetService("ReplicatedStorage").Enums.GameDataRequests)

local NodeInstance = require(game:GetService("ServerScriptService").NodeInstance.NodeInstance)
local ChestInstance = {}
ChestInstance.__index = ChestInstance
setmetatable(ChestInstance, {__index = NodeInstance}) 

function ChestInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, ChestInstance)
	local chestSize = dependencies.stageData.chestSize
	self.model = ChestModel:Clone()
	self.model:SetPrimaryPartCFrame(CFrame.new(dependencies.centerPosition))
	self.model.Parent = self.folder
	self.rewardsHandler = RewardsHandler.new()
	self.rewardsHandler:initRewards(dependencies.playerState, dependencies.echoManager, dependencies.stageData.rewards, dependencies.eventObserver, self.idGenerator)
	self.robloxPlayer = dependencies.robloxPlayer
	self.cardRewardClaimed = false
	self:connectEvents()
	return self
end

function ChestInstance:connectEvents()
	local gameFunctions = self.folder.Functions
	local gameEvents = self.folder.Events
	local c1 = gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
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
			local reward = self.rewardsHandler:retrieveReward(data.id)
			if reward then
				reward:execute()
				return true
			else
				return false
			end
		end
	end
end

function ChestInstance:relayEvent(eventType, data)
	if eventType == GameEventsTypes.OPENING_CARD_PACK then
		self:updateClientUi(UiActions.OPEN_CARD_PACK, data)
	end
end

function ChestInstance:getCameraSubject()
	return self.model
end

function ChestInstance:start()
	local rewards = self.rewardsHandler:serializeRewards()
	print(rewards)
	self:updateClientUi(UiActions.SHOW_GUI, {rewards = rewards})
end

function ChestInstance:connectPlayerToInstance(nodeType)
	ConnectToGame:FireClient(self.robloxPlayer, nodeType, self.folder) --TODO: remove
end

return ChestInstance