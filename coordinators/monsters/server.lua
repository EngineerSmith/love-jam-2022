local network = require("network.server")

return function(coordinator)
  
  local spawnTiles = {}
  
  coordinator.addSpawnTile = function(level, i, j)
      if not spawnTiles[level] then
        spawnTiles[level] = {}
      end
      table.insert(spawnTiles, {i, j})
    end
  
end