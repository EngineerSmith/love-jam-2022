local logger = require("util.logger")
local worldGen = require("coordinators.world.server.worldGen")

local network = require("network.server")

local ld = love.data
local insert = table.insert

return function(coordinator)
  
  local world
  
  coordinator.generateWorld = function()
      world = worldGen()
    end
  
  network.addHandler(network.enum.confirmConnection, function(client)
      network.send(client, network.enum.worldData, world)
    end)
  
  coordinator.updateNetwork = function()
      local players = {}
      for clientID, client in pairs(network.clients) do
        if client.hash then
          insert(players, {
              clientID  = client.hash,
              name      = client.name,
              position  = client.position,
              character = client.character,
            })
        end
      end
      network.sendAll(network.enum.foreignPlayers, players)
    end
  
end