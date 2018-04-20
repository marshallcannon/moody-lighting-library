local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')
local Util = require(directory .. '/util')

local Room = {}
Room.__index = Room

function Room.new(world, x, y, width, height)

  local self = setmetatable({}, Room)

  self.world = world
  self.x = x or 0
  self.y = y or 0
  self.width = width or 0
  self.height = height or 0

  self.lightCanvas = love.graphics.newCanvas(self.width, self.height)
  self.staticLightCanvas = love.graphics.newCanvas(self.width, self.height)

  self.debug = false

  return self

end

function Room:draw()

  local hulls, imageHulls, shadowTriangles, lightTriangles

  --Clear canvas
  love.graphics.setCanvas(self.lightCanvas)
  love.graphics.clear(self.world.ambient)

  --Draw each light
  love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(-self.x, -self.y)
    --Dynamic Lights
    for i, light in ipairs(self.world.lights) do

      if light.on and self:lightInRange(light) then

        --Basic Hulls
        hulls = Util.getHullsInRange(light, self.world.hulls)
        shadowTriangles, lightTriangles = Util.getShadowTriangles(light, hulls)
        love.graphics.setCanvas(self.lightCanvas)
        love.graphics.stencil(function()
          Util.drawHullShadows(shadowTriangles)
        end, 'replace', 1)
        love.graphics.stencil(function()
          Util.drawHullShadows(lightTriangles)
        end, 'replace', 0, true)

        --Image Hulls
        imageHulls = Util.getHullsInRange(light, self.world.imageHulls)
        love.graphics.stencil(function()
          love.graphics.setShader(Shaders.mask)
          for i, imageHull in ipairs(imageHulls) do
            local shadowLength = Util.getShadowLength(light, imageHull)/4
            local extendedPoint = Util.getExtendedPoint(light.x, light.y, imageHull.x, imageHull.y, shadowLength)
            local xLength, yLength = extendedPoint.x-imageHull.x, extendedPoint.y-imageHull.y
            local lightAngle = math.deg(Util.angle(light.x, light.y, imageHull.x, imageHull.y))
            -- love.graphics.polygon('fill', imageHull.x, imageHull.y, imageHull.x, imageHull.y-imageHull.height,
            -- extendedPoint.x, extendedPoint.y)
            -- love.graphics.draw(imageHull.canvas, imageHull.x, imageHull.y-imageHull.height/2, Util.angle(light.x, light.y, imageHull.x, imageHull.y)+math.rad(90),
            -- 1, shadowLength/imageHull.image:getHeight(), imageHull.width/4, imageHull.height)
            love.graphics.draw(imageHull.image, imageHull.x, imageHull.y,
            0, 1, (yLength/imageHull.image:getHeight())*-1, imageHull.image:getWidth()/2, imageHull.image:getHeight(), (xLength/imageHull.width)*-1, 0)
          end
          love.graphics.setShader()
        end, 'replace', 1, true)
        love.graphics.stencil(function()
          love.graphics.setShader(Shaders.mask)
          for i, imageHull in ipairs(imageHulls) do
            love.graphics.draw(imageHull.image, imageHull.x, imageHull.y,
            0, 1, 1, imageHull.image:getWidth()/2, imageHull.image:getHeight())
          end
          love.graphics.setShader()
        end, 'replace', 0, true)

        --Draw light
        love.graphics.setStencilTest('less', 1)
        light:draw(self.lightCanvas)
        love.graphics.setStencilTest()
        
        --SHADOW DEBUG
        -- love.graphics.push()
        -- love.graphics.setCanvas()
        -- for i, triangle in ipairs(shadowTriangles) do
        --   love.graphics.setColor(love.math.random(100, 255), love.math.random(100, 255), love.math.random(100, 255))
        --   love.graphics.polygon('fill', triangle)
        -- end
        -- for i, triangle in ipairs(shadowTriangles) do
        --   love.graphics.setColor(255, 0, 0)
        --   love.graphics.points(triangle)
        -- end
        -- love.graphics.pop()

      end

    end

    --Static lights
    -- if self.world.staticStale == true then
    --   love.graphics.setCanvas(self.staticLightCanvas)
    --   love.graphics.clear()
    --   for i, light in ipairs(self.staticLights) do
    --     if light.on then
    --       light:draw()
    --     end
    --   end
    --   self.world.staticStale = false
    -- end

    --Draw static light canvas to light canvas
    -- love.graphics.setCanvas(self.lightCanvas)
    -- love.graphics.setBlendMode('add', 'premultiplied')
    -- love.graphics.draw(self.staticLightCanvas)

  love.graphics.pop()

  --Draw light canvas
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setBlendMode('multiply', 'premultiplied')
  love.graphics.draw(self.lightCanvas, self.x, self.y)
  love.graphics.setBlendMode('alpha')

end

function Room:lightInRange(light)

  local lightX, lightY = light.x, light.y-light.stature

  if lightX >= self.x and lightY >= self.y and lightX <= self.x+self.width and lightY <= self.y+self.height then
    return true
  else
    if Util.distanceToLine(lightX, lightY, self.x, self.y, self.x+self.width, self.y) <= light.range then
      return true
    elseif Util.distanceToLine(lightX, lightY, self.x+self.width, self.y, self.x+self.width, self.y+self.height) <= light.range then
      return true
    elseif Util.distanceToLine(lightX, lightY, self.x+self.width, self.y+self.height, self.x, self.y+self.height) <= light.range then
      return true
    elseif Util.distanceToLine(lightX, lightY, self.x, self.y+self.height, self.x, self.y) <= light.range then
      return true
    end
  end

  return false

end

return Room