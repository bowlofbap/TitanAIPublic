local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local CardTypes = require(game:GetService("ReplicatedStorage").Enums.CardTypes)
local StatusTypes = require(game:GetService("ReplicatedStorage").Enums.StatusTypes)

local types = {
	BASE = {
		name = "Base Tile",
		onEnter = function(gameInstance, eventObserver, unit)
			
		end,
		onLeave = function(gameInstance, unit)

		end,
		color = Color3.new(124/255, 124/255, 128/255)
	},
	BLOCKING = {
		name = "Block Tile",
		onEnter = function(gameInstance, eventObserver, unit)
			local subscription = eventObserver:subscribeTo(GameEvents.PLAY_CARD, function(instance, data)
				if data.caster == unit then
					instance:applyBlock(unit, {unit}, 2)
				end
			end)
			return subscription
		end,
		onLeave = function(gameInstance, unit)

		end,
		color = Color3.new(1, 0.805722, 0.685878)
	},
	HEAL = {
		name = "Heal Tile",
		onEnter = function(gameInstance, eventObserver, unit)

		end,
		onLeave = function(gameInstance, unit)
			gameInstance:applyHeal(unit, {unit}, 5)
		end,
		color = Color3.new(0.579751, 0.977432, 0.464149)
	},
	STRENGTH = {
		name = "Strength Tile",
		onEnter = function(gameInstance, eventObserver, unit)
			gameInstance:applyStatus(unit, {unit}, StatusTypes.STRENGTH_BUFF, 5)
		end,
		onLeave = function(gameInstance, unit)
			gameInstance:removeStatus({unit}, StatusTypes.STRENGTH_BUFF, 5)
		end,
		color = Color3.new(0.976471, 0.462745, 0.462745)
	},
	ELECTROCHARGED = {
		name = "Electrocharged Tile",
		onEnter = function(gameInstance, eventObserver, unit)
			gameInstance:applyStatus(unit, {unit}, StatusTypes.CHARGE_BUFF, 1)
		end,
		onLeave = function(gameInstance, unit)
			gameInstance:removeStatus({unit}, StatusTypes.CHARGE_BUFF, 1)
		end,
		color = Color3.new(0.462745, 0.968627, 0.976471)
	},
	TRACED = {
		name = "Traced Tile",
		onEnter = function(gameInstance, eventObserver, unit)
			gameInstance:applyStatus(unit, {unit}, StatusTypes.TRACE_BUFF, 1)
		end,
		onLeave = function(gameInstance, unit)
			gameInstance:removeStatus({unit}, StatusTypes.TRACE_BUFF, 1)
		end,
		color = Color3.new(0.886275, 0.482353, 0.294118)
	}
}

return types

