local network = require("network.server")
local logger = require("util.logger")
local world = require("coordinators.world")

local flux = require("libs.flux")

return function(coordinator)
  
  local spawnTiles = {}
  local monsters = {}
  local dead = {}
  local monsterId = 0
  
  local packageMonster = function(monster)
      return {
          id = monster.id,
          type = monster.type,
          x = monster.x,
          y = monster.y,
          health = monster.health,
          maxhealth = monster.maxhealth,
        }
    end
  
  local packageMonsters = function()
      local _monsters = {}
      for _, monster in ipairs(monsters) do
        if not monster.dead then
          table.insert(_monsters, packageMonster(monster))
        end
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
  
  local addTween -- function defined later
  
  coordinator.prepareSpawnTiles = function()
      for _, spawnTilesLevel in pairs(spawnTiles) do
        for _, spawnTile in ipairs(spawnTilesLevel) do
          spawnTile.path = {}
          for _, goal in ipairs(world.nests) do
            local path = world.getMonsterPath(spawnTile.reference, goal)
            if path then
              path.goal = goal
              table.insert(spawnTile.path, path)
            end
          end
        end
      end
      for _, monster in ipairs(monsters) do
        if not monster.dead and monster.path and #monster.path > 0 then
          local path = world.getMonsterPath(monster.path[1], monster.path.goal)
          if path then 
            path.goal = monster.path.goal
            monster.path = path
            monster.tween:stop()
            addTween(monster)
          else
            monster.path = nil
            monster.tween:stop()
          end
        end
      end
    end
  
  local tileW, tileH = 32, 16
  local getXYForTile = function(i, j)
      local y = i * tileH / 2 - j * tileH / 2
      local x = j * tileW / 2 + i * tileW / 2
      return x+tileW/2, y
    end
  
  local newMonster = function(tile)
      local type = coordinator.monsterTypes[love.math.random(1,#coordinator.monsterTypes)]
      local monster = { type = type }
      monster.x, monster.y = getXYForTile(tile.i, tile.j)
      monster.id = monsterId
      local monsterType = coordinator.monsters[monster.type]
      monster.health = monsterType.health
      monster.maxhealth = monsterType.health
      monster.speedMul = monsterType.speedMul
      monster.speedMulMax = monsterType.speedMul
      monster.damage = monsterType.damage
      monster.damagemax = monsterType.damage
      monsterId = monsterId + 1
      return monster
    end
  
  
  local flux = flux.group()
  
  addTween = function(monster)
      local target = monster.path[1]
      if target then
        local x, y = getXYForTile(target.i, target.j)
        monster.tween = flux:to(monster, .9 * monster.speedMul, {x=x,y=y}):ease("linear"):onupdate(function()
          if monster.health <= 0 then
            monster.tween:stop()
            table.insert(dead, packageMonster(monster))
            monsters[monster.position].dead = true
          end
        end):oncomplete(function()
          table.remove(monster.path, 1)
          if monster.health <= 0 then
            table.insert(dead, packageMonster(monster))
            monsters[monster.position].dead = true
          else
            addTween(monster)
          end
        end)
      else
        monster.tween:stop()
        monster.path = nil
        table.insert(dead, packageMonster(monster))
        monsters[monster.position].dead = true
      end
    end
  
  local addSleepTween = function(monster)
      flux:to(monster, 4+love.math.random()*2.5, {}):oncomplete(function()
            addTween(monster)
        end)
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
          addSleepTween(monster)
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