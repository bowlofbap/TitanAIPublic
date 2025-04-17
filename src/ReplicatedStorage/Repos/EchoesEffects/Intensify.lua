local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local EchoRarities = require(game:GetService("ReplicatedStorage").Enums.EchoRarityTypes)
local EchoSubsets = require(game:GetService("ReplicatedStorage").Enums.EchoSubsets)
local BaseEcho = require(script.Parent.BaseEcho)

local Echo = setmetatable({}, { __index = BaseEcho })
Echo.__index = Echo

Echo.data = {
	stringName = "Intensify",
	description = "Increases the damage of your attacks by {value}",
	image = "rbxassetid://78494366360008",
	value = 15,
	countable = false,
	rarity = EchoRarities.COMMON,
	subset = EchoSubsets.GENERAL
}

function Echo.new(id)
	local self = BaseEcho.new(id)
	setmetatable(self, Echo)
	return self
end

function Echo:execute(eventObserver, playerState, deckManager, getCurrentInstance)
	local unsubscribe = eventObserver:subscribeTo(GameEvents.BEFORE_DAMAGE, function(data)
		if data.source == getCurrentInstance().player.unit then
			data.damageObject.damage += self.data.value
		end
	end)
	table.insert(self._unsubscribes, unsubscribe)
end


return Echo
