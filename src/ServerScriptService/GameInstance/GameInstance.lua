local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Enums = ReplicatedStorage.Enums

local Board = require(ServerScriptService.GameInstance.Board)
local GamePlayer = require(ServerScriptService.GameInstance.GamePlayer)
local UnitHolder = require(ServerScriptService.GameInstance.UnitHolder)
local RewardsHandler = require(ServerScriptService.GameInstance.RewardsHandler)
local StateSyncBuffer = require(ServerScriptService.General.StateSyncBuffer)
local StateUpdate = require(ServerScriptService.General.StateUpdate)

local GameActions = require(Enums.GameActions)
local UiActions = require(Enums.GameInstance.UiActions)
local GameEventsTypes = require(Enums.GameEvents)
local GameDataRequests = require(Enums.GameDataRequests)
local GamePhases = require(Enums.GamePhases)
local StatusTypes = require(Enums.StatusTypes)
local DamageTypes = require(Enums.DamageTypes)
local GameResults = require(Enums.GameResults)
local CardTypes = require(Enums.CardTypes)

local TargetingRules = require(ReplicatedStorage.Helpers.GameInstance.TargetingRules)
local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local Tables = require(ReplicatedStorage.Helpers.Tables)
local env = require(ReplicatedStorage.env)

local Constants = require(ReplicatedStorage.Helpers.Constants)

local NodeInstance = require(ServerScriptService.NodeInstance.NodeInstance)
local GameInstance = {}
GameInstance.__index = GameInstance
setmetatable(GameInstance, {__index = NodeInstance}) 

function GameInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, GameInstance)
	local newBoard = Board.new(dependencies.centerPosition, dependencies.robloxPlayer)
	self.isPlayerTurn = false
	self._isPlaying = true
	self._turnCount = 0
	self.board = newBoard	
	self.unitHolder = UnitHolder.new(self.idGenerator, dependencies.eventObserver)
	self.rewardsHandler = RewardsHandler.new()
	self.rewardsHandler:initRewards(dependencies.playerState, dependencies.echoManager, dependencies.stageData.rewards, dependencies.eventObserver, self.idGenerator)
	self.player = GamePlayer.new(dependencies.robloxPlayer, dependencies.playerState, dependencies.deckData, self.idGenerator, self.unitHolder)
	self.cardRewardClaimed = false
	self.stageData = dependencies.stageData
	self.stateSyncBuffer = StateSyncBuffer.new(dependencies.robloxPlayer, self.folder.Events.ToClient.GameSyncEvent)
	self:connectEvents()
	return self
end

function GameInstance:connectEvents()
	local gameFunctions = self.folder.Functions
	local gameEvents = self.folder.Events
	
	gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data) --may change to just generic data, action parameters...
		if robloxPlayer ~= self.player.robloxPlayer then warn("invalid player sent data") return nil end
		if action == GameActions.PLAY_CARD then
			self:requestPlayCard(data)
		elseif action == GameActions.MOVE then
			local direction = data.direction
			local value = data.value or 1 --might change later..? depends on how specific we want to make effects
			local unit = self.player.unit
			local playerCanMoveUnit, reason = self.player:canMove()
			if playerCanMoveUnit and self.isPlayerTurn then
				local unitMovedSuccessfully = self:moveTarget(unit, unit, direction, value)
				if unitMovedSuccessfully then
					self.player:payMovementCost()
					self.stateSyncBuffer:addAwaitingStep()
					self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
					self.stateSyncBuffer:flush()
				end
			else
				warn(reason)
			end
		elseif action == GameActions.SELECT_CARD_REWARD then
			if not self.cardRewardClaimed then
				if data then
					self.cardRewardClaimed = true
					self:fireGameEvent(GameEventsTypes.ADD_CARD, data)
				else
					print("Card reward was skipped")
				end
			else
				warn("Card reward is already claimed for this instance")
			end
		elseif action == GameActions.END_TURN then
			self:requestEndTurn()
		elseif action == GameActions.END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		end
	end)
	
	gameFunctions.GameDataRequest.OnServerInvoke = function(robloxPlayer, requestType, data)
		if requestType == GameDataRequests.OPEN_REWARD then
			local reward = self.rewardsHandler:retrieveReward(data.id)
			if reward then
				reward:execute()
				return true
			else
				return false
			end
		elseif requestType == GameDataRequests.GET_CARD_FOR_UNIT then
			local unit = self.unitHolder:getUnit(data.unitId)
			local card = unit:getLoadedCard()
			return card.id
		end
		return nil
	end
