local network = require("network.client")

local flux = require("libs.flux")

local world = require("coordinators.world")

return function(coordinator)
  local monsters = {}
  local monstersIdRef = {}
  
  network.addHandler(network.enum.monsters, function(_monsters, dead)
      for _, monster in ipairs(_monsters) do
        if not monstersIdRef[monster.id] then
          table.insert(monsters, monster)
          monstersIdRef[monster.id] = #monsters
          monster.character = coordinator.monsters[monster.type]:clone()
        else
          local tbl = _monsters[monstersIdRef[monster.id]]
          tbl.health = monster.health
          if tbl.tween then
            tbl.tween:stop()
          end
          tbl.tween = flux.to(tbl, 1/10, {x=monster.x, y=monster.y})
        end
      end
      if dead then
        for _, monster in ipairs(dead) do
          if monstersIdRef[monster.id] then
            table.remove(monsters, monstersIdRef[monster.id])
            monstersIdRef[monster.id] = nil
          end
        end
      end
    end
  
  local lg = love.graphics
  coordinator.draw = function()
      for _, monster in ipairs(monsters) do
        lg.push("all")
        local w, h = monster.character:getDimensions()
        lg.translate(monster.x-w/2, monster.y-monster.height-h/1.5)
        local z = (monster.y-h/1.5)/world.depthScale
        monster.character:draw(z)
        lg.pop()
      end
    end
  
end