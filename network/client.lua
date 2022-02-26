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
  logger.info("Starting network thread, connecting to", address)
  client.thread = lt.newThread("network/clientthread.lua")
  love.handlers["cmdOut"] = client.handle
  cmdIn:clear()
  cmdIn:push(login)
  client.thread:start(address)
  client.address = address
end

client.handle = function(packetType, encoded)
  local decoded
  if encoded then
    decoded = serialize.decode(encoded)
  end
  if packetType == enumPT.receive then
    local pt = decoded[1]
    remove(decoded, 1)
    for _, callback in ipairs(client.handlers[pt]) do
      callback(unpack(decoded))
    end
  elseif packetType == enumPT.disconnect then
    logger.info("Disconnected, reason:", decoded[1], "code:", decoded[2])
    client.isConnected = false
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
    cmdIn:push(encoded)
  end
end

client.disconnect = function(reason)
  reason = reason or enum.disconnect.normal
  cmdIn:push(enumPT.disconnect..reason)
end

return client