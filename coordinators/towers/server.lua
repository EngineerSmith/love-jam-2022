local network = require("network.server")
local logger = require("util.logger")

local world = require("coordinators.world")
local flux = require("libs.flux").group()

return function(coordinator)
  
  local towers = coordinator.towers
  
  local allTowers = {}
  
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
          
          table.insert(allTowers, {reference=tile, canAttack=tile.canAttack})
          
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
        logger.info("FOUND")
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
      end
    end
  
  coordinator.update = function(dt)
      flux:update(dt)
    end
  
  coordinator.updateNetwork = function()
    for _, tower in ipairs(allTowers) do
      if tower.canAttack then
        if not tower.tween then
          
        end
      end
    end
  end
end