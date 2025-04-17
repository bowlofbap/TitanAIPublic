local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)

local OverlayGui = setmetatable({}, { __index = BaseGui }) 
OverlayGui.__index = OverlayGui

function OverlayGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, OverlayGui)
	return self
end

return OverlayGui