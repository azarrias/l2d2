local l2d2 = { graphics = {} }

-- Workaround to support love.js 0.11.0-rc3 which is a pre-release of v11
--local love11 = love.getVersion() == 11
local love11 = love._version_major == 11 or love._version_major == 0 and love._version_minor == 11

local function round(n)
  return math.floor(n + 0.5)
end

local _clear
local _getBackgroundColor, _getColor
local _setBackgroundColor, _setColor

-- Converts color values from 0-1 range to 0-255
local function normalizedToByte(table)
  if #table == 1 and type(table[1]) == 'table' then
    table = { unpack(table[1]) }
  end
  
  for i, v in ipairs(table) do
    table[i] = round(v * 255)
  end
  
  return table
end

-- Converts color values from 0-255 range to 0-1
local function byteToNormalized(table)
  if #table == 1 and type(table[1]) == 'table' then
    table = { unpack(table[1]) }
  end
  
  for i, v in ipairs(table) do
    table[i] = v / 255
  end
  
  return table
end

local function overrideGetColor(vanilla, func)
  vanilla = func
  return function()
    local r, g, b, a = vanilla()
    local t = byteToNormalized({r, g, b, a})
    return t
  end
end

local function overrideSetColor(vanilla, func)
  vanilla = func
  return function(...)
    local args = {...}
    args = normalizedToByte(args)
    vanilla(unpack(args))
  end
end

if not love11 then
  love.graphics.clear = overrideSetColor(_clear, love.graphics.clear)
  love.graphics.getBackgroundColor = overrideGetColor(_getBackgroundColor, love.graphics.getBackgroundColor)
  love.graphics.getColor = overrideGetColor(_getColor, love.graphics.getColor)
  love.graphics.setBackgroundColor = overrideSetColor(_setBackgroundColor, love.graphics.setBackgroundColor)
  love.graphics.setColor = overrideSetColor(_setColor, love.graphics.setColor)
end
