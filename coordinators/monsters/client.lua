local network = require("network.client")
local logger = require("util.logger")
local flux = require("libs.flux")

local world = require("coordinators.world")

return function(coordinator)
  local monsters = {}
  
  coordinator.reset = function()
      monsters = {}
    end
  
  coordinator.getMonsterByID = function(id)
    return  monsters[id] and not monsters[id].dead and monsters[id]
  end
  
  network.addHandler(network.enum.monsters, function(_monsters, dead)
      if _monsters ~= "nil" then
        for _, monster in ipairs(_monsters) do
          if not monsters[monster.id] then
            monsters[monster.id] = monster
            monster.character = coordinator.monsters[monster.type].character:clone()
            monster.height = -2
          else
            local mon = monsters[monster.id]
            if mon then
              mon.health = monster.health
              if mon.tween then
                mon.tween:stop()
              end
              mon.tween = flux.to(mon, 1/10, {x=monster.x, y=monster.y})
            end
          end
        end
      end
      if dead then
        for _, monster in ipairs(dead) do
          if monsters[monster.id] then
            monsters[monster.id].dead = true
          end
        end
      end
    end)
  
  coordinator.update = function(shouldUpdateHeight)
      if shouldUpdateHeight then
        for _, monster in ipairs(monsters) do
          if not monster.dead then
            local height = world.getHeightAtPoint(monster.x, monster.y)
            if height ~= monster.height then
              if monster.heightTween then
                monster.heightTween:stop()
              end
              monster.heightTween = flux.to(monster, 1/10, {height=height})
            end
          end
        end
      end
    end
  
  local lg = love.graphics
  coordinator.draw = function()
      for _, monster in ipairs(monsters) do
        if not monster.dead then
          lg.push("all")
          local w, h = monster.character:getDimensions()
          lg.translate(monster.x-w/2, monster.y-monster.height-h/1.5)
          local z = (monster.y-h/1.5)/world.depthScale
          monster.character:draw(z)
          lg.push("all")
          lg.setShader()
          lg.setDepthMode("always", false)
          lg.setColor(.6,.1,.1,1)
          lg.rectangle("fill", 10, 0, 10, 2)
          lg.setColor(.03,.7,.1,1)
          lg.rectangle("fill", 10,0, 10*(monster.health/monster.maxhealth), 2)
          lg.pop()
          lg.pop()
        end
      end
    end
  
end