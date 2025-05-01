return function()
    describe("Game Entity Manager", function()
        FOCUS()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ServerScriptService = game:GetService("ServerScriptService")
        local HttpService = game:GetService("HttpService")
        local GameEntityManager = require(ServerScriptService.GameEntity.EntityManager).new()
        local TestData = require(ReplicatedStorage.Repos.StarterRepos.TestData)
        local Player = {Name = "Test", UserId = "0"}
        local data
        local entity

        afterEach(function()
            if entity then
                GameEntityManager:removePlayerEntity(Player)
            end
        end)

        it("Confirms that Game Entity life cycle works", function()
            entity = GameEntityManager:initPlayerEntity(Player, TestData)
            expect(GameEntityManager:getEntityForPlayer(Player)).to.be.ok()
            GameEntityManager:removePlayerEntity(Player)
            expect(GameEntityManager:getEntityForPlayer(Player)).never.to.be.ok()
            entity = GameEntityManager:initPlayerEntity(Player, TestData)
            expect(GameEntityManager:getEntityForPlayer(Player)).to.be.ok()
        end)

        it("Confirms that Game Entity can save/load", function()
            entity = GameEntityManager:initPlayerEntity(Player, TestData)
            entity.echoManager:add("Flurry")
            entity.echoManager:add("IronSkin")
            data = entity:serialize()
            print(entity)
            print(data)
            print(#HttpService:JSONEncode(data).." bytes of data approx")
            expect(#data.echoManager.echos).to.equal(2)
            GameEntityManager:removePlayerEntity(Player)
            expect(GameEntityManager:getEntityForPlayer(Player)).never.to.be.ok()
            entity = GameEntityManager:loadPlayerEntity(Player, data)
            print(entity)
            expect(GameEntityManager:getEntityForPlayer(Player)).to.be.ok()
            local loadedData = entity:serialize()
            print(loadedData)
        end)
    end)
end