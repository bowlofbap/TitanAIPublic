return function()
	describe("Status Effects", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local CardExecutionContext = require(ReplicatedStorage.Helpers.GameInstance.Classes.ServerCardExecutionContext)
		local GameEvents = require(ReplicatedStorage.Enums.GameEvents)
		local StatusTypes = require(ReplicatedStorage.Enums.StatusTypes)
        local EffectTypes = require(ReplicatedStorage.Enums.EffectTypes)
		local DamageTypes = require(ReplicatedStorage.Enums.DamageTypes)
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
			MockedData = table.clone(require(ReplicatedStorage.Repos.StarterRepos.TestData))
            local testDeck = {
                {
                    cardName = "E001",
                    amount = 15,
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
				CurrentInstance:start(statusType.name)
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
				CurrentInstance:start(statusType.name)
				local unit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue)
                --testing that it doesn't stack
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue) 
                local originalCoords = unit.coordinates

                --action
                CurrentInstance:moveTarget(unit, unit, Directions.LEFT, 1)

                --assert
                expect(unit.coordinates).to.equal(originalCoords)

				--act
				passTurn()
                
                --assert
				expect(unit:getStatus(statusType)).never.to.be.ok()
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.CHARGE_BUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local unit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue)
                --testing that it does stack
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue) 

                --action
				passTurn()
                
                --assert
				expect(unit:getStatus(testStatusType).value).to.equal(testStatusValue*2)
				expect(CurrentInstance.player.energy).to.equal(CurrentInstance.player.turnEnergy + testStatusValue * 2)
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.MARK_DEBUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 2
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local playerUnit = CurrentInstance.player.unit
				local unit = CurrentInstance.unitHolder:getEnemies(playerUnit.Team)[1]
                CurrentInstance:applyStatus(playerUnit, {unit}, testStatusType, testStatusValue)
                --testing that it does stack
                CurrentInstance:applyStatus(playerUnit, {unit}, testStatusType, testStatusValue) 
				local previousCardNumber = #CurrentInstance.player:getHand()
                --action
				CurrentInstance:dealDamage(playerUnit, {unit}, unit.health, DamageTypes.DIRECT)
                
                --assert
				expect(CurrentInstance.player.energy).to.equal(CurrentInstance.player.turnEnergy + testStatusValue * 2)
				expect(#CurrentInstance.player:getHand()).to.equal(previousCardNumber + testStatusValue)
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.TRACE_BUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local playerUnit = CurrentInstance.player.unit
				local unit = CurrentInstance.unitHolder:getEnemies(playerUnit.Team)[1]
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue)
				EventObserver:subscribeTo(GameEvents.APPLYING_STATUS, function(CurrentInstance, data)
					expect(data.source).to.equal(playerUnit)
					expect(data.target).to.equal(unit)
					expect(data.statusType).to.equal(StatusTypes[statusType.targetStatusKey])
					expect(data.value).to.equal(testStatusValue)
					eventChecks+=1
				end)
				
                --action
				CurrentInstance:dealDamage(playerUnit, {unit}, 1, DamageTypes.DIRECT)
				CurrentInstance:dealDamage(playerUnit, {unit}, 1, DamageTypes.DIRECT)
                
                --assert
				expect(eventChecks).to.equal(2)
				expect(unit:getStatus(StatusTypes[statusType.targetStatusKey]).value).to.equal(2)
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.CHARGE_BUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local unit = CurrentInstance.player.unit
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue)
                --testing that it does stack
                CurrentInstance:applyStatus(unit, {unit}, testStatusType, testStatusValue) 

                --action
				passTurn()
                
                --assert
				expect(unit:getStatus(testStatusType).value).to.equal(testStatusValue*2)
				expect(CurrentInstance.player.energy).to.equal(CurrentInstance.player.turnEnergy + testStatusValue * 2)
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.MOMENTUM_BUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local playerUnit = CurrentInstance.player.unit
				local mockCard = {cardData = {cost = 1}}
				local mockContext = {
					getCaster = function()
						return playerUnit
					end
				}
				local startingMovementPoints = CurrentInstance.player.movement
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue)
				--test that it doesn't stack
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue) 
				
                --action
				CurrentInstance:spendEnergy(mockCard, mockContext)
                
                --assert
				expect(playerUnit:getStatus(statusType).value).to.equal(1)
				expect(CurrentInstance.player.movement).to.equal(startingMovementPoints + 1)
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.CRIPPLE_DEBUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local playerUnit = CurrentInstance.player.unit
				local unit = CurrentInstance.unitHolder:getEnemies(playerUnit.Team)[1]
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue)
                --testing that it doesn't stack
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue) 
				local originalDamage = 99
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(66)
					eventChecks+=1
				end)

                --action
				CurrentInstance:dealDamage(playerUnit, {unit}, originalDamage, DamageTypes.DIRECT)
                
                --assert
				expect(playerUnit:getStatus(statusType).value).to.equal(1)
				expect(eventChecks).to.equal(1)

				--act
				passTurn()

				--assert
				expect(playerUnit:getStatus(statusType)).never.to.be.ok()
			end)

			it("Confirms that ".. statusType.name .." works with weaken correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local playerUnit = CurrentInstance.player.unit
				local unit = CurrentInstance.unitHolder:getEnemies(playerUnit.Team)[1]
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue)
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, StatusTypes.WEAKEN_DEBUFF, 2) 
				local originalDamage = 99
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(64)
					eventChecks+=1
				end)

                --action
				CurrentInstance:dealDamage(playerUnit, {unit}, originalDamage, DamageTypes.DIRECT)
                
                --assert
				expect(playerUnit:getStatus(statusType).value).to.equal(1)
				expect(eventChecks).to.equal(1)

				--act
				passTurn()

				--assert
				expect(playerUnit:getStatus(statusType)).never.to.be.ok()
			end)
		end)

		describe("StatusTest", function()
            local statusType = StatusTypes.WEAKEN_DEBUFF
			beforeEach(function()
				testStatusType = statusType
				testStatusValue = 1
				setupGameInstance()
			end)

			it("Confirms that ".. statusType.name .." works correctly", function()
				--setup
				CurrentInstance:start(statusType.name)
				local playerUnit = CurrentInstance.player.unit
				local unit = CurrentInstance.unitHolder:getEnemies(playerUnit.Team)[1]
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue)
                --testing that it stacks
                CurrentInstance:applyStatus(playerUnit, {playerUnit}, testStatusType, testStatusValue) 
				local originalDamage = 10
				EventObserver:subscribeTo(GameEvents.AFTER_DAMAGE, function(CurrentInstance, data)
					expect(data.healthLost).to.equal(8)
					eventChecks+=1
				end)

                --action
				CurrentInstance:dealDamage(playerUnit, {unit}, originalDamage, DamageTypes.DIRECT)
                
                --assert
				expect(playerUnit:getStatus(statusType).value).to.equal(2)
				expect(eventChecks).to.equal(1)

				--act
				passTurn()
				passTurn()

				--assert
				expect(playerUnit:getStatus(statusType)).never.to.be.ok()
			end)
		end)
    end)
end