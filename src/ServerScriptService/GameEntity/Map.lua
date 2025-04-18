local ChestGenerator = require(game:GetService("ServerScriptService").ChestInstance.ChestGenerator)

local MapNode = require(game:GetService("ServerScriptService").GameEntity.MapNode)
local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local MapNodeTypes = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeTypes)
local MapNodeSettings = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeSettings)

local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local Map = {}
Map.__index =  Map

function Map.new(parentFolder, idGenerator)
	local self = setmetatable({}, Map)
	self.nodes = {}
	self.nodeGrid = {}
	self.potentialNodes = {}
	self.idGenerator = idGenerator
	self.currentNode = nil
	self.previousNode = nil
	self.mapFolder = nil
	self._dirtyNodes = {}
	self:_resetMapFolder(parentFolder)
	self.root = nil
	return self
end

function Map:_resetMapFolder(parentFolder)
	local mapNodes = Instance.new("Model")
	mapNodes.Name = "MapNodes"
	local mapTails = Instance.new("Folder")
	mapTails.Name = "NodeTails"
	mapTails.Parent = mapNodes
	mapNodes.Parent = parentFolder
	self.mapFolder = mapNodes
end

function Map:reset(parentFolder)
	self.mapFolder:Destroy()
	self.nodes = {}
	self.nodeGrid = {}
	self.potentialNodes = {}
	self.currentNode = nil
	self.previousNode = nil
	self.root = nil
	self:_resetMapFolder(parentFolder)
end

function Map:destroy()
	self:reset()
	setmetatable(self, nil)
end


function Map:markNodeDirty(node)
	self._dirtyNodes[node.Id] = node
end

function Map:findAndClearDirtyNodes()
	local updates = {}
	for id, node in pairs(self._dirtyNodes) do
		table.insert(updates, node:serialize()) 
		node.isDirty = false
	end
	self._dirtyNodes = {}
	return updates
end

function Map:serializeNodes()
	local serializedNodes = {}
	for y = 1, Constants.MAP_SETTINGS.TOTAL_DEPTH do
		local nodes = self.nodeGrid[y]
		serializedNodes[y] = {}
		for x, node in ipairs(nodes) do
			local serializedNode = node:serialize()
			table.insert(serializedNodes[y], serializedNode)
		end
	end
	return serializedNodes
end

function Map:getNodeById(id)
	return self.nodes[id]
end

function Map:isValidNextNode(node)
	if self.currentNode == nil then
		return node == self.root
	end
	return self.currentNode:isParentOf(node)
end

function Map:getCurrentNode()
	if self.currentNode == nil then
		return self.root
	end
	return self.currentNode
end

