return function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DirectionHelper = require(ReplicatedStorage.Helpers.GameInstance.DirectionHelper)
    local Directions = require(ReplicatedStorage.Enums.Directions)
	describe("Direction Helper Functionality", function()
        describe("CLOSER_X works", function()
            it("Confirms CLOSER_X works for player", function()
                local direction = Directions.CLOSER_X
                local mover = {Team = "Player"}
                local reference = {Team = "Game"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.RIGHT)
            end)

            it("Confirms CLOSER_X works for enemy", function()
                local direction = Directions.CLOSER_X
                local mover = {Team = "Game"}
                local reference = {Team = "Player"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.LEFT)
            end)
        end)

        describe("AWAY_X works", function()
            it("Confirms AWAY_X works for player", function()
                local direction = Directions.AWAY_X
                local mover = {Team = "Player"}
                local reference = {Team = "Game"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.LEFT)
            end)

            it("Confirms AWAY_X works for enemy", function()
                local direction = Directions.AWAY_X
                local mover = {Team = "Game"}
                local reference = {Team = "Player"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.RIGHT)
            end)
        end)


        describe("CLOSER_Y works", function()
            SKIP()
            it("Confirms CLOSER_Y works for up", function()
                local direction = Directions.CLOSER_Y
            end)

            it("Confirms CLOSER_Y works for down", function()
            end)
        end)

        describe("AWAY_Y works", function()
            SKIP()
            it("Confirms AWAY_Y works for UP", function()

            end)

            it("Confirms AWAY_Y works for DOWN", function()

            end)
        end)

        describe("Stand Directions work", function()
            it("Confirms LEFT works", function()
                local direction = Directions.LEFT
                local mover = {Team = "Player"}
                local reference = {Team = "Game"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.LEFT)
            end)
            it("Confirms RIGHT works", function()
                local direction = Directions.RIGHT
                local mover = {Team = "Player"}
                local reference = {Team = "Game"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.RIGHT)
            end)
            it("Confirms UP works", function()
                local direction = Directions.UP
                local mover = {Team = "Player"}
                local reference = {Team = "Game"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.UP)
            end)
            it("Confirms DOWN works", function()
                local direction = Directions.DOWN
                local mover = {Team = "Player"}
                local reference = {Team = "Game"}
                expect(DirectionHelper.processDirection(direction, mover, reference)).to.equal(Directions.DOWN)
            end)
        end)
    end)
end