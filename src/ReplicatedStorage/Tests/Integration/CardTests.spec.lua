return function()
	describe("Cards", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local TargetingRules = require(ReplicatedStorage.Helpers.GameInstance.TargetingRules)
		local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
		local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
		local StatusTypes = require(ReplicatedStorage.Enums.StatusTypes)
		local CardRepo = require(ReplicatedStorage.Repos.CardRepo)
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
		local upgraded = false

		local function setupGameInstance(testLevel, numCards)
			print("setting up for new instance") 
			eventChecks = 0
			MockedPlayer = Instance.new("Part")
			MockedData = table.clone(require(ReplicatedStorage.Repos.StarterRepos.TestData))
            local testDeck = {
                {
                    cardName = testCardName,
                    amount = numCards or 1,
                    upgraded = upgraded
                },
            }
            MockedData.deck = testDeck
			MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)
			NodeInstanceFactory = require(ServerScriptService.NodeInstance.NodeInstanceFactory).new()
			IdGenerator = require(ReplicatedStorage.Helpers.Classes.IdGenerator).new()
			EventObserver = require(ReplicatedStorage.Helpers.Classes.EventObserver).new()
			PlayerState = require(ServerScriptService.GameEntity.PlayerState).new(MockedPlayer, MockedData)
			DeckManager = require(ServerScriptService.GameEntity.DeckManager).new(MockedData.deck, IdGenerator)
			EchoManager = require(ServerScriptService.GameEntity.EchoManager).new(EventObserver, IdGenerator, PlayerState, DeckManager, function()
				return CurrentInstance
			end)
			MockedPosition = Vector3.new(0,0,0)
			MockedStageData = require(ReplicatedStorage.Stages.Level1).test[testLevel]
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
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
	
				EventObserver:subscribeTo(GameEvents.PLAY_CARD, function(CurrentInstance, data)
					expect(data.card).to.equal(testingCard)
					eventChecks+=1
				end)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC001"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedEnemies = TargetingRules.getValidTargets(context)
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.source).to.equal(caster)
					eventChecks+=1
				end)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(expectedEnemies[1]:getStatus(StatusTypes.WEAKEN_DEBUFF)).to.be.ok()
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC002"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.APPLYING_BLOCK, function(CurrentInstance, data)
					expect(data.target).to.equal(caster)
					expect(data.blockAmount).to.equal(testingCard.cardData.effects[1].value)
					eventChecks+=1
				end)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
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
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)
				
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
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = caster.coordinates + Vector2.new(1,0)
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.GRANT_ENERGY, function(CurrentInstance, data)
					eventChecks += 1
					expect(data.unit).to.equal(caster)
				end)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
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
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
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
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.source).to.equal(caster)
					expect(data.target).to.equal(expectedTargetEnemy)
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(expectedTargetEnemy:getStatus(StatusTypes.ROOT_DEBUFF)).to.be.ok()
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC006"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = CurrentInstance.unitHolder:getEnemies(caster.Team)[1].coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					eventChecks+=1
				end)
				EventObserver:subscribeTo(GameEvents.GRANT_ENERGY, function(CurrentInstance, data)
					expect(data.unit).to.equal(caster)
					expect(data.value).to.equal(testingCard.cardData.effects[1].energyGained)
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(3)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC007"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
			end)

			it("Confirms that ".. cardName .." pushes correctly", function()
				upgraded = false
				setupGameInstance(2)
				
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedEnemies = TargetingRules.getValidTargets(context)
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.target).to.equal(expectedEnemies[1])
					eventChecks+=1
				end)

				EventObserver:subscribeTo(GameEvents.MOVED, function(CurrentInstance, data)
					expect(data.target).to.equal(expectedEnemies[1])
					expect(data.source).to.equal(caster)
					eventChecks+=1
				end)

				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(2)
			end)

			it("Confirms that ".. cardName .." fails to push and applies status", function()
				upgraded = false
				setupGameInstance(1)
				
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedEnemies = TargetingRules.getValidTargets(context)
				local previousCoordinates = expectedEnemies[1].coordinates
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.target).to.equal(expectedEnemies[1])
					eventChecks+=1
				end)
				EventObserver:subscribeTo(GameEvents.APPLYING_STATUS, function(CurrentInstance, data)
					expect(data.source).to.equal(caster)
					expect(data.target).to.equal(expectedEnemies[1])
					expect(data.statusType).to.equal(testingCard.cardData.effects[2].statusType)
					eventChecks+=1
				end)

				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(expectedEnemies[1].coordinates).to.equal(previousCoordinates)
				expect(eventChecks).to.equal(2)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC008"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = CurrentInstance.unitHolder:getEnemies(caster.Team)[1].coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedEnemies = TargetingRules.getValidTargets(context)

				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(testingCard.cardData.effects[1].value)
					expect(data.target).to.equal(expectedEnemies[1])
					eventChecks+=1
				end)

				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC009"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = caster.coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.APPLYING_STATUS, function(CurrentInstance, data)
					expect(data.target).to.equal(caster)
					expect(data.statusType).to.equal(StatusTypes.CHARGE_BUFF)
					eventChecks+=1
				end)
				EventObserver:subscribeTo(GameEvents.CHANGE_TILE, function(CurrentInstance, data)
					expect(data.source).to.equal(caster)
					expect(data.nodeType).to.equal(testingCard.cardData.effects[1].value)
					eventChecks+=1
				end)
				--expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(2)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC010"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.APPLYING_STATUS, function(CurrentInstance, data)
					expect(data.target).to.equal(caster)
					expect(data.statusType).to.equal(StatusTypes.TRACE_BUFF)
					eventChecks+=1
				end)
				EventObserver:subscribeTo(GameEvents.CHANGE_TILE, function(CurrentInstance, data)
					expect(data.source).to.equal(caster)
					expect(data.nodeType).to.equal(testingCard.cardData.effects[1].value)
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(2)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC011"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = CurrentInstance.unitHolder:getEnemies(caster.Team)[1].coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				local expectedEnemies = TargetingRules.getValidTargets(context)

				EventObserver:subscribeTo(GameEvents.APPLYING_STATUS, function(CurrentInstance, data)
					expect(data.statusType).to.equal(testingCard.cardData.effects[1].statusType)
					expect(data.target).to.equal(expectedEnemies[1])
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(1)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC012"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(caster:getStatus(testingCard.cardData.effects[1].statusType)).to.be.ok()

				--action
				passTurn()

				--assert
				expect(caster:getStatus(testingCard.cardData.effects[1].statusType)).never.to.be.ok()
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC013"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1, 4)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local extraData = {
					selectedCardIds = {
						CurrentInstance.player.hand:getCardByPlace(2).id, CurrentInstance.player.hand:getCardByPlace(3).id
					}
				}
					
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates,
					extraData = extraData
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates, extraData)
				local originalEnergy = CurrentInstance.player.energy
				local cardsInHand = #CurrentInstance.player:getHand()
				expect(TargetingRules.canBePlayed(context)).to.equal(true)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(CurrentInstance.player.energy).to.equal(originalEnergy + testingCard.cardData.effects[2].value)
				expect(#CurrentInstance.player:getHand()).to.equal(cardsInHand-3)
			end)
		end)
		
		describe("CardTest", function()
			local cardName = "ZC014"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1, 15)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.DRAW, function(CurrentInstance, data)
					eventChecks+=1
				end)
				expect(TargetingRules.canBePlayed(context)).to.equal(true)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)

				--assert
				expect(eventChecks).to.equal(testingCard.cardData.effects[1].value)				
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC015"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1, 5)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = nil
				local selectedCard = CurrentInstance.player.hand:getCardByPlace(2)
				local extraData = {
					selectedCardIds = {
						selectedCard.id
					}
				}
					
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates,
					extraData = extraData
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates, extraData)
				local originalMovement = CurrentInstance.player.movement
				local cardsInHand = #CurrentInstance.player:getHand()
				expect(TargetingRules.canBePlayed(context)).to.equal(true)

				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(CurrentInstance.player.movement).to.equal(originalMovement + selectedCard.cardData.cost)
				expect(#CurrentInstance.player:getHand()).to.equal(cardsInHand-2)
			end)
		end)

		describe("CardTest", function()
			local cardName = "ZC016"
			local stringName = CardRepo[cardName].stringName
			beforeEach(function()
				testCardName = cardName
				upgraded = false
				setupGameInstance(1)
			end)

			it("Confirms that ".. cardName .."-"..stringName.." executes correctly", function()
				--setup
				CurrentInstance:start(cardName)
				local caster = CurrentInstance.player.unit
				local testingCard = CurrentInstance.player.hand:getCardByPlace(1)
				local targetCoordinates = CurrentInstance.unitHolder:getEnemies(caster.Team)[1].coordinates
				local mockedClientData = {
					cardId = testingCard.id,
					targetCoordinates = targetCoordinates
				}
				local context = CardExecutionContext.new(CurrentInstance, testingCard.cardData, caster, targetCoordinates)
				EventObserver:subscribeTo(GameEvents.APPLYING_STATUS, function(CurrentInstance, data)
					expect(data.statusType).to.equal(testingCard.cardData.effects[1].statusType)
					eventChecks+=1
				end)

				expect(TargetingRules.canBePlayed(context)).to.equal(true)
	
				--action
				CurrentInstance:requestPlayCard(mockedClientData)
	
				--assert
				expect(eventChecks).to.equal(1)
			end)
		end)
    end)
end