local TargetChoices = require(game:GetService("ReplicatedStorage").Enums.TargetChoices)

local ServerCardExecutionContext = {}
ServerCardExecutionContext.__index = ServerCardExecutionContext

function ServerCardExecutionContext.new(gameInstance, cardData, caster, mainCoordinates)
	local self = setmetatable({}, ServerCardExecutionContext)
	self._gameInstance = gameInstance
	self._cardData = cardData
	self._caster = caster
	self._mainCoordinates = mainCoordinates
	return self
end

function ServerCardExecutionContext:getMainCoordinates()
	return self._mainCoordinates
end

function ServerCardExecutionContext:getCaster()
	return self._caster
end

function ServerCardExecutionContext:getCardData()
	return self._cardData
end

function ServerCardExecutionContext:getBoard()
	return self._gameInstance.board
end

function ServerCardExecutionContext:getNodeAt(coordinates)
	return self:getBoard():getNode(coordinates)
end

function ServerCardExecutionContext:getTargetGroupFromCardData(groupChoice)
	local targetGroup = {}
	local caster = self:getCaster()
	if groupChoice == TargetChoices.ALLY then
		targetGroup = self._gameInstance.unitHolder:getAllies(caster.Team)
	elseif groupChoice == TargetChoices.ENEMY then
		targetGroup = self._gameInstance.unitHolder:getEnemies(caster.Team)
	elseif TargetChoices == TargetChoices.ANY then
		targetGroup = self._gameInstance.unitHolder:getAll()
	end
	return targetGroup
end

function ServerCardExecutionContext:setCardData(cardData)
	self._cardData = cardData
end

return ServerCardExecutionContext
