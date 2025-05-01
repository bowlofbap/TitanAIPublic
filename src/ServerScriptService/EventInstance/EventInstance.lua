local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Enums = ReplicatedStorage.Enums

local StateSyncBuffer = require(ServerScriptService.General.StateSyncBuffer)
local StateUpdate = require(ServerScriptService.General.StateUpdate)
local EventContext = require(ServerScriptService.EventInstance.EventContext)

local UiActions = require(Enums.Event.UiActions)
local GameActions = require(Enums.Event.GameActions)
local GameEventsTypes = require(Enums.GameEvents)
local EventResultTypes = require(Enums.Event.EventResultTypes)

local NodeInstance = require(ServerScriptService.NodeInstance.NodeInstance)
local EventInstance = {}
EventInstance.__index = EventInstance
setmetatable(EventInstance, {__index = NodeInstance}) 

function EventInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, EventInstance)
	self.robloxPlayer = dependencies.robloxPlayer
	self.stateSyncBuffer = StateSyncBuffer.new(dependencies.robloxPlayer, self.folder.Events.ToClient.GameSyncEvent)
	self._context = EventContext.new(self.eventObserver, self.deckManager, self.playerState, self.mapNodeType)
	self:connectEvents()
	self.currentEvent = dependencies.stageData --is of type BaseEvent
	self.currentEvent:setCommand(function(gameEventType, ...)
		self:fireGameEvent(gameEventType, ...)
	end)
	return self
end

function EventInstance:connectEvents()
	local gameEvents = self.folder.Events
	gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data)
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.REQUEST_END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.REQUEST_EVENT_OPTION then
			if self.currentEvent:checkOptionData(data.index, self:getContext()) then
				--TODO: also check that the event is the same event
				--[[
				{
					eventResultType,
					description,
					finishText
				}
				]]
				local choiceResultData = self.currentEvent:executeEvent(data.index, self:getContext())
				if choiceResultData.eventResultType == EventResultTypes.NEW_EVENT or choiceResultData.eventResultType == EventResultTypes.END_RESULT then
					self.stateSyncBuffer:add(StateUpdate.new(UiActions.SELECT_OPTION, {choiceResultData = choiceResultData}))
					self.stateSyncBuffer:flush()
				end
			else
				warn("Option cannot be selected")
			end
		end
	end)
end

function EventInstance:getContext()
	return self._context
end

function EventInstance:loadEvent(baseEvent)
	self.currentEvent = baseEvent
	local choicesData = self.currentEvent:getChoicesData(self:getContext())
	self.stateSyncBuffer:add(StateUpdate.new(UiActions.SHOW_GUI, {eventData = self.currentEvent:serialize(), choicesData = choicesData}))
	self.stateSyncBuffer:flush()
end

function EventInstance:start()
	self:loadEvent(self.currentEvent)
end

function EventInstance:connectPlayerToInstance(nodeType)
	self:fireGameEvent(GameEventsTypes.CONNECT_TO_INSTANCE, {
		nodeType = nodeType, 
		folder = self.folder, 
		args = {
		}
	})
end

function EventInstance:getCameraSubject()
	return self.model
end

return EventInstance