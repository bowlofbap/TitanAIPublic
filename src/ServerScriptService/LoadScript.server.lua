--needed so that parts properly replicate on the client with no character

function setNetworkOwner(model, player)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part:SetNetworkOwner(player) -- Assign ownership to the player
		end
	end
end


local function createCustomCharacter(player)
	local customCharacter = Instance.new("Model")
	customCharacter.Name = player.Name

	local basePart = Instance.new("Part") -- Example base part
	basePart.Size = Vector3.new(2, 5, 2)
	basePart.Position = Vector3.new(0, 5, 0) -- Spawn position
	basePart.Transparency = 1
	basePart.Parent = customCharacter

	customCharacter.Parent = game.Workspace
	player.Character = customCharacter -- Make it the official character

	-- Set network ownership so the client can control it smoothly
	basePart:SetNetworkOwner(player)
end

game.Players.PlayerAdded:Connect(function(player)
	createCustomCharacter(player)
end)