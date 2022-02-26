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
  cmdOut("error", "Could not connect to server.")
  return
end

while true do
  local event, limit = host:service(50), 0 
  while event, limit < 50 do
    
    limit = limit + 1
    event = host:service()
  end
  local cmd, limit = cmdIn:pop(), 0
  while cmd and limit < 20 do
    if cmd[1] == enumPT.disconnect then
      local reason = tonumber(cmd[3]) or enum.disconnect.normal
      server:disconnect(reason)
    else
      server:send(cmd[1])
    end
    cmd = cmdIn:pop()
    limit = limit + 1
  end
end