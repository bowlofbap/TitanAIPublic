local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)
local HttpService = game:GetService("HttpService")

local function sanitizeNode(node)
	local clean = {
		name = node.planNode and node.planNode.phrase or "Unknown",
		type = node.planNode and node.planNode.type or "Unknown",
		status = node.status or "Unknown",
		errors = {},
		children = {}
	}

	-- Clean errors
	if node.errors then
		for _, err in ipairs(node.errors) do
			table.insert(clean.errors, {
				message = tostring(err.message),
				trace = tostring(err.trace or "")
			})
		end
	end

	-- Recurse into children
	if node.children then
		for _, child in ipairs(node.children) do
			table.insert(clean.children, sanitizeNode(child))
		end
	end

	return clean
end

local function sanitizeResults(results)
	return {
		successCount = results.successCount or 0,
		failureCount = results.failureCount or 0,
		skippedCount = results.skippedCount or 0,
		errors = results.errors and table.clone(results.errors) or {},
		root = sanitizeNode(results)
	}
end


return function()
	local testsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Tests")

	local result = TestEZ.TestBootstrap:run({ testsFolder }, TestEZ.Reporters.TeamCityReporter)
	local sanitized = sanitizeResults(result)
	print(sanitized)
	local encodedResult = HttpService:JSONEncode(sanitized)
	print(encodedResult)
	if result.failureCount > 0 then
		warn("❌ Some tests failed.")
	else
		print("✅ All tests passed.")
	end
	return encodedResult
end