local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)
return function()
	local testsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Tests")

	local result = TestEZ.TestBootstrap:run({ testsFolder }, TestEZ.Reporters.JUnitReporter, {showTimingInfo = true})
	local text = TestEZ.TestBootstrap:run({ testsFolder }, TestEZ.Reporters.TextReporter)
	if result.failureCount > 0 then
		warn("❌ Some tests failed.")
	else
		print("✅ All tests passed.")
	end
	return result
end