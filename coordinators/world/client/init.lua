local logger = require("util.logger")

local network = require("network.client")

local assets = require("util.assets")

return function(coordinator)
  
  local world, size
  
  network.addHandler(network.enum.worldData, function(worldData)
      -- process world into something that can be used
      world = worldData
      size = #worldData
    end)
  
  local lg = love.graphics
  
  local heightmap = {
      { assets["tiles.test1"], 0 },
    }
  
  local tileW, tileH = assets["tiles.test1"]:getDimensions()
  tileH = tileH/2
  local getTileForHeight = function(height)
    for _, h in ipairs(heightmap) do
      if height > h[2] then
        return h[1]
      end
    end
  end
  
  coordinator.draw = function()
      if world then
        lg.push()
        lg.translate(0,200)
        lg.scale(2,2)
        for i=1, size do
        for j=size, 1, -1 do
          local target = world[i][j]
          local x = j * tileW / 2 + i * tileW / 2
          local y = i * tileH / 2 - j * tileH / 2
          lg.draw(getTileForHeight(target.height), x, y-math.floor(target.height*3)*10)
        end
        end
        lg.pop()
        
      end
    end
  
end