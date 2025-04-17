local ClientReadyEvent = game:GetService("ReplicatedStorage").Remotes:WaitForChild("ClientReadyEvent")

ClientReadyEvent.OnClientEvent:Connect(function(folder, expectedChildren)
	print(folder, expectedChildren)
	print("Expecting to load "..expectedChildren.. " in "..folder.Name)
	while #folder:GetChildren() ~= expectedChildren do
		print(#folder:GetChildren(), expectedChildren)
		wait()
	end
	print("Finished loading ".. folder.Name)
	ClientReadyEvent:FireServer()
end)