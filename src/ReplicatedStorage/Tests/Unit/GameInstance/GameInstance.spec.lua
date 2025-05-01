return function()
	describe("Instances", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
        local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
		local StatusTypes = require(ReplicatedStorage.Enums.StatusTypes)
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
        local eventChecks = 0
        local testCardName
		
		local function setupGameInstance(testLevel, numCards, addedEchoNames)
			print("setting up for new instance") 

			MockedPlayer = Instance.new("Part")
			MockedData = table.clone(require(ReplicatedStorage.Repos.StarterRepos.TestData))
            local testDeck = {
                {
                    cardName = testCardName,
                    amount = numCards or 1,
                    upgraded = false
                },
            }
            MockedData.deck = testDeck
			MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)
			NodeInstanceFactory = require(ServerScriptService.NodeInstance.NodeInstanceFactory).new()
			IdGenerator = require(ReplicatedStorage.Helpers.Classes.IdGenerator).new()
			EventObserver = require(ReplicatedStorage.Helpers.Classes.EventObserver).new()
			PlayerState = require(ServerScriptService.GameEntity.PlayerState).new(MockedPlayer, MockedData)
			DeckManager = require(ServerScriptService.GameEntity.DeckManager).new(MockedData.deck, IdGenerator)
			EchoManager = require(ServerScriptService.GameEntity.EchoManager).new(EventObserver, IdGenerator, PlayerState, DeckManager)
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
            addedEchoNames = addedEchoNames or {}
            for _, echoName in ipairs(addedEchoNames) do
                EchoManager:add(echoName)
            end
			CurrentInstance = NodeInstanceFactory:createInstance(MapNodeTypes.REGULAR_ENEMY, dependencies)
		end

        describe("Game simulation",function()
            beforeEach(function()
                eventChecks = 0
                testCardName = "R001"
                setupGameInstance(1, 5)
            end)

            afterEach(function()
                if CurrentInstance then
                    print("teardown instance")
                    CurrentInstance:Destroy()
                    CurrentInstance = nil
                end
            end)

            it("Confirms Happy Path works for combat", function()
                CurrentInstance:start("SIM")
                local originalEnergy = CurrentInstance.player.energy
                local enemy = CurrentInstance.unitHolder:getEnemies(CurrentInstance.player.unit.Team)[1]

                local sim = CurrentInstance:createSimulation("SIM_INSTANCE")
                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local simCard = sim.player.hand:getCardById(cardToPlay.id)
                expect(cardToPlay).never.to.equal(simCard)
                local context = CardExecutionContext.new(sim, simCard.cardData, sim.player.unit, nil)
                local simObserver = sim.eventObserver
                EventObserver:subscribeTo(GameEvents.PLAY_CARD, function(CurrentInstance, data)
                    expect(true).never.to.equal(true)
                end)

                simObserver:subscribeTo(GameEvents.PLAY_CARD, function(sim, data)
                    eventChecks += 1
                end)

                sim:executePlayerCard(cardToPlay, context)

                local simEnemy = sim.unitHolder:getEnemies(sim.player.unit.Team)[1]
                expect(CurrentInstance.player.energy).to.equal(originalEnergy)
                expect(simCard.cardData.targetType).to.equal(cardToPlay.cardData.targetType)
                expect(enemy.health).to.equal(enemy.maxHealth)
                expect(eventChecks).to.equal(1)
                expect(simEnemy.health).to.equal(simEnemy.maxHealth - simCard.cardData.effects[1].value)
                expect(simEnemy.unitData.key).to.equal(enemy.unitData.key)
                expect(simEnemy).to.equal(enemy)
            end)

            it("Confirms Damage Boosts can be expected to work works for combat", function()
                CurrentInstance:start("SIM")
                local playerUnit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, StatusTypes.WEAKEN_DEBUFF, 2)

                local sim = CurrentInstance:createSimulation("SIM_INSTANCE")
                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local simCard = sim.player.hand:getCardById(cardToPlay.id)
                local context = CardExecutionContext.new(sim, simCard.cardData, sim.player.unit, nil)

                sim:executePlayerCard(cardToPlay, context)

                local simEnemy = sim.unitHolder:getEnemies(sim.player.unit.Team)[1]
                expect(simEnemy.health).to.equal(simEnemy.maxHealth - simCard.cardData.effects[1].value + 2)
            end)

            it("Confirms that simulation results can be retrieved", function()
                CurrentInstance:start("SIM")
                local playerUnit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, StatusTypes.WEAKEN_DEBUFF, 2)
                local enemy = CurrentInstance.unitHolder:getEnemies(CurrentInstance.player.unit.Team)[1]

                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local data = { cardId = cardToPlay.id, targetCoordinates = nil }
                local results = CurrentInstance:getCardSimulationResults(data)

                for _, unitData in ipairs(results.unitData) do
                    if unitData.id == enemy.Id then
                        expect(unitData.health).to.equal(enemy.maxHealth - cardToPlay.cardData.effects[1].value + 2)
                    end
                end
            end)
        end)

        describe("Game simulation unhappy path",function()
            beforeEach(function()
                eventChecks = 0
                testCardName = "ZC006"
                setupGameInstance(1, 5)
            end)

            afterEach(function()
                if CurrentInstance then
                    print("teardown instance")
                    CurrentInstance:Destroy()
                    CurrentInstance = nil
                end
            end)

            it("Confirms targeting effects can be simmed", function()
                CurrentInstance:start("SIM_2")
                local playerUnit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, StatusTypes.WEAKEN_DEBUFF, 2)
                local enemy = CurrentInstance.unitHolder:getEnemies(CurrentInstance.player.unit.Team)[1]
                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local data = { cardId = cardToPlay.id, targetCoordinates = enemy.coordinates }
                local results = CurrentInstance:getCardSimulationResults(data)
                for _, unitData in ipairs(results.unitData) do
                    if unitData.id == enemy.Id then
                        expect(unitData.health).to.equal(enemy.maxHealth - cardToPlay.cardData.effects[1].value + 2)
                    end
                end
            end)
        end)

        describe("Game simulation others",function()
            beforeEach(function()
                eventChecks = 0
                testCardName = "R002"
                setupGameInstance(1, 5)
            end)

            afterEach(function()
                if CurrentInstance then
                    print("teardown instance")
                    CurrentInstance:Destroy()
                    CurrentInstance = nil
                end
            end)

            it("Confirms blocking can be simmed", function()
                CurrentInstance:start("SIM_3")
                local playerUnit = CurrentInstance.player.unit
                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local data = { cardId = cardToPlay.id, targetCoordinates = nil }
                local results = CurrentInstance:getCardSimulationResults(data)

                for _, unitData in ipairs(results.unitData) do
                    if unitData.id == playerUnit.Id then
                        expect(unitData.block).to.equal(cardToPlay.cardData.effects[1].value)
                    end
                end
            end)
        end)

        describe("Game simulation",function()
            beforeEach(function()
                eventChecks = 0
                testCardName = "R001"
                setupGameInstance(1, 5, {"Flurry"})
            end)

            afterEach(function()
                if CurrentInstance then
                    print("teardown instance")
                    CurrentInstance:Destroy()
                    CurrentInstance = nil
                end
            end)

            it("Confirms that actual echoes counts are not increased", function()
                CurrentInstance:start("SIM_4_1")
                local playerUnit = CurrentInstance.player.unit
                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local data = { cardId = cardToPlay.id, targetCoordinates = nil }
                local results = CurrentInstance:getCardSimulationResults(data)
                expect(EchoManager:getEchoByStringName("Flurry")._count).to.equal(0)
            end)

            it("Confirms that actual echoes effects do not apply to real units", function()
                CurrentInstance:start("SIM_4_2")
                local playerUnit = CurrentInstance.player.unit
                local cardToPlay = CurrentInstance.player.hand:getCardByPlace(1)
                local data = { cardId = cardToPlay.id, targetCoordinates = nil }
                EchoManager:getEchoByStringName("Flurry")._count = 2
                local results = CurrentInstance:getCardSimulationResults(data)
                expect(playerUnit.block).to.equal(0)
                expect(EchoManager:getEchoByStringName("Flurry")._count).to.equal(2)
            end)
        end)
    end)
end