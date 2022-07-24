import "CoreLibs/object"

local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

-- Floating object that can be moved when player runs into it.
-- This class is a sprite but also has its own list of sprites (self.sprites).
-- These allow collisions with a complex image shape. Collision with an instance of this class
-- (as a sprite) is only used to determine whether to test for collision of contained self.sprites. 

class('FloatingObject').extends(gfx.sprite)

function FloatingObject:init(image, sprites, mass)	
	FloatingObject.super.init(self)
	
	self.type = 'FloatingObject' -- used to identify instances of this class in collisions
	
	self.position = vector2D.new(0, 0) -- world position
	self.velocity = vector2D.new(0, 0)
	
	-- FIXME allow object to be composed of one sprite with image and no collision
	-- and a vector of sprites with no image for collision. Allows non-rectangular
	-- collisions.
	
	self.image = image
	self.sprites = sprites -- contained sprites for actual collision testing
	self.mass = mass
	
	-- self as sprite to determine whether to then test contained sprites for collision
	self:setCenter(0, 0)
	self:setCollideRect(0, 0, image.width, image.height)
	self:add()
	
	return self
end

function FloatingObject:collision(momentum)
	self.velocity = self.velocity + momentum:scaledBy(1/self.mass)
end

function FloatingObject:updateViewport(viewport) 	
	self.position:addVector(self.velocity)
	
	pos = self.position - viewport
	self:moveTo(pos.dx, pos.dy)
	self.sprites:moveTo(pos.dx, pos.dy)
end
