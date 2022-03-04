local lfs = love.filesystem
local json = require("util.json")
local args = require("util.args")
local logger = require("util.logger")

local settingsFile = "settings.json"
if type(args["-settings"]) == "table" then
  settingsFile = args["-settings"][1]
end

local defaultSettings = { 
    client = {
        windowsize = { width = 800,  height = 500, },
        windowfullscreen = false,
        controls = {
          forward  = { "w", "up",    },
          backward = { "s", "down",  },
          left     = { "a", "left",  },
          right    = { "d", "right", },
          chat     = { "tab", "t"    },
        },
        lowGraphics = false,
        disableShaking = false,
        volume = 30,
      },
    server = {
        port = 20202,
      },
  }

-- lazy deep copy, the best kind of copy
local b = require("string.buffer")
local settings = b.decode(b.encode(defaultSettings))
b = nil

local formatTable
formatTable = function(dirtyTable, cleanTable)
  for k,v in pairs(cleanTable) do
    local vType = type(v)
    if type(dirtyTable[k]) ~= vType then
        dirtyTable[k] = v
    else
      if vType == "table" then
        dirtyTable[k] = formatTable(dirtyTable[k],v)
      elseif vType == "number" then
        if dirtyTable[k] < 0 then
          dirtyTable[k] = v
        end
      end
    end
  end
  return dirtyTable
end

if lfs.getInfo(settingsFile, "file") then
  local success, decodedSettings = json.decode(settingsFile)
  if success then
    settings = formatTable(decodedSettings, defaultSettings)
  end
end

local encode = function()
  local success, message = json.encode(settingsFile, settings)
  if not success then
    logger.error("Could not update", settingsFile, ":", message)
  end
end
encode() -- creates default file

local handlers = {}
local out = {
    client = {},
    server = {},
    _default = defaultSettings,
    addHandler = function(key, func)
        local h = handlers[key] or {}
        handlers[key] = h
        table.insert(h, func)
      end,
  }
setmetatable(out.client, {
    __index = function(_, key)
        return settings.client[key]
      end,
    __newindex = function(_, key, value)
        settings.client[key] = value
        encode()
        if handlers[key] then
          for _, func in ipairs(handlers[key]) do
            func()
          end
        end
      end,
  })
setmetatable(out.server, {
    __index = function(_, key)
        return settings.server[key]
      end,
    __newindex = function(_, key, value)
        settings.client[key] = value
        encode()
        if handlers[key] then
          for _, func in ipairs(handlers[key]) do
            func()
          end
        end 
      end,
  })

return out