end

function GameInstance:requestPlayCard(data)
	local cardId = data.cardId
	local targetCoordinates = data.targetCoordinates
	local caster = self.player.unit
	local cardToPlay = self.player.hand:getCardById(cardId)
	if not cardToPlay then
		warn("card is not in hand anymore")
	end
	local context = CardExecutionContext.new(self, cardToPlay.cardData, caster, targetCoordinates)
	if TargetingRules.canBePlayed(context) and self.player:canPlayCard(cardToPlay) then
		self:executePlayerCard(cardToPlay, context)
	else
		print("Failed to use card")
	end
end

function GameInstance:requestEndTurn()
	if self.isPlayerTurn and self.player:canEndTurn() then
		self.isPlayerTurn = false
		local handCards = Tables.shallowCopy(self.player.hand:getCards())
		for i, card in ipairs(handCards) do
			--self.player:discardCard(card)
			self:discardCard(card)
		end
		self:endUnitTurn(self.player.unit)
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
		self.stateSyncBuffer:flush()
		print("Flushing player")
		self:startEnemyTurn()
	end
end

function GameInstance:relayEvent(eventType, data)
	if eventType == GameEventsTypes.OPENING_CARD_PACK then
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.OPEN_CARD_PACK, data))
		self.stateSyncBuffer:flush()
	end
end

function GameInstance:getTurnCount()
	return self._turnCount
end

function GameInstance:executePlayerCard(cardToPlay, context: ContextType.context)
	self.player.executingCard = true
	self.player:payCost(cardToPlay)
	self.player.hand:remove(cardToPlay)
	self.stateSyncBuffer:addAwaitingStep()
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.PLAY_CARD, {cardId = cardToPlay.id}))
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
	--self:updateClientUi(UiActions.PLAY_CARD, cardToPlay:toTable())
	self:_executeCard(cardToPlay, context)
	if not cardToPlay:isDepletable() and cardToPlay.cardData.cardType ~= CardTypes.DEPLOY then
		self:discardCard(cardToPlay)
	elseif cardToPlay:isDepletable() then
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.DEPLETE_CARD, {cardId = cardToPlay.id}))
		self:fireGameEvent(GameEventsTypes.DEPLETING_CARD, {card = cardToPlay}) 
	elseif cardToPlay.cardData.cardType == CardTypes.DEPLOY then
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.DEPLOY_UNIT, {cardId = cardToPlay.id}))
	end
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
	print("Flushing player card execution")
	self.stateSyncBuffer:flush()
	self.player.executingCard = false
	--self:updatePlayableCards()
end

function GameInstance:_executeCard(cardToPlay, context: ContextType.context)
	local caster = context:getCaster()
	local primaryTargets = TargetingRules.getValidTargets(context)
	local effectTargets = TargetingRules.getEffectTargets(primaryTargets, context)
	local effectTargetIds = Tables.strip(effectTargets, "Id")
	local primaryTargetIds = Tables.strip(primaryTargets, "Id")
	self:fireGameEvent(GameEventsTypes.PLAY_CARD, {card = cardToPlay, targets = effectTargets, caster = caster})
	local castAnimation = cardToPlay.cardData.unitAnimation
	local cardAnimation = cardToPlay.cardData.animationClass
	if castAnimation then
		self.stateSyncBuffer:addStep(true, {
			StateUpdate.new(UiActions.PLAY_UNIT_ANIMATION, {
				unitId = caster.Id, animation = castAnimation
			})
		})
	end
	if cardAnimation then
		self.stateSyncBuffer:addAwaitingStep()
		self.stateSyncBuffer:addStep(true, {
			StateUpdate.new(UiActions.PLAY_CARD_ANIMATION, {
				unitId = caster.Id, 
				cardId = cardToPlay.id, 
				primaryTargetsIds = primaryTargetIds,
				targetIds = effectTargetIds
			})
		})
	end
	cardToPlay:play(primaryTargets, effectTargets, self, context)
end

function GameInstance:discardCard(card)
	self.player:discardCard(card)
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.DISCARD, {cardId = card.id}))
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
	--self:updatePlayableCards()
end

function GameInstance:executeAiCard(cardToPlay, context: ContextType.context)
	--maybe enemy pays cost?
	--usually AI won't have a present set of targets, default is {}
	--todo: remove the card from the list in the ai interface
	self:_executeCard(cardToPlay, context)
