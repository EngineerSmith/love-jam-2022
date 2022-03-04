local network = require("network.server")
local logger = require("util.logger")

local world = require("coordinators.world")
local flux = require("libs.flux").group()

return function(coordinator)
  
  local towers = coordinator.towers
  
  local allTowers = {}
  
  local tileW, tileH = 32, 16
  local getGraphicPosition = function(i, j)
      local x = j * tileW / 2 + i * tileW / 2
      local y = i * tileH / 2 - j * tileH / 2
      return x, y
    end
  
  coordinator.damageAll = function(damage)
      for _, tower in ipairs(allTowers) do
        if tower.reference.health and tower.reference.health > 0 and tower.reference.tower ~= "NEST" then
          tower.reference.health = tower.reference.health - damage
          local i, j = tower.reference.i, tower.reference.j
          if tower.reference.health <= 0 then
            coordinator.removeTower(tower.reference)
          end
          world.notifyTileUpdate(i, j)
        end
      end
    end
  
  network.addHandler(network.enum.placeTower, function(client, i, j, towerID)
      local tile = world.getTile(i, j)
      if tile and tile.tower == nil and tile.earthquake == nil then
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
          
          tile.canAttack = tower.canAttack
          tile.attackSpeed = tower.attackSpeed or 0
          tile.damage = tower.damage or 0
          tile.range = tower.range
          
          local x, y = getGraphicPosition(i, j)
          table.insert(allTowers, {reference=tile, canAttack=tile.canAttack, x=x, y=y, range=tile.range})
          
          world.notifyTileUpdate(i, j)
          require("coordinators.monsters").prepareSpawnTiles()
        end
      end
    end)
  
  local findTower  = function(tile)
      for index, tower in ipairs(allTowers) do
        if tile == tower.reference then
          return tower, index
        end
      end
      return nil
    end
  
  coordinator.removeTower = function(tile)
      local tower, index = findTower(tile)
      if tower then
        table.remove(allTowers, index)
        if tower.tween then
          tower.tween:stop()
        end
        tile.notWalkable = false
        tile.tower = nil
        tile.owner = nil
        tile.health = nil
        tile.maxhealth = nil
        tile.canAttack = nil
        tile.attackSpeed = nil
        tile.damage = nil
        tile.range = nil
      end
    end
  
  coordinator.update = function(dt)
      flux:update(dt)
    end
  
  coordinator.updateNetwork = function()
    local monsters = require("coordinators.monsters")
    for _, tower in ipairs(allTowers) do
      if tower.canAttack then
        if tower.tween then
          if not tower.target then
            tower.tween:stop()
            tower.tween = nil
          end
        end
        if not tower.tween then
          local target = tower.target and monsters.getMonsterByID(tower.target)
          if target then
            local x = tower.x - target.x
            local y = tower.y*1.5 - target.y*1.5
            if target.health <= 0 or x*x+y*y >= tower.range*tower.range then
              target = nil
            end
          end
          if not target then
            local dist = math.huge
            for _, monster in ipairs(monsters.aliveMonsters) do
              local x = tower.x - monster.x
              local y = tower.y*1.5 - monster.y*1.5
              if monster.health > 0 and x*x+y*y < tower.range*tower.range and x*x+y*y < dist then
                target = monster
                dist = x*x+y*y
              end
            end
          end
          if target then
            tower.target = target.id
            tower.reference.target = target.id
            world.notifyTileUpdate(tower.reference.i, tower.reference.j)
            tower.tween = flux:to(tower, tower.reference.attackSpeed, {}):ease("linear"):onupdate(function()
                local x = tower.x - target.x
                local y = tower.y*1.5 - target.y*1.5
                if target.health <= 0 or x*x+y*y >= tower.range*tower.range then
                  tower.target = nil
                  tower.reference.target = nil
                  world.notifyTileUpdate(tower.reference.i, tower.reference.j)
                  return
                end
              end):oncomplete(function()
                if target.health > 0 then
                  local x = tower.x - target.x
                  local y = tower.y*1.5 - target.y*1.5
                  if x*x+y*y >= tower.range*tower.range then
                    tower.target = nil
                    tower.reference.target = nil
                    world.notifyTileUpdate(tower.reference.i, tower.reference.j)
                    return
                  end
                  target.health = target.health - tower.reference.damage
                  if target.health <= 0 then
                    tower.target = nil
                    tower.reference.target = nil
                    world.notifyTileUpdate(tower.reference.i, tower.reference.j)
                  end
                else
                  tower.target = nil
                  tower.reference.target = nil
                  world.notifyTileUpdate(tower.reference.i, tower.reference.j)
                end
                tower.tween = nil
              end)
          end
        end
      end
    end
  end
end