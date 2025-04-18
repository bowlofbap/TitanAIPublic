local StateUpdate = require(game:GetService("ServerScriptService").General.StateUpdate)

local StateSyncBuffer = {}
StateSyncBuffer.__index = StateSyncBuffer

export type type = {
	add: (update: StateUpdate.type) -> (),
	addStep: (await: boolean, updates: table) -> (),
	addAwaitingStep: () -> (),
	flush: () -> ()
}

function StateSyncBuffer.new(player, event)
	local self = setmetatable({}, StateSyncBuffer)
	self._player = player
	self._event = event
	self._sequence = {} -- List of { await = true?, actions = { updates } }
	self._currentStep = nil
	return self
end

-- Adds a single update to the current step (creates one if none exists)
function StateSyncBuffer:add(update: StateUpdate.type)
	assert(update and update.updateType and update.data, "Invalid update format") --TODO: i wanna do type checking instead of this
	if not self._currentStep then
		self:_startNewStep(false)
	end
	table.insert(self._currentStep.actions, update)
end

-- Adds a full step with multiple updates and an await flag
function StateSyncBuffer:addStep(await: boolean, updates: table)
	assert(type(await) == "boolean", "Await must be a boolean")
	assert(type(updates) == "table", "Updates must be a list")
	table.insert(self._sequence, {
		await = await,
		actions = updates
	})
	self._currentStep = nil
end

-- Adds a new step that will be awaited
function StateSyncBuffer:addAwaitingStep()
	self:_startNewStep(true)
end

-- Internal helper to start a new step
function StateSyncBuffer:_startNewStep(await)
	local step = {
		await = await,
		actions = {}
	}
	table.insert(self._sequence, step)
	self._currentStep = step
end

function StateSyncBuffer:flush()
	if #self._sequence == 0 then return end
	if self._player.ClassName == "Player" then
		self._event:FireClient(self._player, self._sequence)
	else
		print("Mocking out player call for flush")
	end
	self._sequence = {}
	self._currentStep = nil
end

return StateSyncBuffer