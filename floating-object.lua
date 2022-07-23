import "CoreLibs/object"

local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

-- Floating object that can be moved when player runs into it
-- Subclass to set 

class('FloatingObject').extends(gfx.sprite)

function FloatingObject:init(animation)
	FloatingObject.super.init(self)
	
	self.position = vector2D.new(0, 0) -- world position
	self.velocity = vector2D.new(0, 0)
	
	-- FIXME allow object to be composed of one sprite with image and no collision
	-- and a vector of sprites with no image for collision. Allows non-rectangular
	-- collisions.
	
	-- Subclasses or instances should set these to customize appearance, etc
	self.image = nil
	self.sprite = nil
	self.mass = nil
	
	return self
end

function FloatingObject:update(viewport) 
	print(viewport)
	pos = self.position - viewport
	self.sprite:moveTo(pos.dx, pos.dy)
end
