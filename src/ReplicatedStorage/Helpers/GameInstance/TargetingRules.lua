local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local CardUtils = require(ReplicatedStorage.Helpers.CardUtils)
local Tables = require(ReplicatedStorage.Helpers.Tables)
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

	local affectsTiles = CardUtils.hasTag(cardData, CardAttributeTags.AFFECTS_TILE)
	local affectsUnits = CardUtils.hasTag(cardData, CardAttributeTags.AFFECTS_UNIT)
	local isSelectNode = cardData.targetType == TargetTypes.SELECT_NODE

	if affectsTiles then
		effectTargets = TargetingRules.getEffectAreaNodes(primaryTargets, context)
		return effectTargets
	end

	for _, target in ipairs(primaryTargets) do
		if radius > 0 then
			if isSelectNode and not affectsUnits then
				local nodes = AreaResolver.getNodesInRadius(target.coordinates, radius, context)
				for _, node in ipairs(nodes) do
					table.insert(effectTargets, node)
				end
			else
				local units = AreaResolver.getUnitsInRadius(target.coordinates, radius, context)
				for _, unit in ipairs(units) do
					table.insert(effectTargets, unit)
				end
			end
		else
			if isSelectNode and affectsUnits then
				local unit = target:getOccupyingUnit()
				if unit then
					table.insert(effectTargets, unit)
				end
			else
				table.insert(effectTargets, target)
			end
		end
	end

	return Tables.removeDuplicates(effectTargets)
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
		else
			local nodes = AreaResolver.getNodesInRadius(target.coordinates, cardData.radius, context) --TODO ensure no duplicates if we wanna optimise more
			for _, node in ipairs(nodes) do
				table.insert(effectAreaNodes, node)
			end
		end
	end
	return Tables.removeDuplicates(effectAreaNodes)
end

function TargetingRules.getInRangeNodes(primaryTargets, context: ContextType.context)
	local cardData = context:getCardData()
	local handler = RangeIndicatorHandlers[cardData.targetType] or RangeIndicatorHandlers._default
	local nodes = handler.getNodes(primaryTargets, context)
	return nodes
end

function TargetingRules.canBePlayed(context)
	local cardData = context:getCardData()
	if CardUtils.hasTag(cardData, CardAttributeTags.REQUIRES_TARGET) then
		local targets = TargetingRules.getValidTargets(context)
		if not targets or #targets == 0 then
			return false, "No valid targets"
		end
	end

	if CardUtils.hasTag(cardData, CardAttributeTags.REQUIRES_TARGET_IN_NODES) then
		local primaryTargets = TargetingRules.getValidTargets(context)
		if not primaryTargets or #primaryTargets == 0 then
			return false, "No primary target"
		end
		local potentialUnits = AreaResolver.getUnitsInRadius(primaryTargets[1].coordinates, cardData.radius, context)
		if not potentialUnits or #potentialUnits == 0 then
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
