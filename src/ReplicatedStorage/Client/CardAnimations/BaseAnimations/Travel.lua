local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Parts = ReplicatedStorage.Client.CardAnimations.Parts

local animation = {}

function animation.play(context, animationFolder, partName)
	return Promise.new(function(resolve, reject)
		local primaryTargets = context.primaryTargets

		local startPos = context.source:getFirePosition()
		local endPos
		
		if #primaryTargets < 1 then 
			resolve(false, nil) 
			return
		end
		for _, primaryTarget in ipairs(primaryTargets) do
			local part = Parts[animationFolder][partName]:Clone()
			endPos = primaryTargets[1]:getPrimaryPartPosition()

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