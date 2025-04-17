local TargetHelper = require(game:GetService("ReplicatedStorage").Helpers.TargetHelper)

local CardAnimation = {}
CardAnimation.__index = CardAnimation

function CardAnimation.new(args)
	local self = setmetatable({}, CardAnimation)
	self.args = args or {}
	self.event = Instance.new("BindableEvent")
	return self
end

function CardAnimation:play(caster, targetType, targets, game)
	error("Apply method must be overridden in a derived class.")
end

function CardAnimation:getEvent()
	return self.event.Event
end

function CardAnimation:getTargets(caster, gameInstance, cardData, target)
	local targets = TargetHelper.getTargets(caster, gameInstance, cardData, target)
	return targets
end


return CardAnimation
