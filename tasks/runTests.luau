local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runTests = require(ReplicatedStorage.TestRunner)

local results = runTests()
print("::TEST_JSON::"..results)