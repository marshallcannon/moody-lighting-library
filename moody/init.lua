local directory = string.gsub(...,"%.","/") or ""
if string.len(directory) > 0 then directory = directory .. "/" end
local Light = require(directory .. 'light')
local BoxLight = require(directory .. 'boxLight')
local Hull = require(directory .. 'hull')
local Util = require(directory .. 'util')
local Shaders = require(directory .. 'shaders')

--Local function declarations
local drawHullShadows, inLightRange, getShadowPoints, getExtendedPoint, getClosestPoint, getHullsInRange, drawPenumbras

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

  self.offsetX = 0
  self.offsetY = 0

  self.lightCanvas = love.graphics.newCanvas(self.width, self.height)
  self.staticLightCanvas = love.graphics.newCanvas(self.width, self.height)
  --self.penumbraCanvas = love.graphics.newCanvas()

  self.staticStale = true
  self.debug = false

  return self

end

function LightWorld:draw()

  local hulls, shadowPoints, penumbraPoints

  --Clear canvases
  love.graphics.setCanvas(self.lightCanvas)
  love.graphics.clear(self.ambient)
  -- love.graphics.setCanvas(self.penumbraCanvas)
  -- love.graphics.clear(0, 0, 0, 0)

  --Draw each light
  love.graphics.push()
    love.graphics.origin()
    --Dynamic Lights
    for i, light in ipairs(self.lights) do

      if light.on then

        hulls = getHullsInRange(light, self.hulls)
        --shadowPoints, penumbraPoints = getShadowPoints(light, hulls)
        shadowPoints = getShadowPoints(light, hulls)
        love.graphics.setCanvas(self.lightCanvas)
        love.graphics.stencil(function()
          drawHullShadows(shadowPoints)
        end, 'replace', 1)
        love.graphics.setStencilTest('less', 1)
        light:draw(self.lightCanvas, self.offsetX, self.offsetY)
        love.graphics.setStencilTest()
        -- love.graphics.setCanvas(self.penumbraCanvas)
        -- love.graphics.setColor(255, 255, 255, 255)
        -- drawPenumbras(penumbraPoints)

      end

    end

    --Static lights
    if self.staticStale == true then
      love.graphics.setCanvas(self.staticLightCanvas)
      love.graphics.clear()
      for i, light in ipairs(self.staticLights) do
        if light.on then
          light:draw()
        end
      end
      self.staticStale = false
    end

    --Draw static light canvas to light canvas
    love.graphics.setCanvas(self.lightCanvas)
    love.graphics.setBlendMode('add', 'premultiplied')
    love.graphics.draw(self.staticLightCanvas)

  love.graphics.pop()

  --Draw penumbra canvas to light canvas
  -- love.graphics.setShader(Shaders.blur)
  -- love.graphics.setCanvas(self.lightCanvas)
  -- love.graphics.draw(self.penumbraCanvas)
  -- love.graphics.setShader()

  

  --Draw light canvas
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setBlendMode('multiply', 'premultiplied')
  love.graphics.draw(self.lightCanvas)
  love.graphics.setBlendMode('alpha')


  if self.debug then
    --Debug draw hulls
    for i, hull in ipairs(self.hulls) do
      love.graphics.setColor(100, 100, 100, 255)
      love.graphics.rectangle('line', hull.x, hull.y, hull.width, hull.height)
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.points(hull.p1.x, hull.p1.y, hull.p2.x, hull.p2.y, hull.p3.x, hull.p3.y, hull.p4.x, hull.p4.y)
    end
  end

end

function LightWorld:newLight(mode, x, y, range, color)

  local newLight = Light.new(self, mode, x, y, range, color)
  if mode == 'dynamic' then
    table.insert(self.lights, newLight)
  else
    table.insert(self.staticLights, newLight)
    self.staticStale = true
  end
  return newLight

end

function LightWorld:newBoxLight(mode, x, y, width, height, color)

  local newLight = BoxLight.new(self, mode, x, y, width, height, color)
  if mode == 'dynamic' then
    table.insert(self.lights, newLight)
  else
    table.insert(self.staticLights, newLight)
    self.staticStale = true
  end
  return newLight

end

function LightWorld:newHull(x, y, width, height)

  local newHull = Hull.new(world, x, y, width, height)
  table.insert(self.hulls, newHull)
  return newHull

end

--local functions
drawHullShadows = function(shadowPoints)

  for i, shadow in ipairs(shadowPoints) do

    local splitCoordinates = {}
    if table.getn(shadow) > 0 then
      --Split the vertices
      for i, vertex in ipairs(shadow) do
        table.insert(splitCoordinates, vertex.x)
        table.insert(splitCoordinates, vertex.y)
      end
      --Draw the shadow
      love.graphics.polygon('fill', splitCoordinates)
    end

  end

end

