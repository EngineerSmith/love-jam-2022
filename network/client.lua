local lt = love.thread

local logger = require("util.logger")
local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

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

return client