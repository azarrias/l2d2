require 'libs.l2d2'

local mobile_os = (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local web_os = love.system.getOS() == 'Web'
local app_title = 'L2D2 test'
local font_size = 16
local r, g, b, a

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  
  love.window.setTitle(app_title)
  
  font = love.graphics.newFont(font_size)
  love.graphics.setFont(font)
  os_str = love.system.getOS()
  vmajor, vminor, vrevision, vcodename = love.getVersion()
  v_str = string.format("Love version: %d.%d.%d - %s", vmajor, vminor, vrevision, vcodename)
  
  -- this does nothing more than testing the converted color values with instance based functions
  local width, height = 32, 32
  local maxsprites = 10
  imageData = love.image.newImageData(width, height)
  image = love.graphics.newImage(imageData)
  spriteBatch = love.graphics.newSpriteBatch(image, maxsprites)
  spriteBatch:setColor(0.6, 0.6, 0.8)
  r, g, b, a = spriteBatch:getColor()
  
  -- testing the particle system
  particles = love.graphics.newParticleSystem(image)
  particles:setColors({1, 0.6, 0.6}, {1, 1, 1}, {0.1, 0.1, 0.2, 0})
  --particles:setColors(1, 0.6, 0.6, 1, 1, 1, 1, 1, 0.1, 0.1, 0.2, 0)
  c1, c2, c3, c4 = particles:getColors()
  
  -- testing the affected mesh methods
  mesh = love.graphics.newMesh({{0, 0}, {1, 0, 1, 1, 0.5, 0.4, 0.6}}, "fan", "dynamic")
  mesh:setVertex(1, 2, 2, 1, 1, 0.4, 0.1)
  --mesh = love.graphics.newMesh(1, "fan", "dynamic")
  x, y, u, v, r, g, b, a = mesh:getVertex(1)
end

function love.draw()
  love.graphics.setBackgroundColor(0, 0.1, 0)
  love.graphics.setColor({0.6, 0.2, 0.2, 1})
  r, g, b, a = love.graphics.getColor()
  love.graphics.rectangle('fill', 10, 10, 340, 74)
  r, g, b, a = love.graphics.getBackgroundColor()
  
  love.graphics.setColor(0.8, 0.8, 0.8)
  r, g, b, a = love.graphics.getColor()
  love.graphics.print(app_title, 20, 20)
  love.graphics.print("LÖVE Library Wrapper for Multiplatform", 20, 40)
  love.graphics.print("  and Version Compatibility", 20, 56)
  love.graphics.setColor(0.8, 0.6, 0.6)
  love.graphics.print("O.S.: " .. os_str, 10, 100)
  love.graphics.print(v_str, 10, 116)
end