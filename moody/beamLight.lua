local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')
local Light = require(directory .. '/light')
local Util = require(directory .. '/util')

local BeamLight = {}
BeamLight.__index = BeamLight

function BeamLight.new(world, mode, x, y, stature, range, width, angle, color)

    local self = setmetatable({}, BeamLight)

    self.world = world
    self.mode = mode
    self.x = x or 0
    self.y = y or 0
    self.stature = stature
    self.range = range or 50
    self.width = width or 1.0472
    self.angle = angle or 0
    self.color = color or {255, 255, 255, 255}
    self.castShadows = false
    self.on = true

    self:drawCanvas()

    return self

end

setmetatable(BeamLight, Light)

function BeamLight:draw()

  local width, height = self.canvas:getDimensions()
  love.graphics.setColor(self.color)
  love.graphics.setBlendMode('alpha')
  love.graphics.setShader(Shaders.radialFade)
  love.graphics.draw(self.canvas, self.x, self.y-self.stature, self.angle, 1, 1, self.range, self.range)
  love.graphics.setShader()

end

function BeamLight:drawCanvas()

  love.graphics.push()
    love.graphics.origin()
    self.canvas = love.graphics.newCanvas(self.range*2, self.range*2)
    self.canvas:setFilter('linear')
    love.graphics.setCanvas(self.canvas)
      love.graphics.clear()
      love.graphics.setBlendMode('alpha')
      love.graphics.setColor(self.color)
      love.graphics.stencil(function()
        local point1 = Util.getExtendedPoint(self.range, self.range, self.range+1, self.range, self.range*1.5, self.width/2)
        local point2 = Util.getExtendedPoint(self.range, self.range, self.range+1, self.range, self.range*1.5, -self.width/2)
        love.graphics.polygon('fill', self.range, self.range, point1.x, point1.y, point2.x, point2.y)
      end, 'replace', 1)
      love.graphics.setStencilTest('equal', 1)
      love.graphics.circle('fill', self.range, self.range, self.range)
      love.graphics.setStencilTest()
    love.graphics.setCanvas()
  love.graphics.pop()

end

function BeamLight:setAngle(newAngle)
  self.angle = newAngle
  return self.angle
end

function BeamLight:rotate(angle)
  self.angle = self.angle + angle
  return self.angle
end

return BeamLight