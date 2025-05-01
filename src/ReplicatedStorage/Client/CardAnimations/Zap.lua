local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local EmitParticles = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticles)

local animation = {}

function animation.play(context)
	return EmitParticles.play(context, script.Name, "Part")
	:andThen(function(success, responseContext)
		local newContext = table.clone(responseContext)
		newContext.source = context.primaryTargets[1]
		EmitParticles.play(newContext, script.Name, "Completion")
	end)
end

return animation
