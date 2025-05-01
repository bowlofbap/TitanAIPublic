local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Parts = ReplicatedStorage.Client.CardAnimations.Parts

local animation = {}

--we'll be using 
function animation.play(context, animationFolder, partName)
	return Promise.new(function(resolve, reject)
		local part = Parts[animationFolder][partName]:Clone()
		local startPos = context.source:getPrimaryPartPosition()

		task.spawn(function()
			if #context.effectTargets < 1 or context.effectTargets[1] == context.source then
				part.CFrame = CFrame.new(startPos)
			else
				local endPos = context.effectTargets[1]:getBasePartPosition()
				local normalizedEndPos = Vector3.new(endPos.X, startPos.Y, endPos.Z)
				part.CFrame = CFrame.new(normalizedEndPos, startPos)
			end
			part.Parent = context.folder
			local maxLifetime = 0 
			for i,particle in ipairs(part:GetDescendants()) do
				if particle:IsA("ParticleEmitter") then
					if particle.Lifetime.Max > maxLifetime then
						maxLifetime = particle.Lifetime.Max
					end
					task.delay(particle:GetAttribute("EmitDelay"),function()
						particle:Emit(particle:GetAttribute("EmitCount"))
					end)
				end
			end
			resolve(true, context)
			task.wait(maxLifetime)
			part:Destroy()
		end)
	end)
end

return animation
