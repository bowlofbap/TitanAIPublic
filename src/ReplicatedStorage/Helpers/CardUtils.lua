local CardUtils = {}

function CardUtils.hasTag(cardData, tagType)
	if not cardData.tags then return false end
	for _, t in ipairs(cardData.tags) do
		if t.tagType == tagType then
			return t
		end
	end
	return false
end

return CardUtils
