local logger = require("util.logger")
local network = require("network.client")

local chat = require("coordinators.chat")
local world = require("coordinators.world")
local player = require("coordinators.player")

local camera = require("libs.stalker-x")()
camera.scale = 2
camera:setFollowLerp(0.2)
camera:setFollowStyle('TOPDOWN')

local lg, lk = love.graphics, love.keyboard
local sqrt = math.sqrt

local scene = { }

scene.load = function(name, address)
  network.connect(address, { name = name })
end

local chatMode = false
scene.update = function(dt)
  --input
  if not chatMode then
    local dirX, dirY = 0, 0
    if lk.isScancodeDown("w", "up") then
      dirY = dirY - 1
    end
    if lk.isScancodeDown("s", "down") then
      dirY = dirY + 1
    end
    if lk.isScancodeDown("a", "left") then
      dirX = dirX - 1
    end
    if lk.isScancodeDown("d", "right") then
      dirX = dirX + 1
    end
    
    if dirX ~= 0 and dirY ~= 0 then
      local dist = sqrt(dirX*dirX+dirY*dirY)
      dirX, dirY = dirX/dist, dirY/dist
    end
    
    player.moveTowardsDirection(dirX, dirY, dt)
    
  end
  -- camera
  camera:update(dt)
  camera:follow(player.position.x, player.position.y)
end

scene.updateNetwork = function()
  player:updateNetwork()
end

local text = ""
scene.draw = function()
  lg.clear(.1,.1,.1)
  camera:attach()
  world.draw()
  lg.setColor(1,0,1)
  lg.rectangle("fill", player.position.x-20, player.position.y-20, 40,40)
  lg.setColor(1,1,1)
  camera:detach()
  camera:draw()
  lg.setColor(1,1,1)
  lg.print(text.."\n"..table.concat(chat.chat, "\n"))
end

scene.threaderror = function(...)
  if network.threaderror(...) then
    return
  end
  logger.error("Unknown thread error!", ...)
end

local utf8 = require("utf8")

scene.textinput = function(t)
  if chatMode then
    text = text .. t
  end
end

scene.keypressed = function(key)
  if key == "tab" then
    chatMode = not chatMode
  end
  if chatMode then
    if key == "backspace" then
      local byteoffset = utf8.offset(text, -1)
      if byteoffset then
        text = text:sub(1, byteoffset-1)
      end
    elseif key == "return" then
      if text == "disconnect" then
        network.disconnect()
      elseif text ~= "" then
        chat.sendChatMessage(text)
        text = ""
      end
    end
  end
end

scene.resize = function(w, h)
  camera.screen_x = w/2
  camera.screen_y = h/2
  camera.w = w
  camera.h = h
end

return scene