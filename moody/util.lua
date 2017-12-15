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

--Gets point along vector at distance
Util.getExtendedPoint = function(x1, y1, x2, y2, distance, angleOffset)

  if not angleOffset then
    local x, y = Util.normalize(x2-x1, y2-y1)
    return {x=x1+x*distance, y=y1+y*distance}
  else
    local x, y = Util.normalize(x2-x1, y2-y1)
    local rotatedPoint = Util.rotatePoint(x, y, angleOffset)
    return {x=x1+rotatedPoint.x*distance, y=y1+rotatedPoint.y*distance}
  end

end

Util.rotatePoint = function(x, y, theta)
  return {x=x*math.cos(theta)-y*math.sin(theta), y=y*math.cos(theta)+x*math.sin(theta)}
end

return Util
