require 'libs.l2d2'

local MOBILE_OS = (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local WEB_OS = love.system.getOS() == 'Web'
local APP_TITLE = 'L2D2 test'
local FONT_SIZE = 16

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  
  love.window.setTitle(APP_TITLE)
  
  font = love.graphics.newFont(FONT_SIZE)
  love.graphics.setFont(font)
  os_str = love.system.getOS()
  vmajor, vminor, vrevision, vcodename = love.getVersion()
  v_str = string.format("Love version: %d.%d.%d - %s", vmajor, vminor, vrevision, vcodename)
end

function love.draw()
  love.graphics.setColor({0.8, 0.2, 0.2, 1})
  r, g, b, a = love.graphics.getColor()
  love.graphics.rectangle('fill', 10, 10, 340, 74)
  r, g, b, a = love.graphics.getBackgroundColor()
  
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(APP_TITLE, 20, 20)
  love.graphics.print("LÖVE Library Wrapper for Multiplatform", 20, 40)
  love.graphics.print("  and Version Compatibility", 20, 56)
  love.graphics.setColor(0.8, 0.6, 0.6)
  love.graphics.print("O.S.: " .. os_str, 10, 100)
  love.graphics.print(v_str, 10, 116)

end