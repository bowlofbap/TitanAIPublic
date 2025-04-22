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
	tier1 = {
		{
			units = {
				{
					name = "GlitchGoblin",
					position = Vector2.new(1, 2)
				},
				{
					name = "GlitchGoblin",
					position = Vector2.new(2, 2)
				},
				{
					name = "GlitchGoblin",
					position = Vector2.new(3, 2)
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
		
		{
			units = {
				{
					name = "Toadie",
					position = Vector2.new(2, 3)
				},
				{
					name = "Vagrant",
					position = Vector2.new(1, 3)
				},
				{
					name = "Toadie",
					position = Vector2.new(3, 2)
				},
			},
			rewards = {
				{
					RewardTypes.MONEY_SMALL,
					RewardTypes.CARDS_BASIC
				}
			}
		}
	},
}

return Level1
