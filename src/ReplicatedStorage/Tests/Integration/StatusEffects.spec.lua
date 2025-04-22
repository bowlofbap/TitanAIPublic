return function()
	describe("Instances", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
		local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
		local StatusTypes = require(ReplicatedStorage.Enums.StatusTypes)
        local EffectTypes = require(ReplicatedStorage.Enums.EffectTypes)
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
        local testStatusType
		local testStatusValue
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

		describe("StatusTest", function()
            local statusType = StatusTypes.DAMAGE_OVER_TIME
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 5
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start()
				local unit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue)

                local totalLostHealth = 0
                for i = testStatusValue, 2, -1 do 
                    --action
                    passTurn()

                    --assert
                    expect(unit:getStatus(statusType).value).to.equal(i-1)
                    totalLostHealth += i
                    expect(unit.health).to.equal(unit.maxHealth - totalLostHealth)
                end

				--action
                passTurn()
                
                --assert
				expect(unit:getStatus(statusType)).never.to.be.ok()
			end)
		end)

		describe("StatusTest", function()
            local Directions = require(ReplicatedStorage.Enums.Directions)
            local statusType = StatusTypes.ROOT_DEBUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start()
				local unit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue)
                --testing that it doesn't stack
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue) 
                local originalCoords = unit.coordinates

                --action
                CurrentInstance:moveTarget(unit, unit, Directions.LEFT, 1)

                --assert
                expect(unit.coordinates).to.equal(originalCoords)
                
                --assert
				expect(unit:getStatus(statusType)).never.to.be.ok()
			end)
		end)
    end)
end