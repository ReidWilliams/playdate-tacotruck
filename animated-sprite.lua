import "CoreLibs/object"
import "CoreLibs/animation"

local gfx <const> = playdate.graphics

-- Cycles through images to animate

class('AnimatedSprite').extends(gfx.sprite)

function AnimatedSprite:init(animation)
    AnimatedSprite.super.init(self)

    self.animation = animation

    return self
end

function AnimatedSprite:update()
    self:setImage(self.animation:image())
end
