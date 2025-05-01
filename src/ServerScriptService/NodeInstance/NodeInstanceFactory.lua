local MapNodeTypes = require(game:GetService("ReplicatedStorage").Enums.Entity.MapNodeTypes)
local GameInstance = require(game:GetService("ServerScriptService").GameInstance.GameInstance)
local ShopInstance = require(game:GetService("ServerScriptService").ShopInstance.ShopInstance)
local ChestInstance = require(game:GetService("ServerScriptService").ChestInstance.ChestInstance)
local RestInstance = require(game:GetService("ServerScriptService").RestInstance.RestInstance)
local EventInstance = require(game:GetService("ServerScriptService").EventInstance.EventInstance)

local EventSelector = require(game:GetService("ReplicatedStorage").Repos.EventsFolder.EventSelector)
local BaseEvent = require(game:GetService("ServerScriptService").EventInstance.BaseEvent)

local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)
local Probability = require(game:GetService("ReplicatedStorage").Helpers.Probability)

local Factory = {}
Factory.__index = Factory

function Factory.new()
	local self = setmetatable({}, Factory)
	return self
end

function Factory:createInstance(mapNodeType, dependencies)
	if mapNodeType == MapNodeTypes.REGULAR_ENEMY or mapNodeType == MapNodeTypes.ELITE_ENEMY or mapNodeType == MapNodeTypes.BOSS_ENEMY then
		return GameInstance.new(dependencies)
	elseif mapNodeType == MapNodeTypes.SHOP then
		return ShopInstance.new(dependencies)
	elseif mapNodeType == MapNodeTypes.CHEST then
		return ChestInstance.new(dependencies)
	elseif mapNodeType == MapNodeTypes.REST then
		return RestInstance.new(dependencies)
	elseif mapNodeType == MapNodeTypes.EVENT then
		local stageData = dependencies.stageData
		if stageData.mapNodeType == MapNodeTypes.SHOP then
			dependencies.mapNodeType = MapNodeTypes.SHOP
			return ShopInstance.new(dependencies)
		elseif stageData.mapNodeType == MapNodeTypes.REGULAR_ENEMY then
			dependencies.mapNodeType = MapNodeTypes.REGULAR_ENEMY
			dependencies.stageData = stageData.data
			return GameInstance.new(dependencies)
		end
		dependencies.playerState:visitEvent(stageData.data.eventId)
		local event = BaseEvent.new(stageData.data.eventId)
		dependencies.stageData = event
		return EventInstance.new(dependencies)
	else
		warn("no implementation for the mapnodetype", mapNodeType)
		return nil
	end
end

return Factory
