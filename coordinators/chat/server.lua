local logger = require("util.logger")
local utf8 = require("libs.utf8")

local network = require("network.server")

return function(coordinator)
  coordinator.sendChatMessage = function(message)
      network.sendAll(network.enum.chatMessage, message)
    end
  
  coordinator.sendTargetedChatMessage = function(client, message)
      network:send(client, network.enum.chatMessage, message)
    end
  
  coordinator.recieveChatMessage = function(client, message)
      local len = utf8.len(message)
      if len == 0 then
        return
      end
      if len > 100 then
        message = utf8.sub(message, 1, 100)
      end
      coordinator.sendChatMessage(client.name.."> "..message)
    end
  
  network.addHandler(network.enum.chatMessage, coordinator.recieveChatMessage)
  
  network.addHandler(network.enum.confirmConnection, function(client) 
      coordinator.sendChatMessage(client.name.." has joined the game")
    end)
  
  network.addHandler(network.enum.disconnect, function(client)
      coordinator.sendChatMessage(client.name.." has left the game")
    end)
  
end