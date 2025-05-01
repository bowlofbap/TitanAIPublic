local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Parts = ReplicatedStorage.Client.CardAnimations.Parts

local animation = {}

local function buildRoad(part, pointA, pointB, parent)
	local parts = {}
    local dir = (pointB - pointA).Unit
    local dist = (pointB - pointA).Magnitude
    local partLength = part.Size.Z
    local count = math.ceil(dist / partLength)
    local startOffset = partLength/2

    for i = 0, count - 1 do
        local clone = part:Clone()

        -- compute the center position of this tile
        local centerPos = pointA + dir * (startOffset + i * partLength)

        -- orient the part to face along dir
        clone.CFrame = CFrame.lookAt(centerPos, centerPos + dir)

        clone.Parent = parent or workspace
		table.insert(parts, clone)
    end
	return parts
end

function animation.play(context, animationFolder, partName)
	return Promise.new(function(resolve, reject)
		local part = Parts[animationFolder][partName]:Clone()
		local startPos = context.source:getBasePartPosition() + Vector3.new(0, 2, 0)
		local targetNode = context.clientBoard:getNodeByCoords(context.targetCoordinates)
		local endPos = Vector3.new(targetNode.Position.X, startPos.Y, targetNode.Position.Z)
		local road = buildRoad(part, startPos, endPos, context.folder)

		local maxLifetime = 0 
		for _, roadPart in ipairs(road) do
			for i,particle in ipairs(roadPart:GetDescendants()) do
				if particle:IsA("ParticleEmitter") then
					if particle.Lifetime.Max > maxLifetime then
						maxLifetime = particle.Lifetime.Max
					end
					task.delay(particle:GetAttribute("EmitDelay"),function()
						particle:Emit(particle:GetAttribute("EmitCount"))
					end)
				end
			end
			task.wait(0.05)
		end
		resolve(true, context)
		task.wait(maxLifetime)
		for _, roadPart in ipairs(road) do
			roadPart:Destroy()
		end
	end)
end

return animation
