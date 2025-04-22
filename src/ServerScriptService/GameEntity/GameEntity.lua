local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local IdGenerator = require(ReplicatedStorage.Helpers.Classes.IdGenerator)

local PlayerState = require(ServerScriptService.GameEntity.PlayerState)
local DeckManager = require(ServerScriptService.GameEntity.DeckManager)
local EchoManager = require(ServerScriptService.GameEntity.EchoManager)
local EventObserver = require(ServerScriptService.GameEntity.EventObserver)
local Map = require(ServerScriptService.GameEntity.Map)
local NodeInstanceFactory = require(ServerScriptService.NodeInstance.NodeInstanceFactory)
local StateSyncBuffer = require(ServerScriptService.General.StateSyncBuffer)
local StateUpdate = require(ServerScriptService.General.StateUpdate)

local EntityActions = require(ReplicatedStorage.Enums.Entity.EntityActions)
local EntityUIActions = require(ReplicatedStorage.Enums.Entity.EntityUiActions)
local ScreenTransitionTypes = require(ReplicatedStorage.Enums.Client.ScreenTransitionTypes)
local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
local EntityDataRequests = require(ReplicatedStorage.Enums.Entity.EntityDataRequests)
local MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)

local GameEntityFolder = ReplicatedStorage.Models.Entity.GameEntity

local GameEntity = {}
GameEntity.__index = GameEntity

function GameEntity.new(robloxPlayer, data)
	local self = setmetatable({}, GameEntity)
	local entityFolder = GameEntityFolder:Clone()
	entityFolder.Parent = workspace
	self.entityFolder = entityFolder
	self.idGenerator = IdGenerator.new()
	self.robloxPlayer = robloxPlayer
	self.nodeInstance = nil
	self.playerState = PlayerState.new(robloxPlayer, data)
	self.eventObserver = EventObserver.new()
	self.deckManager = DeckManager.new(data.deck, self.idGenerator)
	self.instanceFactory = NodeInstanceFactory.new()
	self.stateSyncBuffer = StateSyncBuffer.new(robloxPlayer, self.entityFolder.Events.ToClient.EntityUiEvent)
	self.echoManager = EchoManager.new(self.eventObserver, self.idGenerator, self.playerState, self.deckManager, function()
		return self.nodeInstance
	end)
	self.mapManager = Map.new(entityFolder, self.idGenerator)
	return self
end

function GameEntity:init()
	self:generateNewMap()
	self:connectEvents()
	self:subscribeToObserver(self.eventObserver)
	self:initializePlayerUi()
	return self
end

function GameEntity:initializePlayerUi()
	local updates = {
		StateUpdate.new(EntityUIActions.UPDATE_PLAYER_HEALTH, {
			health = self.playerState.health, 
			maxHealth = self.playerState.maxHealth
		}),
		StateUpdate.new(EntityUIActions.UPDATE_PLAYER_MONEY, {
			money = self.playerState.money
		}),
		StateUpdate.new(EntityUIActions.UPDATE_PLAYER_DECK, {
			deck = self.deckManager:serialize()
		})
	}
	self:updateClientUiWithUpdates(updates)
end

function GameEntity:getEntityActionEvent()
	return self.entityFolder.Events.ToServer.EntityActionRequest
end

function GameEntity:connectEvents()
	self:getEntityActionEvent().OnServerEvent:Connect(function(player, actionType, data)
		if actionType == EntityActions.RETURN_TO_MAP then
			self.stateSyncBuffer:add(StateUpdate.new(EntityUIActions.HIDE_SCREEN, {transitionType = ScreenTransitionTypes.INSTANT}))
			self.stateSyncBuffer:flush()
			self:returnToMap()
			self.stateSyncBuffer:add(StateUpdate.new(EntityUIActions.SHOW_SCREEN, {transitionType = ScreenTransitionTypes.INSTANT}))
			self.stateSyncBuffer:flush()
		elseif actionType == EntityActions.START_GAME then
			if self.nodeInstance == nil then
				local nodeId = data.nodeId
				local node = self.mapManager:getNodeById(nodeId)
				local isValidNextNode = self.mapManager:isValidNextNode(node)
				if isValidNextNode then
					self:updateClientUiWithUpdate(EntityUIActions.HIDE_SCREEN, {transitionType = ScreenTransitionTypes.INSTANT})
					self.mapManager:updateCurrentNode(node)
					self:startInstance(node.nodeType, node.data)
					self:updateClientUiWithUpdate(EntityUIActions.SHOW_SCREEN, {transitionType = ScreenTransitionTypes.INSTANT})
				end
			else
				warn("Game instance already exists!")
			end
		end
	end)
