import "utils"
import "constants"

local gfx <const> = playdate.graphics

local cons = getConstants()
local objectStep = 25 -- width of cactus, taco sprites. Divide x coord into lattice this wide

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
    self.tacoSprites = {}
    self.cactusSprites = {}

    self.groundImage = gfx.image.new( "images/ground.png" )
    assert( self.groundImage )
    
    self.tacoImage = gfx.image.new( "images/taco.png" )
    assert( self.tacoImage )

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

-- Create taco sprites for given x range. 
function Scene:generateTacos(left, right)
    -- Sweep left to right, randomly deciding if a cactus should spawn
    local x = left
    
    while x < right - objectStep do
        if ( math.random() < cons.tacoFrequency ) then
            self:newTacoAt(x)
        end
        x += objectStep
    end
end

-- Create cacti sprites for given x range. 
-- Sprites are never destroyed
function Scene:generateCacti(left, right)
    -- Sweep left to right, randomly deciding if a cactus should spawn
    local x = left
    local thresh, delta
    
    while x < right - objectStep do
        delta = cons.cactusFrequencyPerlinAmplitudeScale * 
            (gfx.perlin(
                cons.cactusFrequencyPerlinXScale*(self.viewportX + x), 
                0, -- y
                0, -- z
                0, -- repeat
                cons.cactusFrequencyPerlinOctaves, 
                cons.cactusFrequencyPerlinPersitence
            ) - 0.5)
            
        thresh = cons.catusFrequencyBase + delta
        if ( math.random() < thresh ) then
            self:newCactusAt(x)
        end
        x += objectStep
    end
end

function Scene:newTacoAt(x)
    if self:isCactusNearby(x) then 
        return
    end
        
    local tacoSprite = createSpriteWithCollision( self.tacoImage )
    tacoSprite:setZIndex( -99 )
    tacoSprite:moveTo( x, cons.groundY - self.tacoImage.height + - 3) 
    self.tacoSprites[ #self.tacoSprites + 1 ] = tacoSprite 
    tacoSprite:add()
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

function Scene:moveSpritesBy(spriteList, delta)
    for _, sprite in ipairs(spriteList) do
        sprite:moveBy(delta, 0)
    end
end

function Scene:moveBy(delta)
    self.viewportX += delta
    self.leftGeneratedBoundary += delta
    self.rightGeneratedBoundary += delta

    -- Move existing sprites
    self:moveSpritesBy(self.groundSprites, delta)
    self:moveSpritesBy(self.tacoSprites, delta)
    self:moveSpritesBy(self.cactusSprites, delta)
   
    -- Generate new sprites as player gets close to boundaries
    -- No cacti or tacos left of player start
    if ( self.leftGeneratedBoundary > -400) then
        self:newGroundAt( self.leftGeneratedBoundary - 400 )        
        self.leftGeneratedBoundary -= 400
    end

    -- Cacti and tacos right of player start
    if ( self.rightGeneratedBoundary < 800) then
        self:newGroundAt( self.rightGeneratedBoundary )
        self:generateCacti( self.rightGeneratedBoundary, self.rightGeneratedBoundary + 400 )
        self:generateTacos( self.rightGeneratedBoundary, self.rightGeneratedBoundary + 400 )
        self.rightGeneratedBoundary += 400
    end
end

function Scene:moveLeft(delta)
    self:moveBy(-delta)
end

function Scene:moveRight(delta)
    self:moveBy(delta, 0)
end

function Scene:isTaco(sprite)
    return contains(self.tacoSprites, sprite)
end

function Scene:isObstacle(sprite)
	return contains(self.cactusSprites, sprite)
end

function Scene:isGround(sprite)
    return contains(self.groundSprites, sprite)
end

function Scene:isCactusNearby(x)
    local cactus = firstWhere(
        self.cactusSprites, 
        function(cactusSprite)
            return math.abs(cactusSprite.x - x) < cons.minDistanceTacoFromCactus
        end
    )
    
    return cactus ~= nil
end

function Scene:tacoConsumed(tacoSprite)
    removeItem(self.tacoSprites, tacoSprite)
    tacoSprite:remove()
end
    
    
