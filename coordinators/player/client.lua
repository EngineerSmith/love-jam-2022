local logger = require("util.logger")
local network = require("network.client")
local assets = require("util.assets")

local lg = love.graphics
local flux = require("libs.flux")

local world = require("coordinators.world")

return function(coordinator)
  
  coordinator.position = {x=0,y=0,height=0}
  local speed = coordinator.speed
  
  coordinator.money = 0
  
  local p = coordinator.position
  coordinator.setPosition = function(x, y, height)
      p.x, p.y = x, y
      p.height = height or p.height
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
  
  local formatMoney = function(num)
    local i, j, minus, int, fraction = tostring(num):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus..int:reverse():gsub("^,","")..fraction
  end
  
  local coin = assets["ui.coin"]
  coordinator.drawUI = function(windowScale, subtract)
      local width, height = coin:getDimensions()
      local coinScale = 1
      local str = formatMoney(coordinator.money)
      local strWidth = lg.getFont():getWidth(str)
      lg.setColor(.9,.9,.9,.6)
      --lg.rectangle("fill", lg.getWidth()-(width-strWidth)*windowScale, 5, (width+strWidth)*windowScale,(height*coinScale*windowScale)+5, 3)
      lg.setColor(1,1,1)
      width, height = width*coinScale*windowScale, height*coinScale*windowScale
      lg.draw(coin, lg.getWidth()-width-10, 10, 0, coinScale*windowScale, coinScale*windowScale)
      lg.setColor(.2,.2,.2)
      
      lg.print(str, lg.getWidth()-width-10-strWidth, 10+height/2-lg.getFont():getHeight()/2)
      if subtract then
        lg.setColor(.8,.2,.05)
        local subStr = formatMoney(-subtract)
        local subStrWidth = lg.getFont():getWidth(subStr)
        lg.print(subStr, lg.getWidth()-width-10-subStrWidth, 10+height/2+lg.getFont():getHeight()/2)
      end
      lg.setColor(1,1,1)
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
      
      if (p.x ~= newX or p.y ~= newY) and world.canWalkAtPoint(newX, newY) then
        p.x, p.y = newX, newY
        moving = true
      end
      
      coordinator.character:setState(moving and "walking" or "standing")
      if moving then
        local direction = nil
        if dirY >= 0 then
          direction = "F"
        else
          direction = "B"
        end
        if dirX > (direction == "F" and -0.1 or 0.1) then
          direction = direction..(direction == "F" and "R" or "L")
        else
          direction = direction..(direction == "F" and "L" or "R")
        end
        coordinator.character:setDirection(direction)
      end
    end
  
  coordinator.setMoney = function(money)
      coordinator.money = money
    end
  
end