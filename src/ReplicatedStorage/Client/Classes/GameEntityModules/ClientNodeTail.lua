local MapNodeSettings = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeSettings)

local changeableProperties = {
	Transparency = true,
	Color = true
}

local ClientNodeTail = {}
ClientNodeTail.__index = ClientNodeTail

function ClientNodeTail.new(childNode, parentNode, folder)
	local self = setmetatable({}, ClientNodeTail)
	local newPart = initPart(childNode, parentNode, folder)
	self.model = newPart

	local mt = {
		__index = function(table, key)
			if changeableProperties[key] then
				return self.model[key]
			else
				return ClientNodeTail[key] -- Preserve original __index lookup
			end
		end,
		__newindex = function(table, key, value)
			if changeableProperties[key] then
				self:_onPropertyChange(key, value)
			elseif key == "status" then
				self:_onStatusChange(value)
			else
				rawset(self, key, value)  -- Default behavior for other properties
			end
		end
	}
	setmetatable(self, mt) 
	return self
end

function ClientNodeTail:update(data)
	for key, value in pairs(data) do
		self[key] = value
	end
end

function ClientNodeTail:_onPropertyChange(key, value)
	self.model[key] = value
end

function ClientNodeTail:_onStatusChange(status)
	self.model.Color = status.tailColor
	if status.key == MapNodeSettings.STATUSES.CURRENT.key then
		self.model.Transparency = MapNodeSettings.TAIL.DEFEATED_TRANSPARENCY
	end
end

function ClientNodeTail:hover()
	self.model.Transparency = MapNodeSettings.TAIL.HOVERING_TRANSPARENCY
	self.model.Color = MapNodeSettings.STATUSES.POTENTIAL.tailColor
end

function ClientNodeTail:unhover()
	self.model.Transparency = MapNodeSettings.TAIL.BASE_TRANSPARENCY
	self.model.Color = MapNodeSettings.STATUSES.POTENTIAL.tailColor
end

function initPart(childNode, parentNode, folder)
	local p1 = childNode.model.Base
	local p2 = parentNode.model.Base
	local padding = 1
	local width = 1
	-- Get part sizes
	local p1Size = p1.Size
	local p2Size = p2.Size

	-- Calculate direction and distance between parts
	local direction = (p2.Position - p1.Position)
	local dirUnit = direction.Unit

	-- Calculate edge positions
	local p1Edge = p1.Position + dirUnit * (p1Size.X/2)
	local p2Edge = p2.Position - dirUnit * (p2Size.X/2)

	-- Calculate start/end points with padding
	local startPoint = p1Edge + dirUnit * padding
	local endPoint = p2Edge - dirUnit * padding

	-- Verify minimum required distance
	local distance = (endPoint - startPoint).Magnitude
	local requiredDistance = padding * 2 + width
	if distance < requiredDistance then
		warn("Parts are too close! Minimum distance required: "..requiredDistance)
		return nil
	end

	-- Create new part
	local newPart = Instance.new("Part")
	newPart.Name = "ConnectionPart"
	newPart.Anchored = true
	newPart.CanCollide = false

	-- Calculate center position and orientation
	local centerPos = (startPoint + endPoint) / 2
	newPart.Size = Vector3.new(distance, width, width)
	newPart.CFrame = CFrame.lookAt(centerPos, endPoint) * CFrame.Angles(0, math.pi/2, 0)

	-- Set visual properties (optional)
	newPart.CastShadow = false
	newPart.Color = MapNodeSettings.STATUSES.DEFAULT.tailColor
	newPart.Material = Enum.Material.Cardboard
	newPart.Transparency = MapNodeSettings.TAIL.BASE_TRANSPARENCY
	newPart.Parent = folder
	newPart.Name = childNode.Id
	return newPart
end
return ClientNodeTail
