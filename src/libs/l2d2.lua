-- Workaround to support love.js 0.11.0-rc3 which is a pre-release of v11
--local love11 = love.getVersion() == 11
local love11 = love._version_major == 11 or love._version_major == 0 and love._version_minor == 11

local function round(n)
  return math.floor(n + 0.5)
end

local reg = debug.getregistry()
local SpriteBatch = reg.SpriteBatch
local _sbGetColor, _sbSetColor = SpriteBatch.getColor, SpriteBatch.setColor
local ParticleSystem = reg.ParticleSystem
local _psGetColors, _psSetColors = ParticleSystem.getColors, ParticleSystem.setColors

local grp = love.graphics
local _clear = grp.clear
local _getBackgroundColor, _setBackgroundColor = grp.getBackgroundColor, grp.setBackgroundColor
local _getColor, _setColor = grp.getColor, grp.setColor

-- Converts color values from 0-1 range to 0-255
local function normalizedToByte(table)
  for i, arg in ipairs(table) do
    if type(arg) == 'table' then
      for j, elem in ipairs(arg) do
        arg[j] = round(elem * 255)
      end
    else
      table[i] = round(arg * 255)
    end
  end
  return table
end

-- Converts color values from 0-255 range to 0-1
local function byteToNormalized(table)
  for i, arg in ipairs(table) do
    if type(arg) == 'table' then
      for j, elem in ipairs(arg) do
        arg[j] = elem / 255
      end
    else
      table[i] = arg / 255
    end
  end
  return table
end

local function overrideGetColor(vanilla, func)
  return function(...)
    local args = {...}
    local result = { vanilla(args[1]) }
    return unpack(byteToNormalized(result))
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
  SpriteBatch.getColor = overrideGetColor(_sbGetColor, SpriteBatch.getColor)
  SpriteBatch.setColor = overrideSetColor(_sbSetColor, SpriteBatch.setColor)
  ParticleSystem.getColors = overrideGetColor(_psGetColors, ParticleSystem.getColors)
  ParticleSystem.setColors = overrideSetColor(_psSetColors, ParticleSystem.setColors)
end
