local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')
local Light = require(directory .. '/light')

local BoxLight = {}
BoxLight.__index = BoxLight

function BoxLight.new(world, mode, x, y, stature, width, height, color)

    local self = setmetatable({}, BoxLight)

    self.world = world
    self.mode = mode
    self.x = x or 0
    self.y = y or 0
    self.stature = stature
    self.width = width or 32
    self.height = height or 32
    self.color = color or {255, 255, 255, 255}
    self.on = true

    self:drawCanvas()

    return self

end

setmetatable(BoxLight, Light)

function BoxLight:draw()
    
    local width, height = self.canvas:getDimensions()
    love.graphics.setColor(self.color)
    love.graphics.setBlendMode('alpha')
    love.graphics.setShader(Shaders.boxFade)
    love.graphics.draw(self.canvas, self.x-width/2, self.y-height/2-self.stature)
    love.graphics.setShader()

end

function BoxLight:drawCanvas()
    
    love.graphics.push()
        love.graphics.origin()
        self.canvas = love.graphics.newCanvas(self.width, self.height)
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear()
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(self.color)
        love.graphics.rectangle('fill', 0, 0, self.width, self.height)
        love.graphics.setCanvas()
    love.graphics.pop()

end

function BoxLight:setColor(color)
    self.color = color or {255, 255, 255, 255}
    self:drawCanvas()
    if self.mode == 'static' then self.world.staticStale = true end
end

function BoxLight:setIntensity(intensity)
    self.color[4] = intensity
    self:drawCanvas()
    if self.mode == 'static' then self.world.staticStale = true end
end

function BoxLight:hullInRange(hull)
    for i, point in ipairs(hull.points) do
        if math.abs(self.x - point.x) <= self.width/2 and math.abs(self.y - point.y) <= self.height/2 then
            return true
        end
    end
    return false
end

return BoxLight