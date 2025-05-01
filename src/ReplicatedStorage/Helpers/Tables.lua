local Tables = {}

function Tables.getSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

--pass in an indexed table with no keys that has nested tables with key = value. return the first table with keyName = key and value = searchvalue
--[[
t = { 
{
	key = "Hello"
}
}

Tables.find(t, "key", "Hello")
]]
function Tables.find(t, keyName, searchValue)
    for _, obj in ipairs(t) do
        if obj[keyName] == searchValue then
            return obj
        end
    end
    return nil
end

--t = table, s = string, p = property
function Tables.filterByString(t, s, p--[[optional]])
	local returnTable = {}
	for _, v in pairs(t) do
		local matchString = ""
		--if p is passed in, then implies that table t contains objects with properties, and we want to match strings matching s. otherwise, assumes table is all strings
		if (p) then
			matchString = v[p]
		else
			matchString = v
		end
		if string.find(matchString, s) then
			table.insert(returnTable, v)
		end
	end
	return returnTable
end

function Tables.findValueFromName(t, n)
	for name, p in pairs(t) do
		if name == n then
			return p
		end
	end
	return nil
end

function Tables.shallowCopy(t1)
	local t2 = {}
	for _, v in ipairs(t1) do
		table.insert(t2, v)
	end
	return t2
end

function Tables.deepCopy(t1, ...)
	local exclusionTables = ... or {}
	if type(t1) ~= "table" then return t1 end
	for _, exclusionTable in ipairs(exclusionTables) do
		if table.find(exclusionTable, t1) then
			print("Excluding deep copy of ",exclusionTable)
			return t1 
		end
	end
	local copy = {}
	for k, v in pairs(t1) do
		copy[Tables.deepCopy(k)] = Tables.deepCopy(v)
	end
	return copy
end

function Tables.chop(t1)
	local copy = {}
	local length = #t1
	table.move(t1, 1, length > 0 and length - 1 or 0, 1, copy)
	return copy
end

function Tables.selectTwoRandomElements(tbl)
	if #tbl < 2 then
		warn("Table must contain at least two elements")
		return nil
	end

	-- First random index
	local index1 = math.random(#tbl)

	-- Second random index (ensure different from first)
	local index2
	repeat
		index2 = math.random(#tbl)
	until index2 ~= index1

	return tbl[index1], tbl[index2]
end

--Takes in a table of complex tables and strips them down to just a table of a key within the object. {{Id = 5}, {Id = 7}} -> {5, 7}
function Tables.strip(tbl, key)
	local stripped = {}
	for _, obj in ipairs(tbl) do
		table.insert(stripped, obj[key])
	end
	return stripped
end

function Tables.removeDuplicates(tbl)
	local seen = {}
	local result = {}

	for _, value in ipairs(tbl) do
		if not seen[value] then
			seen[value] = true
			table.insert(result, value)
		end
	end

	return result
end

function Tables.deepEquals(a, b)
    local seen = {}

    local function _equals(x, y)
        -- identical or primitive compare
        if x == y then
            return true
        end

        -- must both be tables from here on
        if type(x) ~= "table" or type(y) ~= "table" then
            return false
        end

        -- cycle check
        seen[x] = seen[x] or {}
        if seen[x][y] then
            return true
        end
        seen[x][y] = true

        -- compare every key in x
        for k, v in pairs(x) do
            if y[k] == nil or not _equals(v, y[k]) then
                return false
            end
        end

        -- ensure y doesn’t have extra keys
        for k in pairs(y) do
            if x[k] == nil then
                return false
            end
        end

        return true
    end

    return _equals(a, b)
end


return Tables
