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
				requirement = function(dependencies)
					return dependencies.playerState:canAfford(35)
				end,
				execute = function(dependencies)
					dependencies.eventObserver:emit(GameEvents.CHANGE_MONEY, {moneyChange = -35})
					return {
						eventResultType = EventResultTypes.END_RESULT, 
						description = "You cover your eyes as a sudden light blinds you - As you open them, you see your bag has been cut open and your money gone.",
						finishText = "[Unfortunate]"
					}
				end,
			},
			{
				text = "[Pay with Blood] Lose 17 Health",
				execute = function(dependencies)
					dependencies.eventObserver:emit(GameEvents.PLAYER_HEALTH_HURT_HEAL, {value = -17})
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
				requirement = function(dependencies)
					local unupgradedCards = dependencies.deckManager:getUpgradeableCardData()
					return #unupgradedCards >= 2
				end,
				execute = function(dependencies)
					local unupgradedCards = dependencies.deckManager:getUpgradeableCardData()
					local data1, data2 = Tables.selectTwoRandomElements(unupgradedCards)
					dependencies.eventObserver:emit(GameEvents.PLAYER_HEALTH_HURT_HEAL, {value = -20})
					dependencies.eventObserver:emit(GameEvents.UPGRADE_CARD, {cardId = data1.id})
					dependencies.eventObserver:emit(GameEvents.UPGRADE_CARD, {cardId = data2.id})
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
				execute = function(dependencies)
					dependencies.eventObserver:emit(GameEvents.FINISH_INSTANCE, dependencies.mapNodeType)
					return {
						eventResultType = EventResultTypes.FUNCTION, 
					}
				end,
			},
		},
	},
}

return eventsMap