drawPenumbras = function(penumbras)

  for i, penumbra in ipairs(penumbras) do

    local splitCoordinates = {}
    local splitCoordinates2 = {}
    if table.getn(penumbra) == 6 then
      --Split the vertices
      for i, vertex in ipairs(penumbra) do
        if i <= 3 then
          table.insert(splitCoordinates, vertex.x)
          table.insert(splitCoordinates, vertex.y)
        else
          table.insert(splitCoordinates2, vertex.x)
          table.insert(splitCoordinates2, vertex.y)
        end
      end
      --Draw the penumbra
      love.graphics.polygon('fill', splitCoordinates)
      love.graphics.polygon('fill', splitCoordinates2)
    end

  end

end

getHullsInRange = function(light, hulls)

  local hullsInRange = {}

  for i, hull in ipairs(hulls) do
    if hull.active and light:hullInRange(hull) then
      table.insert(hullsInRange, hull)
    end
  end

  return hullsInRange

end

getShadowPoints = function(light, hulls)

  local shadowPoints = {}
  local penumbraPoints = {}

  for i, hull in ipairs(hulls) do

    local insideVertically, insideHorizontally
    local anchorPoints = {}

    --Determine if in line or diagonal to hull
    if light.x >= hull.x and light.x <= hull.x + hull.width then
      insideVertically = true
    end
    if light.y  >= hull.y and light.y <= hull.y + hull.height then
      insideHorizontally = true
    end

    --Light is inside hull
    if insideVertically and insideHorizontally then
      --Don't check this hull
    --Light is directly above or below
    elseif insideVertically then
      --Directly above
      if light.y < hull.y then
        anchorPoints = {hull.p1, hull.p2}
      --Directly below
      else
        anchorPoints = {hull.p3, hull.p4}
      end
    --Light is directly right or left
    elseif insideHorizontally then
      --Directly left
      if light.x < hull.x then
        anchorPoints = {hull.p4, hull.p1}
      --Directly right
      else
        anchorPoints = {hull.p2, hull.p3}
      end
    --Light is on a corner
    else

      local closestPoint = getClosestPoint(light, hull)

      if closestPoint == hull.p1 then
        anchorPoints = {hull.p2, hull.p4}
      elseif closestPoint == hull.p2 then
        anchorPoints = {hull.p3, hull.p1}
      elseif closestPoint == hull.p3 then
        anchorPoints = {hull.p2, hull.p4}
      elseif closestPoint == hull.p4 then
        anchorPoints = {hull.p1, hull.p3}
      else
        print('No Anchor Point')
      end

    end

    if #anchorPoints > 0 then
      local umbra = {}
      local penumbra = {}
      local closestPoint = getClosestPoint(light, hull)
      local lightSize = light.range or light.width + light.height

      --Get main shadow polygon
      table.insert(umbra, anchorPoints[1])
      table.insert(umbra, anchorPoints[2])
      table.insert(umbra, getExtendedPoint(light.x, light.y, anchorPoints[2].x, anchorPoints[2].y, lightSize*1.5))
      table.insert(umbra, getExtendedPoint(light.x, light.y, anchorPoints[1].x, anchorPoints[1].y, lightSize*1.5))
      table.insert(umbra, 4, getExtendedPoint(light.x, light.y, (umbra[3].x+umbra[4].x)/2, (umbra[3].y+umbra[4].y)/2, lightSize*1.5))
      table.insert(umbra, 2, closestPoint)

      --Get penumbra polygons
      -- table.insert(penumbra, anchorPoints[1])
      -- table.insert(penumbra, getExtendedPoint(light.x, light.y, anchorPoints[1].x, anchorPoints[1].y, light.range*1.5))
      -- table.insert(penumbra, getExtendedPoint(light.x, light.y, anchorPoints[1].x, anchorPoints[1].y, light.range*1.5, -0.17))
      -- table.insert(penumbra, anchorPoints[2])
      -- table.insert(penumbra, getExtendedPoint(light.x, light.y, anchorPoints[2].x, anchorPoints[2].y, light.range*1.5))
      -- table.insert(penumbra, getExtendedPoint(light.x, light.y, anchorPoints[2].x, anchorPoints[2].y, light.range*1.5, 0.17))

      --Add new shadows
      table.insert(shadowPoints, umbra)
      --table.insert(penumbraPoints, penumbra)

    end

  end

  --return shadowPoints, penumbraPoints
  return shadowPoints

end

--Gets point along vector at distance
getExtendedPoint = function(x1, y1, x2, y2, distance, angleOffset)

  if not angleOffset then
    local x, y = Util.normalize(x2-x1, y2-y1)
    return {x=x1+x*distance, y=y1+y*distance}
  else
    local x, y = Util.normalize(x2-x1, y2-y1)
    --local distance = Util.distance(x1, y1, x2, y2)
    local angle = Util.angle(x1, y1, x2, y2)
    return {x=x1+x*distance*math.cos(angleOffset), y=y1+y*distance*math.sin(angleOffset)}
  end

end

getClosestPoint = function(light, hull)

  local closestPoint = nil
  for i, point in ipairs(hull.points) do
    if closestPoint then
      if Util.distance(light.x, light.y, point.x, point.y) < Util.distance(light.x, light.y, closestPoint.x, closestPoint.y) then
        closestPoint = point
      end
    else
      closestPoint = point
    end
  end

  return closestPoint

end

return LightWorld
