local module = {}

function module.roll(percent)
	return math.random() < (percent / 100)
end

return module