end

function GameEntity:destroy()  --TODO: test this refactor
	self.eventObserver:destroy()
	self.echoManager:destroy()
	self.deckManager:destroy()
	self.mapManager:destroy()
	if self.nodeInstance then self.nodeInstance:Destroy() end
	self.entityFolder:Destroy()

	for k in pairs(self) do self[k] = nil end
	setmetatable(self, nil)
end

function GameEntity:generateNewMap()
	self.mapManager:generate(self.playerState)
	local serializedNodes = self.mapManager:serializeNodes()
	self:updateClientUiWithUpdate(EntityUIActions.GENERATE_NEW_MAP, {mapFolder = self.mapManager.mapFolder, mapData = serializedNodes})
end

function GameEntity:returnToMap()
	local currentNode = self.mapManager:getCurrentNode()
	local sentCurrentNodeId = nil
	if self.mapManager.currentNode then --hacky, but need to send nil if its nil
		sentCurrentNodeId = currentNode.Id
	end
	self:updateClientUiWithUpdates({
		StateUpdate.new(EntityUIActions.DISCONNECT_FROM_INSTANCE, {}),
		StateUpdate.new(EntityUIActions.UPDATE_MAP_DATA, 
			{updateData = self.mapManager:findAndClearDirtyNodes(), currentNodeId = sentCurrentNodeId}
		),
		StateUpdate.new(EntityUIActions.ENABLE_MAP_CONTROL, 
			{nodeId = currentNode.Id}
		)
	})
end

--should be the only spots we're able to use the state sync buffer
function GameEntity:updateClientUiWithUpdate(uiAction, data)
	self.stateSyncBuffer:add(StateUpdate.new(uiAction, data))
	self.stateSyncBuffer:flush()
end

function GameEntity:updateClientUiWithUpdates(updates)
	self.stateSyncBuffer:addStep(true, updates)
	self.stateSyncBuffer:flush()
end

