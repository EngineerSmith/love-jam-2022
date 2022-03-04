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
        if not tower.tween then
          local target = tower.target and monsters.getMonsterByID(tower.target)
          if not target then
            for _, monster in ipairs(monsters.aliveMonsters) do
              local x = tower.x - monster.x
              local y = tower.y*2 - monster.y*2
              if x*x+y*y < tower.range*tower.range then
                target = monster
                break
              else
                logger.info("Dist", x*x+y*y, "Goal", tower.range*tower.range)
              end
            end
          end
          if target then
            logger.info("Found target", target.id)
            tower.target = target.id
            tower.tween = flux:to(tower, tower.reference.attackSpeed, {}):ease("linear"):onupdate(function()
                if target.health <= 0 then
                  tower.target = nil
                end
              end):oncomplete(function()
                if target.health > 0 then
                  target.health = target.health - tower.reference.damage
                  if target.health <= 0 then
                    tower.target = nil
                  end
                else
                  tower.target = nil
                end
                tower.tween = nil
              end)
          end
        end
      end
    end
  end
end