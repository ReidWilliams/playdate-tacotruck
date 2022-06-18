local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

function getConstants()
	local c = {}

	c.groundY = 200 -- Y position of ground on which player drives
	c.leftBoundary = 50 -- X position where driving scrolls scene
	c.rightBoundary = 250 -- X position where driving scrolls scene
	
	c.playerGroundDelta = 10 -- how far below top of ground to render player
	c.gravity = vector2D.new(0, 0.25)
	c.playerStartPosition = vector2D.new(50, c.groundY + c.playerGroundDelta)
	c.playerFuelConsumeRate = 0.9

	c.cactusFrequency = 0.1
	return c
end

