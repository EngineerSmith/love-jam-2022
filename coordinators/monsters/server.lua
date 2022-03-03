local network = require("network.server")
local logger = require("util.logger")
local world = require("coordinators.world")

return function(coordinator)
  
  local spawnTiles = {}
  local monsters = {}
  local dead = {}
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
      return #_monsters > 0 and _monsters or nil
    end
  
  network.addHandler(network.enum.confirmConnection, function(client)
      local package = packageMonsters()
      if package then
        network.send(client, network.enum.monsters, package)
      end
    end)
  
  coordinator.addSpawnTile = function(level, tile)
      if not spawnTiles[level] then
        spawnTiles[level] = {}
      end
      table.insert(spawnTiles[level], {reference=tile})
    end
  
  coordinator.prepareSpawnTiles = function()
      for _, spawnTilesLevel in pairs(spawnTiles) do
        for _, spawnTile in ipairs(spawnTilesLevel) do
          spawnTile.path = {}
          for index, goal in ipairs(world.nests) do
            spawnTile.path[index] = world.getMonsterPath(spawnTile.reference, goal)
          end
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
          monster.path = tile.path[love.math.random(1,#tile.path)]
          table.insert(monsters, monster)
          monster.position = #monsters
          table.insert(newMonsters, {
              id = monster.id,
              type = monster.type,
              x = monster.x,
              y = monster.y,
              health = monster.health,
              maxhealth = monster.maxhealth,
            })
        end
        if #newMonsters > 0 then
          logger.info("Spawned", #newMonsters, "new monsters")
          network.sendAll(network.enum.monsters, newMonsters)
        end
      end
    end
  
  coordinator.update = function(dt)
      -- follow monster's path
    end
  
  coordinator.updateNetwork = function()
      local package = packageMonsters()
      if package then
        if #dead > 0 then
          network.sendAll(network.enum.monsters, package, dead)
        else
          network.sendAll(network.enum.monsters, package)
        end
      end
    end
end