local logger = require("util.logger")
local network = require("network.server")

local chat = require("coordinators.chat")
local world = require("coordinators.world")

local scene = { }

scene.load = function(port)
  world.generateWorld()
  network.start(port)
end

scene.threaderror = function(...)
  if network.threaderror(...) then
    return
  end
  logger.error("Unknown thread error!", ...)
end

return scene