local StateUpdate = {}

export type type = {
	updateType: string,
	data: any,
}

--honestly we dont REALLY need this, just want to see how this sort of abstraction feels
function StateUpdate.new(updateType, data)
	assert(type(data) == "table", "Update data must be a table")
	return {
		updateType = updateType,
		data = data
	}
end

return StateUpdate
