return function()
    describe("Server Player Module", function()
        local ServerScriptService = game:GetService("ServerScriptService")
        local GameInstance = ServerScriptService.GameInstance
        local GamePlayer = require(GameInstance.GamePlayer)
        local mockPlayerState = {
            turnEnergy = 3,
            handSize = 1,
            turnMovement = 2,
        }
        local mockRobloxPlayer = Instance.new("Part")
        local mockDeck = {}
        local player

        beforeEach(function()
            player = GamePlayer.new(mockRobloxPlayer, mockPlayerState, mockDeck, nil)
        end)

        it("Ensures Player can spend movement", function()
            --setup
            local startingMovement = player.movement

            --act
            player:payMovementCost()

            --assert
            expect(player.movement).to.equal(startingMovement-1)
        end)

        it("Ensures Player can gain movement", function()
            --setup
            player.movement = 0
            
            --act
            player:gainMovement(1)

            --assert
            expect(player.movement).to.equal(1)
        end)

        it("Ensures Player can gain turn movement", function()
            --setup
            player.movement = 0
            
            --act
            player:replenishMovement()

            --assert
            expect(player.movement).to.equal(player.turnMovement)
        end)

        it("Ensures Player turn movement edge case is handled", function()
            --setup
            player.movement = player.turnMovement
            local previousMovement = player.movement
            
            --act
            player:replenishMovement()

            --assert
            expect(player.movement).to.equal(previousMovement)

            --act
            player:payMovementCost()
            player:replenishMovement()

            --assert
            expect(player.movement).to.equal(previousMovement)
        end)
    end)
end