end

function GameInstance:loadStage(stageData)
	for _, unitData in ipairs(stageData.units) do
		local unit = self.unitHolder:addAiUnit(unitData.name)
		local initNode = self.board:getEnemyNode(unitData.position)
		unit:moveToNode(initNode)
		self.board:occupyNodeAt(initNode.coordinates, unit)
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.CREATE_UNIT, {serializedUnitData = unit:serialize()}))
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_NODE, initNode:serialize()))
	end
end

function GameInstance:loadPlayer(playerState)
	local unit = self.unitHolder:addPlayerUnit(playerState.unitName, self.player.robloxPlayer.Name, playerState)
	self.player.unit = unit
	local initNode = self.board:getPlayerNode(Vector2.new(2,2))
	unit:moveToNode(initNode)
	self.board:occupyNodeAt(initNode.coordinates, unit)
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.CREATE_UNIT, {serializedUnitData = unit:serialize()}))
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.SET_PLAYER_UNIT, {serializedUnitData = unit:serialize()}))
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_NODE, initNode:serialize()))
	self.player.deck:shuffle()
end

function GameInstance:connectPlayerToInstance(nodeType)
	local cardData = self.player.deck:serialize()
	local boardData = self.board:serialize()
	self:fireGameEvent(GameEventsTypes.CONNECT_TO_INSTANCE, {
		nodeType = nodeType, 
		folder = self.folder, 
		args = {
			cardData, boardData
		}
	})
end

function GameInstance:deployUnit(caster, targetNodes, deployData, card)
	for _, node in ipairs(targetNodes) do --if this happens more than once we are cooked
		local unit = self.unitHolder:deployUnit(caster, node, deployData, card, self.eventObserver, self)
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.CREATE_UNIT, {serializedUnitData = unit:serialize()}))
	end
	--self:updatePlayableCards()
end

function GameInstance:moveTarget(caster, target, direction, value)
	local oldCoordinates = target.coordinates
	local newCoordinates = target.coordinates + direction
	--TODO: fix out of bounds issue here
	if newCoordinates.X > 0 and newCoordinates.Y > 0 and newCoordinates.X < Constants.BOARD_SIZE.X+1 and newCoordinates.Y < Constants.BOARD_SIZE.Y+1 then
		if not self.board:isNodeAtCoordsOccupied(newCoordinates) then
			local moveData = {canMove = true}
			local targetNode = self.board:getNode(newCoordinates)
			local previousNode = self.board:getNode(oldCoordinates)
			self:fireGameEvent(GameEventsTypes.BEFORE_MOVE, {target = target, oldNode = previousNode, newNode = targetNode, moveData = moveData})
			if caster ~= target or moveData.canMove then --other users can move the target regardless of canMove
				if targetNode.Team == target.Team then
					self.board:occupyNodeAt(newCoordinates, target)
					target:moveToNode(targetNode)
					self.board:unoccupyNodeAt(oldCoordinates)
					targetNode:enable(self.eventObserver, target, self)
					previousNode:disable(target, self)
					self:fireGameEvent(GameEventsTypes.MOVED, {target = target, source = caster, oldNode = previousNode, newNode = targetNode})
					self.stateSyncBuffer:addAwaitingStep()
					self.stateSyncBuffer:add(StateUpdate.new(UiActions.MOVE_UNIT, {unitId = target.Id, coordinates = target.coordinates}))
					self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_NODE, targetNode:serialize()))
					--self:updatePlayableCards() TODO: do in  the state sync buffer probably
					return true
				else
					warn("not on same team")
				end
			end
		else
			warn("not an available node")
		end
	else
		warn("out of bounds")	
	end
	return false
end

