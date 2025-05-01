local RewardTypes = require(game:GetService("ReplicatedStorage").Enums.GameInstance.RewardTypes)

local ChestTypes = {
    SMALL = {
        key = "SMALL",
        LABEL = "Small",
        CHANCE = 50,
        ECHO_REWARDS = {
            {
                RARITY = RewardTypes.ECHO_COMMON,
                CHANCE = 75
            },
            {
                RARITY = RewardTypes.ECHO_RARE,
                CHANCE = 25
            },
        },
        CARD_REWARDS = {
            {
                RARITY = RewardTypes.CARDS_BASIC,
                CHANCE = 75
            },
            {
                RARITY = RewardTypes.CARDS_RARE,
                CHANCE = 25
            },
        },
        GOLD_DATA = {
            CHANCE = 50,
            TYPE = RewardTypes.MONEY_SMALL
        }
    },
    MEDIUM = {
        key = "MEDIUM",
        LABEL = "Medium",
        CHANCE = 33,
        ECHO_REWARDS = {
            {
                RARITY = RewardTypes.ECHO_COMMON,
                CHANCE = 25
            },
            {
                RARITY = RewardTypes.ECHO_RARE,
                CHANCE = 60
            },
            {
                RARITY = RewardTypes.ECHO_LEGENDARY,
                CHANCE = 15
            },
        },
        CARD_REWARDS = {
            {
                RARITY = RewardTypes.CARDS_BASIC,
                CHANCE = 25
            },
            {
                RARITY = RewardTypes.CARDS_RARE,
                CHANCE = 75
            },
        },
        GOLD_DATA = {
            CHANCE = 50,
            TYPE = RewardTypes.MONEY_MEDIUM
        }
    },
    LARGE = {
        key = "LARGE",
        LABEL = "Large",
        CHANCE = 17,
        ECHO_REWARDS = {
            {
                RARITY = RewardTypes.ECHO_RARE,
                CHANCE = 70
            },
            {
                RARITY = RewardTypes.ECHO_LEGENDARY,
                CHANCE = 30
            },
        },
        CARD_REWARDS = {
            {
                RARITY = RewardTypes.CARDS_RARE,
                CHANCE = 75
            },
            {
                RARITY = RewardTypes.CARDS_LEGENDARY,
                CHANCE = 25
            },
        },
        GOLD_DATA = {
            CHANCE = 50,
            TYPE = RewardTypes.MONEY_LARGE
        }
    },
}

return ChestTypes