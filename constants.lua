local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

function getConstants()
	local c = {}

	c.groundY = 200 -- y position in world coordinates of ground
	
	-- these are screen coordinates where viewport starts to move
	c.leftBoundary = 50 -- X position where driving scrolls scene
	c.rightBoundary = 250 -- X position where driving scrolls scene
	c.topBoundary = 35 -- Y position where viewport scrolls up
	c.bottomBoundary = 65 -- Y position where viewport scrolls down
	
	c.collisionLoss = 0.0 -- how much momentum is lost when one object collides with another
	c.collisionTransfer = 0.50 -- how much momentum is transferred to object collided with
	
	c.playerGroundDelta = 10 -- how far below top of ground to render player
	c.gravity = vector2D.new(0, 0.25)
	c.playerMass = 100
	c.playerStartPosition = vector2D.new(50, c.groundY + c.playerGroundDelta)
	
	c.playerStartFuel = 1000
	c.playerFuelConsumeRate = 0.9
	c.playerFuelPerTaco = 50
	
	c.tacoFrequency = 0.08
	c.minDistanceTacoFromCactus = 100

	c.catusFrequencyBase = 0
	c.cactusFrequencyPerlinXScale = 0.01
	c.cactusFrequencyPerlinAmplitudeScale = 2.0
	c.cactusFrequencyPerlinOctaves = 3
	c.cactusFrequencyPerlinPersitence = 0.1
	
	return c
end

