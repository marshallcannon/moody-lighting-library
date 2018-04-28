local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Util = require(directory .. '/util')

local ImageHull = {}
ImageHull.__index = ImageHull

function ImageHull.new(world, x, y, image, width, height, stature)

  local self = setmetatable({}, ImageHull)

  self.world = world
  self.x = x or 0
  self.y = y or 0
  self.image = image
  self.width = width or image:getWidth()
  self.height = height or image:getHeight()
  self.stature = stature or image:getHeight()

  self.canvas = love.graphics.newCanvas(self.width/2, self.height)
  love.graphics.setCanvas(self.canvas)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, self.width/2, self.height, 30, 30)
  love.graphics.setCanvas()

  self.active = true

  return self

end

function ImageHull:setImage(image)

  self.image = image

end

function ImageHull:getCenter()

  return self.x, self.y

end

function ImageHull:destroy()

  Util.removeElementFromTable(self.world.imageHulls, self)
  self.world:setStaticStale(self)

end

return ImageHull
