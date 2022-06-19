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

function firstWhere(collection, func)
    for _, item in ipairs(collection) do
        if (func(item)) then 
            return item 
        end
    end
    
    return nil
end 

function removeItem(collection, item)
    local i = table.indexOfElement(collection, item)
    if (i) then
        table.remove(collection, i)
    end
end
