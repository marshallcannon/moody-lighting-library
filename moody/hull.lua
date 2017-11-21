local Hull = {}
Hull.__index = Hull

function Hull.new(x, y, width, height)

  local self = setmetatable({}, Hull)

  self.x = x or 0
  self.y = y or 0
  self.width = width or 16
  self.height = height or 16

  self.active = true

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

return Hull
