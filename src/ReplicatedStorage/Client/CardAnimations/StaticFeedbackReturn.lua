local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local EmitParticlesAt = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticlesAt)
local Travel = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.Travel)
local EmitParticles = require(ReplicatedStorage.Client.CardAnimations.BaseAnimations.EmitParticles)

local animation = {}

function animation.play(context)
	local promises = {}
	for _, target in ipairs(context.effectTargets) do
		local localContext = table.clone(context)
		localContext.source = target
		localContext.primaryTargets = { context.source }
		table.insert(promises, Travel.play(localContext, script.Name, "Travel"))
	end
	return Promise.all(promises):andThen(function(results)
		for _, success in ipairs(results) do
			if not success then
				return Promise.new(function(resolve)
					resolve(false)
				end)
			end
		end
		local localContext = table.clone(context)
		localContext.source = context.source
		localContext.effectTargets = { context.source }
		return EmitParticles.play(localContext, script.Name, "Completion")
	end)
end

return animation
