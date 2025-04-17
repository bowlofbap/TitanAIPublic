local ModelFolder = game:GetService("ReplicatedStorage").Models.Units
local GameEvents = require(game:GetService("ReplicatedStorage").Enums.GameEvents)
local StatusTypes = require(game:GetService("ReplicatedStorage").Enums.StatusTypes)
local AnimationTypes = require(game:GetService("ReplicatedStorage").Enums.AnimationTypes)

local UnitRepo = {
	DeployUnits = {
		Empower = {
			Name = "Empower",
			Model = ModelFolder.Empower,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://110809822837427",
				[AnimationTypes.BUFFING] = "rbxassetid://110809822837427",
				[AnimationTypes.IDLE] = "rbxassetid://70376749365831",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://110809822837427",
			},
			onDeploy = function(self, eventObserver, gameInstance)
				local teamUnits = gameInstance.unitHolder:getAllies(self.Team, self)
				gameInstance:applyStatus(self, teamUnits, {statusType = StatusTypes.STRENGTH_BUFF, value = self.data.value})
				return nil
			end,
			onDestroy = function(self, gameInstance)
				local teamUnits = gameInstance.unitHolder:getAllies(self.Team, self)
				gameInstance:removeStatus(teamUnits, StatusTypes.STRENGTH_BUFF, self.data.value)
			end,
		},
		Overclocker = {
			Name = "Overclocker",
			Model = ModelFolder.Empower,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://110809822837427",
				[AnimationTypes.BUFFING] = "rbxassetid://110809822837427",
				[AnimationTypes.IDLE] = "rbxassetid://70376749365831",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://110809822837427",
			},
			onDeploy = function(self, eventObserver, gameInstance)
				return eventObserver:subscribeTo(GameEvents.START_UNIT_TURN, function(data)
					if data.unit == gameInstance.player.unit then
						gameInstance:grantEnergy(data.unit, self.data.value)
					end
				end)
			end,
			onDestroy = function(self, gameInstance)
			end,
		},
	},
}

return UnitRepo
