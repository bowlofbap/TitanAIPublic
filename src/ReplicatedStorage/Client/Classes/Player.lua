local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classes = ReplicatedStorage.Client.Classes

local ClientGameEntity = require(Classes.GameEntityModules.ClientGameEntity)
local EntityController = require(Classes.GameEntityModules.EntityController)
local GuiEvents = ReplicatedStorage.Client.BindableEvents

local EntityActions = require(ReplicatedStorage.Enums.Entity.EntityActions)

local EndEntity = ReplicatedStorage.Remotes.EndEntity
local GuiFunction = ReplicatedStorage.Client.BindableFunctions.GuiFunction


local Player = {}
Player.__index = Player

function Player.new(player)
	local self = setmetatable({}, Player)
	self.robloxPlayer = player
	self.clientNodeInstance = nil
	self.clientEntity = nil
	self.inputManager = nil
	self.entityController = nil
	self:init()
	return self
end

function Player:init()

end

--gets called currently from the Main Menu 
function Player:initGameEntity(entityFolder)
	self.clientEntity = ClientGameEntity.new(entityFolder)
	GuiEvents.GuiEvent:Fire("GameEntityGui", "show")
	GuiEvents.GuiEvent:Fire("EchoesGui", "show")
	self.clientEntity:requestAction(EntityActions.RETURN_TO_MAP)
	self.entityController = EntityController.new(self.clientEntity)
end

function Player:getEntity()
	if not self.clientEntity then warn("No entity found") end
	return self.clientEntity
end

function Player:getCurrentInstance()
	local entity = self:getEntity()
	local instance = entity:getCurrentInstance()
	if not instance then warn("No instance found") end
	return instance
end

function Player:endGameEntity()
	if not self.clientEntity then
		warn("No client entity for player")
		return false
	end
	local success = EndEntity:InvokeServer()
	if success then
		if self.clientEntity then
			self.clientEntity:destroy()
		end
		if self.clientNodeInstance then
			self.clientNodeInstance:destroy()
		end
		if self.inputManager then
			self.inputManager:destroy()
		end
		if self.entityController then
			self.entityController:Destroy()
		end
		GuiEvents.GuiEvent:Fire("EchoesGui", "reset")
		GuiEvents.GuiEvent:Fire("MenuGui", "show")
	end
	return success
end

return Player
