local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local CardUtils = require(ReplicatedStorage.Helpers.CardUtils)
local AreaResolver = require(ReplicatedStorage.Helpers.GameInstance.AreaResolver)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local TargetTypes = require(Enums.TargetTypes)
local CardAttributeTags = require(Enums.CardAttributeTags)

local TargetRulesModules = ReplicatedStorage.Helpers.GameInstance.TargetingRulesModules
local TargetTypeRules = TargetRulesModules.TargetTypeRules
local RangeIndicatorRules = TargetRulesModules.RangeIndicatorRules

local TargetingRules = {}

local TargetTypeHandlers = {
	[TargetTypes.FIRST] = require(TargetTypeRules.FirstTarget),
	[TargetTypes.SELECT_UNIT] = require(TargetTypeRules.SelectUnit),
	[TargetTypes.SELECT_NODE] = require(TargetTypeRules.SelectNode),
	[TargetTypes.SELF] = require(TargetTypeRules.Self),
	[TargetTypes.CLOSEST] = require(TargetTypeRules.Closest)
}

local RangeIndicatorHandlers = {
	[TargetTypes.FIRST] = require(RangeIndicatorRules.FirstTarget),
	_default = require(RangeIndicatorRules.Default)
}

local CustomTargetResolvers = {
	["NONE"] = nil
}

local PlayabilityOverrides = {
	--TODO, this is just an example that hasn't happened yet
	["HexStorm"] = function(card, caster, context) 
		return context:hasStatus(caster, "Hex"), "Caster must have Hex status"
	end
}

function TargetingRules.getValidTargets(context: ContextType.context)
	local cardData = context:getCardData()
	if CardUtils.hasTag(cardData, CardAttributeTags.CUSTOM_TARGETING) then
		local override = CustomTargetResolvers[cardData.key] --TODO
		if override then return override(context) end
	end
	return TargetingRules.useTargetHandler(cardData.targetType, context)
end

function TargetingRules.useTargetHandler(targetType, context: ContextType.context)
	local handler = TargetTypeHandlers[targetType]
	return handler.getTargets(context)
end

function TargetingRules.getEffectTargets(primaryTargets: table, context: ContextType.context)
	local cardData = context:getCardData()
	local radius = cardData.radius or 0
	local effectTargets = {}
	
	if CardUtils.hasTag(cardData, CardAttributeTags.AFFECTS_TILE) then 
		effectTargets = TargetingRules.getEffectAreaNodes(primaryTargets, context)
	end
	
	for _, target in ipairs(primaryTargets) do
		if radius == 0 then
			table.insert(effectTargets, target)
			continue
		else
			if cardData.targetType == TargetTypes.SELECT_NODE then
				local nodes = AreaResolver.getNodesInRadius(target.coordinates, cardData.radius, context)
				for _, node in ipairs(nodes) do
					table.insert(effectTargets, node)
				end
			else
				local units = AreaResolver.getUnitsInRadius(target.coordinates, cardData.radius, context)
				for _, unit in ipairs(units) do
					table.insert(effectTargets, unit)
				end
			end
			continue
		end
	end
	return effectTargets
end

function TargetingRules.getEffectAreaNodes(primaryTargets, context: ContextType.context)
	local cardData = context:getCardData()
	local radius = cardData.radius or 0
	local effectAreaNodes = {}
	for _, target in ipairs(primaryTargets) do
		if radius == 0 then
			local coordinates = target.coordinates
			local node = context:getNodeAt(coordinates)
			table.insert(effectAreaNodes, node)
			continue
		else
			local nodes = AreaResolver.getNodesInRadius(target.coordinates, cardData.radius, context) --TODO ensure no duplicates if we wanna optimise more
			for _, node in ipairs(nodes) do
				table.insert(effectAreaNodes, node)
			end
			continue
		end
	end
	return effectAreaNodes
end

function TargetingRules.getInRangeNodes(primaryTargets, context: ContextType.context)
	local cardData = context:getCardData()
	local handler = RangeIndicatorHandlers[cardData.targetType] or RangeIndicatorHandlers._default
	local nodes = handler.getNodes(primaryTargets, context)
	return nodes
end

function TargetingRules.canBePlayed(context)
	local cardData = context:getCardData()
	local caster = context:getCaster()
	if CardUtils.hasTag(cardData, CardAttributeTags.REQUIRES_TARGET) then
		local targets = TargetingRules.getValidTargets(context)
		if not targets or #targets == 0 then
			return false, "No valid targets"
		end
	end

	if CardUtils.hasTag(cardData, CardAttributeTags.CUSTOM_CAN_BE_PLAYED) then
		local override = PlayabilityOverrides[cardData.key] --TODO
		if override then
			return override(context)
		end
	end

	return true, nil
end

return TargetingRules
