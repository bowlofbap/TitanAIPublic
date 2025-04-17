local MapNodeTypes = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeTypes)
local MapNodeSettings = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeSettings)

local MapNode = {}
MapNode.__index = MapNode

function MapNode.new(nodeType, data, coordinates)
	local self = setmetatable({}, MapNode)
	self.data = data
	self.isTraversed = false
	self._isDirty = false
	self.nodeType = nodeType
	self.status = nil
	self.coordinates = coordinates
	self.connections = {}
	self.connectionIds = {}
	return self
end

function MapNode:addConnection(child)
	if child.coordinates.Y <= self.coordinates.Y then
		error(string.format(
			"Invalid connection from %s to %s - forward links only",
			tostring(self.coordinates),
			tostring(child.coordinates)
			)
		)
	end

	-- Prevent duplicate connections
	if not table.find(self.connections, child) then
		table.insert(self.connections, child)
		table.insert(self.connectionIds, child.Id)
	end
end

function MapNode:setStatus(status)
	self.status = status
	self._isDirty = true
end

function MapNode:isParentOf(node)
	return table.find(self.connections, node)
end

function MapNode:serialize()
	local connectionIds = {}
	
	return {
		id = self.Id,
		connectionIds = self.connectionIds,
		nodeType = self.nodeType,
		status = self.status
	}
end

return MapNode
