local NodeTypes = require(game:GetService("ReplicatedStorage").Enums.GameInstance.NodeTypes)

local Node = {}
Node.__index = Node

local teamColorKey = {
	[1] = Color3.new(0.318914, 0.543145, 1),
	[2] = Color3.new(1, 0.357702, 0.251545)
}

local changeableModelProperties = {
	Parent = true,
	Name = true,
}

local changeablePartProperties = {
	
}

local changeableAttributes = {
	Team = true,
	Id = true
}

function Node.new()
	local self = setmetatable({}, Node)
	self.coordinates = Vector2.new(0, 0)
	self._occupyingUnit = nil
	self._nodeType = NodeTypes.BASE
	self._subscriptions = {}
	return self
end

function Node:occupy(unit)
	self._isOccupied = true
	self._occupyingUnit = unit
end

function Node:unoccupy()
	self._isOccupied = false
	self._occupyingUnit = nil
end

function Node:getOccupyingUnit()
	return self._occupyingUnit
end

function Node:changeType(nodeType)
	self._nodeType = nodeType
	--TODO: probably emit the function
end

function Node:enable(eventObserver, unit, gameInstance)
	local subscription = self._nodeType.onEnter(eventObserver, unit, gameInstance)
	if subscription then
		table.insert(self._subscriptions, subscription)
	end
end

function Node:disable(unit, gameInstance)
	self._nodeType.onLeave(unit, gameInstance)
	for _, unsubscribe in ipairs(self._subscriptions) do
		unsubscribe()
	end
	self._subscriptions = {}
end


function Node:serialize()
	local occupyingUnitId = nil
	if self:getOccupyingUnit() then
		occupyingUnitId = self:getOccupyingUnit().Id
	end
	return {
		team = self.Team,
		id = self.Id,
		coordinates = self.coordinates,
		nodeType = self._nodeType,
		isOccupied = self:getOccupyingUnit() ~= nil,
		occupyingUnitId = occupyingUnitId
	}
end


return Node
