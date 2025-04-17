local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runTests = require(ReplicatedStorage.TestRunner)

local ok = runTests()
if ok then
	os.exit(0)
else
	os.exit(1)
end 