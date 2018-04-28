local directory = string.gsub(...,"%.","/") or ""
if string.len(directory) > 0 then directory = directory .. "/" end
local Light = require(directory .. 'light')
local BoxLight = require(directory .. 'boxLight')
local BeamLight = require(directory .. 'beamLight')
local Hull = require(directory .. 'hull')
local ImageHull = require(directory .. 'imageHull')
local Room = require(directory .. 'room')
local Util = require(directory .. 'util')
local Shaders = require(directory .. 'shaders')

local LightWorld = {}
LightWorld.__index = LightWorld

function LightWorld:new(width, height, ambient)

  local self = setmetatable({}, LightWorld)

  local windowWidth, windowHeight = love.window.getMode()
  self.width = width or windowWidth
  self.height = height or windowHeight
  self.ambient = ambient or {0, 0, 0}

  self.lights = {}
  self.staticLights = {}
  self.hulls = {}
  self.imageHulls = {}
  self.rooms = {}

  self.lightCanvas = love.graphics.newCanvas(self.width, self.height)
  self.staticLightCanvas = love.graphics.newCanvas(self.width, self.height)

  self.debug = false

  return self

end

function LightWorld:draw()

  --Clear canvas
  love.graphics.setCanvas(self.lightCanvas)
  love.graphics.clear(self.ambient)

  --Draw each light
  love.graphics.push()
    love.graphics.origin()
    --love.graphics.translate(-self.x, -self.y)
    --Dynamic Lights
    for i, light in ipairs(self.lights) do

      if light.on then

        if light.castShadows then

          self:drawShadowsToStencil(light, true)
          
        end
        
        --Draw light
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
    if self.staticStale == true then
      love.graphics.setCanvas(self.staticLightCanvas)
      love.graphics.clear()
      for i, light in ipairs(self.staticLights) do
        if light.on then
          if light.castShadows then self:drawShadowsToStencil(light) end
          light:draw()
          love.graphics.setStencilTest()
        end
      end
      self.staticStale = false
    end

    --Draw static light canvas to light canvas
    -- love.graphics.translate(self.x, self.y)
    love.graphics.setCanvas(self.lightCanvas)
    love.graphics.setBlendMode('add', 'premultiplied')
    love.graphics.draw(self.staticLightCanvas)

  love.graphics.pop()

  --Draw light canvas
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setBlendMode('multiply', 'premultiplied')
  love.graphics.draw(self.lightCanvas, self.x, self.y)
  love.graphics.setBlendMode('alpha')

end

function LightWorld:drawShadowsToStencil(light, drawImageHulls)

  local hulls, imageHulls, shadowTriangles, lightTriangles

  --Basic Hulls
  hulls = Util.getHullsInRange(light, self.hulls)
  shadowTriangles, lightTriangles = Util.getShadowTriangles(light, hulls)
  love.graphics.stencil(function()
    Util.drawHullShadows(shadowTriangles)
  end, 'replace', 1)
  love.graphics.stencil(function()
    Util.drawHullShadows(lightTriangles)
  end, 'replace', 0, true)

  if drawImageHulls then
    --Image Hulls
    imageHulls = Util.getHullsInRange(light, self.imageHulls)
    love.graphics.stencil(function()
      love.graphics.setShader(Shaders.mask)
      for i, imageHull in ipairs(imageHulls) do
        local shadowLength = Util.getShadowLength(light, imageHull)
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
  end

  love.graphics.setStencilTest('less', 1)

end

function LightWorld:newLight(mode, x, y, stature, range, color, castShadows)

  local newLight = Light.new(self, mode, x, y, stature, range, color, castShadows)
  if mode == 'dynamic' then
    table.insert(self.lights, newLight)
  else
    table.insert(self.staticLights, newLight)
    self:setStaticStale(newLight)
  end
  return newLight

end

function LightWorld:newBeamLight(mode, x, y, stature, range, width, angle, color, castShadows)

  local newLight = BeamLight.new(self, mode, x, y, stature, range, width, angle, color, castShadows)
  if mode == 'dynamic' then
    table.insert(self.lights, newLight)
  else
    table.insert(self.staticLights, newLight)
    self:setStaticStale(newLight)
  end
  return newLight

end

function LightWorld:newBoxLight(mode, x, y, width, height, stature, color, castShadows)

  local newLight = BoxLight.new(self, mode, x, y, width, height, stature, color, castShadows)
  if mode == 'dynamic' then
    table.insert(self.lights, newLight)
  else
    table.insert(self.staticLights, newLight)
    self:setStaticStale(newLight)
  end
  return newLight

end

function LightWorld:newHull(x, y, width, height, stature)

  local newHull = Hull.new(self, x, y, width, height, stature)
  table.insert(self.hulls, newHull)
  return newHull

end

function LightWorld:newImageHull(x, y, image, width, height, stature)

  local newHull = ImageHull.new(self, x, y, image, width, height, stature)
  table.insert(self.imageHulls, newHull)
  return newHull

end

function LightWorld:newRoom(x, y, width, height)

  local newRoom = Room.new(self, x, y, width, height)
  table.insert(self.rooms, newRoom)
  return newRoom

end

function LightWorld:setStaticStale(object)

  self.staticStale = true

  -- if object then

  --   for i, room in ipairs(self.rooms) do
  --     if room:objectInRange(object) then
  --       room.staticStale = true
  --     end
  --   end

  -- else

  --   for i, room in ipairs(self.rooms) do
  --     room.staticStale = true
  --   end

  -- end

end

return LightWorld
