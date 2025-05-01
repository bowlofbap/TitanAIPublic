-- WeightedPicker.lua
local WeightedPicker = {}

-- Validate that `list` is an array of tables each with a numeric `.weight`
local function validate(list)
    assert(type(list) == "table", "Expected table of choices")
    for i, entry in ipairs(list) do
        assert(type(entry) == "table",    ("Entry %d is not a table"):format(i))
        assert(type(entry.weight) == "number",
               ("Entry %d missing numeric 'weight'"):format(i))
        assert(entry.weight >= 0,
               ("Entry %d has negative weight"):format(i))
    end
end

-- Precomputes cumulative weights; returns totalWeight and an array of prefix sums
local function buildCumulative(list)
    local cumulative = {}
    local sum = 0
    for i, entry in ipairs(list) do
        sum = sum + entry.weight
        cumulative[i] = sum
    end
    return sum, cumulative
end

-- Picks one entry from `list` using math.random()
function WeightedPicker.choose(list)
    validate(list)
    local totalWeight, cumulative = buildCumulative(list)
    if totalWeight == 0 then
        return nil    -- no valid entries
    end

    -- pick a random float in (0, totalWeight]
    local r = math.random() * totalWeight
    -- find first index where cumulative[i] >= r
    for i, threshold in ipairs(cumulative) do
        if r <= threshold then
            return list[i]
        end
    end
end

return WeightedPicker
