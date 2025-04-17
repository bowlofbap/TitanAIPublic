local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)

local results = TestEZ.TestBootstrap:run({
	game:GetService("ReplicatedStorage"):WaitForChild("Tests")
}, TestEZ.Reporters.TextReporter)

if results.failureCount > 0 then
	warn("Some tests failed!")
else
	print("All tests passed!")
end