import "CoreLibs/object"
import "floating-object"
import "utils"

local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

-- Floating object that can be moved when player runs into it
-- Subclass to set 

class('FloatingT').extends(FloatingObject)

function FloatingT:init(position, velocity)	
	local image = gfx.image.new( "images/square.png" )
	local mass = 1000
	local sprites = createSpriteWithCollision(image)
	
	FloatingT.super.init(self, image, sprites, mass)

	self.position = position
	self.velocity = velocity
	
	return self
end
