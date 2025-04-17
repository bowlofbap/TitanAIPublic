local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatusFrame = ReplicatedStorage.Models.UI.Status

local ClientStatusManager = {}
ClientStatusManager.__index = ClientStatusManager

function ClientStatusManager.new(framesContainer)
	local self = setmetatable({}, ClientStatusManager)
	self._frames = framesContainer
	return self
end

function ClientStatusManager:_reset()
	for _, frame in ipairs(self._frames:GetChildren()) do
		if frame.ClassName == "Frame" then
			frame:Destroy()
		end
	end
end

function ClientStatusManager:update(statusData)
	self:_reset()
	for _, statusData in ipairs(statusData) do
		local newStatus = StatusFrame:Clone()
		newStatus.ImageLabel.Image = statusData.statusType.image
		newStatus.ValueLabel.Text = statusData.value
		newStatus.Parent = self._frames
	end
end

return ClientStatusManager
