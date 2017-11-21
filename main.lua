Moody = require 'moody'

love.window.setMode(800, 600, {vsync=false, fullscreen=false})

local lightWorld = Moody:new()
lightWorld.debug = true

translateX = 0
translateY = 0

math.randomseed(os.time())
for i=1, 10 do

  local x, y, width, height
  x = math.random(100, 800)
  y = math.random(100, 600)
  width = math.random(10, 100)
  height = math.random(10, 100)
  lightWorld:newHull(x, y, width, height)

end

local testHull = lightWorld:newHull(100, 100, 100, 100)

local light = lightWorld:newLight(60, 50, 300)

function love.load()

  love.graphics.setBackgroundColor(100, 150, 200, 255)

  background = love.graphics.newImage('TileSet01.png')

end

function love.draw()

  love.graphics.translate(translateX, translateY)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(background)
  lightWorld:draw()
  love.graphics.setColor(100, 150, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

end

function love.update()

  light:setLocation(love.mouse.getX()-translateX, love.mouse.getY()-translateY)

  if love.keyboard.isDown('a') then
    translateX = translateX + 1
    lightWorld:translate(-1, 0)
  end
  if love.keyboard.isDown('d') then
    translateX = translateX - 1
    lightWorld:translate(1, 0)
  end
  if love.keyboard.isDown('w') then
    translateY = translateY + 1
    lightWorld:translate(0, -1)
  end
  if love.keyboard.isDown('s') then
    translateY = translateY - 1
    lightWorld:translate(0, 1)
  end


end

function love.mousepressed(x, y, button, isTouch)

  if button == 1 then
    lightWorld:newLight(x, y, 250, {255, 255, 255})
  end
  if button == 2 then
    light:toggle()
  end
  if button == 3 then
    testHull:toggle()
  end

end
