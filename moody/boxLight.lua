local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')
local Light = require(directory .. '/light')
local Util = require(directory .. '/util')

local BoxLight = {}
BoxLight.__index = BoxLight

function BoxLight.new(world, mode, x, y, width, height, stature, color, castShadows)

    local self = setmetatable({}, BoxLight)

    self.type = 'BoxLight'
    self.world = world
    self.mode = mode
    self.x = x or 0
    self.y = y or 0
    self.stature = stature
    self.width = width or 32
    self.height = height or 32
    self.color = color or {255, 255, 255, 255}
    self.castShadows = castShadows or true
    self.on = true

    if self.width > self.height then self.range = self.width
    else self.range = self.height end

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
    if self.mode == 'static' then self.world:setStaticStale(self) end
end

function BoxLight:setIntensity(intensity)
    self.color[4] = intensity
    self:drawCanvas()
    if self.mode == 'static' then self.world:setStaticStale(self) end
end

function BoxLight:hullInRange(hull)
    if hull.points then
        local selfX, selfY = self.x-self.width/2, self.y-self.height/2
        if hull.p1.x < selfX + self.width and hull.p2.x > selfX and
        hull.p1.y < selfY + self.height and hull.p4.y > selfY then
            return true
        end
    else
        if hull.x > self.x and hull.x <= self.x+self.width and
        hull.y > self.y and hull.y <= self.y+self.height then
            return true
        end
    end
    return false
end

function BoxLight:destroy()

    if self.mode == 'static' then
      Util.removeElementFromTable(self.world.staticLights, self)
      self.world:setStaticStale(self)
    else
      Util.removeElementFromTable(self.world.lights, self)
    end
  
  end

return BoxLight