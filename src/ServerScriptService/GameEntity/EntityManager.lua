local GameEntity = require(game:GetService("ServerScriptService").GameEntity.GameEntity)

local EntityManager = {}
EntityManager.__index =  EntityManager

function EntityManager.new()
	local self = setmetatable({}, EntityManager)
	self.entities = {}
	return self
end

function EntityManager:initPlayerEntity(player, data)
	if self.entities[player.UserId] then
		warn("Entity for user "..player.UserId.." already exists!")
		return nil
	else
		local newEntity = GameEntity.new(player, data):init()
		self.entities[player.UserId] = newEntity
		return newEntity
	end
end

function EntityManager:removePlayerEntity(player)
	if self.entities[player.UserId] then
		--TODO: delete the entity?
		local entity = self.entities[player.UserId]
		entity:destroy()
		self.entities[player.UserId] = nil
		return true
	else
		print("Entity did not exist for the user "..player.UserId)
	end
	return false
end

return EntityManager
