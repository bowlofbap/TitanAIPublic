local CardRepo = require(game:GetService("ReplicatedStorage").Repos.CardRepo)
local ModelFolder = game:GetService("ReplicatedStorage").Models.Units
local AnimationTypes = require(game:GetService("ReplicatedStorage").Enums.AnimationTypes)

local UnitRepo = {
	PlayerUnits = {
		Mage = {
			Name = "Mage",
			key = "Mage",
			Model = ModelFolder.Mage,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://120964381278073",
				[AnimationTypes.BUFFING] = "rbxassetid://113546067337704",
				[AnimationTypes.IDLE] = "rbxassetid://119838540455512",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://119838540455512",
			}
		},
		TestMage = {
			Name = "TestMage",
			key = "TestMage",
			Model = ModelFolder.TestMage,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://114395869354939",
				[AnimationTypes.BUFFING] = "rbxassetid://114395869354939",
				[AnimationTypes.IDLE] = "rbxassetid://121762692644582",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://119838540455512",
			}
		},
		Ze = {
			Name = "Ze",
			key = "Ze",
			Model = ModelFolder.Ze,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://87361367074821",
				[AnimationTypes.BUFFING] = "rbxassetid://72997639646799",
				[AnimationTypes.IDLE] = "rbxassetid://115176516809245",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://113468513410770",
			}
		}
	},
	AiUnits = {
		Toadie = {
			Name = "Toadie",
			key = "Toadie",
			Model = ModelFolder.Toadie,
			MaxHealth = 50,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://129018263677793",
				[AnimationTypes.BUFFING] = "rbxassetid://129018263677793",
				[AnimationTypes.IDLE] = "rbxassetid://90518889562763",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://119838540455512",
			},
			ActionSet = {
				{
					CardRepo.MoveCloserY.key,
					CardRepo.Fireball.key,
					CardRepo.MoveAwayY.key
				},
				{
					CardRepo.MoveCloserY.key,
					CardRepo.Fireball.key,
					CardRepo.Fireball.key,
				}
			}
		},
		Vagrant = {
			Name = "Vagrant",
			key = "Vagrant",
			Model = ModelFolder.Vagrant,
			MaxHealth = 60,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://120964381278073",
				[AnimationTypes.BUFFING] = "rbxassetid://113546067337704",
				[AnimationTypes.IDLE] = "rbxassetid://119838540455512",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://119838540455512",
			},
			ActionSet = {
				{
					CardRepo.Barrier.key,
					CardRepo.Strengthen.key,
					CardRepo.LightningStrike.key,
				}
			}
		},
		Rat = {
			Name = "Rat",
			key = "Rat",
			Model = ModelFolder.Rat,
			MaxHealth = 13,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://114075558888851",
				[AnimationTypes.BUFFING] = "rbxassetid://114075558888851",
				[AnimationTypes.IDLE] = "rbxassetid://108182746813885",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://119838540455512",
			},
			ActionSet = {
				{
					CardRepo.MoveCloserY.key,
					CardRepo.Fireball.key,
					CardRepo.Fireball.key,
				}
			}
		},
		Eater = {
			Name = "Eater",
			key = "Eater",
			Model = ModelFolder.Eater,
			MaxHealth = 20,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://124738666076711",
				[AnimationTypes.BUFFING] = "rbxassetid://124738666076711",
				[AnimationTypes.IDLE] = "rbxassetid://89148020343219",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://119838540455512",
			},
			ActionSet = {
				{
					CardRepo.SearchAttack1.key,
					CardRepo.Barrier1.key,
				}
			}
		},
		Feeder = {
			Name = "Feeder",
			key = "Feeder",
			Model = ModelFolder.Feeder,
			MaxHealth = 20,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://101397352254280",
				[AnimationTypes.BUFFING] = "rbxassetid://113063938464848",
				[AnimationTypes.IDLE] = "rbxassetid://83345185758231",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://118036961637811",
			},
			ActionSet = {
				{
					CardRepo.SearchAttack1.key,
					CardRepo.Barrier1.key,
				}
			}
		},
		Fighter = {
			Name = "Fighter",
			key = "Fighter",
			Model = ModelFolder.Fighter,
			MaxHealth = 15,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://124232454549559",
				[AnimationTypes.BUFFING] = "rbxassetid://126448712784582",
				[AnimationTypes.IDLE] = "rbxassetid://125354508655501",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://96823564590311",
			},
			CardSet = {
				CardRepo.Barrier1.key,
				CardRepo.Fireball.key,
			},

		},
		GlitchGoblin = {
			Name = "Glitch Goblin",
			key = "GlitchGoblin",
			Model = ModelFolder.GlitchGoblin,
			MaxHealth = 15,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://110809822837427",
				[AnimationTypes.BUFFING] = "rbxassetid://110809822837427",
				[AnimationTypes.IDLE] = "rbxassetid://70376749365831",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://110809822837427",
			},
			CardSet = {
				CardRepo.Barrier1.key,
				CardRepo.Fireball.key,
			},
		},
		TestEnemy = {
			Name = "Glitch Goblin",
			key = "TestEnemy",
			Model = ModelFolder.GlitchGoblin,
			MaxHealth = 100,
			Animations = {
				[AnimationTypes.ATTACKING] = "rbxassetid://110809822837427",
				[AnimationTypes.BUFFING] = "rbxassetid://110809822837427",
				[AnimationTypes.IDLE] = "rbxassetid://70376749365831",
				[AnimationTypes.TAKE_DAMAGE] = "rbxassetid://110809822837427",
			},
			CardSet = {
				CardRepo.E001.key,
			},
		},
	}
}

return UnitRepo
