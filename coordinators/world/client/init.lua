local logger = require("util.logger")

local network = require("network.client")

local assets = require("util.assets")

return function(coordinator)
  
  local tileW, tileH = 32, 16
  
  local world
  
  network.addHandler(network.enum.worldData, function(worldData)
      -- process world into something that can be used
      world = worldData
      
      -- LAZY CODE TO FIND SMALLEST AND BIGGEST Y
      local small, big = 0, 0
      for i=0, #world do
          if world[i] then
      for j=#world[i], 0, -1 do
        local target = world[i][j]
        if target then
          local y = i * tileH / 2 - j * tileH / 2
          if small > y then
            small = y
          end
          if big < y then
            big = y
          end
        end
      end
        end
      end
      coordinator.depthScale = big > math.abs(small) and big or math.abs(small)
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
  
  local getTileForHeight = function(height)
    return heightmap[height]
  end
  
  coordinator.draw = function(shader)
      if world then
        lg.push()
        shader:send("scale", tileH*2)
        for i=0, #world do
          if world[i] then
        for j=#world[i], 0, -1 do
          local target = world[i][j]
          if target and target.height then
            local x = j * tileW / 2 + i * tileW / 2
            local y = i * tileH / 2 - j * tileH / 2
            local img = getTileForHeight(target.height)
            local height = target.height*tileH/2
            shader:send("z", (y-tileH)/coordinator.depthScale)
            if type(img) == "table" then
              img:draw(img.image, x, y-height)
            else
              lg.draw(img, x, y-height)
            end
          end
        end
          end
        end
        lg.pop()
      end
    end
  
  coordinator.getHeightAtPoint = function(x, y)
      local a = x/tileW
      local b = y/tileH
      local i = math.floor(a + b)
      local j = math.floor(a - b)
      if world and world[i] and world[i][j] then
        local target = world[i][j]
        if target.height then
          return target.height * tileH/2
        end
      end
      return 0
    end
  
end