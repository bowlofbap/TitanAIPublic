local RewardTypes = require(game:GetService("ReplicatedStorage").Enums.GameInstance.RewardTypes)

local ChestGenerator = {
	CHEST_TYPES = {
		SMALL = {
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
}

function ChestGenerator.getData()
	local rewards = {}
	local chestChance = math.random(1,100)
	local echoRarityChance = math.random(1, 100)
	local cardRarityChance = math.random(1, 100)
	local goldChance = math.random(1, 100)
	local chestSize = ChestGenerator.CHEST_TYPES.SMALL
	local cardRarity = RewardTypes.CARDS_BASIC
	if ChestGenerator.CHEST_TYPES.SMALL.CHANCE <= chestChance then
		chestSize = ChestGenerator.CHEST_TYPES.SMALL
	elseif ChestGenerator.CHEST_TYPES.MEDIUM.CHANCE + ChestGenerator.CHEST_TYPES.SMALL.CHANCE < chestChance then
		chestSize = ChestGenerator.CHEST_TYPES.MEDIUM
	elseif ChestGenerator.CHEST_TYPES.LARGE.CHANCE + ChestGenerator.CHEST_TYPES.MEDIUM.CHANCE + ChestGenerator.CHEST_TYPES.SMALL.CHANCE < chestChance then
		chestSize = ChestGenerator.CHEST_TYPES.LARGE
	end
	local r = 0
	for _, rewardData in ipairs(chestSize.ECHO_REWARDS) do
		r += rewardData.CHANCE
		if r >= echoRarityChance then
			table.insert(rewards, rewardData.RARITY)
			break
		end
	end
	r = 0
	for _, rewardData in ipairs(chestSize.CARD_REWARDS) do
		r += rewardData.CHANCE
		if r >= cardRarityChance then
			table.insert(rewards, rewardData.RARITY)
			break
		end
	end
	local goldType = nil
	if goldChance <= chestSize.GOLD_DATA.CHANCE then
		table.insert(rewards, chestSize.GOLD_DATA.TYPE)
	end
	return {
		chestSize = chestSize,
		rewards = rewards
	}
end

return ChestGenerator
