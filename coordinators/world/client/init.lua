local logger = require("util.logger")
local network = require("network.client")

local assets = require("util.assets")
local flux = require("libs.flux")

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
  
  local texturemap = {
      [0] = assets["tiles.water2"],
      [1] = assets["tiles.sand"],
      [2] = assets["tiles.grass"],
      [3] = assets["tiles.test1"],
      [4] = assets["tiles.test1"],
      [5] = assets["tiles.test1"],
      [6] = assets["tiles.test1"],
      [7] = assets["tiles.test1"],
      [8] = assets["tiles.test1"],
      [9] = assets["tiles.test1"],
    }
  
  local textureOptions = {
      [1] = {
          assets["tiles.debris.sand1"],
          assets["tiles.debris.sand2"],
          assets["tiles.debris.sand3"],
        },
      [2] = {
          assets["tiles.debris.grass1"],
          assets["tiles.debris.grass2"],
          assets["tiles.debris.grass3"],
          assets["tiles.debris.grass4"],
        },
    }
  
  local getTexture = function(textureID)
    return texturemap[textureID]
  end
  
  local time = 0
  coordinator.update = function(dt)
    time = time + dt
  end
  
  local rand = function(seed)
    local x = math.sin(seed) * 43758.5453123
    return x-math.floor(x)
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
            local img = getTexture(target.texture or 0)
            local height = target.height*tileH/2
            if target.texture == 0 or not target.texture then
              height = height + math.sin(x+y+time*1.25)*4.5
              -- Water dancing
            end
            shader:send("z", (y-tileH)/coordinator.depthScale)
            if type(img) == "table" then
              img:draw(img.image, x, y-height)
            else
              lg.draw(img, x, y-height)
            end
            local options = textureOptions[target.texture or 0]
            if options then
              local n = math.floor((rand(x * #world + y) * (#options*10)) + 1)
              if n <= #options then
                lg.push("all")
                lg.setDepthMode("always", true)
                lg.draw(options[n], x, y-height)
                lg.pop()
              end
            end
          end
        end
          end
        end
        lg.pop()
      end
    end
    
  local getTile = function(world, x, y)
      local a = x/tileW
      local b = y/tileH
      local i = math.floor(a + b)
      local j = math.floor(a - b)
      if world and world[i] and world[i][j] then
        return world[i][j]
      end
    end
  
  coordinator.getHeightAtPoint = function(x, y)
      local target = getTile(world, x, y)
      if target and target.height then
        return target.height * tileH/2
      end
      return 0
    end
  
  coordinator.canWalkAtPoint = function(x, y)
    local target = getTile(world, x, y)
    if target and target.notWalkable ~= nil then
      return not target.notWalkable
    end
    return true
  end
  
  coordinator.foreignPlayers = {}
  
  network.addHandler(network.enum.foreignPlayers, function(players)
      if network.hash then
        for _, player in ipairs(players) do
          if coordinator.foreignPlayers[player.clientID] then
            local target = coordinator.foreignPlayers[player.clientID]
            local tween = target.tween
            if target.tween then
              target.tween:stop()
            end
            target.tween = flux.to(target.position, 0.1, player.position)
            target.character = player.charactr or "duck1"
          elseif player.clientID ~= network.hash then
            coordinator.foreignPlayers[player.clientID] = {
                name      = player.name,
                position  = player.position,
                character = player.character or "duck1",
              }
          end
        end
      end
    end)
  
end