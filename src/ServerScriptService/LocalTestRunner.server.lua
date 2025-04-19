local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runTests = require(ReplicatedStorage.TestRunner)

local ok = runTests()
if not ok then
	error("Not all tests passed")
end