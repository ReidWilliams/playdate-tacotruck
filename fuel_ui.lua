import "CoreLibs/object"
import "CoreLibs/animation"

local gfx <const> = playdate.graphics

local iconOffset <const> = 10 -- pixels
local totalIcons <const> = 5

-- Indicates thrust level

class('FuelUI').extends()

function FuelUI:init()
    FuelUI.super.init(self)

    self.icons = {}

    for i=1, totalIcons do
        self.icons[i] = ThrustIcon()
        self.icons[i]:setCenter(0, 0)
        self.icons[i]:add()
    end

    return self
end

function FuelUI:moveTo(x, y)
    for i=1, totalIcons do
        self.icons[i]:moveTo(x + ((i-1)*iconOffset), y)
    end
end

-- Fuel is 0 to 100
function FuelUI:update(amount)
    local discreteLevel = math.floor((amount / 20) + 0.5) -- no round in Lua
    for i=1, totalIcons do
        isFull = discreteLevel >= i
        self.icons[i]:isFull(isFull)
    end
end

class('ThrustIcon').extends(gfx.sprite)

function ThrustIcon:init()
    ThrustIcon.super.init(self)

    self.fullImage = gfx.image.new( "images/thrust-level-full.png" )
    self.emptyImage = gfx.image.new( "images/thrust-level-empty.png" )

    return self
end

function ThrustIcon:isFull(full)
    if full then
        self:setImage(self.fullImage)
    else
        self:setImage(self.emptyImage)
    end
end
