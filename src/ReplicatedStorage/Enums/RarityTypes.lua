local rarityTypes = {
	STARTER = {
		label = "Starter",
		color = Color3.new(0.983368, 0.987518, 1),
		price = 25
	},
	COMMON = {
		label = "Common",
		color = Color3.new(0.479728, 0.485435, 0.485435),
		price = 50
	},
	RARE = {
		label = "Rare",
		color = Color3.new(0.320256, 0.540749, 0.765545),
		price = 100
	},
	LEGENDARY = {
		label = "Legendary",
		color = Color3.new(0.135698, 0.558465, 0.146883),
		price = 225
	},
}

function rarityTypes.getUpgrade(rarityType)
	if rarityType == rarityTypes.STARTER then
		return rarityTypes.COMMON
	elseif rarityType == rarityTypes.COMMON then
		return rarityTypes.RARE
	elseif rarityType == rarityTypes.RARE then
		return rarityTypes.LEGENDARY
	end
	warn("upgrade doesnt' exist for "..rarityType.label)
	return rarityType
end

return rarityTypes
