local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Travel = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.Travel)
local Promise = require(ReplicatedStorage.Packages.Promise)
local EmitParticles = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticles)

local animation = {}

function animation.play(context)
	return Travel.play(context, script.Name, "Part"):andThen(function(success, responseContext)
		if not success then
			return Promise.new(function(resolve)
				resolve()
			end)
		end
		local newContext = table.clone(responseContext)
		newContext.source = context.primaryTargets[1]
		return EmitParticles.play(newContext, script.Name, "Completion")
	end)
end

return animation
