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

--Gets point along vector at distance. Cannot be shorter that distance between points.
Util.getExtendedPoint = function(x1, y1, x2, y2, distance, angleOffset)

  local pointDistance = Util.distance(x1, y1, x2, y2)
  if pointDistance > distance then
    distance = pointDistance+1
  end

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

Util.getHullsInRange = function(light, hulls)

  local hullsInRange = {}

  for i, hull in ipairs(hulls) do
    if hull.active and light:hullInRange(hull) then
      table.insert(hullsInRange, hull)
    end
  end

  return hullsInRange

end

Util.drawHullShadows = function(shadowTriangles)

  for i, triangle in ipairs(shadowTriangles) do
    if #triangle > 0 then
      love.graphics.polygon('fill', triangle)
    end
  end

end

Util.getShadowTriangles = function(light, hulls)

  local shadowTriangles, lightTriangles = {}, {}

  for i, hull in ipairs(hulls) do

    local shadowShapes, lightShapes = Util.getShadowShapes(light, hull)

    if shadowShapes then
      for i, shadowShape in ipairs(shadowShapes) do
        local splitCoordinates = Util.splitCoordinates(shadowShape)
        local triangles = love.math.triangulate(splitCoordinates)
        for i, triangle in ipairs(triangles) do
          table.insert(shadowTriangles, triangle)
        end
      end
    end
    if lightShapes then
      for i, lightShape in ipairs(lightShapes) do
        local splitCoordinates = Util.splitCoordinates(lightShape)
        local triangles = love.math.triangulate(splitCoordinates)
        for i, triangle in ipairs(triangles) do
          table.insert(lightTriangles, triangle)
        end
      end
    end

  end

  return shadowTriangles, lightTriangles

end

Util.getShadowShapes = function(light, hull)

  local limitShadow

  --If the light is higher than the hull is tall
  if light.stature and hull.stature and light.stature > hull.stature then
    limitShadow = true
  end

  local lightRelativePosition = Util.getLightRelativePosition(light, hull)
  local basePoints, extendedPoints, lightPoints = {}, {}, {}
  local addCorner = false

  if lightRelativePosition == 'n' then
    basePoints[1] = {hull.p1, hull.p2}
    extendedPoints[1] = {hull.p2, hull.p1}
  elseif lightRelativePosition == 'e' then
    basePoints[1] = {hull.p2, hull.p3}
    extendedPoints[1] = {hull.p3, hull.p2}
  elseif lightRelativePosition == 's' then
    basePoints[1] = {hull.p3, hull.p4}
    extendedPoints[1] = {hull.p4, {x=hull.p4.x+hull.width/2, y=hull.p4.y}, hull.p3}
    lightPoints[1] = {hull.p3, hull.p4, {x=hull.p4.x, y=hull.p4.y-hull.stature}, {x=hull.p3.x, y=hull.p3.y-hull.stature}}
  elseif lightRelativePosition == 'w' then
    basePoints[1] = {hull.p4, hull.p1}
    extendedPoints[1] = {hull.p1, hull.p4}
  elseif lightRelativePosition == 'ne' then
    basePoints[1] = {hull.p1, hull.p4, hull.p3}
    extendedPoints[1] = {hull.p3, hull.p4, hull.p1}
    basePoints[1].addCorner = true
  elseif lightRelativePosition == 'se' then
    basePoints[1] = {hull.p4, hull.p1, hull.p2}
    extendedPoints[1] = {hull.p2, hull.p1, hull.p4}
    lightPoints[1] = {hull.p3, hull.p4, {x=hull.p4.x, y=hull.p4.y-hull.stature}, {x=hull.p3.x, y=hull.p3.y-hull.stature}}
  elseif lightRelativePosition == 'sw' then
    basePoints[1] = {hull.p1, hull.p2, hull.p3}
    extendedPoints[1] = {hull.p3, hull.p2, hull.p1}
    lightPoints[1] = {hull.p3, hull.p4, {x=hull.p4.x, y=hull.p4.y-hull.stature}, {x=hull.p3.x, y=hull.p3.y-hull.stature}}
  elseif lightRelativePosition == 'nw' then
    basePoints[1] = {hull.p2, hull.p3, hull.p4}
    extendedPoints[1] = {hull.p4, hull.p3, hull.p2}
    basePoints[1].addCorner = true
  elseif lightRelativePosition == 'inside' then
    basePoints[1] = {}
    extendedPoints[1] = {{x=hull.p1.x, y=hull.p1.y-hull.stature}, {x=hull.p2.x, y=hull.p2.y-hull.stature}, {x=hull.p3.x, y=hull.p3.y-hull.stature}, {x=hull.p4.x, y=hull.p4.y-hull.stature}}
    lightPoints[1] = {hull.p1, hull.p2, hull.p3, hull.p4}
  elseif lightRelativePosition == 'covered' then
    basePoints[1] = {{x=light.x-light.range, y=light.y-light.range}, {x=light.x+light.range, y=light.y-light.range}, {x=light.x+light.range, y=light.y+light.range}, {x=light.x-light.range, y=light.y+light.range}}
  end

  --Show/Hide the top of the hull
  if limitShadow then
    table.insert(lightPoints, {{x=hull.p1.x, y=hull.p1.y-hull.stature}, {x=hull.p2.x, y=hull.p2.y-hull.stature}, {x=hull.p3.x, y=hull.p3.y-hull.stature}, {x=hull.p4.x, y=hull.p4.y-hull.stature}})
  else
    table.insert(basePoints, {{x=hull.p1.x, y=hull.p1.y-hull.stature}, {x=hull.p2.x, y=hull.p2.y-hull.stature}, {x=hull.p3.x, y=hull.p3.y-hull.stature}, {x=hull.p4.x, y=hull.p4.y-hull.stature}})
  end

  if #basePoints > 0 then
    local umbras = {}
    local lightAreas = {}
    local shadowLength
    -- if limitShadow then
    --   shadowLength = 500
    -- else
      shadowLength = light.range or light.width + light.height
      shadowLength = shadowLength*3
    -- end

    --Get Shadow Polygon
    for i, bPoints in ipairs(basePoints) do
      local shape = {}
      for j, shadowPoint in ipairs(bPoints) do
        table.insert(shape, shadowPoint)
      end
      if extendedPoints[i] then
        for k, extendedPoint in ipairs(extendedPoints[i]) do
          table.insert(shape, Util.getExtendedPoint(light.x, light.y, extendedPoint.x, extendedPoint.y, shadowLength))
        end
      end
      
      if bPoints.addCorner then
        shape[2] = Util.getClosestPoint(light, hull)
      end

      table.insert(umbras, shape)
    end

    for i, lPoints in ipairs(lightPoints) do
      local shape = {}
      for j, lightPoint in ipairs(lPoints) do
        table.insert(shape, lightPoint)
      end
      table.insert(lightAreas, shape)
    end

    return umbras, lightAreas

  end

