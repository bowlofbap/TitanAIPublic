local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)

return function()
	local testsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Tests")

	local result = TestEZ.TestBootstrap:run({ testsFolder }, TestEZ.Reporters.TextReporter)
	for p, v in pairs(result.errorsTable) do
		print(p, v)
	end
	if result.failureCount > 0 then
		warn("❌ Some tests failed.")
		return false
	else
		print("✅ All tests passed.")
		return true
	end
end