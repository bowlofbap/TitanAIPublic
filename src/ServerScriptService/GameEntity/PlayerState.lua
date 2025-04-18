local Constants = require(game:GetService("ReplicatedStorage").Helpers.Constants)

local PlayerState = {}
PlayerState.__index =  PlayerState

function PlayerState.new(robloxPlayer, data)
	local self = setmetatable({}, PlayerState)
	self.health = data.health
	self.maxHealth = data.health
	self.money = Constants.PLAYER_SETTINGS.STARTING_MONEY
	self.turnEnergy = data.turnEnergy
	self.turnMovement = data.turnMovement
	self.handSize = Constants.PLAYER_SETTINGS.STARTING_HAND_SIZE
	self.unitName = data.unitName
	self.level = 1
	self.visitedEvents = {}
	return self
end

function PlayerState:getVisitedEvents()
	return self.visitedEvents
end

function PlayerState:visitEvent(eventId)
	self.visitedEvents[eventId] = true
end

function PlayerState:levelUp()
	self.level += 1
end

function PlayerState:changeHealthByAmount(value)
	local newHealth = value + self.health
	if newHealth > self.maxHealth then
		newHealth = self.maxHealth
	end
	self.health = newHealth
	if self.health < 0 then
		self.health = 0
	end
	return self.health, self.maxHealth
end

function PlayerState:isDead()
	return self.health <= 0
end

function PlayerState:canAfford(cost)
	return self.money >= cost
end

function PlayerState:spendMoney(cost)
	self.money-=cost
end

function PlayerState:getMoney()
	return self.money
end

function PlayerState:updateMoney(moneyChange)
	self.money += moneyChange
	if self.money < 0 then
		self.money = 0
	end
end

function PlayerState:updateHealth(health, maxHealth)
	self.health = health
	self.maxHealth = maxHealth
end
return PlayerState
