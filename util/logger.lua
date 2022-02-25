local lfs = love.filesystem
local args = require("util.args")

local logger = {
  internallog = {
    ["WARN"] = {},
    ["ERROR"] = {},
    ["FATAL"] = {},
  },
  sinks = {},
  levels = require("util.loggerLevels")
}

logger.addSink = function(sink)
  table.insert(logger.sinks, sink)
  return #logger.sinks
end

logger.removeSink = function(sinkID)
  table.remove(logger.sinks, sinkID)
end

logger.addSink(function(level, logMessage)
    if logger.internallog[level] then
      table.insert(logger.internallog[level], logMessage)
    end
  end)

logger.addSink(function(_, logMessage)
    print(logMessage)
  end)

local getFormattedTime = function()
  return os.date("[%d/%m/%y %H:%M:%S]")
end

logger.file = nil
if args["-log"] then
  local file = "log.txt"
  if type(args["-log"]) == "table" then
    file = args["-log"][1]
  end
  
  if not lfs.getInfo(file, "file") then
    local _, errormsg = lfs.newFile(file, 'c')
    if errormsg then
      logger.runSinks("ERROR", getFormattedTime().." ERROR: Could not make log file: file name: "..file..", error: "..errormsg)
      goto skip
    end
  end
  
  local success, errormsg = lfs.append(file, getFormattedTime().." INFO: New logging session.\n")
  
  if not success then
    logger.runSinks("ERROR", getFormattedTime().." ERROR: Could not append log: file name: "..file..", error: "..errormsg)
    goto skip
  end
  
  logger.addSink(function(_, logMessage)
      lfs.append(file, logMessage.."\n")
    end)
  
  logger.file = file
  ::skip::
end

logger.runSinks = function(level, logMessage)
  for _, sink in ipairs(logger.sinks) do
    sink(level, logMessage);
  end
end

logger.log = function(level, ...)
  if not level or logger.levels[level] == nil then
    level = "UNKNOWN"
  end
  local message, n = "", select("#", ...)
  if n > 1 then
    local t = {}
    for i=1, n do
      t[i] = tostring(select(i, ...))
    end
    message = table.concat(t, " ")
  elseif n == 1 then
    message = tostring(select(1, ...))
  end
  local logMessage = ("%s %s: %s"):format(getFormattedTime(), level, message)
  logger.runSinks(level, logMessage)
end
  
logger.info = function(...)
  logger.log("INFO", ...)
end

logger.warn = function(...)
  logger.log("WARN", ...)
end

logger.error = function(...)
  logger.log("ERROR", ...)
end

logger.fatal = function(name, ...)
  if name == nil then
    logger.log("FATAL", ...)
  elseif not love.window then
    logger.log("FATAL", name, ...)
  else
    logger.log("FATAL", name, ":", ...)
    logger.info("Showing errorbox:", name)
    love.window.showMessageBox("Error occurred: "..name, table.concat({...}, " "), "error", true)
    love.event.quit()
  end
end

return logger