local Util = {}

Util.distance = function(x1, y1, x2, y2)
  return ((x2-x1)^2+(y2-y1)^2)^0.5
end

Util.normalize = function(x, y)
  local l=(x*x+y*y)^.5
  if l==0 then
    return 0,0,0
  else
    return x/l,y/l,l
  end
end

Util.angle = function(x1, y1, x2, y2)
  return math.atan2(y2-y1, x2-x1)
end

return Util
