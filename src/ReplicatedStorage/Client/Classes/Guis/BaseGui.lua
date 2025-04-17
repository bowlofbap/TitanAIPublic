local BaseGui = {}
BaseGui.__index = BaseGui
local player = game:GetService("Players").LocalPlayer

function BaseGui.new(clientPlayer, objectName)
	local newGui = {}
	setmetatable(newGui, BaseGui)
	local object = game:GetService("StarterGui").PC[objectName]:Clone()
	--[[
	if UserInputService.TouchEnabled then
		object = game:GetService("StarterGui").Mobile.MenuGui:Clone()
	end
	]]
	object.Parent = player.PlayerGui
	newGui.object = object
	newGui.clientPlayer = clientPlayer
	return newGui
end

function BaseGui:show()
	self.object.Enabled = true
end

function BaseGui:hide()
	self.object.Enabled = false
end

function BaseGui:get()
	return self.object
end

return BaseGui 