function Map:generate(playerState)
	self.currentNode = nil
	self.nodes = {}
	
	local lastNode = nil
	local frontier = { }
	local prevFrontier = {}
	local width = 0
	for height = 1, Constants.MAP_SETTINGS.TOTAL_DEPTH do
		prevFrontier = frontier
		frontier = {}
		local excludedType = nil
		local forcedType = nil
		if height == 1 then
			width = 1
		elseif height == 2 then
			width = Constants.MAP_SETTINGS.MAX_STARTING_WIDTH
		elseif height == Constants.MAP_SETTINGS.TOTAL_DEPTH - 2 then
			excludedType = MapNodeTypes.REST
		elseif height == Constants.MAP_SETTINGS.TOTAL_DEPTH - 1 then
			width = 2 
			forcedType = MapNodeTypes.REST
		elseif height == Constants.MAP_SETTINGS.TOTAL_DEPTH then
			width = 1
			forcedType = MapNodeTypes.BOSS_ENEMY
		elseif height == math.floor(Constants.MAP_SETTINGS.TOTAL_DEPTH/2) then
			forcedType = MapNodeTypes.CHEST
		elseif height == math.floor(Constants.MAP_SETTINGS.TOTAL_DEPTH/2) - 1 then
			excludedType = MapNodeTypes.CHEST
		else
			local floorMinWidth = math.ceil(#prevFrontier/2)
			local floorMaxWidth = #prevFrontier*2
			if height == Constants.MAP_SETTINGS.TOTAL_DEPTH - 2 then
				floorMaxWidth = 4
			end 
			width = math.random(math.max(Constants.MAP_SETTINGS.MIN_WIDTH, floorMinWidth), math.min(Constants.MAP_SETTINGS.MAX_WIDTH, floorMaxWidth))
		end
		if height == 1 then
			local newNode = self:_createNode(
				MapNodeTypes.SHOP,
				self:getNodeData(MapNodeTypes.SHOP, 0, playerState),
				Vector2.new(1, 1)
			)
			lastNode = newNode
			self.root = newNode
			table.insert(frontier, lastNode)
		elseif height == 2 then
			local startingWidth = math.random(Constants.MAP_SETTINGS.MIN_STARTING_WIDTH, Constants.MAP_SETTINGS.MAX_STARTING_WIDTH)
			for i = 1, startingWidth do
				local coordinate = Vector2.new(1, height)
				local newNode = self:_createChild(self.root, MapNodeTypes.REGULAR_ENEMY, coordinate, playerState)
				table.insert(frontier, newNode)
				lastNode = newNode
			end
		else
			local diff = width - #prevFrontier
			local maxMerge = #prevFrontier - 1
			local numMerges, numSplits = getIndices(diff, maxMerge, #prevFrontier)
			local mergeIndices = selectRandomIndices(Tables.chop(prevFrontier), numMerges)
			local splitIndices = selectRandomIndices(prevFrontier, numSplits)
			local z = 1
			for index, node in ipairs(prevFrontier) do
				local function makeNewNode()
					local coordinate = Vector2.new(1, height)
					local newNodeType
					if excludedType then
						newNodeType = getNodeType(height, node, { [excludedType] = true, [node.nodeType] = true })
					else
						if node.nodeType == MapNodeTypes.REGULAR_ENEMY then
							newNodeType = getNodeType(height, node, {})
						else
							newNodeType = getNodeType(height, node, { [node.nodeType] = true })
						end
					end
					if forcedType then
						newNodeType = forcedType
					end
					local newNode = self:_createChild(node, newNodeType, coordinate)
					z+=1
					table.insert(frontier, newNode)
					lastNode = newNode
				end
				if mergeIndices[index-1] then
					node:addConnection(lastNode)
				else
					makeNewNode()
				end
				if splitIndices[index] then
					makeNewNode()
				end
			end
		end	
		self.nodeGrid[height] = frontier	
	end
	self:updateCurrentNode()
end

function getIndices(diff, maxMerge, maxSplit) 
	local numMerges, numSplits
	if diff <= 0 then
		numMerges = math.random(-1 * diff, maxMerge)
		numSplits = diff + numMerges
	else
		numSplits = math.random(diff, maxSplit)
		numMerges = numSplits - diff
	end
	return numMerges, numSplits
end

function selectRandomIndices(tbl, n)
	local indices = {}
	local result = {}

	-- Create a list of all available indices
	for i = 1, #tbl do
		table.insert(indices, i)
	end

	-- Fisher-Yates shuffle algorithm
	for i = #indices, 2, -1 do
		local j = math.random(i)
		indices[i], indices[j] = indices[j], indices[i]
	end

	-- Select first n elements from shuffled indices
	for i = 1, n do
		result[indices[i]] = true
	end

	return result
end

function getNodeType(height, parentNode, excludeTypes)
	local randomType = MapNodeTypes.getRandomType()
	if excludeTypes[randomType] then
		return getNodeType(height, parentNode, excludeTypes)
	end
	return randomType
end

function Map:updateCurrentNode(node)
	for _, nodeData in ipairs(self.potentialNodes) do
		nodeData.node:setStatus(MapNodeSettings.STATUSES.DEFAULT)
		self:markNodeDirty(nodeData.node)
	end
	
	if node then
		if self.currentNode then
			self.currentNode:setStatus(MapNodeSettings.STATUSES.DEFEATED)
			self:markNodeDirty(self.currentNode)
		end
		self.previousNode = self.currentNode
		self.currentNode = node
		node:setStatus(MapNodeSettings.STATUSES.CURRENT)
		self:markNodeDirty(node)
		
		self.potentialNodes = {}
		for _, child in ipairs(node.connections) do
			child:setStatus(MapNodeSettings.STATUSES.POTENTIAL)
			self:markNodeDirty(child)
			table.insert(self.potentialNodes, {node = child})
		end
	else
		self:markNodeDirty(self.root)
		self.root:setStatus(MapNodeSettings.STATUSES.POTENTIAL)
		table.insert(self.potentialNodes, {node = self.root})
	end
end

function Map:_createNode(nodeType, data, coordinates)
	local newNode = MapNode.new(nodeType, data, coordinates)
	newNode.Id = self.idGenerator:gen()
	newNode.status = MapNodeSettings.STATUSES.DEFAULT
	self.nodes[newNode.Id] = newNode
	return newNode
end 

function Map:getNodeData(nodeType, depth, playerState)
	if nodeType == MapNodeTypes.REGULAR_ENEMY then
		return require(game:GetService("ReplicatedStorage").Stages.Level1).tier1[1]
	elseif nodeType == MapNodeTypes.SHOP then-- shop data is created on entry
		return nil
	elseif nodeType == MapNodeTypes.CHEST then
		return ChestGenerator.getData()
	elseif nodeType == MapNodeTypes.ELITE_ENEMY then
		return require(game:GetService("ReplicatedStorage").Stages.Level1).tier1[1]
	elseif nodeType == MapNodeTypes.BOSS_ENEMY then
		return require(game:GetService("ReplicatedStorage").Stages.Level1).tier1[1]
	elseif nodeType == MapNodeTypes.EVENT then
		return nil
	end
	return require(game:GetService("ReplicatedStorage").Stages.Level1).tier1[1]
end

function Map:_createChild(parent, nodeType, coordinates, playerState)
	local coordinates = coordinates
	
	-- Create node with type-specific data
	local child = self:_createNode(
		nodeType,
		self:getNodeData(nodeType, coordinates.Y, playerState),
		coordinates
	)

	-- Create forward connection only
	parent:addConnection(child)

	return child
end


return Map
