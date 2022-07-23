import "CoreLibs/object"
import "floating-object"
import "utils"

local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

-- Floating object that can be moved when player runs into it
-- Subclass to set 

class('FloatingT').extends(FloatingObject)

function FloatingT:init(position, velocity)
	FloatingObject.super.init(self)
	
	self.position = position
	self.velocity = velocity
	
	-- Subclasses or instances should set these to customize appearance, etc
	self.image = gfx.image.new( "images/square.png" )
	self.mass = 100
	self.sprite = createSpriteWithCollision(self.image)
	
	self.sprite:moveTo(position.dx, position.dy)
	
	return self
end
