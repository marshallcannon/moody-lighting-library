local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')
local Util = require(directory .. '/util')

local Light = {}
Light.__index = Light

function Light.new(world, mode, x, y, stature, range, color, castShadows)

  local self = setmetatable({}, Light)

  self.type = 'Light'
  self.world = world
  self.mode = mode
  self.x = x or 0
  self.y = y or 0
  self.stature = stature
  self.range = range or 64
  self.color = color or {255, 255, 255, 255}
  self.castShadows = castShadows or true
  self.on = true

  self:drawCanvas()

  return self

end

function Light:draw()

  local width, height = self.canvas:getDimensions()
  love.graphics.setColor(self.color)
  love.graphics.setBlendMode('alpha')
  love.graphics.setShader(Shaders.radialFade)
  love.graphics.draw(self.canvas, self.x-width/2, self.y-height/2-self.stature)
  love.graphics.setShader()

end

function Light:drawCanvas()

  love.graphics.push()
    love.graphics.origin()
    self.canvas = love.graphics.newCanvas(self.range*2, self.range*2)
    love.graphics.setCanvas(self.canvas)
      love.graphics.clear()
      love.graphics.setBlendMode('alpha')
      love.graphics.setColor(self.color)
      love.graphics.circle('fill', self.range, self.range, self.range)
    love.graphics.setCanvas()
  love.graphics.pop()

end

function Light:setPosition(x, y)

  self.x = x
  self.y = y

end

function Light:move(x, y)

  self.x = self.x + x
  self.y = self.y + y

end

function Light:toggle(value)

  if value ~= nil then
    self.on = value
  else
    if self.on == true then self.on = false
    else self.on = true end
  end

  if self.mode == 'static' then
    self.world:setStaticStale(self)
  end

end

function Light:setColor(color)
  self.color = color or {255, 255, 255, 255}
  self:drawCanvas()
  if self.mode == 'static' then self.world.staticStale = true end
end

function Light:setIntensity(intensity)
  self.color[4] = intensity
  self:drawCanvas()
  if self.mode == 'static' then self.world.staticStale = true end
end

function Light:hullInRange(hull)

  if hull.points then
    for i, point in ipairs(hull.points) do
      if Util.distance(self.x, self.y, point.x, point.y) <= self.range then
        return true
      end
    end
  else
    if Util.distance(self.x, self.y-self.stature, hull.x, hull.y) <= self.range then
      return true
    end
  end

  return false

end

return Light
