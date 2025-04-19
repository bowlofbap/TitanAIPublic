local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)
local HttpService = game:GetService("HttpService")

local function sanitizeForEncoding(value, seen)
	seen = seen or {}

	if type(value) == "table" then
		if seen[value] then
			return nil -- avoid cyclic reference
		end
		seen[value] = true

		local result = {}
		for k, v in pairs(value) do
			if type(k) ~= "function" and type(k) ~= "userdata" then
				local cleanedValue = sanitizeForEncoding(v, seen)
				if type(cleanedValue) ~= "function" and type(cleanedValue) ~= "userdata" then
					result[k] = cleanedValue
				end
			end
		end
		return result

	elseif type(value) == "function" or type(value) == "userdata" then
		return nil -- skip
	else
		return value -- number, string, boolean
	end
end


return function()
	local testsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Tests")

	local result = TestEZ.TestBootstrap:run({ testsFolder }, TestEZ.Reporters.TextReporter)
	local sanitizedResult = sanitizeForEncoding(result)
	local encodedResult = HttpService:JSONEncode(sanitizedResult)

	if result.failureCount > 0 then
		warn("❌ Some tests failed.")
	else
		print("✅ All tests passed.")
	end
	return encodedResult
end