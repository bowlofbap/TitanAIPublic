local Tables = {}

function Tables.getSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
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

function Tables.print(t)
	for _, v in pairs(t) do
		print(v)
	end
end

function Tables.concat(t1, t2)
	local t3 = table.clone(t1)
	for i=1,#t2 do
		t3[#t3+1] = t2[i]
	end
	return t3
end

function Tables.getIndexOf(t, o)
	for i, v in ipairs(t) do
		if v == o then
			return i 
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

function Tables.deepCopy(t1)
	if type(t1) ~= "table" then return t1 end
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


return Tables
