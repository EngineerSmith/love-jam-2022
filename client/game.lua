local logger = require("util.logger")
local network = require("network.client")

local assets = require("util.assets")

local chat = require("coordinators.chat")
local world = require("coordinators.world")
local player = require("coordinators.player")

local character = require("client.src.character")

local camera = require("libs.stalker-x")()
camera.scale = 2
camera:setFollowLerp(0.2)
camera:setFollowStyle('TOPDOWN')

local lg, lk, lj = love.graphics, love.keyboard, love.joystick
local sqrt = math.sqrt

local joystick

local scene = { }

scene.load = function(name, address)
  player.setCharacter(character.new(require("assets.characters.duck1")))
  network.connect(address, { name = name })
  local joysticks = lj.getJoysticks()
  if joysticks[1] then
    joystick = joysticks[1]
  end
end

local chatMode = false
scene.update = function(dt)
  --input
  if not chatMode then
    local dirX, dirY = 0, 0
    -- Keyboard
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
    
    if joystick then
      local leftX = joystick:getGamepadAxis("leftx")
      local leftY = joystick:getGamepadAxis("lefty")
      local mag = sqrt(leftX*leftX+leftY*leftY)
      if mag > 0.2 then -- deadzone
        dirX = dirX + leftX
        dirY = dirY + leftY
      end
    end
    
    if not (dirX == 0 and dirY == 0) then
      local dist = sqrt(dirX*dirX+dirY*dirY)
      dirX, dirY = dirX/dist, dirY/dist
    end
    
    player.moveTowardsDirection(dirX, dirY, dt)
    
  end
  -- coordinators
  player.update()
  world.update(dt)
  -- camera
  camera:update(dt)
  camera:follow(player.position.x, player.position.y-player.position.height)
end

scene.updateNetwork = function()
  player:updateNetwork()
end

local depthShader = lg.newShader("assets/shaders/depth.glsl")

--[[local canvas = {
    lg.newCanvas(lg.getDimensions()),
    depthstencil = lg.newCanvas(lg.getWidth(), lg.getHeight(), {format="depth32f", readable=true})
  }]]

--[[local depth = lg.newShader([
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    texturecolor.r = abs(-(texturecolor.r - 0.495) * 10);
    return texturecolor.rrra;
}
])]]

local text = ""
scene.draw = function()
  --lg.setCanvas(canvas)
  lg.clear(.1,.1,.1)
  lg.setColor(1,1,1)
  camera:attach()
  if world.depthScale then
    lg.push("all")
    lg.setDepthMode("less", true)
    lg.setShader(depthShader)
    world.draw(depthShader)
    player.draw()
    lg.pop()
  end
  camera:detach()
  camera:draw()
  --lg.setCanvas()
  --lg.clear(.1,.1,.1)
  --lg.setBlendMode("alpha", "premultiplied")
  --if not chatMode then
    --lg.draw(canvas[1])
  --[[else
    lg.setShader(depth)
    lg.draw(canvas.depthstencil)
    lg.setShader()
  end]]
  --lg.setBlendMode("alpha")
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
        -- TODO go back to menu
        love.event.quit()
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

scene.joystickadded = function(js)
  joystick = js
end

scene.joystickremoved = function(js)
  if joystick == js then
    local joysticks = lj.getJoysticks()
    if joysticks[1] then
      joystick = joysticks[1]
    end
  end
end

return scene