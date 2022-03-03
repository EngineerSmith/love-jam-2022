local logger = require("util.logger")
local network = require("network.client")

local assets = require("util.assets")
local settings = require("util.settings")

local chat = require("coordinators.chat")
local world = require("coordinators.world")
local player = require("coordinators.player")
local tower = require("coordinators.towers")
local monsters = require("coordinators.monsters")

local character = require("client.src.character")

local suit = require("libs.suit").new()

local lg, lk, lj = love.graphics, love.keyboard, love.joystick
local sqrt = math.sqrt

local joystick

local scene = { }

local canvas, scale
local camera

local showTowerWheel = nil
local showReadyUp = false

scene.resize = function(w, h)
  local width, height = 400, 300
  local scaleW, scaleH = w/width, h/height
  if scaleW > scaleH then
    scale = scaleH
    width = width + (w - width*scale)/scale
  else
    scale = scaleW
    height = height + (h - height*scale)/scale
  end
  canvas = {
    lg.newCanvas(width, height),
    depthstencil = lg.newCanvas(width, height, { format = "depth24" }),
  }
  canvas[1]:setFilter("nearest", "nearest")
  local x, y = player.position and player.position.x or 0, player.position and player.position.y or 0
  camera = require("libs.stalker-x")(x, y, width, height)
  --camera.draw_deadzone = true
  camera:setFollowLerp(0.2)
  camera:setFollowStyle('TOPDOWN')
  world.setCamera(camera)
  player.setCamera(camera)
end

scene.load = function(name, address)
  scene.resize(lg.getDimensions())
  player.setCharacter(character.new(require("assets.characters.duck1")))
  network.connect(address, { name = name })
  local joysticks = lj.getJoysticks()
  if joysticks[1] then
    joystick = joysticks[1]
  end
end

local chatMode = false
local time = 0
scene.update = function(dt)
  time = time + dt
  --input
  local rightX, rightY, rightMag
  if joystick then
    rightX = joystick:getGamepadAxis("rightx")
    rightY = joystick:getGamepadAxis("righty")
    rightMag = sqrt(rightX*rightX+rightY*rightY)
  end
  if not chatMode and not showReadyUp and not world.boolTriggerEarthquake then
    local dirX, dirY = 0, 0
    -- Keyboard
    if lk.isScancodeDown(unpack(settings.client.controls.forward)) then
      dirY = dirY - 1
    end
    if lk.isScancodeDown(unpack(settings.client.controls.backward)) then
      dirY = dirY + 1
    end
    if lk.isScancodeDown(unpack(settings.client.controls.left)) then
      dirX = dirX - 1
    end
    if lk.isScancodeDown(unpack(settings.client.controls.right)) then
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
  if rightMag then
    if rightMag > 0.2 then
      if not showTowerWheel then
        showTowerWheel = love.timer.getTime()
      end
    else
      showTowerWheel = nil
    end
  end
  if showTowerWheel then
    local dirX, dirY = 0,0
    
    if rightMag then
      if rightMag > 0.2 then -- deadzone
        dirX = dirX + rightX
        dirY = dirY + rightY
      end
    else
      dirX, dirY = love.mouse.getPosition()
      dirX, dirY = dirX-lg.getWidth()/2, dirY-lg.getHeight()/2
    end
    
    local mag = 0
    if dirX ~= 0 and dirY ~= 0 then
      mag = sqrt(dirX*dirX+dirY*dirY)
      dirX, dirY = dirX/mag, dirY/mag
    end
    
    tower.mousePosition(dirX, dirY, not rightMag and mag or math.huge, scale)
  end
  if showReadyUp then
    if world.readyUpState then
      local img = player.ready and assets["ui.cross"] or assets["ui.tick"]
      if suit:ImageButton(img, lg.getWidth()/2-img:getWidth()/2, lg.getHeight()/2-img:getHeight()/2).hit then
        player.setReadyState(not player.ready)
        showReadyUp = false
      end
    else
      showReadyUp = false
    end
  end
  -- coordinators
  player.update()
  world.update(dt)
  monsters.update(not world.boolTriggerEarthquake)
  -- camera
  camera:update(dt)
  if not world.boolTriggerEarthquake then
    camera:follow(player.position.x, player.position.y-player.position.height)
  else
    world.triggerEarthquake(dt)
    camera:follow(world.getEarthquakeLocation())
    chatMode = false
  end
end

scene.updateNetwork = function()
  player:updateNetwork()
end

local depthShader = lg.newShader("assets/shaders/depth.glsl")

--[[local canvas = {
    lg.newCanvas(lg.getDimensions()),
    depthstencil = lg.newCanvas(lg.getWidth(), lg.getHeight(), {format="depth32f", readable=true})
  }

local depth = lg.newShader([
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    texturecolor.r = abs(-(texturecolor.r - 0.495) * 10);
    return texturecolor.rrra;
}
])]]

