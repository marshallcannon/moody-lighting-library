local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Util = require(directory .. '/util')

local ImageHull = {}
ImageHull.__index = ImageHull

function ImageHull.new(world, x, y, image, width, height, stature)

  local self = setmetatable({}, ImageHull)

  self.world = world
  self.x = x or 0
  self.y = y or 0
  if type(image) == 'table' then
    self.image = image[1]
    self.quad = image[2]
  else
    self.image = image
  end
  --If you're using a quad you need to specify these dimensions
  self.width = width or self.image:getWidth()
  self.height = height or self.image:getHeight()
  self.stature = stature or self.image:getHeight()

  self.active = true

  return self

end

function ImageHull:setImage(image)

  if type(image) == 'table' then
    self.image = image[1]
    self.quad = image[2]
  else
    self.image = image
  end

end

function ImageHull:getCenter()

  return self.x, self.y

end

function ImageHull:destroy()

  Util.removeElementFromTable(self.world.imageHulls, self)
  self.world:setStaticStale(self)

end

return ImageHull
