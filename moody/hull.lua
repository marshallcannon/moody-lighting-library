local Hull = {}
Hull.__index = Hull

function Hull.new(world, x, y, width, height, stature)

  local self = setmetatable({}, Hull)

  self.type = 'Hull'
  self.world = world
  self.x = x or 0
  self.y = y or 0
  self.width = width or 16
  self.height = height or 16
  self.stature = stature or 0

  self.active = true
  self.transparent = false

  self.p1 = {x = self.x, y = self.y}
  self.p2 = {x = self.x+self.width, y = self.y}
  self.p3 = {x = self.x+self.width, y = self.y+self.height}
  self.p4 = {x = self.x, y = self.y+self.height}
  self.points = {self.p1, self.p2, self.p3, self.p4}

  return self

end

function Hull:toggle(value)

  if value ~= nil then
    self.active = value
  else
    if self.active then self.active = false
    else self.active = true end
  end

end

function Hull:setTransparent(value)

  if self.transparent ~= value then
    self.transparent = value
    self.world:setStaticStale(self)
  end

end

--Move to an absolute position
function Hull:setPosition(x, y)

  self.x = x
  self.y = y
  self.p1.x = self.x; self.p1.y = self.y
  self.p2.x = self.x+self.width; self.p2.y = self.y
  self.p3.x = self.x+self.width; self.p3.y = self.y+self.height
  self.p4.x = self.x; self.p4.y = self.y+self.height

end

--Move by an amount
function Hull:move(x, y)

  self.x = self.x + x
  self.y = self.y + y
  self.p1.x = self.x; self.p1.y = self.y
  self.p2.x = self.x+self.width; self.p2.y = self.y
  self.p3.x = self.x+self.width; self.p3.y = self.y+self.height
  self.p4.x = self.x; self.p4.y = self.y+self.height

end

function Hull:getCenter()

  return self.x+self.width/2, self.y+self.height/2

end

return Hull
