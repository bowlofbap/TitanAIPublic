local AnimationTypes = require(game:GetService("ReplicatedStorage").Enums.AnimationTypes)

local ClientUnit = require(game:GetService("ReplicatedStorage").Client.Classes.GameModules.ClientUnit)

local ClientUnitHolder = {}
ClientUnitHolder.__index =  ClientUnitHolder

function ClientUnitHolder.new(parentFolder)
	local self = setmetatable({}, ClientUnitHolder)
	local newFolder = Instance.new("Folder")
	newFolder.Name = "Units"
	newFolder.Parent = parentFolder
	self._unitFolder = newFolder
	self._unitsById = {}
	return self
end

function ClientUnitHolder:addUnit(serializedUnitData, clientBoard)
	local newUnit = ClientUnit.new(serializedUnitData)
	newUnit.Parent = self._unitFolder
	local track = newUnit:getAnimation(AnimationTypes.IDLE)
	track:play()
	self._unitsById[newUnit.Id] = newUnit
	newUnit:moveToNode(clientBoard:getNodeByCoords(newUnit.coordinates))
	return newUnit
end

function ClientUnitHolder:removeUnit(unit) 
	local foundUnit = self._unitsById[unit.Id]
	if foundUnit then
		self._unitsById[unit.Id] = nil
		return true
	end
	warn("Unit not found, ", unit)
	return false
end

function ClientUnitHolder:getPlayerUnit() --TODO remove this, it isnt accurate
	for _, unit in pairs(self._unitsById) do
		if unit.team == game:GetService("Players").LocalPlayer.Name then
			return unit
		end
	end
	warn("No player unit was found")
	return nil
end

function ClientUnitHolder:getUnit(id)
	return self._unitsById[id]
end

function ClientUnitHolder:getEnemies(team)
	local enemies = {}
	for _, unit in pairs(self._unitsById) do
		if unit.team ~= team then
			table.insert(enemies, unit)
		end
	end
	return enemies
end

function ClientUnitHolder:getAllies(team, exclude)
	local allies = {}
	for _, unit in pairs(self._unitsById) do
		if unit.team == team and unit ~= exclude then
			table.insert(allies, unit)
		end
	end
	return allies
end

return ClientUnitHolder
