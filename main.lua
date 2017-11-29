Moody = require 'moody'

love.window.setMode(1920, 1080, {vsync=false, fullscreen=true})

local lightWorld = Moody:new(1920, 1080)
lightWorld.debug = true

translateX = 0
translateY = 0

-- math.randomseed(os.time())
-- for i=1, 20 do
--
--   local x, y, width, height
--   x = math.random(100, 1820)
--   y = math.random(100, 980)
--   width = math.random(10, 300)
--   height = math.random(10, 300)
--   lightWorld:newHull(x, y, width, height)
--
-- end

-- testHull = lightWorld:newHull(100, 100, 100, 100)
-- testHull.debug = true

lightWorld:newHull(200, 100, 80, 150)
lightWorld:newHull(1200, 200, 220, 180)
lightWorld:newHull(1100, 600, 200, 150)
lightWorld:newHull(100, 800, 250, 80)
lightWorld:newHull(800, 300, 100, 150)
lightWorld:newHull(650, 600, 300, 40)
lightWorld:newHull(800, 800, 100, 100)
lightWorld:newHull(1300, 900, 200, 100)
lightWorld:newHull(1000, 500, 50, 150)

local light = lightWorld:newLight(60, 50, 500)

function love.load()

  love.graphics.setBackgroundColor(0, 0, 0, 255)

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

  light:setPosition(love.mouse.getX()-translateX, love.mouse.getY()-translateY)

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

  lightWorld:translate(translateX, translateY)

end

function love.mousepressed(x, y, button, isTouch)

  if button == 1 then
    lightWorld:newLight(x-translateX, y-translateY, 500, {255, 255, 255})
  end
  if button == 2 then
    light:toggle()
  end
  if button == 3 then
    testHull:toggle()
  end

end
