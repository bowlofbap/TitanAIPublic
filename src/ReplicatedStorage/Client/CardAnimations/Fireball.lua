local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Helpers.Classes.Promise)

local animation = {}

function animation.play(context)
	return Promise.new(function(resolve, reject)
		local newTargets = context.targets -- or resolve via helper
		local cardData = {} -- only if needed
		local part = script.Part:Clone()

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
		endPos = newTargets[1].model.PrimaryPart.Position

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
		end)

		tween:Play()
	end)
end

return animation
