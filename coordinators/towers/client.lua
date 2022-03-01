local network = require("network.client")
local assets = require("util.assets")

local world = require("coordinators.world")

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
  coordinator.draw = function(showWheel, windowScale)
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
          local width, height = tower.texture:getDimensions()
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
          lg.draw(tower.texture, _x, _y, 0, windowScale*scale*.75, windowScale*scale*.75)
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
  
  coordinator.mousepressed = function(tile, i, j)
      if direction ~= "" then
        network.send(network.enum.placeTower, i, j, direction)
      end
      coordinator.direction = nil
      direction = ""
      love.mouse.setVisible(true)
    end
  
end