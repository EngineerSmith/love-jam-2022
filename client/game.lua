local logger = require("util.logger")
local network = require("network.client")

local chat = require("coordinators.chat")

local lg = love.graphics

local scene = { }

scene.load = function(name, address)
  network.connect(address, { name = name })
end

local text = ""
scene.draw = function()
  lg.clear(.1,.1,.1)
  -- camera.attach
  -- camera.detach
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
  text = text .. t
end

scene.keypressed = function(key)
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

return scene