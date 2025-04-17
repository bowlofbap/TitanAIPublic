local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local EchoRarities = require(game:GetService("ReplicatedStorage").Enums.EchoRarityTypes)
local EchoSubsets = require(game:GetService("ReplicatedStorage").Enums.EchoSubsets)
local CardTypes = require(game:GetService("ReplicatedStorage").Enums.CardTypes)
local BaseEcho = require(script.Parent.BaseEcho)

local Echo = setmetatable({}, { __index = BaseEcho })
Echo.__index = Echo

Echo.data = {
	stringName = "Flurry",
	description = "Every {count} played Attacks, apply {value} Block to yourself",
	image = "rbxassetid://78494366360008",
	count = 3,
	value = 20,
	countable = true,
	rarity = EchoRarities.COMMON,
	subset = EchoSubsets.GENERAL
}

function Echo.new(id)
	local self = BaseEcho.new(id)
	setmetatable(self, Echo)
	self._count = 0
	return self
end

function Echo:execute(eventObserver, playerState, deckManager, getCurrentInstance)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.PLAY_CARD, function(data)
		if data.caster == getCurrentInstance().player.unit and data.card:getCardType() == CardTypes.DAMAGE then
			self._count += 1
			if self._count >= self.data.count then
				self._count = 0 
				getCurrentInstance():applyBlock(getCurrentInstance().player.unit, {getCurrentInstance().player.unit}, self.data.value)
			end
			eventObserver:emit(GameEvents.UPDATE_ECHO_COUNT, {id = self.id, count = self._count})
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end


return Echo
