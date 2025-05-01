local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SaveService = require(ReplicatedStorage.Services.Server.SaveService).get()
local SaveFunction = ReplicatedStorage.Remotes.SaveFunction

game.Players.PlayerAdded:Connect(function(player)
	SaveService:initSession(player)
end)

SaveFunction.OnServerInvoke = function(player)
	return SaveService:loadData(player)
end