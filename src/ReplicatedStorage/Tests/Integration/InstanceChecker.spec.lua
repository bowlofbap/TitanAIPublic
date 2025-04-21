return function()
	describe("Instances", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
		local MockedPlayer
		local MockedData
		local MapNodeTypes
		local NodeInstanceFactory
		local IdGenerator
		local EventObserver
		local PlayerState
		local DeckManager
		local CurrentInstance
		local EchoManager
		local MockedStageData
		local MockedPosition
		local dependencies
		
		beforeEach(function()
			print("setting up for new instance")
			MockedPlayer = Instance.new("Part")
			MockedData = require(ReplicatedStorage.Repos.StarterRepos.TestData)
			MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)
			NodeInstanceFactory = require(ServerScriptService.NodeInstance.NodeInstanceFactory).new()
			IdGenerator = require(ReplicatedStorage.Helpers.Classes.IdGenerator).new()
			EventObserver = require(ServerScriptService.GameEntity.EventObserver).new()
			PlayerState = require(ServerScriptService.GameEntity.PlayerState).new(MockedPlayer, MockedData)
			DeckManager = require(ServerScriptService.GameEntity.DeckManager).new(MockedData.deck, IdGenerator)
			EchoManager = require(ServerScriptService.GameEntity.EchoManager).new(EventObserver, IdGenerator, PlayerState, DeckManager, function()
				return CurrentInstance
			end)
			MockedPosition = Vector3.new(0,0,0)
		end)

		afterEach(function()
			print("teardown instance")
			CurrentInstance:Destroy()
			CurrentInstance = nil
		end)

		it("Confirms that GameInstance is initialized correctly", function()
			local CurrentMapNodeType = MapNodeTypes.REGULAR_ENEMY
			MockedStageData = require(ReplicatedStorage.Stages.Level1).test[1]
			dependencies = {
				mapNodeType = CurrentMapNodeType, 
				robloxPlayer = MockedPlayer, 
				playerState = PlayerState, 
				deckManager = DeckManager,
				deckData = DeckManager:getPlayableDeck(), 
				echoManager = EchoManager, 
				stageData = MockedStageData, 
				parent = workspace, 
				centerPosition = MockedPosition, 
				idGenerator = IdGenerator, 
				eventObserver = EventObserver,
			}
			CurrentInstance = NodeInstanceFactory:createInstance(CurrentMapNodeType, dependencies)
			CurrentInstance:start()
			expect(CurrentInstance._turnCount).to.equal(1)
			expect(CurrentInstance._isPlaying).to.equal(true)
			expect(CurrentInstance.isPlayerTurn).to.equal(true)
			expect(#CurrentInstance.unitHolder:getAll()).to.equal(#MockedStageData.units + 1)
		end)

		it("Confirms ChestInstance is initalized correctly", function()
			local CurrentMapNodeType = MapNodeTypes.CHEST
			MockedStageData = require(ReplicatedStorage.Stages.Level1).test[1]
			dependencies = {
				mapNodeType = CurrentMapNodeType, 
				robloxPlayer = MockedPlayer, 
				playerState = PlayerState, 
				deckManager = DeckManager,
				deckData = DeckManager:getPlayableDeck(), 
				stageData = MockedStageData, 
				echoManager = EchoManager, 
				parent = workspace, 
				centerPosition = MockedPosition, 
				idGenerator = IdGenerator, 
				eventObserver = EventObserver,
			}
			CurrentInstance = NodeInstanceFactory:createInstance(CurrentMapNodeType, dependencies)
			CurrentInstance:start()
			expect(CurrentInstance.cardRewardClaimed).to.equal(false)
			local reward = CurrentInstance.rewardsHandler:serializeRewards()[1]
			expect(CurrentInstance:openReward({id = reward.id})).to.equal(true)
		end)

		it("Confirms ShopInstance is initalized correctly", function()
			local purchaseReflected = false
			EventObserver:subscribeTo(GameEvents.CHANGE_MONEY, function(data)
				purchaseReflected = true
			end)

			local CurrentMapNodeType = MapNodeTypes.SHOP
			dependencies = {
				mapNodeType = CurrentMapNodeType, 
				robloxPlayer = MockedPlayer, 
				playerState = PlayerState, 
				deckManager = DeckManager,
				deckData = DeckManager:getPlayableDeck(),
				echoManager = EchoManager, 
				parent = workspace, 
				centerPosition = MockedPosition, 
				idGenerator = IdGenerator, 
				eventObserver = EventObserver,
			}
			PlayerState:updateMoney(1000)
			local previousMoney = PlayerState:getMoney()
			CurrentInstance = NodeInstanceFactory:createInstance(CurrentMapNodeType, dependencies)
			CurrentInstance:start()
			local id, cardData = next(CurrentInstance.shopManager.cardData)
			local success, purchasedCardData, cost = CurrentInstance:requestPurchase({id = id})
			expect(success).to.equal(true)
			expect(cardData).to.equal(purchasedCardData)
			expect(purchaseReflected).to.equal(true)
		end)

		it("Confirms RestInstance is initalized correctly", function()
			local rested = false
			EventObserver:subscribeTo(GameEvents.PLAYER_HEALTH_HURT_HEAL, function(value)
				rested = true
			end)
			local CurrentMapNodeType = MapNodeTypes.REST
			dependencies = {
				mapNodeType = CurrentMapNodeType, 
				robloxPlayer = MockedPlayer, 
				playerState = PlayerState, 
				deckManager = DeckManager,
				deckData = DeckManager:getPlayableDeck(),
				echoManager = EchoManager, 
				parent = workspace, 
				centerPosition = MockedPosition, 
				idGenerator = IdGenerator, 
				eventObserver = EventObserver,
			}
			CurrentInstance = NodeInstanceFactory:createInstance(CurrentMapNodeType, dependencies)
			expect(CurrentInstance._used).to.equal(false)
			CurrentInstance:start()
			CurrentInstance:requestRest()
			expect(rested).to.equal(true)
			expect(CurrentInstance._used).to.equal(true)
		end)

		it("Confirms EventInstance is initalized correctly", function()
			local EventInstance = require(ServerScriptService.EventInstance.EventInstance)
			local rested = false
			EventObserver:subscribeTo(GameEvents.PLAYER_HEALTH_HURT_HEAL, function(value)
				rested = true
			end)
			local eventId = "e1"
			MockedStageData = require(ServerScriptService.EventInstance.BaseEvent).new(eventId)
			local CurrentMapNodeType = MapNodeTypes.REST
			dependencies = {
				mapNodeType = CurrentMapNodeType, 
				robloxPlayer = MockedPlayer, 
				playerState = PlayerState, 
				deckManager = DeckManager,
				deckData = DeckManager:getPlayableDeck(),
				echoManager = EchoManager, 
				parent = workspace, 
				stageData = MockedStageData, 
				centerPosition = MockedPosition, 
				idGenerator = IdGenerator, 
				eventObserver = EventObserver,
			}
			CurrentInstance = EventInstance.new(dependencies)
			CurrentInstance:start()
			expect(CurrentInstance.currentEvent.eventKey).to.equal(eventId)
		end)
	end)
end