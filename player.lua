import "CoreLibs/animation"
import "animated_sprite"
import "utils"

local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

local cons = getConstants()

class('Player').extends()

function Player:init(startPosition)
    Player.super.init(self)

    self.image = gfx.image.new( "images/player.png" )

    self.position = startPosition
    self.velocity = vector2D.new(0, 0)
    self.direction = 1 -- 1 is right, -1 is left

    self.width = self.image.width
    self.height = self.image.height

    self.sprite = createSpriteWithCollision(self.image)

    -- collide rect is a few pixels shorter than image so sprite appears to sit
    -- slightly below the top of the scene ground sprite
    self.sprite:setCollideRect( 0, 0, self.width, self.height ) 
    self.sprite:moveTo( self.position.dx, self.position.dy )

    -- Set up thrust animation and sprite at bottom of truck
    self.thrustImages = gfx.imagetable.new('images/thrust')
    self.thrustAnimation = gfx.animation.loop.new(100, self.thrustImages, true)
    self.thrustSprite = AnimatedSprite(self.thrustAnimation)
    self.thrustSprite:moveTo(self.position.dx + 30, self.position.dy + 8)
    self.thrustSprite:add() 

    self.showThrust = true

    return self
end

function Player:isOnGround()
	return self.position.dy + self.height - cons.playerGroundDelta >= cons.groundY
end

function Player:getBottom()
	return self.position.dy + self.height
end

function Player:right()
	self.velocity:addVector(vector2D.new(0.10, 0))
	if self.direction < 0 then
	    self.sprite:setImage( self.image ) -- not mirrored
	    self.direction = 1
	end
end

function Player:left()
	self.velocity:addVector(vector2D.new(-0.10, 0))
	if self.direction > 0 then
	    self.sprite:setImage(self.image, gfx.kImageFlippedX)
	    self.direction = -1
	end
end

function Player:jump()
	-- little boost if player is currently on the ground
	if self:isOnGround() then
	    self.velocity:addVector(vector2D.new(0, -0.8))
	end

	-- only make player move faster up to a limit.
	-- Limit this way rather than overall velocity to allow high velocity bounces
	if self.velocity.dy >= -3 then
	    self.velocity:addVector(vector2D.new(0, -0.4))
	end

    self.thrustSprite:setVisible(true)
end

function Player:endJump()
    self.thrustSprite:setVisible(false)
end

function Player:obstacleCollision(obstacleSprite)
	local bottom = self:getBottom()

    if bottom >= obstacleSprite.y + 20 then
        -- player hit obstacle from side
        self:sideCollision()
        
        if self.position.dx < obstacleSprite.x then
            -- hit from left
            self.position.dx = obstacleSprite.x - self.width - 1
        end
        if self.position.dx > obstacleSprite.x then
            -- hit from right
            self.position.x = obstacleSprite.x + obstacleSprite.width
        end
    else
        -- player hit obstacle from above
        self.position.dy = obstacleSprite.y - self.height
        self.velocity.dy = self.velocity.dy * -1.5
    end
end

function Player:groundCollision(groundSprite)
    self.position.dy = groundSprite.y - self.height + cons.playerGroundDelta + 1
    self.velocity.dy = self.velocity.dy * -0.3
end

function Player:sideCollision() 
	self.velocity.dx = self.velocity.dx * -0.9
end

function Player:update()
    self.position:addVector(self.velocity)
    self.velocity:addVector(cons.gravity)
    -- 0.95 is reasonable

    if (self:isOnGround()) then
        self.velocity.dx = self.velocity.dx * 0.97
    else
        self.velocity.dx = self.velocity.dx * 0.999
    end

    -- limit y velocity
    if self.velocity.dy < -6 then self.velocity.dy = -6 end 

    self.sprite:moveTo(self.position.dx, self.position.dy)
    self.thrustSprite:moveTo(self.position.dx + 30, self.position.dy + 35)
end
