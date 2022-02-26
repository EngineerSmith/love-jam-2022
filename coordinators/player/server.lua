local logger = require("util.logger")

local network = require("network.server")

return function(coordinator)
  
  local speed = coordinator.speed
  
  network.addHandler(network.enum.playerPosition, function(client, x, y)
      local position = client.position
      if not position then return end
      local dx = x - position.x
      local dy = y - position.y
      if dx*dx+dy*dy> speed*speed then
        network.send(client, network.enum.playerPosition, position.x, position.y)
      else
        position.x, position.y = x, y
      end
    end
  
  coordinator.movePlayer = function(client, x, y)
      if not client.position then
        client.position = {}
      end
      local p = client.position
      p.x, p.y = x, y
      network.send(client, network.enum.playerPosition, x, y)
    end
  
end