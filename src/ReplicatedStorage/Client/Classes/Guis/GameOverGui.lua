local player = game:GetService("Players").LocalPlayer

local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)
local GameOverGui = setmetatable({}, { __index = BaseGui }) 
GameOverGui.__index = GameOverGui

function GameOverGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, GameOverGui)
	self:init()
	return self
end

function GameOverGui:init()
	self.object.Frame.ContinueButton.MouseButton1Click:Connect(function()
		self:hide()
		local success = self.clientPlayer:endGameEntity()
		print(success)
		if not success then
			warn("Unable to end entity")
		end
	end)
end

return GameOverGui