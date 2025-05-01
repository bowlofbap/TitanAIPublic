local TargetChoices = require(game:GetService("ReplicatedStorage").Enums.TargetChoices)

local ClientCardExecutionContext = {}
ClientCardExecutionContext.__index = ClientCardExecutionContext

function ClientCardExecutionContext.new(clientGame, cardData, caster, mainCoordinates, extraData)
	local self = setmetatable({}, ClientCardExecutionContext)
	self._clientGame = clientGame
	self._cardData = cardData
	self._caster = caster
	self._mainCoordinates = mainCoordinates
	self._extraData = extraData
	return self
end

function ClientCardExecutionContext:getExtraData()
	return self._extraData
end

function ClientCardExecutionContext:getMainCoordinates()
	return self._mainCoordinates
end

function ClientCardExecutionContext:getCaster()
	return self._caster
end

function ClientCardExecutionContext:getCardData()
	return self._cardData
end

function ClientCardExecutionContext:getBoard()
	return self._clientGame.clientBoard
end

function ClientCardExecutionContext:getNodeAt(coordinates)
	return self:getBoard():getNodeByCoords(coordinates)
end

function ClientCardExecutionContext:getTargetGroupFromCardData(groupChoice)
	local targetGroup = {}
	local caster = self:getCaster()
	if groupChoice == TargetChoices.ALLY then
		targetGroup = self._clientGame.clientUnitHolder:getAllies(caster.team)
	elseif groupChoice == TargetChoices.ENEMY then
		targetGroup = self._clientGame.clientUnitHolder:getEnemies(caster.team)
	elseif TargetChoices == TargetChoices.ANY then
		targetGroup = self._clientGame.clientUnitHolder:getAll()
	end
	return targetGroup
end

function ClientCardExecutionContext:setCardData(cardData)
	self._cardData = cardData
end

return ClientCardExecutionContext
