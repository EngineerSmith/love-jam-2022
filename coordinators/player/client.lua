local logger = require("util.logger")
local network = require("network.client")

local flux = require("libs.flux")

local world = require("coordinators.world")

return function(coordinator)
  
  coordinator.position = {x=0,y=0,height=0}
  local speed = coordinator.speed
  
  local p = coordinator.position
  
  coordinator.setPosition = function(x, y, height)
      p.x, p.y = x, y
      p.height = height
    end
    
  local heightTween
  coordinator.update = function()
      local height = world.getHeightAtPoint(p.x+.5, p.y+.5)
      if height ~= p.height then
        if heightTween then
          heightTween:stop()
        end
        heightTween = flux.to(p, 0.1, {height=height})
      end
    end
  
  coordinator.updateNetwork = function()
      network.send(network.enum.playerPosition, p.x, p.y)
    end
  
  local tweenPositionTable, tween = {}, nil
  network.addHandler(network.enum.playerPosition, function(x, y)
      if tween then
        tween:stop()
      end
      -- We want to tween, but not if it's too far away
      local dx, dy = x - p.x, y - p.y
      if dx*dx+dy*dy>speed*speed then -- 11 units away, yump to the position
        coordinator.setPosition(x, y)
      else
        tweenPositionTable.x, tweenPositionTable.y = x, y
        tween = flux.to(coordinator.position, 0.4, tweenPositionTable)
      end
    end)
  
  coordinator.moveTowardsDirection = function(dirX, dirY, dt)
      if dirX ~= 0 then 
        local forceX = dirX * speed * dt
        p.x = p.x + forceX
      end
      if dirY ~= 0 then
        local forceY = dirY * speed * dt
        p.y = p.y + forceY
      end
    end
  
end