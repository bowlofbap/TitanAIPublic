local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmitParticlesAt = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticlesAt)

local animation = {}

function animation.play(context)
	return EmitParticlesAt.play(context, script.Name, "Part", Vector3.new(0, 3, 0), false)
end

return animation
