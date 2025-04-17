local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local RarityTypes = require(game:GetService("ReplicatedStorage").Enums.RarityTypes)
local CardRepo = require(game:GetService("ReplicatedStorage").Repos.CardRepo)
local DeckRepos = game:GetService("ReplicatedStorage").Repos.DeckRepos

local BaseReward = require(script.Parent.BaseReward)
local Reward = setmetatable({}, { __index = BaseReward })
Reward.__index = Reward

local PACK_SIZE = 3

function Reward.new(rewardType, id, eventObserver)
	local self = BaseReward.new(rewardType, id, eventObserver)
	setmetatable(self, Reward)
	self.cardData = {}
	return self
end

function Reward:init(dependencies)
	local selectedCards = {}
	local deckRepo = require(DeckRepos[dependencies.playerState.unitName])
	local eligibleCardNames = deckRepo.getEligibleCardNames()
	for i = 1, PACK_SIZE do
		local cardRarity = self.rewardType.rarity
		local rarityRoll = math.random(1,100)
		if rarityRoll <= self.rewardType.upgradeChance then
			cardRarity = RarityTypes.getUpgrade(cardRarity)
		end
		local potentialCards = CardRepo.getCardsByRarity(eligibleCardNames, cardRarity)
		local selectedCard = nil
		local attempts = 0 
		if #potentialCards <= 0 then
			return false, "Not enough cards for rarity "..cardRarity.label
		end
		repeat
			selectedCard = potentialCards[math.random(#potentialCards)]
			attempts += 1
			-- Break after 100 tries to avoid infinite loops
			if attempts > 100 then
				warn("No unique card found after 100 attempts") --lol honestly hacky but whatever
				break
			end
		until not selectedCards[selectedCard.key]
		selectedCards[selectedCard.key] = true
		table.insert(self.cardData, {cardData = selectedCard, id = dependencies.idGenerator:gen(), upgraded = false} ) 
	end
	return true
end

function Reward:execute()
	if not self.retrieved then 
		self.retrieved = true
		self.eventObserver:emit(GameEvents.OPENING_CARD_PACK, {cardData = self.cardData})
	else
		warn("this reward is already retrieved")
	end
end

function Reward:serialize()
	return {
		rewardType = self.rewardType,
		id = self.id
	}
end

return Reward
