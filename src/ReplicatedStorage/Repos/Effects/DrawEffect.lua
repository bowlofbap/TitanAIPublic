local Effect = require(script.Parent.Effect)

local DrawEffect = setmetatable({}, { __index = Effect })
DrawEffect.__index = DrawEffect

--[[
args needs to be structured as :
{
	value = value
	direction = Directions.DIRECTION
}
]]

function DrawEffect.new(effectData)
	local self = Effect.new(effectData)
	setmetatable(self, DrawEffect)
	return self
end

function DrawEffect:execute(targetNode, caster, cardData, targets, gameInstance)
	gameInstance:drawCards(self.effectData.value) 
end

return DrawEffect
