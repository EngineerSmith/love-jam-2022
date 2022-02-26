local logger = require("util.logger")
local worldGen = require("coordinators.world.server.worldGen")

local network = require("network.server")

return function(coordinator)
  
  local world
  
  coordinator.generateWorld = function()
      world = worldGen(4,4,0)
    end
  
  network.addHandler(network.enum.confirmConnection, function(client)
      network.send(client, network.enum.worldData, world)
    end)
  
end