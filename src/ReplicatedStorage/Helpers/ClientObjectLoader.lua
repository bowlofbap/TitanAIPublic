local module = {}
local ClientReadyEvent = game:GetService("ReplicatedStorage").Remotes.ClientReadyEvent

function module.WaitForObjectLoaded(player, object)
	local connection
	local readyToContinue = false
	ClientReadyEvent:FireClient(player, object, #object:GetChildren())
	connection = ClientReadyEvent.OnServerEvent:Connect(function()
		connection:Disconnect()
		readyToContinue = true
	end)
	while not readyToContinue do
		wait()
	end
	return true
end

return module
