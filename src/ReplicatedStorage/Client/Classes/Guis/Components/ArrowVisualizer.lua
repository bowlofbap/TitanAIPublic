local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiUtils = require(ReplicatedStorage.Helpers.GuiUtils)

local ArrowVisualizer = {}
local Players = game:GetService("Players")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

function ArrowVisualizer.drawArrow(fromGuiObject, toScreenPos)
	local screenGui = playerGui:WaitForChild("OverlayGui")
	local arrow = screenGui:WaitForChild("Arrow")
	local fromPos = GuiUtils.getCenterScreenPosition(fromGuiObject)
	local diff = toScreenPos - fromPos
	local distance = diff.Magnitude
	local angle = math.atan2(diff.Y, diff.X)

	arrow.Position = UDim2.new(0, fromGuiObject.AbsolutePosition.X + fromGuiObject.AbsoluteSize.X/2, 0, fromGuiObject.AbsolutePosition.Y + fromGuiObject.AbsoluteSize.Y/2 )
	arrow.Size = UDim2.new(0, 40, 0, distance)
	arrow.Rotation = math.deg(angle + 90)
	--arrow.Visible = true
end

function ArrowVisualizer.hideArrow()
	local screenGui = playerGui:WaitForChild("OverlayGui")
	local arrow = screenGui:WaitForChild("Arrow")
	arrow.Visible = false
end

return ArrowVisualizer