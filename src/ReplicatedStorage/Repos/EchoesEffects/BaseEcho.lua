local BaseEcho = {}
BaseEcho.__index = BaseEcho

function BaseEcho.new(id)
	local self = setmetatable({}, BaseEcho)
	self.id = id
	self._unsubscribes = {}
	return self
end

function BaseEcho:execute()
	warn("Needs to be overridden")
end

function BaseEcho:remove()
	for _, unsubscribe in ipairs(self._unsubscribes) do
		unsubscribe()
	end
end

function BaseEcho:destroy()
	setmetatable(self, nil)
end

return BaseEcho
