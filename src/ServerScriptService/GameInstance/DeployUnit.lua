local TweenService = game:GetService("TweenService")
local Unit = require(game:GetService("ServerScriptService").GameInstance.Unit)
local UnitGui = game:GetService("ReplicatedStorage").Models.UI.UnitGui
local DeployRepo = require(game:GetService("ReplicatedStorage").Repos.DeployRepo)
local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)
local Card = require(game:GetService("ServerScriptService").GameInstance.Card)
local DeployUnit = setmetatable({}, {__index = Unit})
DeployUnit.__index = DeployUnit

function DeployUnit.new(unitId, deployData, card)
	local base = Unit.new(unitId, deployData.unitData)
	local self = setmetatable(base, DeployUnit)
	self.data = deployData
	self.health = deployData.health
	self.maxHealth = deployData.health
	self._subscriptions = {}
	self._card = card
	return self
end

function DeployUnit:deploy(eventObserver, gameInstance)
	local subscription = self.data.unitData.onDeploy(self, eventObserver, gameInstance)
	if subscription then
		table.insert(self._subscriptions, subscription)
	end
end

function DeployUnit:kill(gameInstance)
	for _, unsubscribe in ipairs(self._subscriptions) do
		unsubscribe()
	end
	self._subscriptions = {}
	self.data.unitData.onDestroy(self, gameInstance)
	if self.Team == gameInstance.player.robloxPlayer.Name then --TODO: probably change this to a more concrete thing
		gameInstance:discardCard(self._card)
	end
	return Unit.kill(self)
end

function DeployUnit:getLoadedCard()
	return self._card
end

return DeployUnit
