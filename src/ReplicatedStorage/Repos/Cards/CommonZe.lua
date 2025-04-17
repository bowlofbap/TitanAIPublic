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
local DeployUnits = require(ReplicatedStorage.Repos.DeployRepo).DeployUnits
local AudioRepo = require(ReplicatedStorage.Repos.AudioRepo)
local Keywords = require(ReplicatedStorage.Repos.Keywords)
local CardAttributeTags = require(Enums.CardAttributeTags)

local CustomEffects = ReplicatedStorage.Repos.Effects.CustomEffects

local CardDatabase = {
	["ZC001"] = {
		stringName = "Zap",
		animationClass = "LightningStrike",
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			},
		},
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.COMMON,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.CLOSEST,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		image = "rbxassetid://90356868289376",
		description = "Deals {1.value} damage to the CLOSEST enemy in range, applying Weaken",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 3,
		radius = 0,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE, 
				damageType = DamageTypes.DIRECT,
				value = 8,
			},
			{ 
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.WEAKEN_DEBUFF,
				value = 1,
			},
		},
		upgrades = {
			{
				stat = "range",
				value = 1
			},
			{
				stat = "2.value",
				value = 1
			},
		}
	},
	["ZC002"] = {
		stringName = "Static Shield",
		animationClass = nil,
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY,
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://92210163001116",
		description = "Apply {1.value} Block and {2.value} Reflect for one turn",
		sound = AudioRepo.SFX.Fire,
		cost = 2,
		range = 0,
		radius = 0,
		effects = {
			{ 
				effectType = EffectTypes.BLOCK, 
				value = 9,
			},
			{ 
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.REFLECT_BUFF,
				value = 3,
			},
		},
		upgrades = {
			{
				stat = "1.value",
				value = 2
			},
			{
				stat = "2.value",
				value = 2
			},
		}
	},
	["ZC003"] = {
		stringName = "Overload",
		animationClass = nil,
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY,
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://120533749305904",
		description = "Grants {1.value} Strength until the end of the turn",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		effects = {
			{ 
				effectType = EffectTypes.STATUS,
				statusType = StatusTypes.STRENGTH_BUFF,
				value = 5
			},
			{ 
				effectType = EffectTypes.STATUS,
				statusType = StatusTypes.STRENGHT_DOWN,
				value = 5
			},
		},
		upgrades = {
			{
				stat = "cost",
				value = -1
			},
		}
	},
	["ZC004"] = {
		stringName = "Overclocker",
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			},
			{
				tagType = CardAttributeTags.REQUIRES_EMPTY_NODE,
			}	
		},
		cardType = CardTypes.DEPLOY,
		rarity = RarityTypes.STARTER,
		unitAnimation = AnimationTypes.BUFFING,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.NONE, 
		effectChoice = TargetChoices.NONE, 
		image = "rbxassetid://88718253755872",
		description = "Provides {1.value} Energy at the start of the turn",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 1,
		radius = 0,
		effects = {
			{ 
				effectType = EffectTypes.DEPLOY,
				unitData = DeployUnits.Overclocker,
				value = 1,
				health = 10
			}
		},
		upgrades = {
			{
				stat = "1.health",
				value = 5
			},
		}
	},
	["ZC005"] = {
		stringName = "Disabler",
		cardType = CardTypes.DEPLOY,
		rarity = RarityTypes.COMMON,
		unitAnimation = AnimationTypes.BUFFING,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.NONE, 
		effectChoice = TargetChoices.NONE, 
		image = "rbxassetid://88718253755872",
		description = "Provides {1.value} Energy at the start of the turn",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 1,
		radius = 0,
		effects = {
			{ 
				effectType = EffectTypes.DEPLOY,
				unitData = DeployUnits.Overclocker,
				value = 1,
				health = 10
			}
		},
		upgrades = {
			{
				stat = "1.health",
				value = 5
			},
		}
	},
}

return CardDatabase
