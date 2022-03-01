local network = require("network.server")

local world = require("coordinators.world")

return function(coordinator)
  
  local towers = coordinator.towers
  
  network.addHandler(network.enum.placeTower, function(client, i, j, towerID)
      local tile = world.getTile(i, j)
      if tile and tile.tower == nil then
        local tower = towers[towerID]
        if tower and client.money - tower.price >= 0 then
          client.money = client.money - tower.price
          tile.tower = towerID
          tile.owner = client.hash
          tile.health = tower.health
          tile.notWalkable = true
          world.notifyTileUpdate(i, j)
        end
      end
    end)
  
end