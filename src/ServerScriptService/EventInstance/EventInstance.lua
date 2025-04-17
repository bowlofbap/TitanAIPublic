local EventModel = game:GetService("ReplicatedStorage").Models.NodeInstances.Event

local UiActions = require(game:GetService("ReplicatedStorage").Enums.Event.UiActions)
local GameActions = require(game:GetService("ReplicatedStorage").Enums.Event.GameActions)
local GameEventsTypes = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local EventResultTypes = require(game:GetService("ReplicatedStorage").Enums.Event.EventResultTypes)

local NodeInstance = require(game:GetService("ServerScriptService").NodeInstance.NodeInstance)
local EventInstance = {}
EventInstance.__index = EventInstance
setmetatable(EventInstance, {__index = NodeInstance}) 

function EventInstance.new(dependencies)
	local self = NodeInstance.new(dependencies)
	setmetatable(self, EventInstance)
	local chestSize = dependencies.stageData.chestSize
	self.model = EventModel:Clone()
	self.model:SetPrimaryPartCFrame(CFrame.new(dependencies.centerPosition))
	self.model.Parent = self.folder
	self.robloxPlayer = dependencies.robloxPlayer
	self:connectEvents()
	self.currentEvent = dependencies.stageData --is of type BaseEvent
	return self
end

function EventInstance:connectEvents()
	local gameFunctions = self.folder.Functions
	local gameEvents = self.folder.Events
	local c1 = gameEvents.ToServer.GameActionRequest.OnServerEvent:Connect(function(robloxPlayer, action, data)
		if robloxPlayer ~= self.robloxPlayer then warn("invalid player sent data") return false end
		if action == GameActions.REQUEST_END_GAME then
			self:fireGameEvent(GameEventsTypes.FINISH_INSTANCE, self)
		elseif action == GameActions.REQUEST_EVENT_OPTION then
			if self.currentEvent:checkOptionData(data.index, self:getDependencies()) then
				--TODO: also check that the event is the same event
				--[[
				{
					eventResultType,
					description,
					finishText
				}
				]]
				local choiceResultData = self.currentEvent:executeEvent(data.index, self:getDependencies())
				if choiceResultData.eventResultType == EventResultTypes.NEW_EVENT or choiceResultData.eventResultType == EventResultTypes.END_RESULT then
					self:updateClientUi(UiActions.SELECT_OPTION, {choiceResultData = choiceResultData})
				end
			else
				warn("Option cannot be selected")
			end
		end
	end)
end

function EventInstance:getDependencies()
	local dependencies = {
		eventObserver = self.eventObserver,
		deckManager = self.deckManager,
		playerState = self.playerState,
		mapNodeType = self.mapNodeType
	}
	return dependencies
end

function EventInstance:loadEvent(baseEvent)
	self.currentEvent = baseEvent
	local choicesData = self.currentEvent:getChoicesData(self:getDependencies())
	self:updateClientUi(UiActions.SHOW_GUI, {eventData = self.currentEvent:serialize(), choicesData = choicesData}) 
end

function EventInstance:start()
	self:loadEvent(self.currentEvent)
end

function EventInstance:connectPlayerToInstance(nodeType)
	ConnectToGame:FireClient(self.robloxPlayer, nodeType, self.folder)
end

function EventInstance:getCameraSubject()
	return self.model
end

return EventInstance