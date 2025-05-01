local RewardTypes = require(game:GetService("ReplicatedStorage").Enums.GameInstance.RewardTypes)

local Level1 = {
	test = {
		{
			units = {
				{
					name = "TestEnemy",
					position = Vector2.new(1, 2)
				},
				{
					name = "TestEnemy",
					position = Vector2.new(2, 2)
				},
			},
			rewards = {
				RewardTypes.MONEY_SMALL,
				RewardTypes.CARDS_BASIC,
				RewardTypes.ECHO_COMMON
			}
		},
		{
			units = {
				{
					name = "TestEnemy",
					position = Vector2.new(1, 2)
				},
			},
			rewards = {
				RewardTypes.MONEY_SMALL,
				RewardTypes.CARDS_BASIC,
				RewardTypes.ECHO_COMMON
			}
		},
	},
	A = {
		{
			weight = 1,
			key = "A01",
			units = {
				{
					name = "GlitchGoblin",
					position = Vector2.new(1, 2)
				},
				{
					name = "GlitchGoblin",
					position = Vector2.new(2, 3)
				},
			},
			rewards = {
				RewardTypes.MONEY_SMALL,
				RewardTypes.CARDS_BASIC,
				RewardTypes.ECHO_COMMON
			}
		},
	},
	B = {
		{
			weight = 1,
			key = "B01",
			units = {
				{
					name = "GlitchGoblin",
					position = Vector2.new(4, 4)
				},
			},
			rewards = {
				RewardTypes.MONEY_SMALL,
				RewardTypes.CARDS_BASIC,
				RewardTypes.ECHO_COMMON
			}
		},
	},
}

return Level1
