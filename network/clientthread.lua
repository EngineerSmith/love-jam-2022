local address = ...

local le = require("love.event")
local ld = require("love.data")
local lt = love.thread

local enet = require("enet")

local cmdIn = lt.getChannel("cmdIn")
local cmdOut = function(...)
  le.push("cmdOut", ...)
end

local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

local host = enet.host_create()
local server = host:connect(address)

local success = host:service(5000)
if not success then
  cmdOut(enumPT.disconnect, serialize.encode("badconnect", enum.disconnect.badconnect))
  return
end

while true do
  local event, limit = host:service(50), 0 
  while event and limit < 50 do
    if event.type == "receive" then
      local success, data = pcall(ld.decompress, "string", "lz4", event.data)
      if not success then
        cmdOut("log", "Could not decompress incoming data from server")
      else
        cmdOut(enumPT.receive, data)
      end
    elseif event.type == "connect" then
      if event.peer ~= server then
        event.peer:disconnect_now(enum.disconnect.badconnect)
      end
    elseif event.type == "disconnect" then
      local reason = enum.convert(event.data, "disconnect")
      cmdOut(enumPT.disconnect, serialize.encode(reason, event.data))
    end
    limit = limit + 1
    event = host:check_events()
  end
  local cmd, limit = cmdIn:pop(), 0
  while cmd and limit < 20 do
    if cmd == "quit" then
      server:disconnect_now(0)
      server:flush()
      return
    elseif cmd[1] == enumPT.disconnect then
      local reason = tonumber(cmd[3]) or enum.disconnect.normal
      server:disconnect(reason)
    else
      local success, data = pcall(ld.compress, "string", "lz4", cmd[1])
      if success then
        server:send(data)
      else
        cmdOut("log", "Could not compress outgoing data")
      end
    end
    cmd = cmdIn:pop()
    limit = limit + 1
  end
end