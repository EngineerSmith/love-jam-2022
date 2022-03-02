local network = require("network.server")

local world = require("coordinators.world")

return function(coordinator)
  
  local spawnTiles = {}
  local monsters = {}
  local monsterId = 0
  
  local packageMonsters = function()
      local _monsters = {}
      for _, monster in ipairs(monsters) do
        table.insert(_monsters, {
            id = monster.id,
            type = monster.type,
            x = monster.x,
            y = monster.y,
            health = monster.health,
            maxhealth = monster.maxhealth,
          })
      end
      return _monsters
    end
  
  network.addHandler(network.enum.confirmConnection, function(client)
      network.send(client, network.enum.monsters, packageMonsters())
    end)
  
  coordinator.addSpawnTile = function(level, tile)
      if not spawnTiles[level] then
        spawnTiles[level] = {}
      end
      table.insert(spawnTiles, {reference=tile})
    end
  
  coordinator.prepareSpawnTiles = function()
      for _, spawnTilesLevel in pairs(spawnTiles) do
        for _, spawnTile in ipairs(spawnTilesLevel) do
          spawnTile.path = world.getMonsterPath(spawnTile.reference)
        end
      end
      -- TODO repath any current monsters
      for _, monster in ipairs(monsters) do
        
      end
    end
  
  local tileH, tileW = 32, 16
  local newMonster = function(tile)
      local type = coordinator.monsterTypes[love.math.random(1,#coordinator.monsterTypes)]
      local monster = { type = type }
      local y = tile.i * tileH / 2 - tile.j * tileH / 2
      local x = tile.j * tileW / 2 + tile.i * tileW / 2
      monster.x, monster.y = x, y
      monster.id = monsterId
      monster.health = coordinator.monsters[monster.type].health
      monster.maxhealth = coordinator.monsters[monster.type].health
      monsterId = monsterId + 1
      return monster
    end
  
  coordinator.spawnMonsters = function(level, number)
      local spawnTilesLevel = spawnTiles[level]
      if spawnTilesLevel then
        local newMonsters = {}
        for i=1, number do
          local tile = spawnTilesLevel[love.math.random(1, #spawnTilesLevel)]
          local monster = newMonster(tile.reference)
          monster.path = spawnTilesLevel.path
          table.insert(monsters, monster)
          monster.position = #monsters
          table.insert(newMonster, {
              id = monster.id,
              type = monster.type,
              x = monster.x,
              y = monster.y,
              health = monster.health,
              maxhealth = monster.maxhealth,
            })
        end
        network.sendAll(network.enum.monsters, newMonsters)
      end
    end
  
  coordinator.update = function(dt)
      -- follow monster's path
    end
  
  coordinator.updateNetwork = function()
      network.sendAll(network.enum.monsters, packageMonsters())
    end
end