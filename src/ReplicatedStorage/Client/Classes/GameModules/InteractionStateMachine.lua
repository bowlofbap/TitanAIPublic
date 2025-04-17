local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Enums

local InteractionStates = require(Enums.GameInstance.InteractionStates)
local UserInputTypes = require(Enums.GameInstance.UserInputTypes)

local InteractionStateMachine = {}
InteractionStateMachine.__index = InteractionStateMachine

function InteractionStateMachine.new()
	local self = setmetatable({}, InteractionStateMachine)
	self._state = nil
	self._stateHandlers = {}
	return self
end

function InteractionStateMachine:registerStateHandler(state, handlerDefinition)
	self._stateHandlers[state] = {
		handlers = handlerDefinition,
		stateData = handlerDefinition.stateData or {},
	}
end

function InteractionStateMachine:changeState(newState, stateData)
	local prevState = self._state
	local oldHandler = self._stateHandlers[prevState]
	local newHandler = self._stateHandlers[newState]
	
	if oldHandler and oldHandler.handlers.onExit then
		oldHandler.handlers.onExit(oldHandler.stateData)
	end

	self._state = newState
	
	if newHandler then
		if stateData then
			newHandler.stateData = stateData
		else
			warn("No state data for new state")
			newHandler.stateData = {}
		end
	end

	if newHandler and newHandler.handlers.onEnter then
		newHandler.handlers.onEnter(newHandler.stateData)
	end
end

function InteractionStateMachine:handle(eventName, input)
	local current = self._stateHandlers[self._state]
	if not current then
		warn("No handler found for state:", self._state)
		return
	end

	local handlers = current.handlers
	local data = current.stateData

	if eventName == "InputBegan" then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if handlers[UserInputTypes.KeyPressed] then
				handlers[UserInputTypes.KeyPressed](input, data)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if handlers[UserInputTypes.MouseDown] then
				handlers[UserInputTypes.MouseDown](input, data)
			end
		end
	elseif eventName == "InputChanged" then
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if handlers[UserInputTypes.MouseMoved] then
				handlers[UserInputTypes.MouseMoved](input, data)
			end
		end
	elseif eventName == "InputEnded" then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if handlers[UserInputTypes.MouseUp] then
				handlers[UserInputTypes.MouseUp](input, data)
			end
		end
	end
end

return InteractionStateMachine
