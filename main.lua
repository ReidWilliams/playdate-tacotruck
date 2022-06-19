-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "constants"
import "utils"
import "scene"
import "player"
import "fuel_UI"

local gfx <const> = playdate.graphics
local vector2D <const> = playdate.geometry.vector2D

local cons = getConstants()

local player = nil
local scene = nil
local rightBoundarySprite = nil
local leftBoundarySprite = nil
local topBoundarySprite = nil

local crashSound = nil

function playCrashSound()
    crashSound:play()
end

function myGameSetUp()
    player = Player(cons.playerStartPosition)
    scene = Scene()

    fuelUI = FuelUI()
    fuelUI:moveTo(8, 8)

    -- local crashSound = playdate.sound.synth.new(playdate.sound.kWaveNoise)
    crashSound = playdate.sound.sampleplayer.new( "sounds/ow.wav" )
    assert( crashSound )
end

function scrollUpdate()
    print("viewport y is " .. scene.viewportY)
    local dx = 0
    local dy = 0
    
    if (player.position.dx < cons.leftBoundary) then
        dx = player.position.dx - cons.leftBoundary
        scene:moveBy(dx, 0)
        player.position.dx = cons.leftBoundary
    end
    
    if (player.position.dx + player.width > cons.rightBoundary) then
        dx = player.position.dx + player.width - cons.rightBoundary
        scene:moveBy(dx, 0)
        player.position.dx = cons.rightBoundary - player.width
    end
    
    if (player.position.dy < cons.topBoundary) then
        local dy = player.position.dy - cons.topBoundary
        scene:moveBy(0, dy)
        player.position.dy = cons.topBoundary
    end
        
    if (scene.viewportY > 0 and player.position.dy + player.height > cons.bottomBoundary) then
        dy = player.position.dy + player.height - cons.bottomBoundary
        scene:moveBy(0, dy)
        player.position.dy = cons.bottomBoundary - player.height
    end
end
    
function collisionUpdate()
    -- test for collision
    local colls = player.sprite:overlappingSprites()
    for _, sprite in ipairs(colls) do
        if scene:isGround(sprite) then 
            player:groundCollision(sprite)
            -- scene:moveBy(0, 0 - scene.viewportY)-- hack because I'm see this incorrectly be -10
        end
        if scene:isObstacle(sprite) then player:obstacleCollision(sprite) end
        -- play sound here
    end
    
    colls = player.eatingSprite:overlappingSprites()
    for _, sprite in ipairs(colls) do
        if scene:isTaco(sprite) then 
            -- event based pattern would be nice here
            player:tacoCollision(sprite)
            scene:tacoConsumed(sprite)
        end
    end
end

function getPlayerInput ()
    -- Poll the d-pad and move our player accordingly.
    -- (There are multiple ways to read the d-pad; this is the simplest.)
    -- Note that it is possible for more than one of these directions
    -- to be pressed at once, if the user is pressing diagonally.

    -- Right
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
        player:right()
    end

    -- Left
    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
        player:left()
    end

    -- Jump
    if playdate.buttonIsPressed( playdate.kButtonB ) or 
        playdate.buttonIsPressed ( playdate.kButtonUp ) then
        player:jump()
    else
        player:endJump()
    end
end


-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()

    collisionUpdate()
    scrollUpdate()
    getPlayerInput()

    player:update()
    -- player.fuel = math.min(player.fuel + 0.2, 100)

    gfx.sprite.update()
    playdate.timer.updateTimers()

    fuelUI:update(player.fuel)
end

