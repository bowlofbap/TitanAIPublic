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

local CustomEffects = game:GetService("ReplicatedStorage").Repos.Effects.CustomEffects

local CardDatabase = {
	["SearchAttack1"] = {
		stringName = "Attack",
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.COMMON,
		animationClass = "LightningStrike",
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.CLOSEST,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		image = "rbxassetid://96774450976094",
		description = "Deals {1.value} damage to the CLOSEST enemy in range",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE, 
				damageType = DamageTypes.DIRECT,
				value = 10,
			},
		},
	},
	["Barrier1"] = {
		stringName = "Block",
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://100422005795953",
		description = "Apply {1.value} Block in {radius} radius",
		sound = AudioRepo.SFX.Shield,
		cost = 1,
		range = 0,
		radius = 1,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.BLOCK, 
				value = 5,
			}
		},
	},
	["MoveLeft"] = {
		stringName = "Move Left",
		cardType = CardTypes.UTILITY,
		unitAnimation = nil,
		targetType = TargetTypes.SELF,--how you obtain the primary target
		targetChoice = TargetChoices.ALLY, --which type of unit it grabs for the primary target
		effectChoice = TargetChoices.ALLY, --which type of unit the effect targets
		rarity = RarityTypes.COMMON,
		image = "",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		description = "Moves {1.value} unit left",
		upgrades = {
		},
		effects = {
			{ 
				effectType = EffectTypes.MOVE, 
				value = 1,
				direction = Directions.LEFT
			}
		}
	},
	["MoveRight"] = {
		stringName = "Move Right",
		cardType = CardTypes.UTILITY,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		rarity = RarityTypes.COMMON,
		image = "",
		description = "Moves {1.value} unit right",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		upgrades = {
		},
		effects = {
			{ 
				effectType = EffectTypes.MOVE, 
				value = 1,
				direction = Directions.RIGHT
			}
		}
	},
	["MoveDown"] = {
		stringName = "Move Down",
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		unitAnimation = nil,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		image = "",
		description = "Moves {1.value} unit down",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		upgrades = {
		},
		effects = {
			{ 
				effectType = EffectTypes.MOVE, 
				value = 1,
				direction = Directions.DOWN
			}
		}
	},
	["MoveUp"] = {
		stringName = "Move Up",
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		unitAnimation = nil,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		image = "",
		description = "Moves {1.value} unit up",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		upgrades = {
		},
		effects = {
			{ 
				effectType = EffectTypes.MOVE, 
				value = 1,
				direction = Directions.UP
			}
		}
	},
	["MoveCloserY"] = {
		stringName = "Move Closer Y",
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		unitAnimation = nil,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		image = "",
		description = "Moves {1.value} unit to the nearest enemy up/down",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		upgrades = {
		},
		effects = {
			{ 
				effectType = EffectTypes.MOVE, 
				value = 1,
				direction = Directions.CLOSER_Y
			}
		}
	},
	["MoveAwayY"] = {
		stringName = "Move Away Y",
		rarity = RarityTypes.COMMON,
		cardType = CardTypes.UTILITY,
		unitAnimation = nil,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		image = "",
		description = "Moves {1.value} unit away from the nearest enemy up/down",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		upgrades = {
		},
		effects = {
			{ 
				effectType = EffectTypes.MOVE, 
				value = 1,
				direction = Directions.AWAY_Y
			}
		}
	},
	["Fireball"] = {
		stringName = "Fireball",
		animationClass = nil,
		rarity = RarityTypes.STARTER,
		cardType = CardTypes.DAMAGE,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.FIRST,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		extraKeywords = {
			Keywords.Decay
		},
		image = "rbxassetid://99288498404093",
		description = "Deals {1.value} damage to FIRST enemy in range",
		upgradeDescription = "Deals {1.value} to FIRST enemy and {2.value} Decay in range",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE, 
				damageType = DamageTypes.DIRECT,
				value = 10,
			},
			{ 
				upgrade = true,
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.DAMAGE_OVER_TIME,
				value = 5,
			}
		},
		upgrades = {
			{
				stat = "cost",
				value = -1
			},
			{
				stat = "1.value",
				value = 5
			}
		}
	},
	["LightningStrike"] = {
		stringName = "Bolt",
		animationClass = "LightningStrike",
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.COMMON,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.CLOSEST,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		image = "rbxassetid://96774450976094",
		description = "Deals {1.value} damage to the CLOSEST enemy in range",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 2,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE, 
				damageType = DamageTypes.DIRECT,
				value = 10,
			},
		},
		upgrades = {
			{
				stat = "range",
				value = 1
			},
		}
	},
	["Draw"] = {
		stringName = "Draw",
		cardType = CardTypes.UTILITY,
		rarity = RarityTypes.COMMON,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		unitAnimation = nil,
		image = "rbxassetid://139758550118723",
		description = "Draw {1.value} Cards",
		sound = AudioRepo.SFX.Fire,
		cost = 0,
		range = 0,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.DRAW, 
				value = 4,
			}
		},
		upgrades = {
		}
	},
	["Recovery"] = {
		stringName = "Recovery",
		cardType = CardTypes.UTILITY,
		rarity = RarityTypes.COMMON,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://99935974018589",
		description = "Heal {1.value} yourself",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.HEAL, 
				value = 15,
			}
		},
		upgrades = {
		}
	},
	["TileChange"] = {
		stringName = "Tile Change",
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			}	
		},
		cardType = CardTypes.UTILITY,
		rarity = RarityTypes.COMMON,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.NONE, 
		effectChoice = TargetChoices.NONE, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://99935974018589",
		description = "Change nodes in area to Block Tile",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 1,
		radius = 1,
		needsTarget = false,
		effects = {
			{ 
				effectType = EffectTypes.NODE_CHANGE, 
				value = NodeTypes.BLOCKING,
			}
		},
		upgrades = {
		}
	},
	["TileChange2"] = {
		stringName = "Tile Change",
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			}	
		},
		cardType = CardTypes.UTILITY,
		rarity = RarityTypes.COMMON,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.NONE, 
		effectChoice = TargetChoices.NONE, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://99935974018589",
		description = "Change a tile to Strength Tile",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 2,
		radius = 2,
		needsTarget = false,
		effects = {
			{ 
				effectType = EffectTypes.NODE_CHANGE, 
				value = NodeTypes.STRENGTH,
			}
		},
		upgrades = {
		}
	},
	["Barrier"] = {
		stringName = "Barrier",
		rarity = RarityTypes.STARTER,
		cardType = CardTypes.UTILITY,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://100422005795953",
		description = "Apply {1.value} block to yourself",
		sound = AudioRepo.SFX.Shield,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.BLOCK, 
				value = 7,
			}
		},
		upgrades = {
			{
				stat = "1.value",
				value = 5
			}
		}
	},
	["Strengthen"] = {
		stringName = "Strengthen",
		rarity = RarityTypes.RARE,
		cardType = CardTypes.UTILITY,
		targetType = TargetTypes.SELF,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://114629219668197",
		description = "Increase Strength and Defense by {1.value}",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 0,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.STRENGTH_BUFF,
				value = 3,
			},
			{ 
				upgrade = true,
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.DEFENSE_UP,
				value = 3,
			}
		},
		upgrades = {
		}
	},
	["Dominate"] = {
		stringName = "Dominate",
		cardType = CardTypes.UTILITY,
		rarity = RarityTypes.RARE,
		targetType = TargetTypes.SELECT_UNIT,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://76081141999565",
		description = "Gain Critical for {1.debuffData.value} turns and apply Vulnerable for {1.buffData.value}",
		sound = AudioRepo.SFX.Fire,
		cost = 2,
		range = 3,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.CUSTOM, 
				customEffect = CustomEffects.DebuffTargetAndBuffSelfEffect,
				debuffData = {
					effectType = EffectTypes.STATUS, 
					statusType = StatusTypes.VULNERABLE_DEBUFF,
					value = 2,
				},
				buffData = {
					effectType = EffectTypes.STATUS, 
					statusType = StatusTypes.CRITICAL_BUFF,
					value = 1,
				},
			}
		},
		upgrades = {
			{
				stat = "1.buffData.value",
				value = 1
			}
		}
	},
	["Toxin"] = {
		stringName = "Toxin",
		tags = {
			{
				tagType = CardAttributeTags.REQUIRES_TARGET,
			}	
		},
		cardType = CardTypes.UTILITY,
		rarity = RarityTypes.COMMON,
		targetType = TargetTypes.SELECT_UNIT,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		unitAnimation = AnimationTypes.BUFFING,
		image = "rbxassetid://73320240929112",
		description = "Apply {1.value} Decay",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 3,
		radius = 0,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.DAMAGE_OVER_TIME,
				value = 3,
			}
		},
		upgrades = {
			{
				stat = "1.value",
				value = 30
			},
			{
				stat = "radius",
				value = 1
			},
		}
	},
	["TestDamage"] = {
		stringName = "damage",
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.RARE,
		unitAnimation = AnimationTypes.BUFFING,
		targetType = TargetTypes.SELECT_UNIT,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		image = "rbxassetid://85432231405400",
		description = "Deals {1.value} damage in {radius} radius",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 2,
		radius = 3,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE, 
				damageType = DamageTypes.DIRECT,
				value = 300,
			},
			{
				effectType = EffectTypes.DEPLETE,
			}
		},
		upgrades = {
			
		}
	},
	["TestDamageArea"] = {
		stringName = "damagearea",
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.RARE,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		image = "rbxassetid://85432231405400",
		description = "Deals {1.value} damage in a {radius} radius",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 2,
		radius = 1,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.DAMAGE,
				damageType = DamageTypes.DIRECT,
				value = 10,
			},
		},
		upgrades = {
			{
				stat = "radius",
				value = 1
			}
		}
	},
	["TestBuffArea"] = {
		stringName = "damagearea",
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.RARE,
		unitAnimation = AnimationTypes.BUFFING,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.ALLY, 
		effectChoice = TargetChoices.ALLY, 
		image = "rbxassetid://85432231405400",
		description = "Buff",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 3,
		radius = 1,
		needsTarget = true,
		effects = {
			{ 
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.STRENGTH_BUFF,
				value = 3,
			},
			{ 
				effectType = EffectTypes.STATUS, 
				statusType = StatusTypes.DEFENSE_UP,
				value = 3,
			}
		},
		upgrades = {
		}
	},
	["Overclocker"] = {
		stringName = "Overclocker",
		cardType = CardTypes.DEPLOY,
		rarity = RarityTypes.RARE,
		unitAnimation = AnimationTypes.BUFFING,
		targetType = TargetTypes.SELECT_NODE,
		targetChoice = TargetChoices.NONE, 
		effectChoice = TargetChoices.NONE, 
		image = "rbxassetid://85432231405400",
		description = "Provides {1.value} Strength",
		sound = AudioRepo.SFX.Fire,
		cost = 1,
		range = 1,
		radius = 0,
		needsTarget = false,
		needsEmptyNode = true,
		effects = {
			{ 
				effectType = EffectTypes.DEPLOY,
				unitData = DeployUnits.Empower,
				value = 5
			}
		},
		upgrades = {
		}
	},
}

return CardDatabase
