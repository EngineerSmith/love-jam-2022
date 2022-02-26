local port, timeout = ...
timeout = timeout or 30

local le = require("love.event")
local ld = require("love.data")
local lt = love.thread

local enet = require("enet")

local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

local cmdIn = lt.getChannel("cmdIn")
local cmdOut = function(...)
  le.push("cmdOut", ...)
end

local host = enet.host_create("*:"..port)

local success = host:service(1000)
if not success then
  cmdOut("error", "Could not start server.")s
  return
end

local hash = function(data)
  return ld.hash("sha224", data)
end

local clients = { }
local getClient = function(clientID)
  local client = clients[clientID] or {}
  clients[clientID] = client
  return client
end
local removeClient = function(clientID)
  clients[clientID] = nil
end

local validateLogin = function(client, encoded)
  local decoded = serialize.decode(encoded)
  client.username = decoded[1]
  if type(client.username) ~= "string" or #client.username == 0 then
    return enum.disconnect.badusername
  end
  if client.username:match("(^%a)") then
    return enum.disconnect.badusername
  end
  client.login = true
  return true
end

while true do
  local event, limit = host:service(timeout)
  while event and limit < 50 then
    local clientID = hash(tostring(event.peer))
    local client = getClient(clientID)
    if event.type == "receive" then
      local success, encoded = pcall(ld.decompress, "string", "lz4", event.data)
      if success then
        if client.login then
          error("TODO")
        elseif validateLogin(client, encoded) then
          cmdOut(enumPT.confirmConnection, serialize.encode({0, clientID, client.name})
        end
      end
    elseif event.type == "disconnect" then
      error("TODO")
    elseif event.type == "connect" then
      client.id = clientID
      client.login = false
      cmdOut(enumPT.firstConnect, serialize.encode({0, clientID}))
    end
    limit = limit + 1
    local event = host:service()
  end
  local cmd, limit = cmdIn:pop(), 0
  while cmd and limit < 20 do
    local target = cmd[1]
    if target == "all" then
      error("TODO")
    else
      local clientID = cmd[2]
      error("TODO")
    end
    if cmd:sub(1,1) == enumPT.disconnect then
      local reason = tonumber(cmd:sub(2)) or enum.disconnect.normal
      server:disconnect(reason)
    else
      server:send(ld.compress("string", "lz4", tostring(cmd)))
    end
    cmd = cmdIn:pop()
    limit = limit + 1
  end
end