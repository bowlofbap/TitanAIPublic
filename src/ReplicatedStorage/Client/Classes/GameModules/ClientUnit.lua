local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitGui = ReplicatedStorage.Models.UI.UnitGui
local UnitRepo = require(ReplicatedStorage.Repos.UnitRepo)
local NumberVisual = require(ReplicatedStorage.Client.Classes.GameModules.NumberVisual)
local ClientStatusManager = require(ReplicatedStorage.Client.Classes.GameModules.ClientStatusManager)
local AnimationTypes = require(ReplicatedStorage.Enums.AnimationTypes)
local NumberTypes = require(ReplicatedStorage.Enums.GameInstance.NumberTypes)
local Promise = require(ReplicatedStorage.Helpers.Classes.Promise)

--Defines the units on the board, physical pieces
local ClientUnit = {}
ClientUnit.__index = ClientUnit

function ClientUnit.new(serializedUnitData)
	local self = setmetatable({}, ClientUnit)
	self._unitData = serializedUnitData.unitData
	self._health = serializedUnitData.health
	self._maxHealth = serializedUnitData.maxHealth
	self._block = serializedUnitData.block
	self.isAlive = serializedUnitData.isAlive
	self.coordinates = serializedUnitData.coordinates
	self.team = serializedUnitData.team
	self.unitType = serializedUnitData.unitType

	self.model = serializedUnitData.unitData.Model:Clone()
	local hover = game:GetService("ReplicatedStorage").Models.Hover:Clone()
	hover.Parent = self.model
	
	local unitGui = UnitGui:Clone() -- maybe make this into an object
	unitGui.Parent = self.model
	unitGui.Adornee = self:getBoneFromName("Head")
	unitGui.HealthFrame.Label.Text = self._health.. "/" ..self._maxHealth
	unitGui.HealthFrame.HealthBar.Size = UDim2.new(1, 0, 1, 0)
	self._unitGui = unitGui
	
	self._clientStatusManager = ClientStatusManager.new(unitGui.StatusFrame)
	self._animations = serializedUnitData.unitData.Animations

	local mt = {
		__index = function(table, key)
			if key == "Name" then
				return self.model.Name
			elseif key == "Position" then
				return self.model.PrimaryPart.Position
			elseif key == "Parent" then
				return self.model.Parent
			elseif key == "Id" then
				return self.model:GetAttribute("Id")
			elseif key == "Hover" then
				return self.model.Hover.Enabled
			else
				return ClientUnit[key]
			end
		end,
		__newindex = function(table, key, value)
			if key == "Name" or key == "Parent" then
				self:_onPropertyChange(key, value)
			elseif key == "Hover" then
				self:_onHoverChange(value)
			elseif key == "Id" then
				self:_onAttributechange(key, value)
			else
				rawset(self, key, value) 
			end
		end
	}
	setmetatable(self, mt) 
	self.Id = serializedUnitData.id
	return self
end

function ClientUnit:destroy()
	self.model:Destroy()
	setmetatable(self, nil)
end

function ClientUnit:updateStatus(statusData)
	self._clientStatusManager:update(statusData)
end

--not being used right now
function ClientUnit:syncWithSerializedData(serializedUnitData)
	self._health = serializedUnitData.health
	self._maxHealth = serializedUnitData.maxHealth
	self._block = serializedUnitData.block
	self._isAlive = serializedUnitData.isAlive
	self._coordinates = serializedUnitData.coordinates
end

function ClientUnit:getLoadedCard()
	warn("Method needs to be overwritten")
end

function ClientUnit:moveToPosition(targetPosition)
	local offset = self.model.base.CFrame:ToObjectSpace(self.model.PrimaryPart.CFrame)
	local rotation = CFrame.Angles(0, math.rad(-90), 0) 
	
	if self.team == "Game" then
		rotation = CFrame.Angles(0, math.rad(90), 0) 
	end

	self.model:SetPrimaryPartCFrame(CFrame.new(targetPosition) * offset * rotation)
