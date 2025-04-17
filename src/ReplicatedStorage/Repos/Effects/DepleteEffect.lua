local Effect = require(script.Parent.Effect)

local DepleteEffect = setmetatable({}, { __index = Effect })
DepleteEffect.__index = DepleteEffect

--[[
args needs to be structured as :
{
	value = value
}
]]

function DepleteEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, DepleteEffect)
	return self
end

function DepleteEffect:execute(targetNode, caster, cardData, targets, gameInstance)
	--doesnt' actually do anything, basically just a flag
end

return DepleteEffect
