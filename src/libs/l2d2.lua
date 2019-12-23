-- Workaround to support love.js 0.11.0-rc3 which is a pre-release of v11
--local love11 = love.getVersion() == 11
local love11 = love._version_major == 11 or love._version_major == 0 and love._version_minor == 11

local function round(n)
  return math.floor(n + 0.5)
end

function table.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

local reg = debug.getregistry()
local SpriteBatch = reg.SpriteBatch
local _sbGetColor, _sbSetColor = SpriteBatch.getColor, SpriteBatch.setColor
local ParticleSystem = reg.ParticleSystem
local _psGetColors, _psSetColors = ParticleSystem.getColors, ParticleSystem.setColors
local Mesh = reg.Mesh
local _mGetVertex = Mesh.getVertex
local _mSetVertex = Mesh.setVertex

local grp = love.graphics
local _clear = grp.clear
local _getBackgroundColor, _setBackgroundColor = grp.getBackgroundColor, grp.setBackgroundColor
local _getColor, _setColor = grp.getColor, grp.setColor
local _newMesh = grp.newMesh

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
  
  function love.graphics.newMesh(...)
    local args = {...}
    if #args > 0 and type(args[1]) == 'table' then
      local first_color, last_color = 5, 8
      for i, elem in ipairs(args[1]) do
        if type(args[1][i]) == 'table' and #args[1][i] >= first_color then
          local colors = table.slice(args[1][i], first_color, last_color)
          colors = normalizedToByte(colors)
          for j = first_color, last_color do
            args[1][i][j] = colors[j - (last_color - first_color + 1)]
          end
        end
      end
    end
    return _newMesh(unpack(args))
  end
  
  function Mesh.setVertex(...)
    local args = {...}
    local ud = args[1] --
    table.remove(args, 1) --
    local first_color, last_color = 5, 8
    local colors = {}
    if #args > 0 and type(args[2]) == 'table' and #args[2] >= first_color then
      colors = table.slice(args[2], first_color, last_color)
      colors = normalizedToByte(colors)
      for i = first_color, last_color do
        args[2][i] = colors[i - (last_color - first_color + 1)]
      end
    elseif #args >= first_color + 1 and type(args[2]) ~= 'table' then
      colors = table.slice(args, first_color + 1, last_color + 1)
      colors = normalizedToByte(colors)
      for i = first_color, last_color do
        args[i+1] = colors[i - (last_color - first_color + 1)]
      end
    end
    return _mSetVertex(ud, unpack(args)) --
  end
  
  function Mesh.getVertex(...)
    local args = {...}
    local ud = args[1]
    table.remove(args, 1)
    local result = { _mGetVertex(ud, unpack(args)) }
    local first_color, last_color = 5, 8
    local colors = table.slice(result, first_color, last_color)
    colors = byteToNormalized(colors)
    for i = first_color, last_color do
      result[i] = colors[i - (last_color - first_color + 1)]
    end
    return unpack(result)
  end
end
