import "CoreLibs/object"
import "CoreLibs/animation"

import "constants"

local gfx <const> = playdate.graphics

local cons = getConstants()

class('FuelUI').extends()

function FuelUI:init()
    FuelUI.super.init(self)

    local iconImage = gfx.image.new("images/thrust-level-icon.png")
    self.iconSprite = gfx.sprite.new(iconImage)
    self.iconSprite:setCenter(0, 0)
    self.iconSprite:add()
    self.x = 0
    self.y = 0

    return self
end

function FuelUI:moveTo(x, y)
    self.iconSprite:moveTo(x, y)
    self.x = x
    self.y = y
end

-- Fuel is 0 to 100
function FuelUI:update(amount)
    -- Use floor b/c no round in Lua
    -- Round to nearest 5
    local rounded = math.floor((amount/5) +0.5)*5

    gfx.getSystemFont():drawText(rounded, self.x + 18, self.y + 2)
end
