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
      [1] = assets["tiles.test1"],
    }
  
  local tileW, tileH = assets["tiles.test1"]:getDimensions()
  tileH = tileH
  local getTileForHeight = function(height)
    error("TODO")
  end
  
  coordinator.draw = function()
      if world then
        lg.push()
        lg.translate(50,100)
        for i=1, size do
        for j=size, 1, -1 do
          local target = world[i][j]
          local x = j * tileW / 2 + i * tileW / 2
          local y = i * tileH / 2 - j * tileH / 2
          lg.draw(assets["tiles.test1"], x, y)
        end
        end
        lg.pop()
        
      end
    end
  
end