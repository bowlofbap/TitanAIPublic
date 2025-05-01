local EntityController = {}
EntityController.__index = EntityController

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CameraBindableEvent = game:GetService("ReplicatedStorage").Remotes:WaitForChild("CameraBindableEvent")

local Directions = require(game:GetService("ReplicatedStorage").Enums.Directions)
local EntityActions = require(game:GetService("ReplicatedStorage").Enums.Entity.EntityActions)
local CameraMethods = require(game:GetService("ReplicatedStorage").Enums.CameraMethods)
local CameraModes = require(game:GetService("ReplicatedStorage").Enums.Client.CameraModes)

local EventBusTypes = require(game:GetService("ReplicatedStorage").Enums.Client.EventBusTypes)
local EventBus = require(game:GetService("ReplicatedStorage").Helpers.EventBus)

local isDragging = false
local dragged = false
local hoveringNode = nil

local pressedKeys = {}

local movementKeys = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
	[Enum.KeyCode.Left] = true,
	[Enum.KeyCode.Right] = true,
	[Enum.KeyCode.Up] = true,
	[Enum.KeyCode.Down] = true
}

function EntityController.new(clientEntity)
	local self = setmetatable({}, EntityController)
	self.clientEntity = clientEntity
	self.connections = {}
	self.subscriptions = {}
	self:init()
	return self
end

function EntityController:init()
	table.insert(self.subscriptions, EventBus:Subscribe(EventBusTypes.ClientEntity.ENABLE_MAP_CONTROLLER, 
		function()
			self:connectAll()
		end)
	)
	table.insert(self.subscriptions, EventBus:Subscribe(EventBusTypes.ClientEntity.DISABLE_MAP_CONTROLLER, 
		function()
			self:disconnectAll()
		end)
	)
end

function EntityController:Destroy()
	for _, subscription in ipairs(self.subscriptions) do
		print("destroyed")
		subscription:Disconnect()
	end
	self:disconnectAll()
end

function EntityController:connectAll()
	local c1 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		self:onInputBegan(input)
	end)

	local c2 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		self:onKeyboardInputBegan(input, gameProcessed)
	end)

	local c3 = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		self:onInputChanged(input)
	end)

	local c4 = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		self:onInputEnded(input)
	end)

	local c5 = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		self:onKeyboardInputEnded(input, gameProcessed)
	end)

	local c6 = RunService.Heartbeat:Connect(function()
		self:moveKeyboardCam()
	end)

	self.connections = {c1, c2, c3, c4, c5, c6}
end

function EntityController:disconnectAll()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
end

function EntityController:moveKeyboardCam()
	for direction, _ in pairs(pressedKeys) do
		CameraBindableEvent:Fire(CameraMethods.dragCamera, nil, direction)
	end
end

function EntityController:onKeyboardInputBegan(input)
	if movementKeys[input.KeyCode] then
		local direction
		-- WASD and Arrow Keys
		if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
			direction = Directions.UP
		elseif input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then
			direction = Directions.DOWN
		elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
			direction = Directions.LEFT
		elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
			direction = Directions.RIGHT
		end
		pressedKeys[direction] = true
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function EntityController:onKeyboardInputEnded(input)

	-- Check if pressed key is in our movement set
	if movementKeys[input.KeyCode]then
		-- Handle movement direction
		local direction = nil

		-- WASD and Arrow Keys
		if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
			direction = Directions.UP
		elseif input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then
			direction = Directions.DOWN
		elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
			direction = Directions.LEFT
		elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
			direction = Directions.RIGHT
		end
		
		pressedKeys[direction] = nil
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function EntityController:onInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
		CameraBindableEvent:Fire(CameraMethods.initializeCameraDrag, input.Position)
	
	end
end

function EntityController:onInputChanged(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if isDragging then
			dragged = true
			CameraBindableEvent:Fire(CameraMethods.dragCamera, input.Position, nil)
		end

		local nodeModel = self:getNodeAtPosition()
		if nodeModel then
			if hoveringNode then
				if hoveringNode ~= nodeModel then
					self:toggleNodeHover(hoveringNode, false)
					self:toggleNodeHover(nodeModel, true)
					hoveringNode = nodeModel
				end
			else
				self:toggleNodeHover(nodeModel, true)
				hoveringNode = nodeModel
			end
		else
			if hoveringNode then
				self:toggleNodeHover(hoveringNode, false)
				hoveringNode = nil
			end
		end
	end
	
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		CameraBindableEvent:Fire(CameraMethods.setDistance, CameraModes.MAP_VIEW, input.Position.Z)
	end
end

function EntityController:onInputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
		CameraBindableEvent:Fire(CameraMethods.endDrag)
		--if the player clicked down but didn't move the mouse (basically clicked)
		if not dragged then
			dragged = false
			local mousePos = input.Position
			local nodePart = self:getNodeAtPosition()
			if nodePart then
				local nodeId = nodePart:GetAttribute("Id")
				self.clientEntity:requestAction(EntityActions.START_GAME, {nodeId = nodeId})
				if hoveringNode then
					self:toggleNodeHover(hoveringNode, false)
					hoveringNode = nil
				end
			end
		--player dragged the mouse but lifted the button now
		else
			dragged = false
		end
	end
end

function EntityController:toggleNodeHover(nodeModel, bool)
	local nodeId = nodeModel:GetAttribute("Id")
	self.clientEntity.clientMap:toggleNodeHover(bool, nodeId)
end

function EntityController:getNodeAtPosition()
	local target = game.Players.LocalPlayer:GetMouse().Target
	if target and target:IsDescendantOf(self.clientEntity.entityFolder.MapNodes) then
		return getNodeModel(target)
	end
	return nil
end

function getNodeModel(part)
	local parent = part.Parent
	while parent do
		-- Check if this parent is a model and has the "IsUnit" attribute
		if parent:IsA("Model") and parent:GetAttribute("Id") then
			return parent
		end
		-- Move up to the next parent
		parent = parent.Parent
	end
	-- Return nil if no valid model is found
	return nil
end

return EntityController
