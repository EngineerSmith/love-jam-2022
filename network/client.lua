local lt = love.thread

local logger = require("util.logger")
local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

local remove, insert = table.remove, table.insert

local client = {
    enum = enumPT,
    handlers = { },
    isConnected = false,
  }

for _, enumValue in pairs(client.enum) do
  client.handlers[enumValue] = {}
end

local cmdIn = lt.getChanne("cmdIn")

client.connect = function(address, login)
  if client.isConnected or not (client.thread and client.thread:isRunning()) then
    error("Cannot connect when already connected")
  end
  logger.info("Starting network thread, connecting to", address)
  if not client.thread then
    client.thread = lt.newThread("network/clientthread.lua")
  end
  love.handlers["cmdOut"] = client.handle
  cmdIn:clear()
  cmdIn:push(login)
  client.thread:start(address)
  client.address = address
end

client.threaderror = function(thread, errorMessage)
  if thread == client.thread then
    logger.warn("Error on network thread:", errorMessage)
    client.thread = nil
    client.isConnected = false
    return true
  end
  return false
end

client.quit = function()
  if client.thread and client.thread:isRunning() then
    cmdIn:performAtomic(function()
        cmdIn:clear()
        cmdIn:push("quit")
      end)
    client.thread:wait()
  end
  client.isConnected = false
end

client.handle = function(packetType, encoded)
  if packetType == "warn" then
    logger.warn(encoded)
    return
  end
  local decoded = serialize.decode(encoded)
  encoded = nil
  if packetType == enumPT.receive then
    local pt = decoded[1]
    for _, callback in ipairs(client.handlers[pt]) do
      callback(unpack(decoded, 2))
    end
  elseif packetType == enumPT.disconnect then
    logger.info("Disconnected, reason:", decoded[1], "code:", decoded[2])
    client.quit()
    for _, callback in ipairs(client.handlers[enumPT.disconnect]) do
      callback(unpack(decoded))
    end
  elseif packetType == enumPT.confirmConnection then
    logger.info("Successful connection made")
    client.isConnected = true
    for _, callback in ipairs(client.handlers[enumPT.confirmConnection]) do
      callback(unpack(decoded))
    end
  end
end

client.addHandler = function(packetType, callback)
  insert(client.handlers[packetType], callback)
end

client.send = function(packetType, ...)
  local encoded = serialize.encode(packetType, ...)
  if encoded then
    cmdIn:push({encoded})
  end
end

client.disconnect = function(reason)
  reason = reason or enum.disconnect.normal
  cmdIn:push({enumPT.disconnect, reason})
end

return client