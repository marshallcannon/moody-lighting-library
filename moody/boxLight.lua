local directory = (...):match("^(.+)[%./][^%./]+") or ""
local Shaders = require(directory .. '/shaders')
local Light = require(directory .. '/light')

local BoxLight = {}
BoxLight.__index = BoxLight

function BoxLight.new(x, y, width, height, color)

    local self = setmetatable({}, BoxLight)

    self.x = x or 0
    self.y = y or 0
    self.width = width or 32
    self.height = height or 32
    self.color = color or {255, 255, 255}
    self.castShadows = false
    self.on = true

    return self

end

setmetatable(BoxLight, Light)

function Light:draw()
    
    local width, height = self.canvas:getDimensions()
    love.graphics.setColor(self.color)
    love.graphics.setBlendMode('alpha')
    love.graphics.setShader(Shaders.radialFade)
    love.graphics.draw(self.canvas, self.x-width/2, self.y-height/2)
    love.graphics.setShader()

end