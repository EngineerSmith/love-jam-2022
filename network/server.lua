local lt, ld = love.thread, love.data

local logger = require("util.logger")
local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

local remove, insert = table.remove, table.insert

local server = { 
    enum = enumPT,
    handlers = {},
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

local EncodeID = function(id)
  --return love.data.encode("string", "base64", id)
  return id
end

server.handle = function(packetType, ...)
  if packetType == "error" then
    server.threaderror(server.thread, ...)
    return
  elseif packetType == "log" then
    logger.info(...)
    return
  end
  
  local clientID, encoded = ...
  local decoded
  if encoded then
    decoded = serialize.decode(encoded)
  end
  local client = server.getClient(clientID)
  
  if packetType == enumPT.receive then
    local pt = decoded[1]
    for _, callback in ipairs(server.handlers[pt]) do
      callback(client, unpack(decoded, 2))
    end
  elseif packetType == enumPT.disconnect then
    logger.info("Disconnect from", EncodeID(clientID))
    server._removeClient(clientID)
    if client.name then
      for _, callback in ipairs(server.handlers[enumPT.disconnect]) do
        callback(client)
      end
    end
  elseif packetType == enumPT.confirmConnection then
    client.name = decoded[2]
    client.hash = decoded[3]
    logger.info("Confirmed connection for", EncodeID(clientID), "named", client.name)
    for _, callback in ipairs(server.handlers[enumPT.confirmConnection]) do
      callback(client, unpack(decoded, 2))
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
    }
  server.clients[clientID] = client
  return client
end

-- used internally only, use server.disconnect to disconnect a client
server._removeClient = function(clientID)
  server.clients[clientID] = nil
end

server.addHandler = function(packetType, callback)
  insert(server.handlers[packetType], callback)
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

server.disconnect = function(client, reason)
  reason = reason or enum.disconnect.normal
  cmdIn:push({client.id, enumPT.disconnect, reason})
end

return server