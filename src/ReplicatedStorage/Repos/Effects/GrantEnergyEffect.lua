local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = require(script.Parent.Effect)
local ContextType = require(ReplicatedStorage.Helpers.GameInstance.Classes.CardExecutionContextType)

local GrantEnergyEffect = setmetatable({}, { __index = Effect })
GrantEnergyEffect.__index = GrantEnergyEffect

--[[
args needs to be structured as :
{
	value = value
}
]]

function GrantEnergyEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, GrantEnergyEffect)
	return self
end

function GrantEnergyEffect:execute(primaryTargets, effectTargets, gameInstance, context: ContextType.context)
	for _, target in ipairs(effectTargets) do
		gameInstance:grantEnergy(target, self.effectData.value)
	end
end

return GrantEnergyEffect
