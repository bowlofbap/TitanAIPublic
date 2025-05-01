local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classes = ReplicatedStorage.Client.Classes

local InputManager = require(Classes.InputManager)
local InteractionManager = require(Classes.GameModules.InteractionManager)
local ClientGame = require(Classes.GameModules.ClientGame)
local ClientShop = require(Classes.ClientShopModules.ClientShop)
local ClientChest = require(Classes.ClientChestModules.ClientChest)
local ClientRest = require(Classes.ClientRestModules.ClientRest)
local ClientEvent = require(Classes.ClientEventModules.ClientEvent)

local MapNodeTypes = require(ReplicatedStorage.Enums.Entity.MapNodeTypes)

local GuiService = require(ReplicatedStorage.Services.Client.GuiService)

local ClientInstanceManager = {}
ClientInstanceManager.__index = ClientInstanceManager

function ClientInstanceManager.new()
	local self = setmetatable({}, ClientInstanceManager)
	self._currentInstance = nil
	self._inputManager = nil
	return self
end

function ClientInstanceManager:getCurrentInstance()
	return self._currentInstance
end

function ClientInstanceManager:connectToInstance(nodeType, instanceFolder, ...)
	if self._currentInstance then
		warn("Instance was already here")
		self:disconnectFromInstance()
	end
	if nodeType.label == MapNodeTypes.REGULAR_ENEMY.label or nodeType.label == MapNodeTypes.ELITE_ENEMY.label or nodeType.label == MapNodeTypes.BOSS_ENEMY.label then
		local newInstance = ClientGame.new(instanceFolder, ...)
		local battleGuiObject = GuiService:getGui("BattleGui").object
		local interactionManager = InteractionManager.new({clientGame = newInstance, playZoneFrame = battleGuiObject.PlayZoneFrame})
		local newInputManager = InputManager.new(interactionManager)
		self._currentInstance = newInstance
		self._inputManager = newInputManager
		local c1, c2 
		c1 = self._currentInstance.isPaused.Changed:Connect(function(value)
			--[[ use a state machine for this
			newController:disconnectAll()
			if not value then
				newController:connectAll()
			end
			--]]
		end)
		c2 = self._currentInstance.isPlaying.Changed:Connect(function(value)
			self:_disconnectInputManager()
			interactionManager:cleanup() --sets the state to Game over but doesn't do anything really, just trasntiions out of current states
			newInstance:cleanup()
		end)
		GuiService:invoke("BattleGui", "updateConnections")
	elseif nodeType.label == MapNodeTypes.SHOP.label then
		self._currentInstance = ClientShop.new(instanceFolder, ...)
	elseif nodeType.label == MapNodeTypes.CHEST.label then
		self._currentInstance = ClientChest.new(instanceFolder, ...)
	elseif nodeType.label == MapNodeTypes.REST.label then
		self._currentInstance = ClientRest.new(instanceFolder, ...)
	elseif nodeType.label == MapNodeTypes.EVENT.label then
		self._currentInstance = ClientEvent.new(instanceFolder, ...)
		print("instance set")
	else
		warn("implementation for node hasn't be resolved", nodeType)
	end
	return self._currentInstance
end

function ClientInstanceManager:disconnectFromInstance()
	if self._currentInstance then
		self._currentInstance:destroy()
		self._currentInstance = nil
	end
	self:_disconnectInputManager()
end

function ClientInstanceManager:_disconnectInputManager()
	if self._inputManager then
		self._inputManager:destroy()
		self._inputManager = nil
	end
end

return ClientInstanceManager
