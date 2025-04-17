local TweenService = game:GetService("TweenService")
local Unit = require(game:GetService("ServerScriptService").GameInstance.Unit)
local UnitGui = game:GetService("ReplicatedStorage").Models.UI.UnitGui
local UnitRepo = require(game:GetService("ReplicatedStorage").Repos.UnitRepo)
local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)
local Card = require(game:GetService("ServerScriptService").GameInstance.Card)
local PlayerUnit = setmetatable({}, {__index = Unit})
PlayerUnit.__index = PlayerUnit

function PlayerUnit.new(unitId, playerState)
	local unitData = UnitRepo.PlayerUnits[unitId]
	local base = Unit.new(unitId, unitData)
	local self = setmetatable(base, PlayerUnit)
	self.health = playerState.health
	self.maxHealth = playerState.maxHealth
	return self
end

return PlayerUnit
