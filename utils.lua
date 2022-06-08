local gfx <const> = playdate.graphics

-- All utils as pure functions with no state

-- Crate and return sprite with collision from image
function createSpriteWithCollision(image)
    local w, h = image:getSize()
    local sprite = gfx.sprite.new( image )  
    sprite:setCenter( 0, 0 ) 

    sprite:setCollideRect( 0, 0, w, h )   
    sprite:add() 

    return sprite
end

function contains(collection, item)
    return table.indexOfElement(collection, item) ~= nil
end

