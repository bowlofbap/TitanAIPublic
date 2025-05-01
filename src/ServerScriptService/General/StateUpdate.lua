local StateUpdate = {}

export type type = {
	updateType: string,
	data: any,
}

function StateUpdate.new(updateType, data)
	data = data or {}
	assert(type(data) == "table", "Update data must be a table")
	return {
		updateType = updateType,
		data = data
	}
end

return StateUpdate