function GameInstance:dealDamage(source, targets, damageAmount, damageType)
	self:fireGameEvent(GameEventsTypes.ATTACKING, {source = source, targets = targets})
	if #targets == 0 then
		warn("No targets found to damage")
		return 
	end
	self.stateSyncBuffer:addAwaitingStep()
	for _, target in ipairs(targets) do
		if not target:canTakeDamage() then continue end
		local damageObject = {damage = self:calculateFinalDamage(source, target, damageAmount, damageType)}
		self:fireGameEvent(GameEventsTypes.BEFORE_DAMAGE, {damageObject = damageObject, source = source, target = target})
		if damageObject.damage < 0 then
			damageObject.damage = 0
		end
		local healthLost, blockLost = target:takeDamage(damageObject.damage)
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.DEAL_DAMAGE, {
			unitId = target.Id, 
			healthLost = healthLost, 
			blockLost = blockLost,
			newHealth = target.health,
			newBlock = target.block
		}))
		self:fireGameEvent(GameEventsTypes.HEALTH_CHANGED, {target})
		--[[
		if blockLost > 0 or healthLost == 0 then
			AudioClientEvent:FireClient(self.robloxPlayer, AudioSettings.PLAY_SOUND, AudioRepo.SFX.Generic_Blocked)
		else
			AudioClientEvent:FireClient(self.robloxPlayer, AudioSettings.PLAY_SOUND, AudioRepo.SFX.Generic_Damaged)
		end
		--]]
		if self.player.unit == target then
			self:fireGameEvent(GameEventsTypes.PLAYER_HEALTH_HURT_HEAL, {value = -1 * healthLost})
		end
		if not target.isAlive then
			self:fireGameEvent(GameEventsTypes.DEATH, target)
			self.stateSyncBuffer:add(StateUpdate.new(UiActions.KILL_UNIT, {unitId = target.Id}))
			self:removeUnitFromGame(target)
			self:checkForGameEnd(target)
		end
		self:fireGameEvent(GameEventsTypes.AFTER_DAMAGE, {healthLost = healthLost, blockLost = blockLost, source = source, target = target, damageType = damageType})
	end
end

function GameInstance:checkForGameEnd(lastDeathTarget)
	local teamUnits = self.unitHolder:getAllies(lastDeathTarget.Team)
	if #teamUnits == 0 then
		if lastDeathTarget.Team == "Game" then
			self.isPlayerTurn = false
			self._isPlaying = false
			--TODO: change these to the sequencedispatcher
			self.stateSyncBuffer:add(StateUpdate.new(UiActions.END_GAME, {gameResult = GameResults.WIN, rewards = self.rewardsHandler:serializeRewards()}))
		elseif lastDeathTarget.Team == self.player.robloxPlayer.Name then
			self.isPlayerTurn = false
			self._isPlaying = false
			self.stateSyncBuffer:add(StateUpdate.new(UiActions.END_GAME, {gameResult = GameResults.LOSE}))
		else
			print("Not a real unit")
		end
	end
end

function GameInstance:removeUnitFromGame(unit)
	self.board:unoccupyNodeAt(unit.coordinates)
	unit:kill(self)
	self.unitHolder:removeUnit(unit)
end

--[[
function GameInstance:depleteCard(cardId)
	local card = self.player.deck:getCardById(cardId)
	local success = self.player.deck:remove(card)
	if success then
		self:updateClientUi(UiActions.DEPLETE_CARD, {cardId = cardId})
		self:fireGameEvent(GameEventsTypes.DEPLETING_CARD, {card = card})
	else
		warn("didn't deplete card ", card)
	end
end
]]

function GameInstance:applyHeal(source, targets, healAmount)
	self:fireGameEvent(GameEventsTypes.HEALING, {source = source, targets = targets})
	if #targets == 0 then
		warn("No targets found to heal")
		return 
	end
	for _, target in ipairs(targets) do
		local finalHeal = self:calculateFinalDamage(source, target, healAmount)
		local healthGained = target:heal(finalHeal)
		self:fireGameEvent(GameEventsTypes.HEALTH_CHANGED, {target})
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.APPLY_HEAL, 
			{
				unitId = target.Id,
				healthGained = healthGained,
				newHealth = target.health
			}))
		if self.player.unit == target then
			self:fireGameEvent(GameEventsTypes.PLAYER_HEALTH_CHANGED, {
				health = target.health, 
				maxHealth = target.maxHealth
			})
		end
	end
end

function GameInstance:applyBlock(source, targets, blockAmount)
	self:fireGameEvent(GameEventsTypes.BLOCKING, {source = source, targets = targets})
	if #targets == 0 then
		warn("No targets found to block")
		return 
	end
	for _, target in ipairs(targets) do
		local finalBlock = self:calculateFinalBlock(source, target, blockAmount)
		local appliedBlock = target:applyBlock(finalBlock)
		self:fireGameEvent(GameEventsTypes.APPLYING_BLOCK, {source = source, target = target, blockAmount = appliedBlock})
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.APPLY_BLOCK, 
			{
				unitId = target.Id,
				value = target.block,
			}))
	end
