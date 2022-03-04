local network = require("network.server")
local logger = require("util.logger")

local world = require("coordinators.world")
local towers = require("coordinators.towers")

local flux = require("libs.flux").group()

return function(coordinator)
  
  local spawnTiles = {}
  coordinator.aliveMonsters = {}
  local dead = {}
  local monsterId = 0
  
  coordinator.reset = function()
      coordinator.aliveMonsters = {}
      dead = {}
      monsterId = 0
    end
  
  coordinator.getMonsterByID = function(id)
    for _, mon in ipairs(coordinator.aliveMonsters) do
      if not mon.dead and mon.health > 0 and mon.id == id then
        return mon
      end
    end
    return nil
  end
  
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
      for _, monster in ipairs(coordinator.aliveMonsters) do
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
  local tweensToStop = {}
  local startMovingAgain = {}
  
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
      for _, monster in ipairs(coordinator.aliveMonsters) do
        if not monster.dead and monster.path and #monster.path > 0 and monster.tween then
          monster.goal = monster.path and monster.path.goal
          monster.path = nil
          table.insert(tweensToStop, monster.tween)
          monster.tween = nil
          table.insert(startMovingAgain, monster)
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
      monsterId = monsterId + 1
      monster.id = monsterId
      local monsterType = coordinator.monsters[monster.type]
      monster.health = monsterType.health
      monster.maxhealth = monsterType.health
      monster.speedMul = monsterType.speedMul
      monster.speedMulMax = monsterType.speedMul
      monster.damage = monsterType.damage
      monster.damagemax = monsterType.damage
      monster.attackspeed = monsterType.attackspeed
      monster.attackspeedmax = monsterType.attackspeed
      return monster
    end
  
  -- should be in world, but /shrug at this point
  local removeIfNest = function(tile)
      if tile.nestPos then
        logger.info("removed nest")
        for i=tile.nestPos+1, #world.nests do
          local target = world.nests[i]
          target.nestPos = target.nestPos - 1
        end
        table.remove(world.nests, tile.nestPos)
        tile.nestPos = nil
        tile.tower = nil
        tile.notWalkable = false
        tile.health = nil
        tile.owner = nil
        tile.maxhealth = nil
      end
    end
  
  addTween = function(monster)
      if monster.tween then
        logger.info("HAS TWEEN ALREADY:", debug.traceback())
        return
      end
      local target = monster.path and monster.path[1]
      if target then
    -- attack target
        if target.tower and target.health and target.health > 0 then
          monster.tween = flux:to(monster, monster.attackspeed, {}):ease("linear"):onupdate(function()
              if monster.health <= 0 then
                table.insert(tweensToStop, monster.tween)
                monster.tween = nil
                table.insert(dead, packageMonster(monster))
                coordinator.aliveMonsters[monster.position].dead = true
              else
                if not target.health or target.health <= 0 then
                  table.insert(tweensToStop, monster.tween)
                  monster.tween = nil
                  table.insert(startMovingAgain, monster)
                end
              end
            end):oncomplete(function()
              monster.tween = nil
              if monster.health <= 0 then
                table.insert(dead, packageMonster(monster))
                monster[monster.position].dead = true
              else
                if target.health and target.health > 0 then
                  target.health = target.health - monster.damage
                  if target.health <= 0 then
                    towers.removeTower(target)
                    removeIfNest(target)
                    coordinator.prepareSpawnTiles()
                  end
                  world.notifyTileUpdate(target.i, target.j)
                end
                addTween(monster)
              end
            end)
          return
        end
    -- move to target
        local x, y = getXYForTile(target.i, target.j)
        monster.tween = flux:to(monster, .9 * monster.speedMul, {x=x,y=y}):ease("linear"):onupdate(function()
            if monster.health <= 0 then
              table.insert(tweensToStop, monster.tween)
              monster.tween = nil
              table.insert(dead, packageMonster(monster))
              coordinator.aliveMonsters[monster.position].dead = true
            end
          end):oncomplete(function()
            if monster.path then
              table.remove(monster.path, 1)
            end
            monster.tween = nil
            if monster.health <= 0 or not monster.path then
              table.insert(dead, packageMonster(monster))
              coordinator.aliveMonsters[monster.position].dead = true
            else
              addTween(monster)
            end
          end)
        return
      else
        monster.tween = nil
        monster.path = nil
        -- find new path
        local goal = monster.goal
        if goal and not (goal.tower and goal.health and goal.health > 0) then
          goal = nil
        end
        if not goal then
          if #world.nests == 0 then
            return
          end
          goal = world.nests[love.math.random(1, #world.nests)]
        end
        local path = world.getMonsterPath(world.getTileAtPixels(monster.x, monster.y), goal)
        if path then
          path.goal = goal
          monster.path = path
          addTween(monster)
        end
      end
    end
  
  local addSleepTween = function(monster)
      flux:to(monster, 2.5+love.math.random()*2.5, {}):oncomplete(function()
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
          addSleepTween(monster)
          table.insert(coordinator.aliveMonsters, monster)
          monster.position = #coordinator.aliveMonsters
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
      if #tweensToStop > 0 then
        for _, tween in ipairs(tweensToStop) do
          tween:stop()
        end
        tweensToStop = {}
      end
      if #startMovingAgain > 0 then
        for _, monster in ipairs(startMovingAgain) do
          if not monster.tween then
            addTween(monster)
          end
        end
        startMovingAgain = {}
      end
      flux:update(dt)
      if #tweensToStop > 0 then
        for _, tween in ipairs(tweensToStop) do
          tween:stop()
        end
        tweensToStop = {}
      end
      if #startMovingAgain > 0 then
        for _, monster in ipairs(startMovingAgain) do
          if not monster.tween then
            addTween(monster)
          end
        end
        startMovingAgain = {}
      end
    end
  
  coordinator.isAllMonstersDead = function()
      local monsters = coordinator.aliveMonsters
      local count = #monsters
      for _, m in ipairs(monsters) do
        if m.dead or m.health <= 0 then
          count = count - 1
        end
      end
      return count == 0
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
      elseif #dead > 0 then
        network.sendAll(network.enum.monsters, "nil", dead)
        dead = {}
      end
    end
end