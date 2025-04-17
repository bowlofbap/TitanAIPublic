local DragManager = {}
DragManager.__index = DragManager

function DragManager.new()
	local self = setmetatable({}, DragManager)
	self._current = nil
	self._isDragging = false
	return self
end

function DragManager:startDrag(dragObject)
	assert(dragObject.OnDragStart, "Missing OnDragStart on draggable")
	self._current = dragObject
	self._isDragging = true
	dragObject:onDragStart()
end

function DragManager:update(mousePos)
	if self._current and self._isDragging then
		self._current:onDragUpdate(mousePos)
	end
end

function DragManager:endDrag(mousePos)
	if self._current and self._isDragging then
		self._current:onDragEnd(mousePos)
		self:_reset()
	end
end

function DragManager:cancelDrag()
	if self._current and self._isDragging then
		self._current:onCancel()
		self:_reset()
	end
end

function DragManager:_reset()
	self._isDragging = false
	self._current = nil
end

return DragManager