end

function GameInstance:resetUnitBlock(unit)
	unit:removeBlock()
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.APPLY_BLOCK, 
		{
			unitId = unit.Id,
			value = unit.block,
		}))
end

function GameInstance:applyStatus(source, targets, statusType, value)
	self.stateSyncBuffer:addAwaitingStep()
	for _, target in ipairs(targets) do
		self:fireGameEvent(GameEventsTypes.BEFORE_APPLY_STATUS, {statusType = statusType, value = value, source = source, target = target})
		target:applyStatus(statusType, value, self.eventObserver, self, self.deckManager, self.playerState)
		self:fireGameEvent(GameEventsTypes.APPLYING_STATUS, {statusType = statusType, value = value, source = source, target = target})
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_STATUS, {
			unitId = target.Id,
			statusData = target.statusManager:serialize()
		}))
	end
end

function GameInstance:removeStatus(targets, statusType, value)
	for _, target in ipairs(targets) do
		target:removeStatus(statusType, value)
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_STATUS, {
			unitId = target.Id,
			statusData = target.statusManager:serialize()
		}))
	end
end

function GameInstance:calculateFinalBlock(source, target, value)
	local blockBuffStatus = source:getStatus(StatusTypes.BLOCK_BUFF)
	if blockBuffStatus then
		value += blockBuffStatus.value
	end
	return value
end

function GameInstance:calculateFinalHeal(source, target, value)
	--TODO adjust based on stuff?
	return value
end

function GameInstance:calculateFinalDamage(source, target, value, damageType)
	if damageType == DamageTypes.DIRECT then
		local strengthStatus = source:getStatus(StatusTypes.STRENGTH_BUFF)
		local criticalStatus = source:getStatus(StatusTypes.CRITICAL_BUFF)
		local weakenStatus = source:getStatus(StatusTypes.WEAKEN_DEBUFF)
		
		local defenseStatus = target:getStatus(StatusTypes.DEFENSE_UP)
		local vulnerableStatus = target:getStatus(StatusTypes.VULNERABLE_DEBUFF)
		
		if strengthStatus then
			value += strengthStatus.value
		end
		if criticalStatus then
			value *= Constants.INSTANCE_SETTINGS.BATTLE_SETTINGS.CRITICAL_VALUE
		end
		
		if defenseStatus then
			value -= defenseStatus.value
			if value < 0 then
				value = 0
			end
		end
		if vulnerableStatus then
			value *= Constants.INSTANCE_SETTINGS.BATTLE_SETTINGS.VULNERABLE_VALUE
		end
		if weakenStatus then
			value -= Constants.INSTANCE_SETTINGS.BATTLE_SETTINGS.WEAKEN_VALUE * value
		end
		value = math.ceil(value)
	elseif damageType == DamageTypes.DAMAGE_OVER_TIME then
		value = value --Modifiers?
	end
	return value
end

function GameInstance:grantEnergy(unit, value)
	if unit == self.player.unit then
		self.player:grantEnergy(value)	
		self:fireGameEvent(GameEventsTypes.GRANT_ENERGY, {unit = unit, value = value})	
	else
		warn("Cannot give unit energy", unit, value)
	end
end

function GameInstance:changeNodeType(node, nodeType)
	local units = self.unitHolder:getAll()
	local onTileUnit = nil
	for _, unit in ipairs(units) do
		if unit.coordinates == node.coordinates then
			onTileUnit = unit
			break
		end
	end
	--if the unit exists, disable the past node
	--then set the node to the new node type
	--then enable the node
	if onTileUnit then
		node:disable(onTileUnit, self)
	end
	node:changeType(nodeType)
	if onTileUnit then
		node:enable(self.eventObserver, onTileUnit, self)
	end
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_NODE, node:serialize()))
end

