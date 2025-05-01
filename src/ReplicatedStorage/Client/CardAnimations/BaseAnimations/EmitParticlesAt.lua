local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Parts = ReplicatedStorage.Client.CardAnimations.Parts

local animation = {}

--we'll be using 
function animation.play(context, animationFolder, partName, lift, lookAt)
	return Promise.new(function(resolve, reject)
		lift = lift or Vector3.new(0,0,0)
		local part = Parts[animationFolder][partName]:Clone()
		local startNode = context.clientBoard:getNodeByCoords(context.targetCoordinates)
		local startPos = startNode.Position + (lift)

		task.spawn(function()
			if not lookAt then
				part.CFrame = CFrame.new(startPos)
			else
				--TODO
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
