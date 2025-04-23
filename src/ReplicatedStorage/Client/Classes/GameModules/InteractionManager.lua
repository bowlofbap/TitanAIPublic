local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classes = ReplicatedStorage.Client.Classes
local Enums = ReplicatedStorage.Enums
local Helpers = ReplicatedStorage.Helpers

local InteractionStateMachine = require(Classes.GameModules.InteractionStateMachine)
local CardHoverVisualizer = require(Classes.GameModules.CardHoverVisualizer)
local ArrowVisualizer = require(Classes.Guis.Components.ArrowVisualizer)

local InteractionStates = require(Enums.GameInstance.InteractionStates)
local UserInputTypes = require(Enums.GameInstance.UserInputTypes)
local GameActions = require(Enums.GameActions)
local Directions = require(Enums.Directions)

local GuiUtils = require(Helpers.GuiUtils)
local ClientCardExecutionContext = require(Helpers.GameInstance.Classes.ClientCardExecutionContext)

local InteractionManager = {}
InteractionManager.__index = InteractionManager

function InteractionManager.new(context)
	local self = setmetatable({}, InteractionManager)
	self._clientGame = context.clientGame
	self._dropZone = context.cardsFrame
	self._stateMachine = InteractionStateMachine.new()
	self:_registerStateHandlers()
	self:changeState(InteractionStates.IDLE)
	return self
end

function InteractionManager:handleInput(eventName, input)
	self._stateMachine:handle(eventName, input)
end

function InteractionManager:changeState(newState, stateData)
	self._stateMachine:changeState(newState, stateData)
end

function InteractionManager:_registerStateHandlers()
	self._stateMachine:registerStateHandler(InteractionStates.IDLE, {
		[UserInputTypes.MouseDown] = function(input, stateData)
			local hoveringCard = self:_getCardUnderMouse(input)
			if hoveringCard and hoveringCard:isPlayable() then --TODO: further define what "playable" means
				local newStateData = {
					draggedCard = hoveringCard,
					draggedStartingPosition = hoveringCard.Position,
					draggedMouseStartingPosition = input.Position
				}
				self:changeState(InteractionStates.CARD_DRAGGING, newStateData)
			end
		end,
		[UserInputTypes.MouseMoved] = function(input, stateData)
			local hoveringCard = self:_getCardUnderMouse(input)
			if hoveringCard and hoveringCard ~= stateData.hoveringCard then
				self:_clearHoverState(stateData)
				hoveringCard:runHoverFunction()
				stateData.hoveringCard = hoveringCard
			elseif not hoveringCard and stateData.hoveringCard then
				self:_clearHoverState(stateData)
			end
		end,
		[UserInputTypes.KeyPressed] = function(input)
			self:_attemptMoveUnit(input)
		end,
		onEnter = function()
			
		end,
		onExit = function()
			
		end,
	})

	self._stateMachine:registerStateHandler(InteractionStates.CARD_DRAGGING, {
		[UserInputTypes.MouseMoved] = function(input, stateData)
			self:_updateStateCoordinates(input, stateData)
			self:_showDraggingVisual(input, stateData)
		end,
		[UserInputTypes.MouseUp] = function(input, stateData)
			self:_updateStateCoordinates(input, stateData)
			self:_tryPlayCard(input, stateData)
			self:changeState(InteractionStates.IDLE)
		end,
		onEnter = function()
			
		end,
		onExit = function(stateData)
			self:_clearDraggedCardState(stateData)
		end,
	})

	self._stateMachine:registerStateHandler(InteractionStates.SELECTING_CARDS, {
		[UserInputTypes.MouseDown] = function(input, stateData)
			local hoveringCard = self:_getCardUnderMouse(input)
		end,
		[UserInputTypes.MouseMoved] = function(input, stateData)
			local hoveringCard = self:_getCardUnderMouse(input)
			if hoveringCard and hoveringCard ~= stateData.hoveringCard then
				self:_clearHoverState(stateData)
				hoveringCard:runHoverFunction()
				stateData.hoveringCard = hoveringCard
			elseif not hoveringCard and stateData.hoveringCard then
				self:_clearHoverState(stateData)
			end
		end,
		[UserInputTypes.KeyPressed] = function(input)
			self:_attemptMoveUnit(input)
		end,
		onEnter = function()
			
		end,
		onExit = function()
			
		end,
	})
