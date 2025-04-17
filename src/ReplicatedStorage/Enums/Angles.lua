local Angles = {
	TOP_DOWN = CFrame.Angles(math.rad(-90), 0, 0),  -- Directly overhead
	SLIGHT_TOP_DOWN = CFrame.Angles(math.rad(-45), 0, 0), -- Slight tilt
	ISO_ANGLE = CFrame.Angles(math.rad(-35), math.rad(45), 0), -- Isometric view
	SIDE_VIEW = CFrame.Angles(0, math.rad(90), 0), -- Side-scrolling style
	FRONT_VIEW = CFrame.Angles(0, 0, 0) -- Direct front
}

return Angles
