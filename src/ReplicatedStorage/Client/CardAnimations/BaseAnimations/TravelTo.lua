local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Parts = ReplicatedStorage.Client.CardAnimations.Parts

local animation = {}

function animation.play(context, animationFolder, partName)
	return Promise.new(function(resolve, reject)

		
		if #context.effectTargets < 1 then 
			resolve(false, nil) 
			return
		end
		for _, effectTarget in ipairs(context.effectTargets) do
			local part = Parts[animationFolder][partName]:Clone()
			local startPos = effectTarget:getPrimaryPartPosition()
			local endPos = context.source:getPrimaryPartPosition()

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
				resolve(true, context)
			end)

			tween:Play()
		end
	end)
end

return animation