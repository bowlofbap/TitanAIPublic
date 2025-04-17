local RunService = game:GetService("RunService")
local Directions = require(game:GetService("ReplicatedStorage").Enums.Directions)
local CameraModes = require(game:GetService("ReplicatedStorage").Enums.Client.CameraModes)
local Angles = require(game:GetService("ReplicatedStorage").Enums.Angles)

local CameraController = {}
CameraController.__index = CameraController

local DRAG_SENSITIVITY = 0.09  -- Adjust this value for faster/slower panning
local MAX_PAN_SPEED = 100       -- Studs per frame limit
local CAMERA_SPEED = 65  -- Studs per second for keyboard
local MAX_DISTANCE = 30
local MIN_DISTANCE = 10

function CameraController.new()
	local self = setmetatable({}, CameraController)
	self.camera = game.Workspace.CurrentCamera
	self.target = nil -- The piece we're focusing on
	self.distances = {
		[CameraModes.MAP_VIEW] =  CFrame.new(0, 30, 30),
		[CameraModes.BATTLE_VIEW] = CFrame.new(0, 22, 22),
		[CameraModes.SHOP_VIEW] = CFrame.new(0, 0, 20),
	}
	self.adjustments = {
		[CameraModes.BATTLE_VIEW] = Vector3.new(0, 0, 5),
	}
	self.angle = CFrame.Angles(math.rad(-30), 0, 0) -- Default angle
	self.currentPosition = nil
	self.dragStartPos = nil
	self.initialCameraCFrame = nil
	return self
end

-- Function to find the center of a Model
local function getModelCenter(model)
	local totalPosition = Vector3.new(0, 0, 0)
	local numParts = 0
	-- Loop through all parts in the model and sum their positions
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			totalPosition = totalPosition + part.Position
			numParts = numParts + 1
		end
	end

	-- Calculate the center position by averaging the part positions
	if numParts > 0 then
		return totalPosition / numParts
	else
		return model.PrimaryPart and model.PrimaryPart.Position or model.Position
	end
end

-- Modify setTarget to handle both Part and Model
function CameraController:setTarget(target, angle, cameraMode)
	local targetPosition
	if target:IsA("Model") then
		self.target = target
		targetPosition = getModelCenter(target)
	else
		print("Target is not a model")
		return
	end
	-- Adjust the camera position to look at the target
	local distance = self.distances[cameraMode]
	local adjustment = self.adjustments[cameraMode] or Vector3.new(0,0,0)
	local targetCFrame = CFrame.new(targetPosition + adjustment) * distance * angle
	self.camera.CameraType = Enum.CameraType.Scriptable
	self.camera.CFrame = targetCFrame
end

function CameraController:setDistance(cameraMode, adjustment)
	--TODO: implement much much later
	--[[
	local zoomSpeed = 2
	self.distances[cameraMode] += math.clamp(adjustment * zoomSpeed, MIN_DISTANCE, MAX_DISTANCE)
	--TODO: now that we have the distance, we need to set that 
	--]]
end

-- Smoothly transition to a new target
function CameraController:transitionTo(model, distance, angle, duration)
	self.target = model
	self.distance = distance or self.distance
	self.angle = angle or self.angle
	duration = duration or 3

	local startPos = self.camera.CFrame
	local targetCFrame = self:_calculateCFrame()
	local startTime = tick()

	-- Smooth transition
	game:GetService("RunService").RenderStepped:Connect(function()
		local alpha = math.min((tick() - startTime) / duration, 1) -- Normalize time
		self.camera.CFrame = startPos:Lerp(targetCFrame.Position, alpha)
		if alpha >= 1 then return end -- Stop once done
	end)
end

function CameraController:initializeCameraDrag(inputPosition)
	self.initialCameraCFrame = self:_projectToPlane(self.camera.CFrame)
	self.dragStartPos = Vector2.new(inputPosition.X, inputPosition.Y)
end

function CameraController:dragCamera(inputPos, keyboardDirection)
	-- Get directional vectors based on current camera orientation
	local projectedCFrame = self:_projectToPlane(self.camera.CFrame)
	local forward = projectedCFrame.LookVector
	local right = projectedCFrame.RightVector
	local deltaTime = RunService.Heartbeat:Wait()

	local panOffset = Vector3.new(0, 0, 0)

	if keyboardDirection then
		-- Handle WASD keyboard movement
		local moveDirection = Vector3.new(0, 0, 0)

		if keyboardDirection == Directions.UP then
			moveDirection += forward
		end
		if keyboardDirection == Directions.DOWN then
			moveDirection -= forward
		end
		if keyboardDirection == Directions.LEFT then
			moveDirection -= right
		end
		if keyboardDirection == Directions.RIGHT then
			moveDirection += right
		end

		-- Normalize and scale by deltaTime for frame independence
		if moveDirection.Magnitude > 0 then
			panOffset = moveDirection.Unit * CAMERA_SPEED * deltaTime
		end
		local newPosition = self.camera.CFrame.Position + panOffset
		self.camera.CFrame = CFrame.new(newPosition) * self.camera.CFrame.Rotation
		self.currentPosition = newPosition
	else
		local inputPosition = Vector2.new(inputPos.X, inputPos.Y)
		-- Handle mouse drag movement
		local delta = (inputPosition - self.dragStartPos) * DRAG_SENSITIVITY

		panOffset = (right * -delta.X) + (forward * delta.Y)

		panOffset = panOffset.Magnitude > MAX_PAN_SPEED 
			and panOffset.Unit * MAX_PAN_SPEED 
			or panOffset
		
		local position = self.initialCameraCFrame.Position + panOffset
		self.camera.CFrame = CFrame.new(position) * self.camera.CFrame.Rotation
		self.currentPosition = position
	end
end

function CameraController:endDrag()
	self.dragStartPos = nil
	self.initialCameraCFrame = nil
end

-- Calculate the desired camera position
function CameraController:_calculateCFrame()
	if not self.target then return self.camera.CFrame end
	local targetPos = getModelCenter(self.target)
	local offset = self.angle * Vector3.new(0, 0, self.distance)
	return CFrame.new(targetPos + offset, targetPos)
end

-- Directly update the camera position
function CameraController:_updateCamera()
	if self.target then
		self.camera.CFrame = self:_calculateCFrame()
	end
end

-- Helper function to project to movement plane
function CameraController:_projectToPlane(cframe)
	local _, y = cframe:ToEulerAnglesYXZ()
	return CFrame.new(cframe.Position) * CFrame.Angles(0, y, 0)
end

return CameraController
