local CameraController = require(game:GetService("ReplicatedStorage").Client.Classes.CameraController)
local CameraEvent = game:GetService("ReplicatedStorage").Remotes:WaitForChild("CameraEvent")
local CameraBindableEvent = game:GetService("ReplicatedStorage").Remotes:WaitForChild("CameraBindableEvent")
local CameraMethods = require(game.ReplicatedStorage.Enums.CameraMethods)	

local methodMap = {}

--This has the drawback of needing to order the methods in the correct order 
for methodName, method in pairs(CameraController) do
	if type(method) == "function" and string.sub(methodName, 1, 1) ~= "_" and methodName ~= "new" then
		methodMap[methodName] = function(self, ...)
			local success, result = pcall(method, self, ...)
			if not success then
				warn("Error calling method: " .. methodName .. " - " .. result)
			end
			return result
		end
	end
end

local playerCamera = CameraController.new()

function runCameraEvent(eventEnum, ...)
	-- Validate if the eventEnum corresponds to a valid method
	if CameraMethods[eventEnum] then
		local method = methodMap[eventEnum]
		if method then
			return method(playerCamera, ...)
		else
			warn("Method for event " .. eventEnum .. " not found.")
		end
	else
		warn("Invalid eventEnum: ", eventEnum)
	end
end

-- Handle Remote Event Calls
CameraEvent.OnClientEvent:Connect(runCameraEvent)
CameraBindableEvent.Event:Connect(runCameraEvent)