local text = ""
local disabledArrow = false
scene.draw = function()
  lg.push()
  lg.origin()
  lg.setCanvas(canvas)
  lg.clear(.08627,.09019,.10196)
  lg.setColor(1,1,1)
  camera:attach()
  if world.depthScale then
    lg.push("all")
    lg.setDepthMode("less", true)
    lg.setShader(depthShader)
    lg.setFont(assets["fonts.futile.12"])
    world.draw(depthShader)
    if tower.direction then
      local x, y = love.mouse.getPosition()
      local mx, my = camera:toWorldCoords(x/scale, y/scale)
      local tile, i, j = world.getTile(mx, my-6)
      local _, pi, pj = world.getTile(player.position.x, player.position.y)
      local a, b = i-pi, j-pj
      local mag = sqrt(a*a+b*b)
      disabledArrow = mag > 5 or tile.texture == nil or tile.texture == 0 or tile.tower ~= nil or tile.earthquake ~= nil -- todo check for player
      world.drawArrowAt(tile, i, j, disabledArrow)
    end
    monsters.draw()
    lg.setFont(assets["fonts.futile.18"])
    player.draw()
    lg.pop()
  end
  camera:detach()
  camera:draw()
  lg.setCanvas()
  --[[lg.setCanvas()
  lg.clear(.1,.1,.1)
  lg.setBlendMode("alpha", "premultiplied")
  if not chatMode then
    lg.draw(canvas[1])
  else
    lg.setShader(depth)
    lg.draw(canvas.depthstencil)
    lg.setShader()
  end
  lg.setBlendMode("alpha")]]
  lg.clear(.1,.1,.1)
  lg.push("all")
  lg.setBlendMode("alpha", "premultiplied")
  lg.draw(canvas[1], 0,0, 0, scale, scale)
  lg.pop()
  chat.draw(chatMode, text, time)
  tower.draw(showTowerWheel, scale)
  player.drawUI(scale, tower.cost)
  if showReadyUp then
    lg.push("all")
    lg.setColor(.7,.7,.7,.3)
    lg.rectangle("fill",0,0,lg.getDimensions())
    lg.setColor(1,1,1,1)
    lg.setFont(assets["fonts.futile.28"])
    local readyStr = "Ready up?"
    lg.print(readyStr, math.floor(lg.getWidth()/2-lg.getFont():getWidth(readyStr)/2), math.floor(lg.getHeight()/2)-lg.getFont():getHeight()-assets["ui.tick"]:getHeight()/2*1.1)
    lg.pop()
  end
  suit:draw()
  lg.pop()
end

scene.threaderror = function(...)
  if network.threaderror(...) then
    return
  end
  logger.error("Unknown thread error!", ...)
end

local utf8 = require("utf8")

local switch = false
scene.textinput = function(t)
  if chatMode then
    if switch then
      for _, chatButton in ipairs(settings.client.controls.chat) do
        if t == chatButton then
          return
        end
      end
    end
    local len = utf8.len(text..t)
    if len <= 100-8 then
      text = text .. t
    end
  end
  switch = false
end

scene.keypressed = function(key, scancode)
  if not showReadyUp and not showTowerWheel and not chatMode and not world.boolTriggerEarthquake then
    for _, chatButton in ipairs(settings.client.controls.chat) do
      if chatButton == scancode then
        chatMode = not chatMode
        text = ""
        switch = true
        return
      end
    end
  end
  if chatMode and (key == "tab" or key == "escape") then
    text = ""
    chatMode = false
  end
  if showReadyUp and key == "escape" then
    showReadyUp = false
  end
  if chatMode then
    if key == "backspace" then
      local byteoffset = utf8.offset(text, -1)
      if byteoffset then
        text = text:sub(1, byteoffset-1)
      end
    elseif key == "return" then
      if text == "disconnect" then
        text = ""
        network.disconnect()
        chat.clear()
        require("util.sceneManager").changeScene("client.menu", "normal")
      elseif text ~= "" then
        chat.sendChatMessage(text)
        text = ""
        chatMode = false
      end
    end
  end
  if not world.boolTriggerEarthquake and not showTowerWheel and world.readyUpState and scancode == "space" then
    showReadyUp = not showReadyUp
  end
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

local tileW, tileH = 32, 16
local oldX, oldY
scene.mousepressed = function(x, y, button)
  if button == 2 and not chatMode and not showReadyUp and not world.boolTriggerEarthquake then
    oldX, oldY = x, y
    love.mouse.setPosition(lg.getWidth()/2, lg.getHeight()/2)
    showTowerWheel = love.timer.getTime()
  end
  if button == 1 and tower.direction and not disabledArrow then
    local mx, my = camera:toWorldCoords(x/scale, y/scale)
    local tile, i, j = world.getTile(mx, my-6)
    if tile then
      tower.mousepressed(tile, i, j)
    end
  end
end

scene.mousereleased = function(x, y, button)
  if not chatMode and not world.boolTriggerEarthquake and not showReadyUp then
    if button == 2 and showTowerWheel then
      love.mouse.setPosition(oldX, oldY)
      showTowerWheel = nil
      tower.letGo()
    end
  end
end

return scene