local GuiUtils = {}

function GuiUtils.isOverElement(mousePos, element)
	local absPos = element.AbsolutePosition
	local absSize = element.AbsoluteSize

	return mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
		and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
end

function GuiUtils.getCenterScreenPosition(guiObject)
	local absPos = guiObject.AbsolutePosition
	local absSize = guiObject.AbsoluteSize
	return absPos + (absSize / 2)
end

return GuiUtils
