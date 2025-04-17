local CardRepo = require(game:GetService("ReplicatedStorage").Repos.CardRepo)
local DeckRepos = game:GetService("ReplicatedStorage").Repos.DeckRepos
local RarityTypes = require(game:GetService("ReplicatedStorage").Enums.RarityTypes)

local ShopManager = {}
ShopManager.__index =  ShopManager

local SETTINGS = {
	NUM_CARDS = 3,
	CHANCE_RARE_CARD = 25,
	PRICE_BOUND = .1
}

function ShopManager.new(playerState, idGenerator)
	local self = setmetatable({}, ShopManager)
	self.cardData = {}
	self.idGenerator = idGenerator
	self:init(playerState)
	return self
end

function ShopManager:init(playerState)
	local selectedCards = {}
	self.cards = {}
	local deckRepo = require(DeckRepos[playerState.unitName])
	local eligibleCardNames = deckRepo.getEligibleCardNames()
	for i = 1, SETTINGS.NUM_CARDS do
		local r = math.random(1,100)
		local rarity = RarityTypes.COMMON
		if r <= SETTINGS.CHANCE_RARE_CARD or i == 1 then
			rarity = RarityTypes.RARE
		end
		local potentialCards = CardRepo.getCardsByRarity(eligibleCardNames, rarity)
		local selectedCard = nil
		repeat
			selectedCard = potentialCards[math.random(#potentialCards)]
		until not selectedCards[selectedCard]
		selectedCards[selectedCard] = true
		local cost = math.random(rarity.price * (1-SETTINGS.PRICE_BOUND), rarity.price * (1+SETTINGS.PRICE_BOUND))
		local id = self.idGenerator:gen()
		self.cardData[id] = {cardData = selectedCard, cost = cost, purchased = false, upgraded = false, id = id}
	end
end

function ShopManager:tryPurchase(id, playerState)
	local data = self.cardData[id]
	if data then
		local cost = data.cost
		if playerState:canAfford(cost) then --something feels like we shouldnt check the playerstate ehre but w.e
			if not data.purchased then
				data.purchased = true
				return data, cost
			else 
				warn("Already purchased")
			end
		else
			warn("Couldn't afford")
		end
	else
		warn("couldn't find card for id ".. id)
	end
	return nil
end

function ShopManager:purchase(id, playerState)
	self.cardData[id].purchased = true
end

--converts to a table of names and ids to send up to client
function ShopManager:serialize(hasPlace)
	local cards = {}
	for id, cardData in pairs(self.cardData) do
		table.insert(cards, {cardData = cardData.cardData, id = id, cost = cardData.cost, purchased = cardData.purchased, upgraded = cardData.upgraded})
	end
	return cards
end

return ShopManager
