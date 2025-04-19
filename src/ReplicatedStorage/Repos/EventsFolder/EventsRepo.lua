local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)
local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local EventResultTypes = require(game:GetService("ReplicatedStorage").Enums.Event.EventResultTypes)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)

local eventsMap = {
	e1 = {
		name = "A Rock and a Hard Place",
		validLevels = { [1] = true },
		description = "The path ahead collapses suddenly, trapping your leg beneath a boulder."..
			"A shadowy figure emerges from the dust, offering aid... for a price. "..
			"\"I can free you, but it'll cost you. Choose wisely, traveler.\"",
		image = "",
		choices = {
			{
				text = "[Pay with "..Constants.MONEY_NAME.."] Lose 35 "..Constants.MONEY_NAME,
				requirement = function(context)
					return context.playerState:canAfford(35)
				end,
				execute = function(context)
					context.eventObserver:emit(GameEvents.CHANGE_MONEY, {moneyChange = -35})
					return {
						eventResultType = EventResultTypes.END_RESULT, 
						description = "You cover your eyes as a sudden light blinds you - As you open them, you see your bag has been cut open and your money gone.",
						finishText = "[Unfortunate]"
					}
				end,
			},
			{
				text = "[Pay with Blood] Lose 17 Health",
				execute = function(context)
					context.eventObserver:emit(GameEvents.PLAYER_HEALTH_HURT_HEAL, {value = -17})
					return {
						eventResultType = EventResultTypes.END_RESULT, 
						description = "The figure lunges at your suddenly with a knife and slashes at your cheek. As you cover your face, you hear a rustle of the wind - He's gone.",
						finishText = "[Unfortunate]"
					}
				end,
			},
		},
	},
	e2 = {
		name = "A Place of Prayer",
		validLevels = { [1] = true },
		description = "You find a hidden chapel in the clearing. "..
			"In the center you see an altar that seems the be illuminated from the heavens.",
		image = "",
		choices = {
			{			
				text = "[Enter and Pray] Upgrade 2 random cards. Lose 20 Health",
				requirement = function(context)
					local unupgradedCards = context.deckManager:getUpgradeableCardData()
					return #unupgradedCards >= 2
				end,
				execute = function(context)
					local unupgradedCards = context.deckManager:getUpgradeableCardData()
					local data1, data2 = Tables.selectTwoRandomElements(unupgradedCards)
					context.eventObserver:emit(GameEvents.PLAYER_HEALTH_HURT_HEAL, {value = -20})
					context.eventObserver:emit(GameEvents.UPGRADE_CARD, {cardId = data1.id})
					context.eventObserver:emit(GameEvents.UPGRADE_CARD, {cardId = data2.id})
					return {
						eventResultType = EventResultTypes.END_RESULT, 
						description = "You lift your head and hear a voice in the background, \"Rise and go.\" You feel much more powerful.",
						finishText = "[Leave]"
					}
				end
			},
			{
				text = "[Leave]",
				isCloseButton = true,
				execute = function(context)
					context.eventObserver:emit(GameEvents.FINISH_INSTANCE, context.mapNodeType)
					return {
						eventResultType = EventResultTypes.FUNCTION, 
					}
				end,
			},
		},
	},
	e3 = {
		name = "Fountain of Youth",
		validLevels = { [1] = true },
		description = "A radiant fountain shimmers in the overgrown chapel."..
						"\nThey say its waters grant unexpected gifts."..
						"\nYou feel a pull — gold, energy... or something rarer.",
		image = "",
		choices = {
			{			
				text = "[Bathe and Relax] Regain 25 Health",
				execute = function(context)
					context.eventObserver:emit(GameEvents.PLAYER_HEALTH_HURT_HEAL, {value = 25})
					return {
						eventResultType = EventResultTypes.END_RESULT, 
						description = "You close your eyes and rest. Hours later, you awake with a jolt to realize"..
						"\nthat you're now lying in an empty basin."
						,
						finishText = "[Leave]"
					}
				end
			},
			{			
				text = "[Steal the Relic] Gain 49 Gold",
				execute = function(context)
					context.eventObserver:emit(GameEvents.CHANGE_MONEY, {moneyChange = 49})
					return {
						eventResultType = EventResultTypes.END_RESULT, 
						description = "You dislodge the basin and break it into pieces. Stuffing in your bag,"..
						"\nyou know this will sell for a pretty penny... though you feel slightly guilty."
						,
						finishText = "[Thief!]"
					}
				end
			},
		},
	},
}

return eventsMap
