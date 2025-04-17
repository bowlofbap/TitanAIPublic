local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local CardTypes = require(game:GetService("ReplicatedStorage").Enums.CardTypes)
local StatusTypes = require(game:GetService("ReplicatedStorage").Enums.StatusTypes)

local types = {
	BASE = {
		name = "Base Tile",
		onEnter = function(eventObserver, unit, gameInstance)
			
		end,
		onLeave = function(unit, gameInstance)

		end,
		color = Color3.new(124/255, 124/255, 128/255)
	},
	BLOCKING = {
		name = "Block Tile",
		onEnter = function(eventObserver, unit, gameInstance)
			local subscription = eventObserver:subscribeTo(GameEvents.PLAY_CARD, function(data)
				if data.caster == unit then
					gameInstance:applyBlock(unit, {unit}, 2)
				end
			end)
			return subscription
		end,
		onLeave = function(unit, gameInstance)

		end,
		color = Color3.new(1, 0.805722, 0.685878)
	},
	HEAL = {
		name = "Heal Tile",
		onEnter = function(eventObserver, unit, gameInstance)

		end,
		onLeave = function(unit, gameInstance)
			gameInstance:applyHeal(unit, {unit}, 5)
		end,
		color = Color3.new(0.579751, 0.977432, 0.464149)
	},
	STRENGTH = {
		name = "Strength Tile",
		onEnter = function(eventObserver, unit, gameInstance)
			gameInstance:applyStatus(unit, {unit}, {statusType = StatusTypes.STRENGTH_BUFF, value = 5})
		end,
		onLeave = function(unit, gameInstance)
			gameInstance:removeStatus({unit}, StatusTypes.STRENGTH_BUFF, 5)
		end,
		color = Color3.new(0.579751, 0.977432, 0.464149)
	}
}

return types

