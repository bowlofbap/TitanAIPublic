local ClientBoardNode = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientBoardNode)
local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local ClientBoard = {}
ClientBoard.__index = ClientBoard


function ClientBoard.new(serializedBoard, parent)
	local self = setmetatable({}, ClientBoard)
	self._nodes = {}
	self._nodesByCoords = {}
	self:_initNodes(serializedBoard, parent)
	return self
end

function ClientBoard:_initNodes(serializedBoard, parent)
	print(serializedBoard, parent)
	local model = Instance.new("Model")
	model.Name = "Nodes"
	model.Parent = parent
	self.model = model
	local nodeSize = ClientBoardNode:getSize()
	local centerPosition = Constants.INSTANCE_SETTINGS.INSTANCE_POSITION
	local gridWidth  = Constants.BOARD_SIZE.X 
	local gridHeight = Constants.BOARD_SIZE.Y 
	local startX = centerPosition.X - ((gridWidth / 2) * nodeSize.X) + (nodeSize.X / 2)
	local startZ = centerPosition.Z - ((gridHeight / 2) * nodeSize.Z) + (nodeSize.Z / 2)
	
	for _, nodeData in ipairs(serializedBoard) do
		local newNode = ClientBoardNode.new(nodeData)
		self._nodes[nodeData.id] = newNode
		
		local x = nodeData.coordinates.X
		local y = nodeData.coordinates.Y
		local nodePosition = Vector3.new(
			startX + (x * nodeSize.X),
			centerPosition.Y,
			startZ + (y * nodeSize.Z)
		)
		newNode.Position = nodePosition
		newNode.Parent = model
		
		if not self._nodesByCoords[x] then
			self._nodesByCoords[x] = {}
		end

		-- Store node at coordinates
		self._nodesByCoords[x][y] = newNode
	end
end

function ClientBoard:getNode(id)
	local node = self._nodes[id]
	if not node then
		warn("No node found for "..id)
		return nil	
	end
	return node
end

function ClientBoard:getModelNodeMap()
	local modelToNode = {}
	for _, node in pairs(self._nodes) do
		modelToNode[node.model] = node
	end
	return modelToNode
end

function ClientBoard:getNodeAtMousePosition() --maybe a bit hacky? seems fine to me
	local mouse = game.Players.LocalPlayer:GetMouse()
	local origin = mouse.UnitRay.Origin
	local direction = mouse.UnitRay.Direction * 50 -- Adjust as needed

	local modelToNode = self:getModelNodeMap()

	-- Create a raycast parameters object
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local whitelist = {}
	-- Add all valid parts to the whitelist
	for model, _ in pairs(modelToNode) do
		if not model then continue end
		table.insert(whitelist, model.PrimaryPart)
	end

	raycastParams.FilterDescendantsInstances = whitelist -- Populate with allowed parts
	-- Perform the raycast
	local result = workspace:Raycast(origin, direction, raycastParams)

	-- If we hit a valid part, return its associated node
	if result and modelToNode[result.Instance.Parent] then
		return modelToNode[result.Instance.Parent]
	end

	return nil
end

function ClientBoard:getNodeByCoords(coordinates)
	--if coordinates.X > 0 and coordinates.X < Constants.BOARD_SIZE.X and coordinates.Y > 0 and coordinates.Y < Constants.BOARD_SIZE.Y
	if self._nodesByCoords[coordinates.X] and self._nodesByCoords[coordinates.X][coordinates.Y] then
		return self._nodesByCoords[coordinates.X][coordinates.Y]
	else
		--print("Node out of bounds at ("..x..", "..y..")")
		return nil -- Return nil if out of bounds
	end
end

return ClientBoard
