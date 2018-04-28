Moody = require 'moody'
Piefiller = require 'piefiller'
Pie = Piefiller:new()

love.window.setMode(800, 600, {vsync=false, fullscreen=false})

local lightWorld = Moody:new(800, 600, {50, 50, 50})
--lightWorld.debug = true

translateX = 0
translateY = 0

lightX, lightY = 200, 200
mouseX, mouseY = 0, 0
wallOpacity = 255

math.randomseed(os.time())
-- for i=1, 20 do

--   local x, y, width, height
--   x = math.random(100, 1820)
--   y = math.random(100, 980)
--   width = math.random(10, 300)
--   height = math.random(10, 300)
--   lightWorld:newHull(x, y, width, height)

-- end

-- testHull = lightWorld:newHull(100, 100, 100, 100)
-- testHull.debug = true

local light = lightWorld:newBeamLight('dynamic', 60, 50, 36, 200, math.rad(45), math.rad(180), {255, 255, 255}, true)

local wall1 = lightWorld:newHull(100, 290, 250, 20, 80)
local wall2 = lightWorld:newHull(450, 290, 250, 20, 80)
local smallBox = lightWorld:newHull(300, 100, 20, 20, 20)


local room1 = lightWorld:newRoom(100, 0, 600, 300)
local room2 = lightWorld:newRoom(100, 300, 600, 300)

testPoint = {x=0,y=0}

function love.load()

  love.graphics.setBackgroundColor(0, 0, 0, 255)

  background = love.graphics.newImage('TileSet01.png')
  frog = love.graphics.newImage('frog.png')
  player = love.graphics.newImage('player.png')

  imageHull = lightWorld:newImageHull(400, 100, frog, 32, 16)
  imageHull2 = lightWorld:newImageHull(500, 150, player)

end

function love.draw()
  
  --Pie:attach()

  --Floor
  love.graphics.translate(translateX, translateY)
  love.graphics.setColor(232, 65, 27, 255)
  love.graphics.rectangle('fill', 100, 0, 600, 290)
  love.graphics.setColor(175, 175, 175, 255)
  love.graphics.rectangle('fill', 100, 290, 600, 20)
  love.graphics.setColor(27, 232, 116, 255)
  love.graphics.rectangle('fill', 100, 310, 600, 290)
  
  --Walls
  love.graphics.setColor(56, 56, 56, wallOpacity)
  love.graphics.rectangle('fill', 100, 210, 250, 100)
  love.graphics.rectangle('fill', 450, 210, 250, 100)

  --Frog
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(frog, imageHull.x, imageHull.y, 0, 1, 1, frog:getWidth()/2, frog:getHeight())

  --Player
  love.graphics.draw(player, imageHull2.x, imageHull2.y, 0, 1, 1, player:getWidth()/2, player:getHeight())

  --Small Box
  love.graphics.setColor(41, 89, 165)
  love.graphics.rectangle('fill', 300, 100, 20, 20)
  love.graphics.setColor(67, 125, 219)
  love.graphics.rectangle('fill', 300, 80, 20, 20)

  --Avatar
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('fill', lightX, lightY, 5)
  
  --Lights
  lightWorld:draw()
  --room1:draw()
  --room2:draw()

  --Info
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  love.graphics.print('Light stature: '..tostring(light.stature), 10, 20)

  --Pie:detach()
  
end

function love.update()

  mouseX, mouseY = love.mouse.getPosition()

  if love.keyboard.isDown('f') then
    testHull:setPosition(500, 500)
  end
  if love.keyboard.isDown('r') then
    testHull:setPosition(100, 100)
  end

  if love.keyboard.isDown('a') then
    translateX = translateX + 1
  end
  if love.keyboard.isDown('d') then
    translateX = translateX - 1
  end
  if love.keyboard.isDown('w') then
    translateY = translateY + 1
  end
  if love.keyboard.isDown('s') then
    translateY = translateY - 1
  end
  
  if love.keyboard.isDown('left') then
    lightX = lightX - 0.5
  end
  if love.keyboard.isDown('right') then
    lightX = lightX + 0.5
  end
  if love.keyboard.isDown('up') then
    lightY = lightY - 0.5
  end
  if love.keyboard.isDown('down') then
    lightY = lightY + 0.5
  end

  if love.keyboard.isDown('z') then
    light.stature = light.stature - 0.1
  elseif love.keyboard.isDown('x') then
    light.stature = light.stature + 0.1
  end

  light:setPosition(lightX, lightY)
  light:setAngle(-math.atan2(mouseX-lightX, mouseY-lightY)+math.rad(90))

  if lightY < 310 then
    wallOpacity = 100
    wall1:setTransparent(true)
    wall2:setTransparent(true)
  else
    wallOpacity = 255
    wall1:setTransparent(false)
    wall2:setTransparent(false)
  end

end

function love.mousepressed(x, y, button, isTouch)

  if button == 1 then
    lightWorld:newLight('static', x-translateX, y-translateY, 50, 200, {255, 255, 255})
  end
  if button == 2 then
    boxLight = lightWorld:newBoxLight('static', x-translateX, y-translateY, 300, 250, 50, {255, 255, 255})
  end
  if button == 3 then
    boxLight:setIntensity(100)
  end

end

function love.keypressed(key)

  Pie:keypressed(key)

  if key == 'delete' then
    imageHull:destroy()
  end

end
