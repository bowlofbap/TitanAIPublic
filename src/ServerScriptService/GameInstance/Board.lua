local Node = require(game:GetService("ServerScriptService").GameInstance.Node) 
local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)
local Board = {}
Board.__index = Board

function Board.new(centerPosition, robloxPlayer)
	local self = setmetatable({}, Board)
	self.nodes = {}
	self.nodesById = {}
	
	local gridWidth  = Constants.BOARD_SIZE.X 
	local gridHeight = Constants.BOARD_SIZE.Y 
	local id = 1

	for x = 1, gridWidth do
		self.nodes[x] = {}
		local team = robloxPlayer.Name
		if x > gridWidth/2 then
			team = "Game"
		end
		for z = 1, gridHeight  do
			local newNode = Node.new()
			newNode.Name = id
			newNode.Team = team
			newNode.Id = id
			newNode.coordinates = Vector2.new(x, z)
			self.nodes[x][z] = newNode -- Store in 2D array
			self.nodesById[id] = newNode
			id += 1
		end
	end
	
	return self
end

function Board:isNodeAtCoordsOccupied(coordinates)
	local node = self:getNode(coordinates)
	if not node then warn("No node found at " ..coordinates) return nil end
	return node:getOccupyingUnit()
end

function Board:occupyNodeAt(coordinates, unit)
	local node = self.nodes[coordinates.X][coordinates.Y]
	node:occupy(unit)
	return node
end

function Board:unoccupyNodeAt(coordinates)
	local node = self.nodes[coordinates.X][coordinates.Y]
	node:unoccupy()
	return node
end

function Board:getNode(coordinates)
	if not coordinates then return nil end
	local x = coordinates.X
	local y = coordinates.Y
	if self.nodes[x] and self.nodes[x][y] then
		return self.nodes[x][y]
	else
		--print("Node out of bounds at ("..x..", "..y..")")
		return nil -- Return nil if out of bounds
	end
end

function Board:getNodeById(id)
	local node = self.nodesById[id]
	if not node then
		warn("No node found with id")
		return nil	
	end
	return node
end

function Board:getPlayerNode(coordinates)
	return self:getNode(coordinates)
end

function Board:getEnemyNode(coordinates)
	return self:getNode(coordinates + Vector2.new(Constants.BOARD_SIZE.X/2, 0))
end

function Board:serialize()
	local nodes = {}
	for _, row in ipairs(self.nodes) do
		for _, node in ipairs(row) do
			table.insert(nodes, node:serialize())
		end
	end
	return nodes
end

return Board