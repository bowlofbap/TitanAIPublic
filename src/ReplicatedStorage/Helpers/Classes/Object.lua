local Object = {}
Object.__index = Object

function Object.new()
    return setmetatable({}, Object)
end

local function deepClone(original, copies)
	copies = copies or {}
	if type(original) ~= "table" then
		return original
	elseif copies[original] then
		return copies[original] -- handle cycles
	end

	local copy = {}
	copies[original] = copy
	for k, v in pairs(original) do
		copy[deepClone(k, copies)] = deepClone(v, copies)
	end
	return setmetatable(copy, getmetatable(original))
end

function Object:clone()
	return deepClone(self)
end

function Object:extend()
    local cls = {}
  
    --copy *all* metamethods 
    for k,v in pairs(self) do
      if type(k) == "string" and k:match("^__") then
        cls[k] = v
      end
    end
  
    --normal method inheritance to shorten syntax
    cls.super     = self
    cls.__index   = cls
    setmetatable(cls, { __index = self })
    return cls
end

return Object