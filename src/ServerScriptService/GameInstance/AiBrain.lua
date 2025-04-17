local AiBrainRepo = require(game:GetService("ReplicatedStorage").Repos.AiBrainRepo)

local AiBrain = {}
AiBrain.__index = AiBrain

function AiBrain.new(brainKey)
	local self = setmetatable({}, AiBrain)
	self._data = AiBrainRepo[brainKey]
	return self
end

function AiBrain:getNextCardIndex(unit, gameInstance)
	return self._data.selectCard(unit, gameInstance)
end


return AiBrain
