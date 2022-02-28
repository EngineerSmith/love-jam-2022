local logger = require("util.logger")
local network = require("network.client")

local lg = love.graphics
local flux = require("libs.flux")

local world = require("coordinators.world")

return function(coordinator)
  
  coordinator.position = {x=700,y=50,height=0}
  local speed = coordinator.speed
  
  local p = coordinator.position
  coordinator.setPosition = function(x, y, height)
      p.x, p.y = x, y
      p.height = height
    end
    
  local heightTween
  coordinator.update = function()
      local w = coordinator.character:getDimensions()
      w = w/2.5
      local height1 = world.getHeightAtPoint(p.x-w, p.y)
      local height2 = world.getHeightAtPoint(p.x+w, p.y)
      local height = height1 > height2 and height1 or height2
      local height3 = world.getHeightAtPoint(p.x  , p.y)
      height = height > height3 and height or height3
      if height ~= p.height then
        if heightTween then
          heightTween:stop()
        end
        heightTween = flux.to(p, 0.1, {height=height})
      end
    end
  
  coordinator.updateNetwork = function()
      network.send(network.enum.playerPosition, p.x, p.y, coordinator.character.characterState.id)
    end
    
  coordinator.setCharacter = function(character)
      coordinator.character = character
    end
    
  coordinator.draw = function()
      if coordinator.character then
        lg.push("all")
        local w, h = coordinator.character:getDimensions()
        lg.translate(p.x-w/2, p.y-p.height-h/1.5)
        local z = (p.y-h/1.5)/world.depthScale
        coordinator.character:draw(z)
        lg.pop()
      end
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
        tween = flux.to(coordinator.position, 0.2, tweenPositionTable)
      end
    end)
  
  coordinator.moveTowardsDirection = function(dirX, dirY, dt)
      local moving = false
      local newX, newY = p.x, p.y
      if dirX ~= 0 then 
        local forceX = dirX * speed * dt
        newX = p.x + forceX
      end
      if dirY ~= 0 then
        local forceY = dirY * (speed/1.5) * dt
        newY = p.y + forceY
      end
      
      if world.canWalkAtPoint(newX, newY) then
        p.x, p.y = newX, newY
        moving = true
      end
      
      coordinator.character:setState(moving and "walking" or "standing")
      if moving then
        local directon = nil
        if dirY >= 0 then
          directon = "F"
        else
          directon = "B"
        end
        if dirX > -0.1 then
          directon = directon.."R"
        else
          directon = directon.."L"
        end
        coordinator.character:setDirection(directon)
      end
    end
  
end