local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local EchoRarityTypes = require(game:GetService("ReplicatedStorage").Enums.EchoRarityTypes)
local EchoSubsets = require(game:GetService("ReplicatedStorage").Enums.EchoSubsets)
local EchoRepo = require(game:GetService("ReplicatedStorage").Repos.EchoRepo)

local BaseReward = require(script.Parent.BaseReward)
local Reward = setmetatable({}, { __index = BaseReward })
Reward.__index = Reward

function Reward.new(rewardType, id, eventObserver)
	local self = BaseReward.new(rewardType, id, eventObserver)
	setmetatable(self, Reward)
	self._echoName = nil
	return self
end

--TODO: we don't need playerstate now but we might later for the unit name
function Reward:init(dependencies)
	local echoRarity = self.rewardType.rarity
	local echoDatas = EchoRepo.get(echoRarity, {EchoSubsets.GENERAL})
	local echoNames = {}
	for echoName, data in pairs(echoDatas) do
		local alreadyOwned = dependencies.echoManager:getEchoByStringName(data.stringName)
		if not alreadyOwned then
			table.insert(echoNames, echoName)
		end
	end
	if #echoNames <= 0 then
		return false, "not enough echos for rarity "..self.rewardType.rarity.label
	end
	local randomEchoName = echoNames[math.random(#echoNames)]
	self._echoName = randomEchoName
	return true
end

function Reward:execute()
	if not self.retrieved then 
		self.retrieved = true
		self.eventObserver:emit(GameEvents.ADD_ECHO, {echoName = self._echoName})
	else
		warn("this reward is already retrieved")
	end
end

function Reward:serialize()
	return {
		rewardType = self.rewardType,
		id = self.id,
		echoName = self._echoName
	}
end

return Reward
