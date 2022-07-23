import "CoreLibs/object"

local gfx <const> = playdate.graphics



class('AnimatedSprite').extends(gfx.sprite)

function AnimatedSprite:init(animation)
	AnimatedSprite.super.init(self)

	self.animation = animation

	return self
end

function AnimatedSprite:update()
	self:setImage(self.animation:image())
end
