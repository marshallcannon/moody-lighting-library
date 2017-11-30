local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')

local Light = {}
Light.__index = Light

function Light.new(x, y, range, color)

  local self = setmetatable({}, Light)

  self.x = x or 0
  self.y = y or 0
  self.range = range or 64
  self.color = color or {255, 255, 255}
  self.castShadows = false
  self.on = true

  self:drawCanvas()

  return self

end

function Light:draw()

  local width, height = self.canvas:getDimensions()
  love.graphics.setColor(self.color)
  love.graphics.setBlendMode('alpha')
  love.graphics.setShader(Shaders.radialFade)
  love.graphics.draw(self.canvas, self.x-width/2, self.y-height/2)
  love.graphics.setShader()

end

function Light:drawCanvas()

  self.canvas = love.graphics.newCanvas(self.range*2, self.range*2)
  love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.range, self.range, self.range)
  love.graphics.setCanvas()

end

function Light:setPosition(x, y)

  self.x = x
  self.y = y

end

function Light:move(x, y)

  self.x = self.x + x
  self.y = self.y + y

end

function Light:shouldCastShadows(value)

  self.castShadows = value

end

function Light:toggle(value)

  if value ~= nil then
    self.on = value
  else
    if self.on == true then self.on = false
    else self.on = true end
  end

end

return Light
