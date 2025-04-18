return function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")
    local MockedPlayer = Instance.new("Part")
    local MockedData = require(ReplicatedStorage.Repos.StarterRepos.Ze)
    local MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)
    local NodeInstanceFactory = require(ServerScriptService.NodeInstance.NodeInstanceFactory).new()
	local IdGenerator = require(ReplicatedStorage.Helpers.Classes.IdGenerator).new()
	local EventObserver = require(ServerScriptService.GameEntity.EventObserver).new()
    local PlayerState = require(ServerScriptService.GameEntity.PlayerState).new(MockedPlayer, MockedData)
	local DeckManager = require(ServerScriptService.GameEntity.DeckManager).new(MockedData.deck, IdGenerator)
	local GameInstance = nil
	local EchoManager = require(ServerScriptService.GameEntity.EchoManager).new(EventObserver, IdGenerator, PlayerState, DeckManager, function()
		return GameInstance
	end)
	local MockedStageData = require(ReplicatedStorage.Stages.Level1).tier1[1]
	local MockedPosition = Vector3.new(0,0,0)
	local dependencies = {
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
    GameInstance = NodeInstanceFactory:createInstance(MapNodeTypes.REGULAR_ENEMY, dependencies)
	GameInstance:start()
	
	expect(game._turnCount).to.equal(1)
	expect(game._isPlaying).to.equal(true)
	expect(game.isPlayerTurn).to.equal(true)
end