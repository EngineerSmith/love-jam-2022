local network = require("network.client")
local assets = require("util.assets")

local logger = require("util.logger")

local world = require("coordinators.world")

local flux = require("libs.flux")

return function(coordinator)
  
  local towers = coordinator.towers
  
  local direction = "NE"
  coordinator.mousePosition = function(x, y, mag, windowScale)
      love.mouse.setVisible(true)
      direction = ""
      coordinator.direction = nil
      if mag < 20*windowScale*2 then
        coordinator.cost = nil
        return
      end
      if y > 0 then
        direction = direction.."S"
      else
        direction = direction.."N"
      end
      if x > 0 then
        direction = direction..(direction == "N" and "E" or "W")
      else
        direction = direction..(direction == "N" and "W" or "E")
      end
      coordinator.cost = towers[direction].price
    end
  
  local lg = love.graphics
  local wheel = assets["ui.wheel"]
  local wheels = {
      ["NE"] = assets["ui.wheel.ne"],
      ["NW"] = assets["ui.wheel.nw"],
      ["SE"] = assets["ui.wheel.se"],
      ["SW"] = assets["ui.wheel.sw"],
    }
  
  coordinator.drawUI = function(showWheel, windowScale)
      if showWheel then
        local time = love.timer.getTime() - showWheel
        local scale = math.min(time/.5, 1)
        local width, height = wheel:getDimensions()
        local x = lg.getWidth()/2-(width*2*windowScale*scale)/2
        local y = lg.getHeight()/2-(height*2*windowScale*scale)/2
        if direction == "" then
          lg.draw(wheel, x, y, 0, 2*windowScale*scale)
        else
          lg.draw(wheels[direction], x, y, 0, 2*windowScale*scale, 2*windowScale*scale)
        end
        for direction, tower in pairs(towers) do
          if (direction == "NE" or direction == "NW" or direction == "SW" or direction == "SE") and tower.wheel then
            local width, height = tower.wheel:getDimensions()
            local _y, _x = lg.getHeight()/2 -height*scale*windowScale*.33, lg.getWidth()/2 - width*scale*windowScale*.33
            local dir = direction:sub(1,1)
            if dir == "N" then
              _y = _y - (width*2*windowScale*scale)/2
            else
              _y = _y + (width*2*windowScale*scale)/2
            end
            if direction:sub(2,2) == (dir == "N" and "W" or "E") then
              _x = _x - (height*2*windowScale*scale)/2 + width*scale*windowScale
            else
              _x = _x + (height*2*windowScale*scale)/2 - width*scale*windowScale
            end
            lg.draw(tower.wheel, _x, _y, 0, windowScale*scale*.75, windowScale*scale*.75)
          end
        end
      end
    end
  
  coordinator.letGo = function()
      if direction ~= "" then
        love.mouse.setVisible(false)
        coordinator.direction = direction
        coordinator.cost = nil
      end
    end
  
  local animations = {}
  
  local removeAnimation = function(animation)
      for index, anim in ipairs(animations) do
        if anim == animation then
          table.remove(animations, index)
          return
        end
      end
    end
  
  coordinator.update = function(dt)
      for _, animations in ipairs(animations) do
        animations:update(dt)
      end
    end
  
  local projectiles = {}
  
  coordinator.addProjectile = function(pType, startX, startY, targetX, targetY)
      local pro = {x=startX, y=startY, pType=pType}
      pro.tween = flux.to(pro, .5, {x=targetX, y=targetY}):ease("linear"):oncomplete(function()
          for index, p in ipairs(projectiles) do
            if p == pro then
              table.remove(projectiles, index)
              return
            end
          end
        end)
      table.insert(projectiles, pro)
    end
  
  local projectileImages = {
      ["NE"] = assets["objects.bullets.green"],
      ["NW"] = assets["objects.bullets.purple"],
      ["SE"] = assets["objects.bullets.red"],
    }
  
  coordinator.draw = function()
      for _, pro in ipairs(projectiles) do
        local image = projectileImages[pro.pType] -- centre pro when drawn
        lg.push()
        local w, h = image:getDimensions()
        lg.translate(pro.x-w/2, pro.y-h/2)
        if type(image) == "table" then
          image:draw(image.image)
        else
          lg.draw(image)
        end
        lg.pop()
      end
    end
  
  local tileW, tileH = 32, 16 -- how many times have I rewrote this
  coordinator.towerHasTarget = function(tile)
      if not tile.target or not tile.tower then
        if tile.animate then
          removeAnimation(tile.animate)
          tile.animate = nil
        end
        return
      end
      
      if not tile.animate then
        tile.animate = towers[tile.tower].attackAnimation:clone(function()
            if tile.animate then
              local y = tile.i * tileH / 2 - tile.j * tileH / 2
              local x = tile.j * tileW / 2 + tile.i * tileW / 2
              local target = require("coordinators.monsters").getMonsterByID(tile.target)
              if target then
                coordinator.addProjectile(tile.tower, x+32, y-118, target.x, target.y-target.height-16)
                removeAnimation(tile.animate)
                tile.animate = nil
              end
            end
          end)
        tile.animate.image = towers[tile.tower].attackAnimation.image
        table.insert(animations, tile.animate)
      end
      tile.animate:gotoFrame(1)
    end
  
  coordinator.mousepressed = function(tile, i, j)
      if direction ~= "" then
        network.send(network.enum.placeTower, i, j, direction)
      end
      coordinator.direction = nil
      direction = ""
      love.mouse.setVisible(true)
    end
  
end