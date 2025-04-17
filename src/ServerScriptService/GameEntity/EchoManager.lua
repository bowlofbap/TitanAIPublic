local Echoes = game:GetService("ReplicatedStorage").Repos.EchoesEffects

local EchoManager = {}
EchoManager.__index =  EchoManager

function EchoManager.new(eventObserver, idGenerator, playerState, deckManager, getCurrentInstance)
	local self = setmetatable({}, EchoManager)
	self.echos = {}
	self._idGenerator = idGenerator
	self._eventObserver = eventObserver
	self._playerState = playerState
	self._deckManager = deckManager
	self._getCurrentInstance = getCurrentInstance
	return self
end

function EchoManager:add(echoName)
	local echoClass = Echoes:FindFirstChild(echoName)
	if echoClass then
		local id = self._idGenerator:gen()
		local newEcho = require(echoClass).new(id)
		newEcho:execute(self._eventObserver, self._playerState, self._deckManager, self._getCurrentInstance)
		self.echos[id] = newEcho
		return newEcho
	else
		warn("Echo "..echoName.." was not found")
	end
end

function EchoManager:getEchoByStringName(echoStringName)
	for _, echo in pairs(self.echos) do
		if echo.data.stringName == echoStringName then
			return echo
		end
	end
	return nil
end

function EchoManager:destroy()
	-- Explicitly destroy all echoes
	for id, echo in pairs(self.echos) do
		if echo.destroy then
			echo:destroy()
		end
		self.echos[id] = nil
	end

	-- Clear all other references explicitly
	self.echos = nil
	self._idGenerator = nil
	self._eventObserver = nil
	self._playerState = nil
	self._deckManager = nil
	self._getCurrentInstance = nil

	-- Remove metatable reference
	setmetatable(self, nil)
end

return EchoManager
