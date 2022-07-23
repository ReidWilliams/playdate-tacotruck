import "CoreLibs/object"
import "letters"

local vector2D <const> = playdate.geometry.vector2D

-- Manages all flying objects

class('FloatingObjects').extends()

function FloatingObjects:init()
	FloatingObjects.super.init(self)

	-- FIXME turn this into vector of letters
	self.letters = FloatingT(vector2D.new(100, 100), vector2D.new(0, 0))

	return self
end

function FloatingObjects:update(viewport) 
	self.letters:update(viewport)
end