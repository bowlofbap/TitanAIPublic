local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)
local Unit = require(game:GetService("ServerScriptService").GameInstance.Unit) 
local AiUnit = require(game:GetService("ServerScriptService").GameInstance.AiUnit) 
local PlayerUnit = require(game:GetService("ServerScriptService").GameInstance.PlayerUnit) 
local DeployUnit = require(game:GetService("ServerScriptService").GameInstance.DeployUnit) 
local UnitRepo = require(game:GetService("ReplicatedStorage").Repos.UnitRepo)
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local AnimationTypes = require(game:GetService("ReplicatedStorage").Enums.AnimationTypes)
local UnitTypes = require(game:GetService("ReplicatedStorage").Enums.UnitTypes)

local UnitHolder = {}
UnitHolder.__index =  UnitHolder

function UnitHolder.new(idGenerator, eventObserver)
	local self = setmetatable({}, UnitHolder)
	self.eventObserver = eventObserver
	self.idGenerator = idGenerator
	self.unitsById = {}
	self.units = {}
	return self
end

function UnitHolder:_configureUnit(unit, team)
	unit.Id = self.idGenerator:gen()
	unit.Team = team
	self.unitsById[unit.Id] = unit
	table.insert(self.units, unit)
	self.eventObserver:emit(GameEvents.LOADED_UNIT, {unit = unit})
end

function UnitHolder:addPlayerUnit(unitId, team, playerState)
	local newUnit = PlayerUnit.new(unitId, playerState)
	newUnit.UnitType = UnitTypes.DEFAULT
	self:_configureUnit(newUnit, team)
	return newUnit
end

function UnitHolder:addAiUnit(unitId)
	local newUnit = AiUnit.new(unitId, self.idGenerator)
	newUnit.UnitType = UnitTypes.DEFAULT
	self:_configureUnit(newUnit, "Game")
	return newUnit
end

function UnitHolder:deployUnit(caster, node, deployData, card, eventObserver, gameInstance)
	local newUnit = DeployUnit.new(self.idGenerator:gen(), deployData, card)
	newUnit.UnitType = UnitTypes.DEPLOY
	self:_configureUnit(newUnit, caster.Team)
	newUnit:moveToNode(node)
	gameInstance.board:occupyNodeAt(node.coordinates, newUnit)
	newUnit:deploy(eventObserver, gameInstance)
	return newUnit
end

function UnitHolder:removeUnit(unit) 
	local unitId = unit.Id
	for i, unit in self.units do
		if unit.Id == unitId then
			table.remove(self.units, i)
			self.unitsById[unitId] = nil
			print("Removing unit from UnitHolder ", unit)
			return true
		end
	end
	return false
end

function UnitHolder:getUnit(id)
	return self.unitsById[id]
end

function UnitHolder:getAll()
	return self.units
end

function UnitHolder:getEnemies(team)
	local enemies = {}
	for _, unit in ipairs(self.units) do
		if unit.Team ~= team then
			table.insert(enemies, unit)
		end
	end
	return enemies
end

function UnitHolder:getAllies(team, exclude)
	local allies = {}
	for _, unit in ipairs(self.units) do
		if unit.Team == team and unit ~= exclude then
			table.insert(allies, unit)
		end
	end
	return allies
end

function UnitHolder:serialize()
	local units = {}
	for _, unit in ipairs(self.units) do
		table.insert(units, unit:serialize())
	end
	return units
end

return UnitHolder
