import "CoreLibs/object"
import "letters"

local vector2D <const> = playdate.geometry.vector2D

-- Manages all flying objects

class('FloatingObjects').extends()

function FloatingObjects:init()
	FloatingObjects.super.init(self)

	-- FIXME turn this into vector of letters
	self.letters = FloatingT(vector2D.new(100, 50), vector2D.new(0.05, -0.01))

	return self
end

function FloatingObjects:isFloatingObject(sprite)	
	return sprite.type == 'FloatingObject'
end

function FloatingObjects:update(viewport) 
	self.letters:updateViewport(viewport)
end