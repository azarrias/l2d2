-- Workaround to support love.js 0.11.0-rc3 which is a pre-release of v11
--local love11 = love.getVersion() == 11
local love11 = love._version_major == 11 or love._version_major == 0 and love._version_minor == 11

local function round(n)
  return math.floor(n + 0.5)
end

function overrideGetColor(func)
  local _vanilla = func
  return function()
    local r, g, b, a = _vanilla()
    return round(r / 255), round(g / 255), round(b / 255), round(a / 255)
  end
end

if not love11 then
  love.graphics.getBackgroundColor = overrideGetColor(love.graphics.getBackgroundColor)
  love.graphics.getColor = overrideGetColor(love.graphics.getColor)
end
  
love.graphics.vanillaSetColor = love.graphics.setColor

function love.graphics.setColor(...)
  local arg = {...}
  
  if #arg == 1 and type(arg[1]) == 'table' then
    arg = { unpack(arg[1]) }
  end
  
  if not love11 then
    for i, v in pairs(arg) do
      arg[i] = v * 255
    end
  end
  
  love.graphics.vanillaSetColor(arg)
end

