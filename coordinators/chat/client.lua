local logger = require("util.logger")
local utf8 = require("libs.utf8")
local assets = require("util.assets")

local network = require("network.client")

return function(coordinator)
  coordinator.sendChatMessage = function(message)
      if network.isConnected then
        network.send(network.enum.chatMessage, message)
      end
    end
  
  coordinator.addChatMessage = function(message)
    if utf8.len(message) > 100 then
      message = utf8.sub(message, 1, 100)
    end
    coordinator.chat.insert(message)
  end
  
  coordinator.clear = function()
      coordinator.chat.clear()
    end
  
  network.addHandler(network.enum.gamelost, function()
      coordinator.addChatMessage("Game has been lost! Type 'disconnect' in chat to leave. Server will auto restart.")
    end)
  
  network.addHandler(network.enum.chatMessage, coordinator.addChatMessage)
  
  network.addHandler(network.enum.disconnect, function(reason, code)
      coordinator.addChatMessage("Disconnected. Reason: "..tostring(reason)..", Code: "..tostring(code))
    end)
  
  local lg = love.graphics
  coordinator.draw = function(chatMode, text, time)
    lg.push("all")
    local font = assets["fonts.futile.21"]
    lg.setFont(font)
    local width = lg.getWidth()/10*4 + 10
    local height = font:getHeight() + 5
    lg.setColor(.3,.3,.3,.7)
    if chatMode then
      lg.rectangle("fill", -8, lg.getHeight()-height*9, width+8, height*9+8, 8)
      lg.setColor(.2,.2,.2,.7)
      lg.rectangle("fill", 0, lg.getHeight()-height, width, height)
      lg.setColor(1,1,1,1)
      lg.print("> "..text, 7, lg.getHeight()-height)
      local chat = {}
      for i=#coordinator.chat, math.max(#coordinator.chat-8, 1), -1 do
        local _, txt = font:getWrap(coordinator.chat[i], width)
        for j=#txt, 1, -1 do
          if #chat < 8 then
            table.insert(chat, txt[j])
          else
            break
          end
        end
      end
      for i, text in ipairs(chat) do
        lg.print(text, 7, lg.getHeight()-height*i-height)
      end
    elseif #coordinator.chat > 0 then
      local chat = {}
      for i=#coordinator.chat, math.max(#coordinator.chat-3, 1), -1 do
        local _, txt = font:getWrap(coordinator.chat[i], width)
        for j=#txt, 1, -1 do
          if #chat < 3 then
            table.insert(chat, txt[j])
          end
        end
      end
      lg.rectangle("fill", -8, lg.getHeight()-height*3, width+8, height*3+8, 8)
      lg.setColor(1,1,1)
      for i, text in ipairs(chat) do
        lg.print(text,7, lg.getHeight()-height*i)
      end
    end
    lg.pop()
    end
end