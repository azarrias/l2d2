-- Workaround to support love.js 0.11.0-rc3 which is a pre-release of v11
--local love11 = love.getVersion() == 11
local love11 = love._version_major == 11 or love._version_major == 0 and love._version_minor == 11

local function round(n)
  return math.floor(n + 0.5)
end

local reg = debug.getregistry()
local SpriteBatch = reg.SpriteBatch
local _spriteBatchGetColor, _spriteBatchSetColor = SpriteBatch.getColor, SpriteBatch.setColor

local grp = love.graphics
local _clear = grp.clear
local _getBackgroundColor, _setBackgroundColor = grp.getBackgroundColor, grp.setBackgroundColor
local _getColor, _setColor = grp.getColor, grp.setColor

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
  return function(...)
    local args = {...}
    local r, g, b, a = vanilla(args[1])
    return unpack(byteToNormalized({r, g, b, a}))
  end
end

local function overrideSetColor(vanilla, func)
  return function(...)
    local args = {...}
    local ud
    if #args > 0 and type(args[1]) == 'userdata' then
      ud = args[1]
      table.remove(args, 1)
      args = normalizedToByte(args)
      vanilla(ud, unpack(args))
    else
      args = normalizedToByte(args)
      vanilla(unpack(args))
    end
  end
end

if not love11 then
  grp.clear = overrideSetColor(_clear, grp.clear)
  grp.getBackgroundColor = overrideGetColor(_getBackgroundColor, grp.getBackgroundColor)
  grp.setBackgroundColor = overrideSetColor(_setBackgroundColor, grp.setBackgroundColor)
  grp.getColor = overrideGetColor(_getColor, grp.getColor)
  grp.setColor = overrideSetColor(_setColor, grp.setColor)
  SpriteBatch.getColor = overrideGetColor(_spriteBatchGetColor, SpriteBatch.getColor)
  SpriteBatch.setColor = overrideSetColor(_spriteBatchSetColor, SpriteBatch.setColor)
end
