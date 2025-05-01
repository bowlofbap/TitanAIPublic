local ClientMapNode = require(game:GetService("ReplicatedStorage").Client.Classes.GameEntityModules.ClientMapNode)
local MapNodeSettings = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeSettings)

local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local ClientMap = {}
ClientMap.__index = ClientMap

function ClientMap.new()
	local self = setmetatable({}, ClientMap)
	self.mapFolder = nil
	self.currentNode = nil
	self.nodesById = {}
	self._nodeGrid = {}
	return self
end

function ClientMap:initMap(mapFolder, serializedMapData)
	self.nodesById = {}
	self._nodeGrid = {}
	self.mapFolder = mapFolder
	self.currentNode = nil
	
	for y, nodeRow in ipairs(serializedMapData) do
		local width = #nodeRow
		self._nodeGrid[y] = {}
		for x, nodeData in ipairs(nodeRow) do
			local newNode = ClientMapNode.new(nodeData)
			newNode.Id = nodeData.id
			newNode.Parent = mapFolder
			self.nodesById[nodeData.id] = newNode
			table.insert(self._nodeGrid[y], newNode)

			local noiseFactor = Constants.MAP_SETTINGS.NODE_SETTINGS.NOISE
			local scale = Constants.MAP_SETTINGS.NODE_SETTINGS.SCALE
			local initialPosition = Constants.MAP_SETTINGS.NODE_SETTINGS.INITIAL_POSITION
			local offset = Vector3.new(width * scale/2, 0, 0)
			local noise = Vector3.new(math.random(-noiseFactor, noiseFactor), 0, math.random(-noiseFactor, noiseFactor))
			local position = initialPosition + Vector3.new(scale * x, 0, -scale * y) - offset + noise
			newNode:setPosition(position)
			newNode:setStatus(nodeData.status)
		end
	end
	
	--then set up node connections
	for y = 1, Constants.MAP_SETTINGS.TOTAL_DEPTH do
		local nodes = self._nodeGrid[y]
		for x, node in ipairs(nodes) do
			for _, connectionId in ipairs(node.connectionIds) do
				table.insert(node.connections, self.nodesById[connectionId])
			end
		end
	end

	--then create the node tails
	for y = 1, Constants.MAP_SETTINGS.TOTAL_DEPTH do
		local nodes = self._nodeGrid[y]
		for x, node in ipairs(nodes) do
			for _, child in ipairs(node.connections) do
				child:addTail(node, self.mapFolder.NodeTails)
			end
		end
	end
end

function ClientMap:updateCurrentNode(currentNodeId)
	self.currentNode = self:getNodeById(currentNodeId)
end

function ClientMap:updateMapData(updateData, newCurrentNodeId)
	local previousCurrentNode = self.currentNode
	local currentNode = self:getNodeById(newCurrentNodeId)
	if currentNode then
		self:updateCurrentNode(newCurrentNodeId)
	end
	for _, nodeData in ipairs(updateData) do
		local node = self:getNodeById(nodeData.id)
		node:update(nodeData, currentNode, previousCurrentNode)
	end
end

function ClientMap:getNodeById(id)
	local node = self.nodesById[id]
	if not node then
		warn("No node for id ", id)
	end
	return node
end

function ClientMap:getNodeConnections(node)
	if not node then return nil end
	local nodesById = {}
	for _, nodeId in ipairs(self.nodesById[node.Id].connectionIds) do
		nodesById[nodeId] = self.nodesById[nodeId]
	end
	return nodesById
end

function ClientMap:toggleNodeHover(value, nodeId)
	local node = self.nodesById[nodeId]
	local nodeConnections = self:getNodeConnections(self.currentNode)
	if nodeConnections then
		if nodeConnections[node.Id] then
			node:toggleHover(value, self.currentNode.Id)	
		else
			node:toggleHover(value, nil)
		end
	else
		node:toggleHover(value, nil)
	end
end

return ClientMap
