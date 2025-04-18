local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage.Client.Classes
local Enums = ReplicatedStorage.Enums

local PlayerDeck = require(Classes.GameModules.PlayerDeck)
local PlayerHand = require(Classes.GameModules.PlayerHand)
local PlayerDiscard = require(Classes.GameModules.PlayerDiscard)
local CardHolder = require(Classes.GameModules.CardHolder)
local ClientBoard = require(Classes.GameModules.ClientBoard)
local ClientUnitHolder = require(Classes.GameModules.ClientUnitHolder)
local HandLayoutManager = require(Classes.GameModules.HandLayoutManager)
local SequenceDispatcher = require(Classes.SequenceDispatcher)
local UiEventHandler = require(Classes.GameModules.UiEventHandler)

local GuiEvent = ReplicatedStorage.Client.BindableEvents.GuiEvent
local GuiFunction = ReplicatedStorage.Client.BindableFunctions.GuiFunction

local UiActions = require(Enums.GameInstance.UiActions)
local ClientEvents = require(Enums.ClientEvents)
local GameDataRequests = require(Enums.GameDataRequests)
local GameResults = require(Enums.GameResults)

local ClientNodeInstance = require(Classes.ClientNode.ClientNodeInstance)

local ClientGame = setmetatable({}, {__index = ClientNodeInstance})
ClientGame.__index = ClientGame

function ClientGame.new(instanceFolder, deckData, boardData)
	local self = ClientNodeInstance.new(instanceFolder)
	setmetatable(self, ClientGame)
	local battleGui = GuiFunction:Invoke("BattleGui", "get")
	GuiEvent:Fire("BattleGui", "reset")
	self.handLayoutManager = HandLayoutManager.new(battleGui)
	self.cardHolder = CardHolder.new(deckData, battleGui.HoldingFrame, self.handLayoutManager)
	self.clientBoard = ClientBoard.new(boardData, instanceFolder)
	self.playerDeck = PlayerDeck.new(self.cardHolder:getAllCards())
	self.playerHand = PlayerHand.new()
	self.playerDiscard = PlayerDiscard.new()
	self.clientUnitHolder = ClientUnitHolder.new(instanceFolder)
	self.sequenceDispatcher = SequenceDispatcher.new()
	
	self._playerUnit = nil
	self.isPaused = Instance.new("BoolValue") --is  used in cardselectiongui
	self.isPaused.Value = false
	self.isPlaying = Instance.new("BoolValue")
	self.isPlaying.Value = true
	self:bindDispatcher()
	self:bindEvents()
	return self
end

function ClientGame:getPlayerUnit()
	return self._playerUnit
end

function ClientGame:getCameraSubject()
	return self.clientBoard.model
end

function ClientGame:bindDispatcher()
	local dispatcher = self.sequenceDispatcher
	UiEventHandler.bind(dispatcher)
end

function ClientGame:bindEvents()
	local events = self.instanceFolder.Events
	events.ToClient.GameSyncEvent.OnClientEvent:Connect(function(sequence)
		print(sequence)
		self.sequenceDispatcher:enqueue(sequence, {clientGame = self, guiEvent = GuiEvent})
	end)

	--TODO: remove the GameUiEvent..?

	events.Bindable.ClientEvent.Event:Connect(function(clientEvent, data)
		if clientEvent == ClientEvents.TOGGLE_PAUSE then
			self.isPaused.Value = data.value --TODO: DO NOTE: that this event is CURRENTLY unused. we might need to get rid of it for unneeded purposes
		end
	end)
end

function ClientGame:updatePlayableCards(data)
	local playableCardData = data.playableCardData
	for _, cardData in ipairs(playableCardData) do
		local card = self.cardHolder:getCardById(cardData.id)
		if cardData.isPlayable then
			card:showPlayable()
		else
			card:hidePlayable()
		end
	end
end

function ClientGame:endGame(data)
	local gameResult = data.gameResult
	if gameResult == GameResults.WIN then
		task.wait(1)
		GuiEvent:Fire("BattleGui", "hide")
		local rewards = data.rewards
		GuiEvent:Fire("BattleVictoryGui", "show", rewards)
	elseif gameResult == GameResults.LOSE then
		GuiEvent:Fire("BattleGui", "hide")
	end
end

function ClientGame:createUnit(data)
	local serializedUnitData = data.serializedUnitData
	self.clientUnitHolder:addUnit(serializedUnitData, self.clientBoard)
end

function ClientGame:_drawCard(data)
	local cardId = data.cardId
	local drawnCard = self.playerDeck:draw(cardId)
	self.playerHand:add(drawnCard)
	self.handLayoutManager:addCard(drawnCard)
end

function ClientGame:_resetDeck(data)
	local deckData = data.deckData
	local discardData = data.discardData
	local newDeck = {}
	local newDiscard = {}
	for _, data in ipairs(deckData) do
		local card = self.cardHolder:getCardById(data.id)
		table.insert(newDeck, card)
	end
	for _, data in ipairs(discardData) do
		local card = self.cardHolder:getCardById(data.id)
		table.insert(newDiscard, card)
	end
	self.playerDeck:swapDeck(newDeck)
	self.playerDiscard:swapDiscard(newDiscard)
end

function ClientGame:discard(cardId)
	local card = self.cardHolder:getCardById(cardId)
	if card then
		self.playerHand:remove(card)
		self.playerDiscard:add(card)
		self.handLayoutManager:discardCard(card)
		--GuiEvent:Fire("BattleGui", "discardCard", card.model)
	else
		warn("Card doesn't exist for "..cardId.." anymore")
	end
end

function ClientGame:playCard(cardId)
	local card = self.cardHolder:getCardById(cardId)
	self.playerHand:remove(card)
	GuiEvent:Fire("BattleGui", "playCard", cardId)
end

function ClientGame:setPlayerUnit(unit)
	self._playerUnit = unit
end

function ClientGame:depleteCard(cardId)
	GuiEvent:Fire("BattleGui", "depleteCard", cardId)
end

function ClientGame:deployUnit(cardId)
	local card = self.cardHolder:getCardById(cardId)
	self.playerHand:remove(card)
	self.handLayoutManager:discardCard(card)
end

--waits for the server to respond then executes a function
function ClientGame:initResponseConnection(func)
	local connection
	local events = self.instanceFolder.Events.ToClient
	connection = events.GameUiEvent.OnClientEvent:Connect(function(uiAction, data)
		if uiAction == UiActions.GENERIC_RESPONSE then
			connection:Disconnect()
			func(data)
		end
	end)
end

return ClientGame
