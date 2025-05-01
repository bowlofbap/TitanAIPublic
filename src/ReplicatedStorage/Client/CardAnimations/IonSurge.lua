local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local BuildRoad = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.BuildRoad)
local EmitParticles = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticles)

local animation = {}

function animation.play(context)
	return BuildRoad.play(context, script.Name, "Part"):andThen(function(success, responseContext)
		if not success then
			return Promise.new(function(resolve)
				resolve()
			end)
		end
		local promises = {}
		for _, target in ipairs(context.effectTargets) do
			local newContext = table.clone(responseContext)
			newContext.source = target
			table.insert(promises, 
				EmitParticles.play(newContext, "Zap", "Completion"))
		end
		return Promise.all(promises)
	end)
end

return animation
