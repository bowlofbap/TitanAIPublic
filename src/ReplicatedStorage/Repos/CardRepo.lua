local Cards = game:GetService("ReplicatedStorage").Repos.Cards
local TempRepo = require(Cards.TemporaryRepo)
local ZeCards = require(Cards.ZeCards)
local RainbowAll = require(Cards.RainbowAll)
local EnemyAll = require(Cards.EnemyAll)

local CardDatabase = {}

for _, cardSet in pairs({
	TempRepo, RainbowAll, EnemyAll,
	ZeCards
	}) do
	for cardName, cardData in pairs(cardSet) do
		CardDatabase[cardName] = cardData
	end
end

for key, card in pairs(CardDatabase) do
	card.key = key
end

function CardDatabase.getCardsByRarity(cardNames, rarity)
	local output = {}
	for _, cardName in ipairs(cardNames) do
		local card = CardDatabase[cardName]
		if card.rarity == rarity then
			table.insert(output, card)
		end
	end
	return output
end

CardDatabase._loaded = true

return CardDatabase
