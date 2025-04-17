local MapNodeSettings = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeSettings)
local NodeModel = game:GetService("ReplicatedStorage").Models.Entity.Client.Node
local NodeTail = require(game:GetService("ReplicatedStorage").Client.Classes.GameEntityModules.ClientNodeTail)

local changeableProperties = {
	Parent = true,
}

local changeableAttributes = {
	Id = true
}

local ClientMapNode = {}
ClientMapNode.__index = ClientMapNode

function ClientMapNode.new(nodeData)
	local connectionIds, nodeType, id = nodeData.connectionIds, nodeData.nodeType, nodeData.id
	local self = setmetatable({}, ClientMapNode)
	self.model = NodeModel:Clone()
	self.connectionIds = connectionIds
	self.connections = {}
	self.tails = {}
	self.status = nil

	self.typeModel = nodeType.model:Clone()
	self.typeModel.Parent = self.model
	
	-- Explicitly create a new metatable for this instance, can use this MapNode as basically just a Part
	-- EG position = newMapNode.Position -> returns the Vector3 of the MapNode's part's position
	local mt = {
		__index = function(table, key)
			if changeableProperties[key] then
				return self.model[key]
			elseif changeableAttributes[key] then
				return self.model:GetAttribute(key)
			else
				return ClientMapNode[key] -- Preserve original __index lookup
			end
		end,
		__newindex = function(table, key, value)
			if changeableProperties[key] then
				self:_onPropertyChange(key, value)
			elseif changeableAttributes[key] then
				self:_onAttributeChange(key, value)
			else
				rawset(self, key, value)  -- Default behavior for other properties
			end
		end
	}
	setmetatable(self, mt) 
	
	configureInfoGui(self.model.StageInfoGui, nodeType.label, nodeType.description)
	return self
end

function ClientMapNode:setStatus(status)
	self.status = status
	self.model.Base.BrickColor = status.color
end

function configureInfoGui(billboardGui, name, description)
	billboardGui.Frame.NameLabel.Text = name
	billboardGui.Frame.DescriptionLabel.Text = description
end

function ClientMapNode:update(data, currentNode, previousNode)
	for key, value in pairs(data) do
		if key == "status" then
			self:setStatus(value)
		else
			self[key] = value
		end
	end
	if data.status.key == MapNodeSettings.STATUSES.POTENTIAL.key and currentNode and self.tails[currentNode.Id] then
		self.tails[currentNode.Id]:update(data)
	elseif data.status.key == MapNodeSettings.STATUSES.DEFAULT.key and previousNode and self.tails[previousNode.Id] then
		self.tails[previousNode.Id]:update(data)
	elseif data.status.key == MapNodeSettings.STATUSES.CURRENT.key and previousNode and self.tails[previousNode.Id] then
		self.tails[previousNode.Id]:update(data)
	end
end

function ClientMapNode:toggleHover(value, tailId)
	if value then
		self.model.SelectionBox.Visible = true
		self.model.StageInfoGui.Enabled = true
		local tail = self.tails[tailId]
		if tailId and tail then
			tail:hover()
		end
	else
		self.model.SelectionBox.Visible = false
		self.model.StageInfoGui.Enabled = false
		local tail = self.tails[tailId]
		if tailId and tail then
			tail:unhover()
		end
	end
end

function ClientMapNode:setPosition(position)
	self.model:SetPrimaryPartCFrame(CFrame.new(position))
	local offset = self.typeModel.Base.CFrame:ToObjectSpace(self.typeModel.PrimaryPart.CFrame)
	self.typeModel:SetPrimaryPartCFrame(CFrame.new(self.model.PrimaryPart.Position) * offset)
end

function ClientMapNode:addTail(parentNode, tailFolder)
	local newTail = NodeTail.new(self, parentNode, tailFolder)
	self.tails[parentNode.Id] = newTail
end

function ClientMapNode:_onPropertyChange(key, value)
	self.model[key] = value
end

function ClientMapNode:_onAttributeChange(key, value)
	local id = tonumber(value) or error("Invalid ID format: "..tostring(value))
	self.model:SetAttribute(key, id)
end

return ClientMapNode
