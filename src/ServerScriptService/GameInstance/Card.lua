local CardDatabase = require(game:GetService("ReplicatedStorage").Repos.CardRepo)
local EffectTypes = require(game:GetService("ReplicatedStorage").Enums.EffectTypes)

local Card = {}
Card.__index = Card

function Card.new(entityCard)
	local self = setmetatable({}, Card)
	local cardData = entityCard.data
	self.id = entityCard.id
	self.upgraded = entityCard.upgraded
	self.cardData = cardData
	self.depletable = false
	
	self.effects = {}
	
	for _, effectData in ipairs(cardData.effects) do
		local data = effectData
		--insert the upgraded effects and take out removed effects
		if effectData.upgrade and not entityCard.upgraded then continue end
		if effectData.removeOnUpgrade and entityCard.upgraded then continue end
		local effectClass
		if effectData.effectType == EffectTypes.CUSTOM then
			effectClass = require(effectData.customEffect)
		elseif effectData.effectType == EffectTypes.DEPLETE then
			self.depletable = true
			continue
		else
			effectClass = require(game:GetService("ReplicatedStorage").Repos.Effects[effectData.effectType])
		end
		table.insert(self.effects, {effect = effectClass.new(data), data = data})
	end
	return self
end

-- Function to play a card (applies all effects to the target)
function Card:play(primaryTargets, effectTargets, gameInstance, context)
	for i, effectTable in ipairs(self.effects) do
		effectTable.effect:execute(primaryTargets, effectTargets, gameInstance, context, self)  -- Executes each effect
		--it's hacky to add the self at the end, but it's necessary for the deployed cards to have a reference 
	end
end

function Card:getCardType()
	return self.cardData.cardType
end

function Card:isDepletable()
	return self.depletable
end

function Card:toTable()
	return { name = self.cardData.key, id = self.id, upgraded = self.upgraded }
end

return Card
