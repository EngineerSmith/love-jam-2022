local logger = require("util.logger")

local network = require("network.server")

local world = require("coordinators.world")

return function(coordinator)
  
  local speed = coordinator.speed
  
  network.addHandler(network.enum.playerPosition, function(client, x, y, character)
      local position = client.position
      if not position then return end
      local dx = x - position.x
      local dy = y - position.y
      if dx*dx+dy*dy> speed*speed then
        network.send(client, network.enum.playerPosition, position.x, position.y)
      else
        position.x, position.y = x, y
      end
      client.character = character
    end)
  
  coordinator.movePlayer = function(client, x, y)
      if not client.position then
        client.position = { }
      end
      local p = client.position
      p.x, p.y = x, y
      network.send(client, network.enum.playerPosition, x, y)
    end
  
  network.addHandler(network.enum.confirmConnection, function(client)
      coordinator.movePlayer(client, world.getSpawnPoint())
    end)
  
  coordinator.getCurrency = function(client)
      client.money = client.money or 0
      return client.money
    end
  
  network.addHandler(network.enum.readyUpState, function(client, ready)
      client.ready = ready or false
      if coordinator.areAllPlayersReady() then
        coordinator.resetPlayerReady()
        world.itsGoTime()
      end
    end)
  
  coordinator.areAllPlayersReady = function()
      for clientID, client in pairs(network.clients) do
        if client.hash and client.position then
          if not client.ready then
            return false
          end
        end
      end
      return true
    end
  
  coordinator.resetPlayerReady = function()
      for clientID, client in pairs(network.clients) do
        if client.hash and client.position then
          client.ready = false
        end
      end
    end
  
end