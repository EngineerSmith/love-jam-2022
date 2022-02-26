local logger = require("util.logger")

local network = require("network.client")

local assets = require("util.assets")

return function(coordinator)
  
  local world
  
  network.addHandler(network.enum.worldData, function(worldData)
      -- process world into something that can be used
      world = worldData
    end)
  
  local lg = love.graphics
  
  local heightmap = {
      [0] = assets["tiles.test1"],
      [1] = assets["tiles.test2"],
      [2] = assets["tiles.test3"],
      [3] = assets["tiles.test1"],
      [4] = assets["tiles.test1"],
      [5] = assets["tiles.test1"],
      [6] = assets["tiles.test1"],
      [7] = assets["tiles.test1"],
      [8] = assets["tiles.test1"],
      [9] = assets["tiles.test1"],
    }
  
  local tileW, tileH = assets["tiles.test1"]:getDimensions()
  tileH = tileH/2
  local getTileForHeight = function(height)
    return heightmap[height]
  end
  
  coordinator.draw = function()
      if world then
        lg.push()
        for i=0, #world do
          if world[i] then
        for j=#world[i], 0, -1 do
          local target = world[i][j]
          if target and target.height then
            local x = j * tileW / 2 + i * tileW / 2
            local y = i * tileH / 2 - j * tileH / 2
            local img = getTileForHeight(target.height)
            if img then
              lg.draw(img, x, y-math.floor(target.height)*10)
            else
              print(target.height)
            end
          end
        end
          end
        end
        lg.pop()
        
      end
    end
  
end