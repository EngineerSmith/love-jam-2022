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

if not host then
  cmdOut("error", "Could not start server.")
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
  if type(decoded[1]) ~= "table" then
    return enum.disconnect.badlogin
  end
  client.name = decoded[1].name
  if type(client.name) ~= "string" or #client.name == 0 or #client.name > 16 or client.name:match("(^%a)") then
    return enum.disconnect.badusername
  end
  client.login = true
  return true
end

while true do
  local event, limit = host:service(timeout), 0
  while event and limit < 50 do
    local clientID = hash(tostring(event.peer))
    local client = getClient(clientID)
    if event.type == "receive" then
      local success, encoded = pcall(ld.decompress, "string", "lz4", event.data)
      if success then
        if client.login then
          cmdOut(enumPT.receive, clientID, encoded)
        else
          local result = validateLogin(client, encoded)
          if result == true then
            local hash = ld.encode("string", "base64", clientID)
            cmdOut(enumPT.confirmConnection, clientID, serialize.encode(0, client.name, hash))
            local encoded = serialize.encode(enumPT.confirmConnection, hash)
            if encoded then
              cmdIn:push({clientID, encoded})
            end
          else
            client.peer:disconnect_now(result or enum.disconnect.badlogin)
          end
        end
      else
        cmdOut("log", "Could not decompress incoming data from "..tostring(client.id)..(client.name and " known as "..tostring(client.name) or ""))
        if not client.login then
          client.peer:disconnect_now(enum.disconnect.badlogin)
        end
      end
    elseif event.type == "disconnect" then
      removeClient(clientID)
      cmdOut(enumPT.disconnect, serialize.encode(0, clientID))
    elseif event.type == "connect" then
      client.id = clientID
      client.login = false
      client.loginAttempt = 0
      client.peer = event.peer
    end
    limit = limit + 1
    event = host:service()
  end
  local cmd, limit = cmdIn:pop(), 0
  while cmd and limit < 20 do
    local target = cmd[1]
    if target == "all" then
      local success, data = pcall(ld.compress, "string", "lz4", cmd[2])
      if success then
        host:broadcast(data)
      else
        cmdOut("log", "Could not compress outgoing data to all")
      end
    else
      local client = getClient(target)
      if cmd[2] == enumPT.disconnect then
        local reason = tonumber(cmd[3]) or enum.disconnect.normal
        client.peer:disconnect(reason)
      else
        local success, data = pcall(ld.compress, "string", "lz4", cmd[2])
        if success then
          client.peer:send(data)
        else
          cmdOut("log", "Could not compress outgoing data to "..tostring(target))
        end
      end
    end
    cmd = cmdIn:pop()
    limit = limit + 1
  end
end