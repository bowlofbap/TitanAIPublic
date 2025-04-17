local brainRepo = {
	Fighter = {
		selectCard = function(unit, gameInstance)
			if gameInstance:getTurnCount() % 2 == 1 then
				return 2
			else
				return 1
			end
		end,
	},
	GlitchGoblin = {
		selectCard = function(unit, gameInstance)
			if gameInstance:getTurnCount() % 2 == 1 then
				return 2
			else
				return 1
			end
		end,
	} 
}

return brainRepo