function GameInstance:drawCards(numCards)
	local cards = {}
	self.stateSyncBuffer:addAwaitingStep()
	local function drawCard()
		local drawnCard = self.player:draw()
		self.stateSyncBuffer:add(StateUpdate.new(UiActions.DRAW, {
			cardId = drawnCard.id, 
			deckData = self.player.deck:serialize()
		}))
		table.insert(cards, drawnCard.id)
	end
	for i = 1, numCards do
		if self.player.deck:canDraw() then
			drawCard()
		else
			--if player's discard has something
			if #self.player.discard.cards > 0 then
				self.player:resetDeck()
				local data = {
					deckData = self.player.deck:serialize(), 
					discardData = self.player.discard:toTable()
				}
				self.stateSyncBuffer:addAwaitingStep()
				self.stateSyncBuffer:add(StateUpdate.new(UiActions.RESET_DECK, data))
				self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
				self:fireGameEvent(GameEventsTypes.SHUFFLE, data)
				self.stateSyncBuffer:addAwaitingStep()
				drawCard()
			else
				print("No more cards to draw")
			end
		end
	end
	self:fireGameEvent(GameEventsTypes.DRAW, {cardIds = cards})
end

--called to initiate the game
function GameInstance:start()
	self:loadPlayer(self.playerState)
	self:loadStage(self.stageData)
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.SHOW_GUI, {guiName = "BattleGui"}))
	self:startPlayerTurn()
	self:fireGameEvent(GameEventsTypes.GAME_START, self)
end

function GameInstance:startUnitTurn(unit)
	if not self._isPlaying then return end
	self:fireGameEvent(GameEventsTypes.START_UNIT_TURN, {unit = unit})
end

function GameInstance:endUnitTurn(unit)
	if not self._isPlaying then return end
	self:fireGameEvent(GameEventsTypes.END_UNIT_TURN, {unit = unit})
	unit:tickStatus()	
	self.stateSyncBuffer:addAwaitingStep()
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_STATUS, {
		unitId = unit.Id,
		statusData = unit.statusManager:serialize()
	}))
end

function GameInstance:startPlayerTurn()
	if not self._isPlaying then return end
	self._turnCount += 1
	self:drawCards(self.player.turnCards)
	self.player:replenishEnergy()
	self.player:replenishMovement()
	self:startUnitTurn(self.player.unit)
	self:resetUnitBlock(self.player.unit)
	self:fireGameEvent(GameEventsTypes.CHANGE_PHASE, {phase = GamePhases.PLAYER_TURN})
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.CHANGE_PHASE, {phase = GamePhases.PLAYER_TURN}))
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_FRAMES, self:getUiData()))
	self:reloadEnemyActions()
	self.isPlayerTurn = true
	--self:updatePlayableCards()
	print("Flushing player start turn")
	self.stateSyncBuffer:flush()
end

function GameInstance:updatePlayableCards()
	local playableCardData = {}
	local handCards = self.player:getHand()
	for _, card in ipairs(handCards) do
		table.insert(playableCardData, {id = card.id, isPlayable = self:cardCanBePlayed(card, nil, self.player.unit.Id)})
	end
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.UPDATE_PLAYABLE_CARDS, {playableCardData = playableCardData}))
end

function GameInstance:reloadEnemyActions()
	local enemies = self.unitHolder:getEnemies(self.player.unit.Team)
	for _, enemy in ipairs(enemies) do
		enemy:reloadActions(self)
	end
end

function GameInstance:startEnemyTurn()
	if not self._isPlaying then return end
	self:fireGameEvent(GameEventsTypes.CHANGE_PHASE, {phase = GamePhases.ENEMY_TURN})
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.CHANGE_PHASE, {phase = GamePhases.ENEMY_TURN}))
	local enemies = self.unitHolder:getEnemies(self.player.unit.Team)
	local lastEnemy = nil
	for _, enemy in ipairs(enemies) do
		self:resetUnitBlock(enemy)
	end
	for _, enemy in ipairs(enemies) do
		if env.ENV ~= "test" then
			wait(1)
		end
		if lastEnemy then
			lastEnemy.Hover = false
		end
		lastEnemy = enemy
		lastEnemy.Hover = true
		self:startUnitTurn(enemy)
		enemy:executeActions(self)
		self:endUnitTurn(enemy)
		print("Flushing enemy end turn")
		self.stateSyncBuffer:flush()
	end
	if lastEnemy then
		lastEnemy.Hover = false
	end
	self:startPlayerTurn()
end

function GameInstance:getUiData()
	local uiData = {
		Energy = {
			currentValue = self.player.energy,
			turnValue = self.player.turnEnergy
		},
		Movement = {
			currentValue = self.player.movement,
			turnValue = self.player.turnMovement
		},
		Deck = {
			value = #self.player.deck.cards
		},
		Discard = {
			value = #self.player.discard.cards
		}
	}
	return uiData
end


return GameInstance