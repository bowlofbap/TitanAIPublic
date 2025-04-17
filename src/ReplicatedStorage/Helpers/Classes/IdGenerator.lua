local IdGenerator = {}
IdGenerator.__index = IdGenerator

function IdGenerator.new()
	local self = setmetatable({}, IdGenerator)
	self.id = 0
	return self
end

function IdGenerator:gen()
	self.id += 1
	return self.id
end

return IdGenerator
