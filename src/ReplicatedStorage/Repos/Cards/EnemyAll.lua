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
	["E001"] = {
		stringName = "Do Nothing",
		animationClass = nil,
		tags = {
		},
		cardType = CardTypes.DAMAGE,
		rarity = RarityTypes.COMMON,
		unitAnimation = AnimationTypes.ATTACKING,
		targetType = TargetTypes.CLOSEST,
		targetChoice = TargetChoices.ENEMY, 
		effectChoice = TargetChoices.ENEMY, 
		image = "rbxassetid://90356868289376",
		description = "Does nothing, just for testing and passing turn",
		sound = AudioRepo.SFX.Fire,
		cost = 0,
		range = 1,
		radius = 0,
		effects = {
		},
		upgrades = {
		}
	},
}

return CardDatabase
