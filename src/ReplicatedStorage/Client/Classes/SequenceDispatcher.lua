local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Helpers.Classes.Promise)

local SequenceDispatcher = {}
SequenceDispatcher.__index = SequenceDispatcher

function SequenceDispatcher.new()
	local self = setmetatable({}, SequenceDispatcher)
	self._queue = {}
	self._playing = false
	self._handlers = {}
	return self
end

-- Register handler functions
function SequenceDispatcher:register(updateType, handler)
	self._handlers[updateType] = handler
end

-- Enqueue a new sequence (called by the RemoteEvent listener)
function SequenceDispatcher:enqueue(sequencePayload, context)
	table.insert(self._queue, { sequence = sequencePayload, context = context })
	self:_tryPlayNext()
end

function SequenceDispatcher:_tryPlayNext()
	if self._playing then return end
	local next = table.remove(self._queue, 1)
	if not next then return end

	self._playing = true
	self:_playSequence(next.sequence, 1, next.context):andThen(function()
		self._playing = false
		self:_tryPlayNext()
	end)
end

function SequenceDispatcher:_playSequence(sequence, index, context)
	local step = sequence[index]
	if not step then return Promise.resolve() end

	local promises = {}

	for _, update in ipairs(step.actions) do
		local handler = self._handlers[update.updateType]
		if handler then
			local maybePromise = handler(update.data, context)
			if step.await and maybePromise and maybePromise.await then
				table.insert(promises, maybePromise)
			end
		else
			warn("[SequenceDispatcher] Unhandled update type:", update.updateType)
		end
	end

	local nextStep = function()
		return self:_playSequence(sequence, index + 1, context)
	end

	if step.await and #promises > 0 then
		return Promise.all(promises):andThen(nextStep)
	else
		return Promise.delay(0.05):andThen(nextStep)
	end
end

return SequenceDispatcher