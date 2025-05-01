local modelRepo = game:GetService("ReplicatedStorage").Models.Entity.MapModels
local Angles = require(game:GetService("ReplicatedStorage").Enums.Angles)
local CameraModes = require(game:GetService("ReplicatedStorage").Enums.Client.CameraModes)

local types = {
	REGULAR_ENEMY = {
		key = "",
		color = BrickColor.Gray(), -- curently color is unused
		model = modelRepo.NormalEnemy,
		description = "A normal fight",
		label = "Enemy Encounter",
		cameraAngle = Angles.BIG_TOP_DOWN,
		cameraMode = CameraModes.BATTLE_VIEW
	},
	BOSS_ENEMY = {
		key = "",
		color = BrickColor.Gray(),
		model = modelRepo.BossEnemy,
		description = "",
		label = "Boss Encounter",
		cameraAngle = Angles.BIG_TOP_DOWN,
		cameraMode = CameraModes.BATTLE_VIEW
	},
	SHOP = {
		key = "",
		color = BrickColor.Gray(),
		model = modelRepo.Shop,
		description = "A merchant who sells powerful wares",
		chance = .05,
		label = "Shop",
		cameraAngle = Angles.FRONT_VIEW,
		cameraMode = CameraModes.SHOP_VIEW
	},
	EVENT = {
		key = "",
		color = BrickColor.Gray(),
		model = modelRepo.Event,
		description = "A mysterious event... what could it be?",
		chance = .22,
		label = "Event",
		cameraAngle = Angles.FRONT_VIEW,
		cameraMode = CameraModes.SHOP_VIEW
	},
	REST = {
		key = "",
		color = BrickColor.Gray(),
		model = modelRepo.Rest,
		description = "A place to rest or upgrade your cards",
		chance = .12,
		label = "Rest",
		cameraAngle = Angles.FRONT_VIEW,
		cameraMode = CameraModes.SHOP_VIEW
	},
	ELITE_ENEMY = {
		key = "",
		color = BrickColor.Gray(),
		model = modelRepo.EliteEnemy,
		description = "An extra powerful enemy with great rewards",
		chance = .08,
		label = "Elite Encounter",
		cameraAngle = Angles.BIG_TOP_DOWN,
		cameraMode = CameraModes.BATTLE_VIEW
	},
	CHEST = {
		key = "",
		color = BrickColor.Gray(),
		model = modelRepo.Chest,
		description = "A reward for your troubles",
		chance = .02,
		label = "Chest",
		cameraAngle = Angles.FRONT_VIEW,
		cameraMode = CameraModes.SHOP_VIEW
	},
}


function types.getRandomType()
	local candidates = {}
	local totalChance = 0

	-- Define processing order for chance-based types (excluding REGULAR_ENEMY)
	local chanceTypes = {}
	for key, entry in pairs(types) do
		if type(entry) == "table" and entry.chance then
			table.insert(chanceTypes, key)
		end
	end
	-- Calculate total chance and prepare candidates
	for _, key in ipairs(chanceTypes) do
		local entry = types[key]
		if entry.chance then
			totalChance = totalChance + entry.chance
			table.insert(candidates, {
				entry = entry,
				cumulative = totalChance
			})
		end
	end

	local rand = math.random()

	-- Check if we should use a chance-based type
	if rand <= totalChance then
		for _, candidate in ipairs(candidates) do
			if rand <= candidate.cumulative then
				return candidate.entry
			end
		end
	end

	-- Fallback to REGULAR_ENEMY if no chance-based type was selected
	return types.REGULAR_ENEMY
end

for key, nodeType in pairs(types) do
	if type(nodeType) == "function" then continue end
	nodeType.key = key
end

return types
