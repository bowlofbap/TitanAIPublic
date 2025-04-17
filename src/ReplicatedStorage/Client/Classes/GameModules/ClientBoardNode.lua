local NodeModel = game:GetService("ReplicatedStorage").Models.NodeInstances.Node

local ClientBoardNode = {}
ClientBoardNode.__index = ClientBoardNode

local hovering = NumberSequence.new(0, 1)
local hiding = NumberSequence.new(1)

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

function ClientBoardNode.new(nodeData)
	local self = setmetatable({}, ClientBoardNode)
	local newModel: Model = NodeModel:Clone()
	self.model = newModel
	self.coordinates = nodeData.coordinates
	self.isOccupied = nodeData.isOccupied
	self.nodeType = nodeData.nodeType
	self.occupyingUnit = nil
	
	-- Explicitly create a new metatable for this instance, can use this Node as basically just a Part
	-- EG position = newNode.Position -> returns the Vector3 of the Node's part's position
	local mt = {
		__index = function(table, key)
			if changeablePartProperties[key] then
				return self.model.PrimaryPart[key]
			elseif changeableModelProperties[key] then
				return self.model[key]
			elseif changeableAttributes[key] then
				return self.model:GetAttribute(key)
			elseif key == "Position" then
				return self.model.PrimaryPart.Position
			elseif key == "Size" then
				return self.model.PrimaryPart.Size 
			else
				return ClientBoardNode[key] -- Preserve original __index lookup
			end
		end,
		__newindex = function(table, key, value)
			if changeableModelProperties[key] then
				self:_onModelPropertyChange(key, value)
			elseif changeablePartProperties[key] then
				self:_onPartPropertyChange(key, value)
			elseif changeableAttributes[key] then
				self:_onAttributeChange(key, value)
			elseif key == "Size" then
				--TODO: Handle if needed
			elseif key == "Position" then
				self:_onPositionChange(value)
			else
				rawset(self, key, value)  -- Default behavior for other properties
			end
		end
	}
	setmetatable(self, mt) 
	
	self.Id = nodeData.id
	self.Team = nodeData.team
	
	return self
end

function ClientBoardNode:toggleHighlight(value)
	if value then
		self.model.Highlight.Transparency = 0.3
	else
		self.model.Highlight.Transparency = 1
	end
end

function ClientBoardNode:toggleRadiusIndicator(value)
	if value then
		self.model.RadiusPart.Transparency = 0.3
	else
		self.model.RadiusPart.Transparency = 1
	end
end

function ClientBoardNode:toggleUnitTarget(value)
	if value then
		self.model.PrimaryPart.HoverAttachment.HoverVFX.Transparency = hovering
	else
		self.model.PrimaryPart.HoverAttachment.HoverVFX.Transparency = hiding
	end
end

function ClientBoardNode:update(serializedNodeData, context)
	self.model.PrimaryPart.Color = serializedNodeData.nodeType.color
	self.occupyingUnit = context.clientGame.clientUnitHolder:getUnit(serializedNodeData.occupyingUnitId)
end

function ClientBoardNode:getOccupyingUnit()
	return self.occupyingUnit
end

function ClientBoardNode:_onModelPropertyChange(key, value)
	self.model[key] = value
end

function ClientBoardNode:_onPartPropertyChange(key, value)
	self.model.PrimaryPart[key] = value
end

function ClientBoardNode:_onAttributeChange(key, value)
	self.model:SetAttribute(key, value)
	if key == "Team" then
		if value == "Game" then
			self:_changeBorderColor(teamColorKey[2])
		else
			self:_changeBorderColor(teamColorKey[1])
		end
	end
end

function ClientBoardNode:_getModelProperty(key)
	return self.model[key]
end

function ClientBoardNode:_getPartProperty(key)
	return self.model.PrimaryPart[key]
end

function ClientBoardNode:_changeBorderColor(color)
	for _, borderPart in ipairs(self.model.NodeBorder:GetChildren()) do
		borderPart.Color = color
	end
end

function ClientBoardNode:_onPositionChange(value)
	self.model:SetPrimaryPartCFrame(CFrame.new(value))
end

-- Static method that returns the node size -- TODO: dont make the border hardcoded
function ClientBoardNode.getSize()
	return NodeModel.PrimaryPart.Size + (Vector3.new(.25,0,.25) * 2)
end

return ClientBoardNode
