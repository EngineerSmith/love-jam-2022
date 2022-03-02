local network = require("network.server")

local world = require("coordinators.world")

return function(coordinator)
  
  local towers = coordinator.towers
  
  network.addHandler(network.enum.placeTower, function(client, i, j, towerID)
      local tile = world.getTile(i, j)
      if tile and tile.tower == nil then
        local tower = towers[towerID]
        for _, client in pairs(network.clients) do
          if client.position then
            if tile == world.getTileAtPixels(client.position.x, client.position.y) then
              return
            end
          end
        end
        if tower and client.money - tower.price >= 0 then
          client.money = client.money - tower.price
          tile.tower = towerID
          tile.owner = client.hash
          tile.health = tower.health
          tile.maxhealth = tower.health
          tile.notWalkable = true
          tile.targetPos = world.addTarget(i, j)
          world.notifyTileUpdate(i, j)
        end
      end
    end)
  
end