end

Util.getLightRelativePosition = function(light, hull)

  local insideVertically, insideHorizontally = false, false

  --Determine if in line or diagonal to hull
  if light.x >= hull.x and light.x <= hull.x + hull.width then
    insideVertically = true
  end
  if light.y  >= hull.y and light.y <= hull.y + hull.height then
    insideHorizontally = true
  end

  --If the light is inside hull bounds
  if insideVertically and insideHorizontally then
    --If it's higher than the hull
    if light.stature and hull.stature and light.stature > hull.stature then
      --Cast shadows in all directions
      return 'above'
    else
      return 'covered'
    end
    --Otherwise do nothing
  --Light is directly above or below
  elseif insideVertically then
    --Directly above
    if light.y < hull.y then
      return 'n'
    --Directly below
    else
      return 's'
    end
  --Light is directly right or left
  elseif insideHorizontally then
    --Directly left
    if light.x < hull.x then
      return 'w'
    --Directly right
    else
      return 'e'
    end
  --Light is on a corner
  else

    local closestPoint = Util.getClosestPoint(light, hull)

    if closestPoint == hull.p1 then
      return 'nw'
    elseif closestPoint == hull.p2 then
      return 'ne'
    elseif closestPoint == hull.p3 then
      return 'se'
    elseif closestPoint == hull.p4 then
      return 'sw'
    else
      print('No Anchor Point for Shadow')
    end

  end

end

Util.getClosestPoint = function(light, hull)

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

Util.splitCoordinates = function(coordinates)

  local splitCoordinates = {}

  for i, coordinate in ipairs(coordinates) do
    table.insert(splitCoordinates, coordinate.x)
    table.insert(splitCoordinates, coordinate.y)
  end

  return splitCoordinates

end

return Util
