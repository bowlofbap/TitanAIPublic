local Keywords = require(game:GetService("ReplicatedStorage").Repos.Keywords)

local t = {}

local patterns = {
	["<d>(.-)/>"] = `<font color="#EA5637">%1</font>`, --damage
	["<e>(.-)/>"] = `<font color="#37BFEA">%1</font>`, --energy
	["<k>(.-)/>"] = `<font color="#EAA837">%1</font>`, --keyword
	["<b>(.-)/>"] = `<font color="#E9E2BF">%1</font>`, --block
	["<g>(.-)/>"] = `<font color="#37E946">%1</font>`, --green
}

function t.ProcessText(text, parentData)
	local effects = parentData.effects
	-- First process color tags
	for pattern, replacement in pairs(patterns) do
		text = text:gsub(pattern, replacement)
	end

	-- Then process variable replacements
	text = text:gsub("{(.-)}", function(match)
		local parts = {}
		for part in match:gmatch("[^.]+") do
			table.insert(parts, part)
		end

		local value = effects  -- Start with root effects table

		for _, key in ipairs(parts) do
			-- Convert numeric keys to numbers
			local convertedKey = tonumber(key) or key
			value = value and value[convertedKey]

			if not value then break end
		end

		-- If value wasn't found in effects, check parentData as fallback
		if value == nil and parentData then
			value = parentData[match]
		end

		-- Still nil? Return original placeholder
		if value == nil then
			return "{"..match.."}"
		end

		return tostring(value)
	end)

	return text
end

function t.ProcessKeyWords(text)
	local foundKeywords = {}
	for keyword, keywordData in pairs(Keywords) do
		local pattern = "%f[%w]"..keyword.."%f[%W]" -- ensure full-word match
		text = text:gsub(pattern, function(match)
			table.insert(foundKeywords, keywordData)
			return "<k>" .. match .. "/>" -- mark for highlighting
		end)
	end
	return text, foundKeywords
end

function t.AddDepleteText(text)
	return text .. "\nDeplete"
end

return t


