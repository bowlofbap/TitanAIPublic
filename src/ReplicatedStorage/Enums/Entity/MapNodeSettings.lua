local settings = {
	TAIL = {
		BASE_TRANSPARENCY = 0.7,
		HOVERING_TRANSPARENCY = 0.15,
		DEFEATED_TRANSPARENCY = 0.35,
	},
	STATUSES = {
		CURRENT = {
			key = "CURRENT",
			color = BrickColor.Green(),
			tailColor = Color3.new(0.188235, 0.188235, 0.188235)
		},
		DEFEATED = {
			key = "DEFEATED",
			color = BrickColor.Black(),
			tailColor = Color3.new(0.188235, 0.188235, 0.188235)
		},
		POTENTIAL = {
			key = "POTENTIAL",
			color = BrickColor.Blue(),
			tailColor = Color3.new(0.490196, 0.556863, 1)
		},
		DEFAULT = {
			key = "DEFAULT",
			color = BrickColor.Gray(),
			tailColor = Color3.new(0.996078, 0.992157, 1)
		}
	}
}

return settings
