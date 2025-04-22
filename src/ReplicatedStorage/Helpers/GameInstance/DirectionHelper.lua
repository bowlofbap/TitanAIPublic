local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Directions = require(ReplicatedStorage.Enums.Directions)

local DirectionHelper = {}

function DirectionHelper.processDirection(direction, mover, reference)
    if direction == Directions.AWAY_X or direction == Directions.CLOSER_X then
        if (direction == Directions.AWAY_X and mover.Team == "Game") or (direction == Directions.CLOSER_X and mover.Team ~= "Game") then
            return Directions.RIGHT
        else
            return Directions.LEFT
        end
    elseif direction == Directions.AWAY_Y or direction == Directions.CLOSER_Y then
        return Directions.UP --TODO
    end
    return direction
end

return DirectionHelper