return function()
	describe("Events", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ServerScriptService = game:GetService("ServerScriptService")
		local EventContext = require(ServerScriptService.EventInstance.EventContext)
		local EventsRepo = require(ReplicatedStorage.Repos.EventsFolder.EventsRepo)
		local MockedPlayer
		local MockedData
		local MapNodeTypes
		local IdGenerator
		local EventObserver
		local PlayerState
		local DeckManager
		local context 
		
		beforeEach(function()
			print("setting up for new event")
			MockedPlayer = Instance.new("Part")
			MockedData = require(ReplicatedStorage.Repos.StarterRepos.TestData)
			MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)
			IdGenerator = require(ReplicatedStorage.Helpers.Classes.IdGenerator).new()
			EventObserver = require(ReplicatedStorage.Helpers.Classes.EventObserver).new()
			PlayerState = require(ServerScriptService.GameEntity.PlayerState).new(MockedPlayer, MockedData)
			DeckManager = require(ServerScriptService.GameEntity.DeckManager).new(MockedData.deck, IdGenerator)
			context = EventContext.new(EventObserver, DeckManager, PlayerState, MapNodeTypes.EVENT)
		end)

		afterEach(function()
			context = nil
		end)

		local BaseEvent = require(ServerScriptService.EventInstance.BaseEvent)
		for eventId, event in pairs(EventsRepo) do

			it("Ensures event "..event.name.." is working", function()
				local newEvent = BaseEvent.new(eventId)
				newEvent:setCommand(function(gameEventType, ...)
					
				end)
				print(context.eventObserver)
				for i, choice in ipairs(event.choices) do
					expect(function()
						return newEvent:checkOptionData(i, context)
					end).never.to.throw()
					expect(function()
						return newEvent:executeEvent(i, context)
					end).never.to.throw()
				end
			end)
		end
	end)
end