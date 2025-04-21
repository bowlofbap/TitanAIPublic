return function()
	describe("Instances", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local TargetingRules = require(ReplicatedStorage.Helpers.GameInstance.TargetingRules)
		local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
		local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
		local StatusTypes = require(ReplicatedStorage.Enums.StatusTypes)
		local TargetTypes = require(ReplicatedStorage.Enums.TargetTypes)
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
        local testCardName 
		local eventChecks = 0

		local function setupGameInstance()
			print("setting up for new instance") 
			eventChecks = 0
			MockedPlayer = Instance.new("Part")
			MockedData = require(ReplicatedStorage.Repos.StarterRepos.TestData)
            local testDeck = {
                {
                    cardName = testCardName,
                    amount = 1,
                    upgraded = false
                },
            }
            MockedData.deck = testDeck
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
			MockedStageData = require(ReplicatedStorage.Stages.Level1).test[1]
			dependencies = {
				mapNodeType = MapNodeTypes.REGULAR_ENEMY, 
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
			CurrentInstance = NodeInstanceFactory:createInstance(MapNodeTypes.REGULAR_ENEMY, dependencies)
		end

		local function passTurn()
			CurrentInstance:requestEndTurn()
		end

		afterEach(function()
			print("teardown instance")
			CurrentInstance:Destroy()
			CurrentInstance = nil
		end)

		describe("CardTest", function()
			local cardName = "E001"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
	
				EventObserver:subscribeTo(GameEvents.PLAY_CARD, function(data)
					expect(data.card).to.equal(testingCard)
					eventChecks+=1
				end)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC001"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedEnemies = TargetingRules.getValidTargets(context)
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.source).to.equal(caster)
					eventChecks+=1
				end)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				expect(expectedEnemies[1]:getStatus(StatusTypes.WEAKEN_DEBUFF)).to.be.ok()
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC002"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.APPLYING_BLOCK, function(data)
					expect(data.target).to.equal(caster)
					expect(data.blockAmount).to.equal(testingCard.cardData.effects[1].value)
					eventChecks+=1
				end)

				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				expect(caster:getStatus(StatusTypes.REFLECT_BUFF)).to.be.ok()
				expect(caster:getStatus(StatusTypes.REFLECT_DOWN)).to.be.ok()

				--action
				passTurn()

				--assert
				expect(caster:getStatus(StatusTypes.REFLECT_BUFF)).never.to.be.ok()
				expect(caster:getStatus(StatusTypes.REFLECT_DOWN)).never.to.be.ok()
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC003"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)

				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				expect(caster:getStatus(StatusTypes.STRENGTH_BUFF)).to.be.ok()
				expect(caster:getStatus(StatusTypes.STRENGHT_DOWN)).to.be.ok()

				--action
				passTurn()

				--assert
				expect(caster:getStatus(StatusTypes.STRENGTH_BUFF)).never.to.be.ok()
				expect(caster:getStatus(StatusTypes.STRENGHT_DOWN)).never.to.be.ok()
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC004"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = caster.coordinates + Vector2.new(1,0)
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.GRANT_ENERGY, function(data)
					eventChecks += 1
					expect(data.unit).to.equal(caster)
				end)

				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				local occupyingUnit = CurrentInstance.board:isNodeAtCoordsOccupied(targetCoordinates)
				expect(occupyingUnit).to.be.ok()
				
				--action
				passTurn()

				--assert
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC005"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = CurrentInstance.unitHolder:getEnemies(caster.Team)[1].coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedTargetNodes = TargetingRules.getValidTargets(context)
				local expectedTargetEnemy = expectedTargetNodes[1]:getOccupyingUnit()
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.source).to.equal(caster)
					expect(data.target).to.equal(expectedTargetEnemy)
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				expect(expectedTargetEnemy:getStatus(StatusTypes.ROOT_DEBUFF)).to.be.ok()
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC006"
			beforeEach(function()
				testCardName = cardName
				setupGameInstance()
			end)

			it("Confirms that ".. cardName .." is executes correctly", function()
				--setup
				CurrentInstance:start()
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = CurrentInstance.unitHolder:getEnemies(caster.Team)[1].coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					eventChecks+=1
				end)
				EventObserver:subscribeTo(GameEvents.GRANT_ENERGY, function(data)
					expect(data.unit).to.equal(caster)
					expect(data.value).to.equal(testingCard.cardData.effects[1].energyGained)
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData, context)
	
				--assert
				expect(eventChecks).to.equal(3)
			end)
		end)
    end)
end