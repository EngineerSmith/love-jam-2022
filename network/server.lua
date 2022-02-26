local lt, ld = love.thread, love.data

local logger = require("util.logger")
local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

local remove, insert = table.remove, table.insert

local server = { 
    enum = enumPT,
    callbacks = {},
    clients = {},
  }

for _, enumValue in pairs(server.enum) do
  server.handlers[enumValue] = {}
end 

local cmdIn = lt.getChannel("cmdIn")

server.start = function(port)
  logger.info("Starting server on port", port)
  server.thread = lt.newThread("network/serverthread.lua")
  love.handlers["cmdOut"] = server.handle
  cmdIn:clear()
  server.thread:start(port)
  server.port = port
end

server.threaderror = function(thread, errorMessage)
  if thread == server.thread then
    logger.fatal("Error on network thread:", errorMessage)
    love.event.quit(-1)
    return true
  end
  return false
end

server.handle = function(packetType, encoded)
  local decoded = serialize.decode(encoded)
  encoded = nil
  local clientID = decoded[2]
  local client = server.getClient(clientID)
  decoded[2] = client
  if packetType == enumPT.receive then
    local pt = decoded[1]
    remove(decoded, 1)
    for _, callback in ipairs(server.handlers[pt]) do
      callback(unpack(decoded))
    end
  elseif packetType == enumPT.disconnect then
    logger.info("Disconnect from", clientID)
    for _, callback in ipairs(server.handlers[enumPT.disconnect]) do
      callback(unpack(decoded))
    end
  elseif packetType == enumPT.firstConnect then
    logger.info("Connection from", clientID)
  elseif packetType == enumPT.confirmConnection then
    logger.info("Confirmed connection for", clientID, "named", client.name)
    for _, callback in ipairs(server.handlers[enumPT.confirmConnection]) do
      callback(unpack(decoded))
    end
  end
end

server.getClient = function(clientID)
  local client = server.clients[clientID]
  if client then
    return client
  end
  client = {
      id = clientID,
      name = "unknown",
    }
  server.clients[clientID] = client
  return client
end

server.addHandler = function(packetType, callback)
  insert(client.handlers[packetType], callback)
end

server.send = function(client, packetType, ...)
  local encoded = serialize.encode(packetType, ...)
  if encoded then
    cmdIn:push({client.id, encoded})
  end
end

server.sendAll = function(packetType, ...)
  local encoded = serialize.encode(packetType, ...)
  if encoded then
    cmdIn:push({"all", encoded})
  end
end

return server