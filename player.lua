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
    self.fuel = cons.playerStartFuel
    self.isJumping = false
    
    self.viewport = vector2D.new(0, 0)

    self.width = self.image.width
    self.height = self.image.height

    self.sprite = createSpriteWithCollision(self.image)

    -- collide rect is a few pixels shorter than image so sprite appears to sit
    -- slightly below the top of the scene ground sprite
    self.sprite:setCollideRect( 0, 0, self.width, self.height ) 
    
    -- smaller sprite with no image centered inside player sprite
    -- use collision with this sprite to know when player has eaten or consumed an item
    -- so that items are not consumed as soon as the edge of the player touches them
    self.eatingSprite = gfx.sprite.new()
    self.eatingSprite:setCollideRect(10, 5, self.width - 30, self.height - 10)
    self.eatingSprite:add()

    -- Set up thrust animation and sprite at bottom of truck
    self.thrustImages = gfx.imagetable.new('images/thrust')
    self.thrustAnimation = gfx.animation.loop.new(100, self.thrustImages, true)
    self.thrustSprite = AnimatedSprite(self.thrustAnimation)
    self.thrustSprite:add() 

    self.showThrust = true
    
    self:update()

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
    if self.fuel > 0 then
        self.isJumping = true
    	-- little boost if player is currently on the ground
    	if self:isOnGround() then
    	    self.velocity:addVector(vector2D.new(0, -0.8))
    	end

    	-- only make player move faster up to a limit.
    	-- Limit this way rather than overall velocity to allow high velocity bounces
    	if self.velocity.dy >= -3 then
    	    self.velocity:addVector(vector2D.new(0, -0.4))
    	end

        self.fuel = self.fuel - cons.playerFuelConsumeRate
        self.thrustSprite:setVisible(true)
    else
        self:endJump()
    end
end

function Player:endJump()
    self.thrustSprite:setVisible(false)
    self.isJumping = false
end

function Player:tacoCollision(tacoSprite)
    self.fuel = self.fuel + cons.playerFuelPerTaco
end

function Player:obstacleCollision(obstacleSprite)
	local bottom = self:getBottom()

    if bottom >= obstacleSprite.worldPosition.dy + 20 then
        -- player hit obstacle from side
        self:sideCollision()
        
        if self.position.dx < obstacleSprite.worldPosition.dx then
            -- hit from left
            self.position.dx = obstacleSprite.worldPosition.dx - self.width - 1
        end
        if self.position.dx > obstacleSprite.worldPosition.dx then
            -- hit from right
            self.position.x = obstacleSprite.worldPosition.dx + obstacleSprite.width
        end
    else
        -- player hit obstacle from above
        self.position.dy = obstacleSprite.worldPosition.dy - self.height
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

function Player:getViewportCoordsPosition()
    return self.position - self.viewport
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
    
    -- update sprites based on position and viewport
    local spritePosition = self:getViewportCoordsPosition()
    self.sprite:moveTo(spritePosition.dx, spritePosition.dy)
    self.eatingSprite:moveTo(spritePosition.dx, spritePosition.dy)
    self.thrustSprite:moveTo(spritePosition.dx + 30, spritePosition.dy + 40)
end
