local BaseReward = {}
BaseReward.__index = BaseReward

function BaseReward.new(rewardType, id, eventObserver)
	local self = setmetatable({}, BaseReward)
	self.eventObserver = eventObserver
	self.retrieved = false
	self.id = id
	self.rewardType = rewardType
	return self
end

function BaseReward:init()
	error("Apply method must be overridden in a derived class.")
end

function BaseReward:execute()
	error("Apply method must be overridden in a derived class.")
end

function BaseReward:serialize()
	error("Apply method must be overridden in a derived class.")
end

return BaseReward
