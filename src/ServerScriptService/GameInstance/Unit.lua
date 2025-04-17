local TweenService = game:GetService("TweenService")
local UnitGui = game:GetService("ReplicatedStorage").Models.UI.UnitGui
local UnitRepo = require(game:GetService("ReplicatedStorage").Repos.UnitRepo)
local StatusManager = require(game:GetService("ServerScriptService").GameInstance.StatusManager)
local AnimationTypes = require(game:GetService("ReplicatedStorage").Enums.AnimationTypes)

local Unit = {}
Unit.__index = Unit

function Unit.new(unitId, unitData)
	local self = setmetatable({}, Unit)
	self.unitData = unitData
	self.block = 0
	self.isAlive = true
	self.health = 0
	self.coordinates = nil
	self.Id = unitId
	self.maxHealth = 0 --these get set outside in the superclasses
	self.statusManager = StatusManager.new()
	return self
end

function Unit:getLoadedCard()
	warn("Method needs to be overwritten")
end

function Unit:moveToNode(node)
	self.coordinates = node.coordinates
end

function Unit:canTakeDamage()
	return true
end

function Unit:kill()
	self.coordinates = nil
end

function Unit:setHealth(value)
	self.health = value
end

function Unit:setMaxHealth(value)
	self.maxHealth = value
end

function Unit:takeDamage(value)
	local difference = 0
	local originalHealth = self.health
	local blockLost = 0
	if self:canTakeDamage() then
		if self.block > 0 then
			if self.block >= value then
				blockLost = value
				self.block -= value
				value = 0
			elseif self.block < value then
				blockLost = self.block
				value = value - self.block
				self.block = 0
			end
		end
		local newHealth = self.health - value
		newHealth = math.clamp(newHealth, 0, self.maxHealth)
		self:setHealth(newHealth)
		difference = originalHealth - self.health
		if self.health <= 0 then
			self.isAlive = false 
		end
	end
	return difference, blockLost
end

function Unit:heal(value)
	local difference = 0
	local originalHealth = self.health
	local newHealth = self.health + value
	newHealth = math.clamp(newHealth, 0, self.maxHealth)
	self:setHealth(newHealth)
	difference = self.health - originalHealth
	return difference
end

function Unit:removeBlock()
	self.block = 0
end

function Unit:applyBlock(value)
	self.block += value
	if self.block < 0 then
		self.block = 0
	end
	return value
end

function Unit:tickStatus()
	self.statusManager:tick()
end

function Unit:applyStatus(effectData, eventObserver, gameInstance, deckManager, playerState)
	--[[
			{ 
				effectType = EffectTypes.TYPE, 
				statusType = StatusTypes.TYPE,
				value = VALUE,
			}
	]]
	self.statusManager:add(effectData, self, eventObserver, gameInstance, deckManager, playerState)
end

function Unit:removeStatus(statusType, value)
	self.statusManager:tryRemoveStatus(statusType, value)
end

function Unit:getStatus(statusType)
	return self.statusManager:getStatus(statusType)
end

function Unit:serialize()
	return {
		unitData = self.unitData,
		health = self.health,
		maxHealth = self.maxHealth,
		block = self.block,
		isAlive = self.isAlive,
		coordinates = self.coordinates,
		id = self.Id,
		team = self.Team,
		unitType = self.UnitType,
		--statusManagerData = self.statutManager:serialize() 
		--instead of sending statusmanager, we should just make sure we're in sync..? seems a little risky
	}
end

return Unit
