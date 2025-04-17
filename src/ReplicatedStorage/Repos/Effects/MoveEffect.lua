local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)
local TargetChoices = require(game:GetService("ReplicatedStorage").Enums.TargetChoices)
local Directions = require(game:GetService("ReplicatedStorage").Enums.Directions)

local TargetHelper = require(game:GetService("ReplicatedStorage").Helpers.TargetHelper)

local MoveEffect = setmetatable({}, { __index = Effect })
MoveEffect.__index = MoveEffect

--[[
args needs to be structured as :
{
	value = value
	direction = Directions.DIRECTION
}
]]

function MoveEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, MoveEffect)
	return self
end

function MoveEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	local cardData = context:getCardData()
	local caster = context:getCardData()
	local direction = self.effectData.direction
	if self.effectData.direction == Directions.CLOSER_Y then
		local closerData = {
			effectChoice = TargetChoices.ENEMY,
			range = cardData.range
		}
		local closestEnemy = TargetHelper.getClosest(caster, gameInstance, closerData)
		if caster.coordinates.Y > closestEnemy.coordinates.Y then
			direction = Directions.UP
		elseif caster.coordinates.Y < closestEnemy.coordinates.Y then
			direction = Directions.DOWN
		else
			print("already on same level")
			return 
		end
	elseif self.effectData.direction == Directions.AWAY_Y then
		local enemyCoords = TargetHelper.getClosest(caster, gameInstance, cardData).coordinates
		local potentialCoords1 = caster.coordinates + Directions.DOWN
		local potentialCoords2 = caster.coordinates + Directions.UP
		if gameInstance.board:getNode(potentialCoords1) and 
			math.abs(potentialCoords1.Y - enemyCoords.Y) >= math.abs(potentialCoords2.Y - enemyCoords.Y) and 
			math.abs(potentialCoords1.Y - enemyCoords.Y) >= math.abs(caster.coordinates.Y - enemyCoords.Y) then
			direction = Directions.DOWN
		elseif gameInstance.board:getNode(potentialCoords2) and 
			math.abs(potentialCoords2.Y - enemyCoords.Y) >= math.abs(potentialCoords1.Y - enemyCoords.Y) and 
			math.abs(potentialCoords2.Y - enemyCoords.Y) >= math.abs(caster.coordinates.Y - enemyCoords.Y) then
			direction = Directions.UP
		else
			print("best solution is to stay still")
			return
		end
	end
	for _, target in ipairs(effectTargets)  do
		gameInstance:moveTarget(caster, target, direction, self.effectData.value)
	end 
end

return MoveEffect
