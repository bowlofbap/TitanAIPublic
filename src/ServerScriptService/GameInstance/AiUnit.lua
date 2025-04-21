local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Unit = require(ServerScriptService.GameInstance.Unit)
local UnitRepo = require(ReplicatedStorage.Repos.UnitRepo)
local Card = require(ServerScriptService.GameInstance.Card)
local EntityCard = require(ServerScriptService.GameEntity.EntityCard)
local AiBrain = require(ServerScriptService.GameInstance.AiBrain)

local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local env = require(ReplicatedStorage.env)

local AiUnit = setmetatable({}, {__index = Unit})
AiUnit.__index = AiUnit

function AiUnit.new(unitId, idGenerator)
	local unitData = UnitRepo.AiUnits[unitId]
	local base = Unit.new(unitId, unitData)
	local self = setmetatable(base, AiUnit)
	
	self.cardSet = UnitRepo.AiUnits[unitId].CardSet
	self.cards = {}
	self.actions = {}
	self.idGenerator = idGenerator
	
	self.health = unitData.MaxHealth
	self.maxHealth = unitData.MaxHealth
	self._aiBrain = AiBrain.new(unitData.key)
	self:initCards()
	return self
end

function AiUnit:getLoadedCard()
	error("Not implemented yet")
end

function AiUnit:initCards()
	for _, cardName in ipairs(self.cardSet) do
		if self.cards[cardName] then continue end
		local entityCard = EntityCard.new(cardName, false, self.idGenerator:gen())
		local newCard = Card.new(entityCard)
		table.insert(self.cards, newCard)
	end
end

function AiUnit:reloadActions(gameInstance)
	local randomAction = self._aiBrain:getNextCardIndex(self, gameInstance)
	self.actions = { self.cards[randomAction] }
	--TODO: error handling
end

function AiUnit:executeActions(gameInstance)
	for _, card in self.actions do
		local targetCoordinates = nil
		local context = CardExecutionContext.new(gameInstance, card.cardData, self, targetCoordinates)
		gameInstance:executeAiCard(card, context)
		if env.ENV ~= "test" then
			wait(.5)
		end
	end
end

return AiUnit
