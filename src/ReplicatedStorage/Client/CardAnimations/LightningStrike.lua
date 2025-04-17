local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Helpers.Classes.Promise)

local animation = {}

function createLightning(endPos, startPos, duration, folder)
	local segments = 18
	local startThickness = 1.2  -- Thickness at top
	local endThickness = 0.3    -- Thickness at bottom
	local verticalBias = 0.2

	-- Generate path points with downward bias
	local points = {}
	local verticalDirection = (endPos - startPos).Unit
	for i = 0, segments do
		local t = i/segments
		local basePos = startPos:Lerp(endPos, t)

		-- Dynamic noise that reduces near bottom
		local noise = Vector3.new(
			math.noise(t * 25, 0, 0) * 2 * (1 - t),
			0,
			math.noise(0, t * 25, 0) * 2 * (1 - t)
		)

		table.insert(points, basePos + noise + (verticalDirection * 3 * (1 - t)))
	end

	-- Create tapered lightning segments
	local lightningParts = {}
	for i = 1, #points - 1 do
		local startPoint = points[i]
		local endPoint = points[i+1]
		local segmentVector = endPoint - startPoint
		local distance = segmentVector.Magnitude

		-- Calculate tapered thickness
		local thicknessProgress = (i-1)/(#points-2) -- 0-1 from top to bottom
		local currentThickness = startThickness - (startThickness - endThickness) * thicknessProgress
		currentThickness *= math.random(80, 120)/100 -- Add 20% randomness

		local part = Instance.new("Part")
		part.Size = Vector3.new(currentThickness, currentThickness, distance)
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromHSV(
			0.6, 
			0.5 - (thicknessProgress * 0.3),  -- Less saturated at bottom
			0.9 - (thicknessProgress * 0.4)    -- Darker at bottom
		)
		part:SetAttribute("Thickness", thicknessProgress)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false

		-- Orient with natural lightning rotation
		part.CFrame = CFrame.lookAt(startPoint, endPoint)
			* CFrame.new(0, 0, -distance/2)
			* CFrame.Angles(0, math.rad(math.random(-5,5)), 0) -- Natural twist

		part.Parent = folder
		table.insert(lightningParts, part)
	end

	-- Animate with thickness-aware timing
	local startTime = os.clock()
	while os.clock() - startTime < duration do
		local progress = (os.clock() - startTime)/duration

		for i, part in ipairs(lightningParts) do
			if i/#lightningParts <= progress then
				part.Transparency = 0.1 + (part:GetAttribute("Thickness") * 0.6)
				local h, s, v = part.Color:ToHSV()
				local newV = v * (1 + math.sin(os.clock() * 30) / 15)
				part.Color = Color3.fromHSV(
					h, 
					s, 
					math.clamp(newV, 0.7, 1.2) -- Keep between 70-120% brightness
				)
			end
		end

		RunService.Heartbeat:Wait()
	end

	-- Fade and destroy
	for _, part in ipairs(lightningParts) do
		part:Destroy()
	end
end

function animation.play(context)
	return Promise.new(function(resolve, reject)
		local newTargets = context.targets
		local startingPosition : Vector3 
		local finalPosition : Vector3 
		if #newTargets > 0 then
			for _, target in ipairs(newTargets) do
				startingPosition = target.model.base.Position
				finalPosition = startingPosition + Vector3.new(0, 18, 0)
				createLightning(startingPosition, finalPosition, .7, context.folder)
				resolve()
			end
		else
			warn("No targets found")
			resolve()
		end
	end)
end

return animation
