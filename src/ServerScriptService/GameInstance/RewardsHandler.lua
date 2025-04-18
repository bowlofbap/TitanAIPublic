local RewardsFolder = game:GetService("ServerScriptService").GameInstance.Rewards

local RewardsHandler = {}
RewardsHandler.__index =  RewardsHandler

function RewardsHandler.new()
	local self = setmetatable({}, RewardsHandler)
	self.rewards = {}
	return self
end

function RewardsHandler:initRewards(playerState, echoManager, data, eventObserver, idGenerator)
	for _, rewardType in ipairs(data) do
		self:_addReward(playerState, echoManager, rewardType, eventObserver, idGenerator)
	end
end

function RewardsHandler:_addReward(playerState, echoManager, rewardType, eventObserver, idGenerator)
	local rewardClass = require(RewardsFolder[rewardType.class])
	local newReward = rewardClass.new(rewardType, idGenerator:gen(), eventObserver)
	local dependencies = {
		playerState = playerState,
		echoManager = echoManager,
		idGenerator = idGenerator
	}
	local success, reason = newReward:init(dependencies)
	if success then
		table.insert(self.rewards, newReward)
	else
		warn("Reward was unable to be created, reason:", reason)
	end
end

function RewardsHandler:retrieveReward(rewardId) 
	for i, reward in ipairs(self.rewards) do
		if reward.id == rewardId then
			local retrievedReward = table.remove(self.rewards, i)
			return retrievedReward
		end
	end
	return nil
end

function RewardsHandler:serializeRewards()
	local clientRewards = {}
	for _, reward in ipairs(self.rewards) do
		table.insert(clientRewards, reward:serialize())
	end
	return clientRewards
end

return RewardsHandler
