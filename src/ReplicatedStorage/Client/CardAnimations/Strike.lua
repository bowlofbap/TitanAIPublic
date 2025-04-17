local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Helpers.Classes.Promise)
local Parts = ReplicatedStorage.Client.CardAnimations.Parts:WaitForChild(script.Name)

local animation = {}

function animation.play(context)
	return Promise.new(function(resolve, reject)
		local newTargets = context.targets -- or resolve via helper
		local primaryTargets = context.primaryTargets
		local cardData = {} -- only if needed
		local part = Parts.Part:Clone()
		local completion = Parts.Completion:Clone()

		local startPos = context.caster:getFirePosition()
		local endPos
		
		--[[
		if #newTargets == 0 then
			local endNode = TargetHelper.getEndOfRowNode(caster, gameInstance)
			local reverse = if caster.Team == "Game" then -2 else 2
			endPos = Vector3.new(
				endNode.Position.X + (endNode.Size.X * reverse),
				startPos.Y,
				endNode.Position.Z
			)
		else
			endPos = newTargets[1].model.PrimaryPart.Position
		end
		--]]
		endPos = primaryTargets[1].model.PrimaryPart.Position

		part.CFrame = CFrame.new(startPos)
		part.Parent = context.folder

		local tweenInfo = TweenInfo.new(
			1, -- time
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(part, tweenInfo, {
			CFrame = CFrame.new(endPos)
		})

		tween.Completed:Once(function()
			part:Destroy()
			resolve()
			task.spawn(function()
				completion.CFrame = CFrame.new(endPos)
				completion.Parent = context.folder
				local maxLifetime = 0 
				for i,particle in ipairs(completion:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						if particle.Lifetime.Max > maxLifetime then
							maxLifetime = particle.Lifetime.Max
						end
						task.delay(particle:GetAttribute("EmitDelay"),function()
							particle:Emit(particle:GetAttribute("EmitCount"))
						end)
					end
				end
				task.wait(maxLifetime)
				completion:Destroy()
			end)
		end)

		tween:Play()
	end)
end

return animation
