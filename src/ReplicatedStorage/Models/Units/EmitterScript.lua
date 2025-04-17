
--[[
local character = script.Parent
local emissionTable = {}

for _, part in ipairs(character:GetChildren()) do
	if part:FindFirstChild("Emitter") then
		emissionTable[part] = part.Emitter.Value
	end
end

-- Jitter configuration
local maxJumps = 10                  -- Max position jumps per particle
local jumpPower = 3.2                -- Base jump distance
local jumpInterval = 0.07            -- Time between jumps
local jumpVariance = 0.4             -- Randomness multiplier
local downwardChance = 0.15          -- Chance for downward jump
local horizontalIntensity = 1.1      -- Sideways jump strength
local stepDelay = 0.1

-- Visual settings
local colors = {
	Color3.fromRGB(0, 255, 255),   -- Cyan
	Color3.fromRGB(255, 0, 255)    -- Magenta
}

local function getCharacterVectors()
	local cf = character.PrimaryPart.CFrame
	return {
		back = -cf.LookVector,
		right = cf.RightVector,
		up = cf.UpVector
	}
end

local function emitGlitchPart(basePosition)
	local glitchPart = Instance.new("Part")
	glitchPart.Size = Vector3.new(0.35, 0.35, 0.35)
	glitchPart.Shape = Enum.PartType.Block
	glitchPart.Anchored = true
	glitchPart.CanCollide = false
	glitchPart.Material = Enum.Material.Neon
	glitchPart.Transparency = 0.15
	glitchPart.Color = colors[math.random(#colors)]

	-- Initial position with offset
	glitchPart.Position = basePosition + Vector3.new(
		math.random(-jumpVariance, jumpVariance),
		math.random(-0.2, 0.2),
		math.random(-jumpVariance, jumpVariance)
	)
	glitchPart.Parent = game.Workspace

	task.spawn(function()
		local vectors = getCharacterVectors()
		local jumpsRemaining = math.random(6, maxJumps)
		local currentPosition = glitchPart.Position

		-- Movement biases
		local verticalBias = math.random() * 0.6 + 0.4  -- Upward tendency (0.4-1.0)
		local horizontalBias = vectors.right * math.random(-1, 1)
		local backwardBias = vectors.back * 0.8

		while jumpsRemaining > 0 do
			-- Random direction components
			local verticalDirection = math.random() < downwardChance and -1 or 1
			local verticalJump = vectors.up * verticalBias * jumpPower * verticalDirection
			local horizontalJump = (horizontalBias + vectors.right * math.random(-1, 1)) * horizontalIntensity
			local backwardJump = backwardBias * (0.5 + math.random() * 0.5)

			-- Combine jumps with randomness
			local newPosition = currentPosition + 
				(verticalJump + horizontalJump + backwardJump) * 0.7 +
				Vector3.new(
					math.random(-jumpVariance, jumpVariance),
					math.random(-jumpVariance*0.5, jumpVariance*0.5),
					math.random(-jumpVariance, jumpVariance)
				)

			-- Visual effects
			glitchPart.Transparency = 0.15 + (1 - (jumpsRemaining/maxJumps)) * 0.7
			glitchPart.Color = colors[(jumpsRemaining % 2) + 1]
			glitchPart.Orientation = Vector3.new(
				math.random(-35, 35),
				math.random(-180, 180),
				math.random(-35, 35)
			)

			-- Instant teleport
			glitchPart.Position = newPosition
			currentPosition = newPosition

			jumpsRemaining -= 1
			wait(jumpInterval * math.random(7, 13)/10)
		end

		glitchPart:Destroy()
	end)
end

local function startGlitchEffect()
	while true do
		for part in pairs(emissionTable) do
			-- Cluster emission
			for _ = 1, math.random(2, 4) do
				local emitPos = part.Position + 
					Vector3.new(
						math.random(-0.6, 0.6),
						math.random(-0.4, 0.4),
						math.random(-0.6, 0.6)
					)

				emitGlitchPart(emitPos)
				wait(math.random(1, 4)*0.015)
			end
		end

		wait(stepDelay * math.random(5, 15)/10)
	end
end

]]