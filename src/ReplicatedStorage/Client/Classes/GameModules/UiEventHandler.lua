local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local UiActions = require(Enums.GameInstance.UiActions)

local UiEventDispatcher = {}

function UiEventDispatcher.bind(dispatcher)
	dispatcher:register(UiActions.DRAW, function(data, context)
		context.clientGame:_drawCard(data)
	end)

	dispatcher:register(UiActions.RESET_DECK, function(data, context)
		context.clientGame:_resetDeck(data)
	end)

	dispatcher:register(UiActions.MOVE_UNIT, function(data, context) --we use the context because we might want to move these bindings somewhere else that isn't the ClientGame to prevent bloat
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		local targetNode = context.clientGame.clientBoard:getNodeByCoords(data.coordinates)
		if not unit then warn("Unit not found", data) return end
		if not targetNode then warn("Node not found", data) return end
		unit:moveToNode(targetNode)
	end)

	dispatcher:register(UiActions.UPDATE_FRAMES, function(data, context)
		context.guiEvent:Fire("BattleGui", "updateFrames", data)
	end)

	dispatcher:register(UiActions.DISCARD, function(data, context)
		context.clientGame:discard(data.cardId)
	end)

	dispatcher:register(UiActions.PLAY_CARD, function(data, context)
		context.clientGame:playCard(data.cardId)
	end)

	dispatcher:register(UiActions.DEAL_DAMAGE, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		if not unit then warn("Unit not found") return end
		unit:takeDamage(data.newHealth, data.newBlock, data.healthLost, data.blockLost)
	end)

	dispatcher:register(UiActions.KILL_UNIT, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		if not unit then warn("Unit not found") return end
		context.clientGame.clientUnitHolder:removeUnit(unit)
		unit:removeModel()
	end)

	dispatcher:register(UiActions.PLAY_UNIT_ANIMATION, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		if not unit then warn("Unit not found") return end
		local promise = unit:playAnimationAndWaitForMarker(data.animation)
		return promise
	end)

	dispatcher:register(UiActions.PLAY_CARD_ANIMATION, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		local targets = {}
		local primaryTargets = {}
		local card = context.clientGame.cardHolder:getCardById(data.cardId)
		if not unit then warn("Unit not found") return end
		if not card then warn("Card not found") return end
		for _, targetId in ipairs(data.targetIds) do
			local target = context.clientGame.clientUnitHolder:getUnit(targetId)
			if not target then warn("Target not found", targetId) continue end
			table.insert(targets, target)
		end
		for _, targetId in ipairs(data.primaryTargetsIds) do
			local target = context.clientGame.clientUnitHolder:getUnit(targetId)
			if not target then warn("Target not found", targetId) continue end
			table.insert(primaryTargets, target)
		end
		local cardContext = {
			caster = unit,
			targets = targets,
			primaryTargets = primaryTargets,
			folder = context.clientGame.instanceFolder.Temp
		}
		return card:playAnimationAndWait(cardContext)
	end)

	dispatcher:register(UiActions.APPLY_HEAL, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		if not unit then warn("Unit not found") return end
		unit:heal(data.newHealth, data.healthGained)
	end)

	dispatcher:register(UiActions.APPLY_BLOCK, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		if not unit then warn("Unit not found") return end
		unit:setBlock(data.value)
	end)

	dispatcher:register(UiActions.UPDATE_STATUS, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.unitId)
		if not unit then warn("Unit not found") return end
		unit:updateStatus(data.statusData)
	end)

	dispatcher:register(UiActions.UPDATE_NODE, function(data, context)
		local targetNode = context.clientGame.clientBoard:getNodeByCoords(data.coordinates)
		if not targetNode then warn("Node not found") return end
		targetNode:update(data, context)
	end)

	dispatcher:register(UiActions.CREATE_UNIT, function(data, context)
		context.clientGame:createUnit(data)
	end)

	dispatcher:register(UiActions.DEPLOY_UNIT, function(data, context)
		context.clientGame:deployUnit(data.cardId)
	end)

	dispatcher:register(UiActions.SET_PLAYER_UNIT, function(data, context)
		local unit = context.clientGame.clientUnitHolder:getUnit(data.serializedUnitData.id)
		if not unit then warn("Unit not found") return end
		context.clientGame:setPlayerUnit(unit)
	end)

	dispatcher:register(UiActions.END_GAME, function(data, context)
		context.clientGame:endGame(data)
	end)
end

return UiEventDispatcher
