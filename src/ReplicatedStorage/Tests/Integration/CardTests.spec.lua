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
        local testCardName 
		
		beforeEach(function()
			print("setting up for new instance")
			MockedPlayer = Instance.new("Part")
			MockedData = require(ReplicatedStorage.Repos.StarterRepos.TestData)
            local c = require(game:GetService("ReplicatedStorage").Repos.CardRepo)

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
		end)

		afterEach(function()
			print("teardown instance")
			CurrentInstance:Destroy()
			CurrentInstance = nil
		end)

        testCardName = "ZC001"
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
			expect(#CurrentInstance.unitHolder:getAll()).to.equal(2)
		end)

    end)
end