end

function ClientUnit:moveToNode(node)
	self.coordinates = node.coordinates
	self:moveToPosition(node.Position)
end

function ClientUnit:getBoneFromName(boneName)
	assert(type(boneName) == "string", "boneName must be string")
	local mesh = self.model.Mesh
	for _, bone in ipairs(mesh:GetDescendants()) do
		if bone.Name == boneName then
			return bone
		end
	end
	warn("Couldn't find "..boneName )
	return nil
end

function ClientUnit:getFirePosition()
	local firePart = self:getBoneFromName("FirePart")
	if firePart then
		return firePart.WorldCFrame.Position
	elseif self.model:FindFirstChild("HumanoidRootPart") then
		return self.model.HumanoidRootPart.Position
	else 
		return self.model.Head.Position
	end
end

function ClientUnit:getAnimation(animationName)
	local animation = Instance.new("Animation")
	animation.AnimationId = self._animations[animationName]
	local track = self.model.AnimationController:LoadAnimation(animation)
	return track
end

function ClientUnit:playAnimationAndWaitForMarker(animationName)
	return Promise.new(function(resolve, reject)
		local track = self:getAnimation(animationName)
		
		local markerSignal = track:GetMarkerReachedSignal("Cast")
		local connection
		
		connection = markerSignal:Connect(function()
			if connection then
				connection:Disconnect()
			end
			resolve()
		end)

		track:Play()
	end)
end

function ClientUnit:removeModel()
	local duration = 1
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween: Tween = nil
	for _, part in ipairs(self.model:GetDescendants()) do
		if part:IsA("BasePart") then
			tween = TweenService:Create(part, tweenInfo, { Transparency = 1 })
			tween:Play()
		end
	end
	tween.Completed:Connect(function()
		self:destroy()
	end)
	return tween
end

function ClientUnit:setHealth(value)
	self._health = value
	self:updateHealthBar()
end

function ClientUnit:setMaxHealth(value)
	self._maxHealth = value
	self:updateHealthBar()
end

function ClientUnit:takeDamage(newHealth, newBlock, healthLost, blockLost)
	self._health = newHealth
	self._block = newBlock
	self:getAnimation(AnimationTypes.TAKE_DAMAGE):play()
	if blockLost == 0 or not (blockLost > 0 and healthLost == 0)then
		local numberVisual = NumberVisual.new(healthLost, NumberTypes.DAMAGE, self)
		numberVisual:play()
	end
	if blockLost > 0 then
		local blockVisual = NumberVisual.new(blockLost, NumberTypes.SHIELD_DAMAGE, self)
		blockVisual:play()
	end
	self:updateHealthBar()
end

function ClientUnit:heal(newHealth, healthGained)
	self:setHealth(newHealth)
	self:updateHealthBar()

	local healVisual = NumberVisual.new(healthGained, NumberTypes.HEAL, self)
	healVisual:play()
end

function ClientUnit:setBlock(value)
	self._block = value
	self:updateHealthBar()
	return value
end

function ClientUnit:updateHealthBar()
	self._unitGui.HealthFrame.Label.Text = self._health.. "/" ..self._maxHealth
	self._unitGui.HealthFrame.HealthBar.Size = UDim2.new(self._health/self._maxHealth, 0, 1, 0)
	if self._block > 0 then
		self._unitGui.BlockFrame.Label.Text = self._block
		self._unitGui.BlockFrame.Visible = true
	else
		self._unitGui.BlockFrame.Visible = false
	end
end

function ClientUnit:_onHoverChange(value)
	self.model.Hover.Enabled = value
end

function ClientUnit:_onPropertyChange(propertyName, value)
	self.model[propertyName] = value
end

function ClientUnit:_onAttributechange(attributeName, value)
	self.model:SetAttribute(attributeName, value)
end

return ClientUnit
