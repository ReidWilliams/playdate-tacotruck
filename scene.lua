import "utils"
import "constants"

local gfx <const> = playdate.graphics

local cons = getConstants()

class('Scene').extends()

-- FIXME use object pattern from Asteroid game

-- Scene initializes with 3 ground sprites, each 400 pixels wide to cover one
-- viewport offscreen to the left, one onscreen viewport, and one offscreen
-- viewport to the right. As player scrolls beyond this, ground and obstacle
-- sprites are dynamically generated.

function Scene:init()
    Scene.super.init(self)

    -- game will render (x, x + 400) on screen. Changing x will scroll the scene
    self.viewportX = 0

    -- left and rightmost pixels that have been generated, relative to viewPortX
    self.rightGeneratedBoundary = 800 
    self.leftGeneratedBoundary = -400

    self.groundSprites = {}
    self.cactusSprites = {}

    self.groundImage = gfx.image.new( "images/ground.png" )
    assert( self.groundImage )

    self.cactusImage = gfx.image.new( "images/cactus.png" )
    assert( self.cactusImage )

    self:newGroundAt(-400)
    self:newGroundAt(0)
    self:newGroundAt(400)

    self:newCactusAt(300)
    -- Generate for offscreen left 400 pixels, and offscreen right 400 pixels.
    self:generateCacti( -400, 0 )
    self:generateCacti( 400, 800 )

    return self
end

-- Create cacti sprites for given x range. 
-- Sprites are never destroyed
function Scene:generateCacti(left, right)
    -- Sweep left to right, randomly deciding if a cactus should spawn
    local step = self.cactusImage.width
    local x = left

    while x < right - step do
        if ( math.random() < cons.cactusFrequency ) then
            self:newCactusAt(x)
        end
        x += step
    end
end

function Scene:newCactusAt(x)
    local cactusSprite = createSpriteWithCollision( self.cactusImage )
    cactusSprite:setZIndex( -99 )
    cactusSprite:moveTo( x, cons.groundY - self.cactusImage.height + 4 ) 
    self.cactusSprites[ #self.cactusSprites + 1 ] = cactusSprite 
    cactusSprite:add()
end

-- Generates new ground 400 pixels wide, from x to x + 400
function Scene:newGroundAt(x)
    local groundSprite = createSpriteWithCollision( self.groundImage )
    groundSprite:setZIndex(-100)
    groundSprite:setCollideRect( 0, cons.playerGroundDelta, self.groundImage.width, self.groundImage.height )
    groundSprite:moveTo( x, cons.groundY ) 
    self.groundSprites[ #self.groundSprites + 1 ] = groundSprite
    groundSprite:add()
end

function Scene:moveBy(delta)
    self.viewportX += delta
    self.leftGeneratedBoundary += delta
    self.rightGeneratedBoundary += delta

    -- Move existing sprites
    for _, sprite in ipairs(self.groundSprites) do
        sprite:moveBy(delta, 0)
    end

    for _, sprite in ipairs(self.cactusSprites) do
        sprite:moveBy(delta, 0)
    end

    -- Generate new sprites as player gets close to boundaries
    if ( self.leftGeneratedBoundary > -400) then
        self:newGroundAt( self.leftGeneratedBoundary - 400 )
        self.leftGeneratedBoundary -= 400
    end

    if ( self.rightGeneratedBoundary < 800) then
        self:newGroundAt( self.rightGeneratedBoundary )
        self:generateCacti( self.rightGeneratedBoundary, self.rightGeneratedBoundary + 400 )
        self.rightGeneratedBoundary += 400
    end
end

function Scene:moveLeft(delta)
    self:moveBy(-delta)
end

function Scene:moveRight(delta)
    self:moveBy(delta, 0)
end

function Scene:isObstacle(sprite)
	return contains(self.cactusSprites, sprite)
end

function Scene:isGround(sprite)
    return contains(self.groundSprites, sprite)
end


