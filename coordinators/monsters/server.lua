local network = require("network.server")
local logger = require("util.logger")
local world = require("coordinators.world")

local flux = require("libs.flux")

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
  
  local tileW, tileH = 32, 16
  local getXYForTile = function(i, j)
      local y = i * tileH / 2 - j * tileH / 2
      local x = j * tileW / 2 + i * tileW / 2
      return x+tileW/2, y+tileH/2
    end
  
  local newMonster = function(tile)
      local type = coordinator.monsterTypes[love.math.random(1,#coordinator.monsterTypes)]
      local monster = { type = type }
      monster.x, monster.y = getXYForTile(tile.i, tile.j)
      monster.id = monsterId
      monster.health = coordinator.monsters[monster.type].health
      monster.maxhealth = coordinator.monsters[monster.type].health
      monsterId = monsterId + 1
      return monster
    end
  
  
  local flux = flux.group()
  
  local addTween
  addTween = function(monster)
      local target = monster.path[#monster.path]
      if target then
        local x, y = getXYForTile(target.i, target.j)
        monster.tween = flux:to(monster, 10, {x=x,y=y}):onupdate(function()
          if monster.health <= 0 then
            monster.tween:stop()
            table.insert(dead, monster)
          end
        end):oncomplete(function()
          table.remove(monster.path, 1)
          if monster.health <= 0 then
            table.insert(dead, monster)
          else
            addTween(monster)
          end
        end)
      end
    end
  
  coordinator.spawnMonsters = function(level, number)
      local spawnTilesLevel = spawnTiles[level]
      if spawnTilesLevel then
        local newMonsters = {}
        for i=1, number do
          local tile = spawnTilesLevel[love.math.random(1, #spawnTilesLevel)]
          local monster = newMonster(tile.reference)
          monster.path = tile.path[love.math.random(1,#tile.path)]
          addTween(monster)
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
      flux:update(dt)
    end
  
  coordinator.updateNetwork = function()
      local package = packageMonsters()
      if package then
        if #dead > 0 then
          network.sendAll(network.enum.monsters, package, dead)
          dead = {}
        else
          network.sendAll(network.enum.monsters, package)
        end
      end
    end
end