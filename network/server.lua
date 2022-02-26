local lt, ld = love.thread, love.data

local logger = require("util.logger")
local serialize = require("network.serialize")
local enum = require("network.enum")
local enumPT = enum.packetType

local server = { 
    callbacks = {},
    enum = enumPT,
  }

server.start = function(port)
  logger.info("Starting server on port", port)
  
end

return server