local UserInputService = game:GetService("UserInputService")

local InputManager = {}
InputManager.__index = InputManager

function InputManager.new(interactionManager)
	local self = setmetatable({}, InputManager)
	self._interactionManager = interactionManager
	self._connections = {}
	self:_init()
	return self
end

function InputManager:destroy()
	self:disconnectAll()
	setmetatable(self, nil)
end

function InputManager:_init()
	self._connections = {
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed then
				self._interactionManager:handleInput("InputBegan", input)
			end
		end),
		UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if not gameProcessed then
				self._interactionManager:handleInput("InputChanged", input)
			end
		end),
		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if not gameProcessed then
				self._interactionManager:handleInput("InputEnded", input)
			end
		end),
	}
end

function InputManager:disconnectAll()
	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	self._connections = nil
end

return InputManager
