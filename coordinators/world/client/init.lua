local logger = require("util.logger")
local network = require("network.client")
local settings = require("util.settings")

local assets = require("util.assets")
local flux = require("libs.flux")

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

return function(coordinator)
  
  local tileW, tileH = 32, 16
  
  local world
  local sea, seaOffset
  
  network.addHandler(network.enum.worldData, function(worldData)
      -- process world into something that can be used
      world = worldData
      
      -- LAZY CODE TO FIND SMALLEST AND BIGGEST Y
      local small, big = 0, 0
      local smallx, bigx = 0,0
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
          local x = j * tileW / 2 + i * tileW / 2
          if smallx > x then
            smallx = x
          end
          if bigx < x then
            bigx = x
          end
        end
      end
        end
      end
      coordinator.depthScale = big > math.abs(small) and big or math.abs(small)
      if settings.client.lowGraphics then
        local canvas = lg.newCanvas(bigx-smallx, big-small)
        seaOffset = small
        lg.push("all")
        lg.translate(-smallx, -small-4)
        lg.setCanvas(canvas)
        for i=0, #world do
          if world[i] then
        for j=#world[i], 0, -1 do
          local target = world[i][j]
          if target and (target.texture or 0) == 0 then
            local y = i * tileH / 2 - j * tileH / 2
            local x = j * tileW / 2 + i * tileW / 2
            texturemap[0]:draw(texturemap[0].image, x, y-4)
          end
        end
          end
        end
        lg.pop()
        sea = lg.newImage(canvas:newImageData())
      end
    end)
  
  local getTexture = function(textureID)
    return texturemap[textureID]
  end
  
  coordinator.foreignPlayers = {} -- added to later
  
  local time = 0
  coordinator.update = function(dt)
    time = time + dt
    for _, player in pairs(coordinator.foreignPlayers) do
      local char = player.character
      local x, y = player.position.x, player.position.y
      local w, h = char:getDimensions()
      w = w/2.5
      local height1 = coordinator.getHeightAtPoint(x-w, y)
      local height2 = coordinator.getHeightAtPoint(x+w, y)
      local height = height1 > height2 and height1 or height2
      local height3 = coordinator.getHeightAtPoint(x  , y)
      height = height > height3 and height or height3
      if height ~= player.position.height then
        if player.heightTween then
          player.heightTween:stop()
        end
        player.heightTween = flux.to(player.position, 0.1, {height=height})
      end
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
  
  local getState = function(oldX, oldY, newX, newY)
      local moving = true
      if oldX == newX and oldY == newY then
        moving = false
      end
      local direction = nil
      if moving then
        local dirX, dirY = newX-oldX, newY-oldY
        local mag = math.sqrt(dirX*dirX+dirY*dirY)
        dirX, dirY = dirX/mag, dirY/mag
        if dirY >= 0 then
          direction = "F"
        else
          direction = "B"
        end
        if dirX > -0.1 then
          direction = direction.."R"
        else
          direction = direction.."L"
        end
      end
      return moving and "walking" or "standing", direction
    end
  
  local character = require("client.src.character")  
  
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
            if target.character.id ~= player.character then
              local success, state = pcall(require, "assets.characters."..(player.character or "duck1"))
              if not success then
                state = require("assets.characters.duck1")
              end
              target.character.characterState = state
            end
            local state, facing = getState(target.position.x, target.position.y, player.position.x, player.position.y)
            target.character:setState(state)
            if facing then
              target.character:setDirection(facing)
            end
          elseif player.clientID ~= network.hash then
            logger.info("Making character for", player.name)
            local success, state = pcall(require, "assets.characters."..(player.character or "duck1"))
            if not success then
              state = require("assets.characters.duck1")
            end
            player.position.height = 0
            coordinator.foreignPlayers[player.clientID] = {
                name      = player.name,
                position  = player.position,
                character = character.new(state),
              }
          end
        end
      end
    end)
  
  network.addHandler(network.enum.foreignDisconnect, function(clientID)
      coordinator.foreignPlayers[clientID] = nil
    end)
  
  local rand = function(seed)
    local x = math.sin(seed) * 43758.5453123
    return x-math.floor(x)
  end
  
  coordinator.draw = function(shader)
      if world then
        if sea then
          shader:send("scale", sea:getHeight()/4)
          shader:send("z", -4)
          lg.draw(sea, 0, seaOffset)
        end
        lg.push()
        shader:send("scale", tileH*2)
        for i=0, #world do
          if world[i] then
        for j=#world[i], 0, -1 do
          local target = world[i][j]
          if target and target.height then
            if sea and target.texture == 0 or target.texture == nil then
              goto continue
            end
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
          ::continue::
        end
          end
        end
        lg.pop()
      end
      for _, player in pairs(coordinator.foreignPlayers) do
        lg.push("all")
        local char = player.character
        local x, y = player.position.x, player.position.y
        local height = player.position.height
        local w, h = char:getDimensions()
        lg.translate(x-w/2, y-height-h/1.5)
        local z = (y-h/1.5)/coordinator.depthScale
        char:draw(z)
        lg.push("all")
        lg.setShader()
        lg.setDepthMode("always", false)
        lg.print(player.name, 0, -10)
        lg.pop()
        lg.pop()
      end
    end
  
end