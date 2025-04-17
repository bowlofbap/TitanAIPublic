local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local BaseReward = require(script.Parent.BaseReward)
local Reward = setmetatable({}, { __index = BaseReward })
Reward.__index = Reward

function Reward.new(rewardType, id, eventObserver)
	local self = BaseReward.new(rewardType, id, eventObserver)
	setmetatable(self, Reward)
	self.value = math.random(rewardType.min, rewardType.max)
	return self
end

function Reward:init()
	return true
end

function Reward:execute()
	if not self.retrieved then 
		self.retrieved = true
		self.eventObserver:emit(GameEvents.CHANGE_MONEY, {moneyChange = self.value})
	else
		warn("this reward is already retrieved")
	end
end

function Reward:serialize()
	return {
		rewardType = self.rewardType,
		value = self.value,
		id = self.id
	}
end

return Reward
