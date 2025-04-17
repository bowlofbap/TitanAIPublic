local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = ReplicatedStorage.Enums

local CardTypes = require(Enums.CardTypes)
local EffectTypes = require(Enums.EffectTypes)
local Directions = require(Enums.Directions)
local TargetTypes = require(Enums.TargetTypes)
local TargetChoices = require(Enums.TargetChoices)
local DamageTypes = require(Enums.DamageTypes)
local StatusTypes = require(Enums.StatusTypes)
local RarityTypes = require(Enums.RarityTypes)
local AnimationTypes = require(Enums.AnimationTypes)
local UpgradeTypes = require(Enums.UpgradeTypes)
local NodeTypes = require(Enums.GameInstance.NodeTypes)
local CardAttributeTags = require(Enums.CardAttributeTags)

local DeployUnits = require(ReplicatedStorage.Repos.DeployRepo).DeployUnits
local AudioRepo = require(ReplicatedStorage.Repos.AudioRepo)
local Keywords = require(ReplicatedStorage.Repos.Keywords)

local CustomEffects = game:GetService("ReplicatedStorage").Repos.Effects.CustomEffects

local CardDatabase = {
	["R001"] = {
		stringName = "Strike",
		animationClass = "Strike",
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.STARTER,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.FIRST,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			}	
		},
		image = "rbxassetid://101523792841244",
		description = "Deals {1.value} damage to the FIRST enemy in range",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 4,
		radius = 1,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE, 
				damageType = DamageTypes.DIRECT,
				value = 6,
			},
		},
		upgrades = {
			{
				stat = "1.value",
				value = 3
			}
		}
	},
	["R002"] = {
		stringName = "Barrier",
		rarity = RarityTypes.STARTER,
		cardType = CardTypes.UTILITY,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		unitAnimation = AnimationTypes.BUFFING,
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			}	
		},
		image = "rbxassetid://78242216902808",
		description = "Apply {1.value} Block to yourself",
		sound = AudioRepo.SFX.Shield,
		cost = 1,
		range = 0,
		radius = 0,
		effects = {
			{ 
				effectType = EffectTypes.BLOCK, 
				value = 7,
			}
		},
		upgrades = {
			{
				stat = "1.value",
				value = 4
			}
		}
	},
}

return CardDatabase
