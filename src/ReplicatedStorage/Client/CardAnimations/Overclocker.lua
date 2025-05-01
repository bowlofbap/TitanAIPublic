local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmitParticles = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticles)

local animation = {}

function animation.play(context)
	return EmitParticles.play(context, script.Name, "Part")
end

return animation
