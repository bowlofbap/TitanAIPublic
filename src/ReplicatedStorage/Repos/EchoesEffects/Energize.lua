local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local EchoRarities = require(game:GetService("ReplicatedStorage").Enums.EchoRarityTypes)
local EchoSubsets = require(game:GetService("ReplicatedStorage").Enums.EchoSubsets)
local BaseEcho = require(script.Parent.BaseEcho)

local Echo = setmetatable({}, { __index = BaseEcho })
Echo.__index = Echo

Echo.data = {
	stringName = "Energize",
	description = "Gain {value} Max Health at the start of combat",
	image = "rbxassetid://78494366360008",
	value = 5,
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
	local unsubscribe = eventObserver:subscribeTo(GameEvents.GAME_START, function()
		local data = {health = playerState.health + 5, maxHealth = playerState.maxHealth + 5}
		eventObserver:emit(GameEvents.PLAYER_HEALTH_CHANGED, data)
	end)
	table.insert(self._unsubscribes, unsubscribe)
end


return Echo
