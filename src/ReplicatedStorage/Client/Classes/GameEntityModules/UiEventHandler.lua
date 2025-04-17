local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local EntityUIActions = require(Enums.Entity.EntityUiActions)
local EventBusTypes = require(Enums.Client.EventBusTypes)
local CameraModes = require(Enums.Client.CameraModes)

local EventBus = require(ReplicatedStorage.Helpers.EventBus)

local UiEventHandler = {}

function UiEventHandler.bind(dispatcher)
	dispatcher:register(EntityUIActions.ENABLE_MAP_CONTROL, function(data, context)
		EventBus:Publish(EventBusTypes.ClientEntity.ENABLE_MAP_CONTROLLER)
		local currentNode = context.clientEntity.clientMap:getNodeById(data.nodeId)
		context.clientEntity:focusCamera(currentNode.model, CameraModes.MAP_VIEW)
	end)

	dispatcher:register(EntityUIActions.CONNECT_TO_INSTANCE, function(data, context)
		context.clientEntity:connectToInstance(data)
	end)	

	dispatcher:register(EntityUIActions.DISCONNECT_FROM_INSTANCE, function(data, context)
		context.clientEntity:disconnectFromInstance()
	end)	

	dispatcher:register(EntityUIActions.DISABLE_MAP_CONTROL, function(data, context)
		EventBus:Publish(EventBusTypes.ClientEntity.DISABLE_MAP_CONTROLLER) --TODO i want to not have this be a thing..
	end)		

	dispatcher:register(EntityUIActions.CAMERA_FOCUS_INSTANCE, function(data, context)
		local currentInstance = context.clientEntity:getCurrentInstance()
		if currentInstance then
			local cameraSubject = currentInstance:getCameraSubject()
			context.clientEntity:focusCamera(cameraSubject, CameraModes.MAP_VIEW)
		end
	end)	

	dispatcher:register(EntityUIActions.GENERATE_NEW_MAP, function(data, context)
		context.clientEntity.clientMap:initMap(data.mapFolder, data.mapData)
	end)	

	dispatcher:register(EntityUIActions.UPDATE_MAP_DATA, function(data, context)
		context.clientEntity.clientMap:updateMapData(data.updateData, data.currentNodeId) --update current node here
	end)	

	dispatcher:register(EntityUIActions.HIDE_SCREEN, function(data, context)
		context.guiEvent:Fire("TransitionGui", "show", data.transitionType)
	end)	

	dispatcher:register(EntityUIActions.SHOW_SCREEN, function(data, context)
		context.guiEvent:Fire("TransitionGui", "hide", data.transitionType)
	end)	

	dispatcher:register(EntityUIActions.UPDATE_PLAYER_HEALTH, function(data, context)
		context.guiEvent:Fire("GameEntityGui", "updateHealth", data.health, data.maxHealth)
	end)	

	dispatcher:register(EntityUIActions.UPDATE_PLAYER_MONEY, function(data, context)
		context.guiEvent:Fire("GameEntityGui", "updateMoney", data.money)
	end)	

	dispatcher:register(EntityUIActions.UPDATE_PLAYER_DECK, function(data, context)
		context.clientEntity:setDeck(data.deck)
		context.guiEvent:Fire("GameEntityGui", "updateDeck", #data.deck)
	end)	

	dispatcher:register(EntityUIActions.ADD_ECHO, function(data, context)
		context.guiEvent:Fire("EchoesGui", "addEcho", data)
	end)	

	dispatcher:register(EntityUIActions.UPDATE_ECHO_COUNT, function(data, context)
		context.guiEvent:Fire("EchoesGui", "updateEchoCount", data.id, data.count)
	end)	

	dispatcher:register(EntityUIActions.UPGRADE_CARD, function(data, context)
		print("TODO", data.unupgradedCard, data.upgradedCard)
		--context.guiEvent:Fire("UpgradeGui", data.unupgradedCard, data.upgradedCard)
	end)	

	dispatcher:register(EntityUIActions.SHOW_END_GAME, function(data, context)
		context.guiEvent:Fire("GameOverGui", "EXCEPT")
	end)	
end

return UiEventHandler
