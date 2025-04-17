local Echoes = game:GetService("ReplicatedStorage").Repos.EchoesEffects
local repo = {
	echoes = {}
}

for _, echoClass in ipairs(Echoes:GetChildren()) do
	if echoClass.Name ~= "BaseEcho" then
		local echo = require(echoClass)
		repo.echoes[echoClass.Name] = echo.data
	end
end

function repo.get(rarity, subsets)
	local pSubsets = {}
	--preproccessing for quicklookup
	for _, subset in ipairs(subsets) do
		pSubsets[subset] = true
	end
	local output = {}
	for echoName, echoData in pairs(repo.echoes) do
		if echoData.rarity == rarity and pSubsets[echoData.subset] then
			output[echoName] = echoData
		end
	end
	return output
end

return repo
