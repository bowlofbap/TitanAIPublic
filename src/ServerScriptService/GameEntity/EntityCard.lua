local CardDatabase = require(game:GetService("ReplicatedStorage").Repos.CardRepo)
local Tables = require(game:GetService("ReplicatedStorage").Helpers.Tables)

local EntityCard = {}
EntityCard.__index = EntityCard

function EntityCard.new(name, upgraded, id)
	local self = setmetatable({}, EntityCard)
	local cardData = Tables.deepCopy(CardDatabase[name])
	if not cardData then
		warn("no card data for card", self)
		return nil
	end
	self.data = cardData
	self.key = name
	self.upgraded = upgraded
	self.id = id

	if self.upgraded then
		self:applyUpgrades()
	end

	return self
end

function EntityCard:destroy()
	self.data = nil
	self.key = nil
	self.upgraded = nil
	self.id = nil
	setmetatable(self, nil)
end

function EntityCard:applyUpgrades()
	local upgrades = self.data.upgrades
	for _, upgrade in ipairs(upgrades) do
		local pathParts = {}
		for part in upgrade.stat:gmatch("[^.]+") do
			table.insert(pathParts, part)
		end
		local target = self.data -- Start at instance root

		-- Navigate to the target property
		for i = 1, #pathParts - 1 do
			local part = pathParts[i]
			if tonumber(part) then
				target = target.effects[tonumber(part)]
			else
				target = target[part]
			end
		end

		-- Apply modification to final property
		local finalProp = pathParts[#pathParts]
		target[finalProp] = target[finalProp] + upgrade.value
	end
end

function EntityCard:upgrade()
	self.upgraded = true
	self:applyUpgrades()
end

function EntityCard:getName()
	if self.upgraded then
		return self.data.stringName .. "+"
	else
		return self.data.stringName
	end
end

function EntityCard:serialize()
	return {
		cardData = self.data,
		id = self.id,
		upgraded = self.upgraded
	}
end

return EntityCard
