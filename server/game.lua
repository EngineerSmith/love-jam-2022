local logger = require("util.logger")
local network = require("network.server")

local chat = require("coordinators.chat")
local world = require("coordinators.world")
local player = require("coordinators.player")
local towers = require("coordinators.towers")
local monsters = require("coordinators.monsters")

-- server is mostly reactive than active; hence the barebones

local scene = { }

scene.load = function(port)
  world.generateWorld()
  network.start(port)
end

scene.update = function(dt)
  monsters.update(dt)
  towers.update(dt)
end

scene.updateNetwork = function()
  world.updateNetwork()
  monsters.updateNetwork()
  towers.updateNetwork()
end

scene.threaderror = function(...)
  if network.threaderror(...) then
    return
  end
  logger.error("Unknown thread error!", ...)
end

return scene