end

function InteractionManager:_clearHoverState(stateData)
	if stateData.hoveringCard then
		stateData.hoveringCard:runHoverLeaveFunction()
	end
	stateData.hoveringCard = nil
end

function InteractionManager:_clearDraggedCardState(stateData)
	if stateData.draggedCard then
		stateData.draggedCard:runHoverLeaveFunction()
	end
	ArrowVisualizer.hideArrow()
	CardHoverVisualizer.reset()
end

function InteractionManager:_getCardUnderMouse(input)
	local mousePos = input.Position
	local playerCards = self._clientGame.playerHand:getAll()
	local topCard = nil
	for _, card in ipairs(playerCards) do
		if GuiUtils.isOverElement(mousePos, card.model) then
			if topCard == nil or card.ZIndex > topCard.ZIndex then
				topCard = card
			end
		end
	end
	return topCard
end

function InteractionManager:_showDraggingVisual(input, stateData)
	local mousePos = input.Position
	if not stateData.draggedCard then return end
	
	if stateData.draggedCard:isDraggable() then
		self:_dragCardWithMouse(input, stateData)
	else
		ArrowVisualizer.drawArrow(stateData.draggedCard.model, Vector2.new(input.Position.X, input.Position.Y))
	end
	
	if not GuiUtils.isOverElement(mousePos, self._dropZone) then --TODO also expand this to include not just dragging
		local context = ClientCardExecutionContext.new(self._clientGame, stateData.draggedCard.data, self._clientGame:getPlayerUnit(), stateData.hoveringCoordinates)
		CardHoverVisualizer.visualizeCardEffect(context)
	else
		CardHoverVisualizer.reset()
	end
end 

function InteractionManager:_dragCardWithMouse(input, stateData)
	local mousePos = input.Position
	local mouseDiff = mousePos - stateData.draggedMouseStartingPosition
	stateData.draggedCard.Position = UDim2.new(
		stateData.draggedStartingPosition.X.Scale, 
		stateData.draggedStartingPosition.X.Offset + mouseDiff.X, 
		stateData.draggedStartingPosition.Y.Scale, 
		stateData.draggedStartingPosition.Y.Offset + mouseDiff.Y
	)
end

function InteractionManager:_updateStateCoordinates(input, stateData)
	local nodeAtPosition = self._clientGame.clientBoard:getNodeAtMousePosition()
	if nodeAtPosition then
		stateData.hoveringCoordinates = nodeAtPosition.coordinates
	end
end

function InteractionManager:_tryPlayCard(input, stateData)
	local mousePos = input.Position
	if not GuiUtils.isOverElement(mousePos, self._dropZone) then
		self._clientGame:requestGameAction(GameActions.PLAY_CARD, {cardId = stateData.draggedCard.Id, targetCoordinates = stateData.hoveringCoordinates})
	end
end


function InteractionManager:_attemptMoveUnit(input)
	local movementKeys = {
		[Enum.KeyCode.W] = true,
		[Enum.KeyCode.A] = true,
		[Enum.KeyCode.S] = true,
		[Enum.KeyCode.D] = true,
		[Enum.KeyCode.Left] = true,
		[Enum.KeyCode.Right] = true,
		[Enum.KeyCode.Up] = true,
		[Enum.KeyCode.Down] = true
	}

	-- Check if pressed key is in our movement set
	if movementKeys[input.KeyCode] then
		-- Handle movement direction
		local direction = nil

		-- WASD and Arrow Keys
		if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
			direction = Directions.UP
		elseif input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then
			direction = Directions.DOWN
		elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
			direction = Directions.LEFT
		elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
			direction = Directions.RIGHT
		end

		-- Call movement function
		self._clientGame:requestGameAction(GameActions.MOVE, {direction = direction})
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

return InteractionManager