function GameEntity:subscribeToObserver(observer)
	observer:subscribeTo(GameEvents.FINISH_GAME, function(data)
		self:updateClientUiWithUpdate(EntityUIActions.SHOW_END_GAME)
	end)
	
	observer:subscribeTo(GameEvents.PLAYER_HEALTH_CHANGED, function(data)
		self.playerState:updateHealth(data.health, data.maxHealth)
		self:updateClientUiWithUpdate(EntityUIActions.UPDATE_PLAYER_HEALTH, data)
		if self.nodeInstance and (self.nodeInstance.mapNodeType == MapNodeTypes.REGULAR_ENEMY or self.nodeInstance.mapNodeType == MapNodeTypes.BOSS_ENEMY or self.nodeInstance.mapNodeType == MapNodeTypes.ELITE_ENEMY)  then
			self.nodeInstance.player.unit:setHealth(data.health)	
			self.nodeInstance.player.unit:setMaxHealth(data.maxHealth)	
		end
	end)
	
	observer:subscribeTo(GameEvents.PLAYER_HEALTH_HURT_HEAL, function(data)
		local currentHealth, maxHealth = self.playerState:changeHealthByAmount(data.value)
		self:updateClientUiWithUpdate(EntityUIActions.UPDATE_PLAYER_HEALTH, {health = currentHealth, maxHealth = maxHealth})
		if self.playerState:isDead()  then
			self:fireGameEvent(GameEvents.FINISH_GAME)
 		else
			if self.nodeInstance and (self.nodeInstance.mapNodeType == MapNodeTypes.REGULAR_ENEMY or self.nodeInstance.mapNodeType == MapNodeTypes.BOSS_ENEMY or self.nodeInstance.mapNodeType == MapNodeTypes.ELITE_ENEMY)  then
				self.nodeInstance.player.unit:setHealth(currentHealth)		
			end
		end
	end)
	
	observer:subscribeTo(GameEvents.ADD_ECHO, function(data)
		local newEcho = self.echoManager:add(data.echoName)
		self:updateClientUiWithUpdate(EntityUIActions.ADD_ECHO, {id = newEcho.id, echoData = newEcho.data})
	end)
	
	observer:subscribeTo(GameEvents.CHANGE_MONEY, function(data)
		self.playerState:updateMoney(data.moneyChange)
		self:updateClientUiWithUpdate(EntityUIActions.UPDATE_PLAYER_MONEY, {money = self.playerState.money})
	end)
	
	observer:subscribeTo(GameEvents.ADD_CARD, function(data)
		local card = self.deckManager:addCard(data)
		self:updateClientUiWithUpdate(EntityUIActions.UPDATE_PLAYER_DECK, {deck = self.deckManager:serialize()})
	end)
	
	observer:subscribeTo(GameEvents.OPENING_CARD_PACK, function(data)
		self.nodeInstance:relayEvent(GameEvents.OPENING_CARD_PACK, data)
	end)
	
	observer:subscribeTo(GameEvents.FINISH_INSTANCE, function(data)
		self:updateClientUiWithUpdate(EntityUIActions.HIDE_SCREEN, {transitionType = ScreenTransitionTypes.INSTANT})
		local heldNodeType = data.mapNodeType 
		self.nodeInstance:Destroy()
		self.nodeInstance = nil
		if heldNodeType == MapNodeTypes.BOSS_ENEMY then 
			self.mapManager:reset(self.entityFolder)
			self.playerState:levelUp()
			self:generateNewMap()
		end
		self:returnToMap()
		self:updateClientUiWithUpdate(EntityUIActions.SHOW_SCREEN, {transitionType = ScreenTransitionTypes.FADE})
	end)	
	
	observer:subscribeTo(GameEvents.UPDATE_ECHO_COUNT, function(data)
		self:updateClientUiWithUpdate(EntityUIActions.UPDATE_ECHO_COUNT, {id = data.id, count = data.count})
	end)
	
	observer:subscribeTo(GameEvents.UPGRADE_CARD, function(data)
		local unupgradedCard = self.deckManager:getCardById(data.cardId):serialize()
		local upgradedCard = self.deckManager:upgradeCardById(data.cardId):serialize()
		self:updateClientUiWithUpdates({
			StateUpdate.new(EntityUIActions.UPGRADE_CARD, {unupgradedCard = unupgradedCard, upgradedCard = upgradedCard}),
			StateUpdate.new(EntityUIActions.UPDATE_PLAYER_DECK, {deck = self.deckManager:serialize()})
		})
	end)
	
	observer:subscribeTo(GameEvents.CONNECT_TO_INSTANCE, function(data)
		--ClientObjectLoader.WaitForObjectLoaded(self.robloxPlayer, data.folder)
		self:updateClientUiWithUpdate(EntityUIActions.CONNECT_TO_INSTANCE, data)
	end)
end

function GameEntity:fireGameEvent(event, ...)
	self.eventObserver:emit(event, ...)
end

function GameEntity:startInstance(nodeType, stageData)
	self:updateClientUiWithUpdate(EntityUIActions.DISABLE_MAP_CONTROL, {})
	local centerPosition = Vector3.new(50, 1, 50)
	local dependencies = {
		mapNodeType = nodeType, 
		robloxPlayer = self.robloxPlayer, 
		playerState = self.playerState, 
		deckManager = self.deckManager,
		deckData = self.deckManager:getPlayableDeck(), 
		echoManager = self.echoManager, 
		stageData = stageData, 
		parent = workspace, 
		centerPosition = centerPosition, 
		idGenerator = self.idGenerator, 
		eventObserver = self.eventObserver,
	}
	local newNodeInstance = self.instanceFactory:createInstance(nodeType, dependencies)
	self.nodeInstance = newNodeInstance
	local nodeInstanceType = newNodeInstance.mapNodeType
	newNodeInstance:connectPlayerToInstance(nodeInstanceType)
	newNodeInstance:start()
	self.eventObserver:emit(GameEvents.ENTERED_INSTANCE, newNodeInstance)
	self:updateClientUiWithUpdate(EntityUIActions.CAMERA_FOCUS_INSTANCE, {})
end

return GameEntity