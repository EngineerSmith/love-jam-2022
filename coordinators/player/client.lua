local logger = require("util.logger")
local network = require("network.client")

local flux = require("libs.flux")

return function(coordinator)
  
  coordinator.position = {x=0,y=0,z=0}
  local speed = coordinator.speed
  
  local p = coordinator.position
  
  coordinator.setPosition = function(x, y)
      p.x, p.y = x, y
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
  
end