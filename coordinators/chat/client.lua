local logger = require("util.logger")
local utf8 = require("libs.utf8")

local network = require("network.client")

return function(coordinator)
  coordinator.sendChatMessage = function(message)
      if network.isConnected then
        network.send(network.enum.chatMessage, message)
      end
    end
  
  coordinator.addChatMessage = function(message)
    if utf8.len(message) > 150 then
      message = utf8.sub(message, 1, 150)
    end
    coordinator.chat.insert(message)
  end
  
  network.addHandler(network.enum.chatMessage, coordinator.addChatMessage)
  
  network.addHandler(network.enum.disconnect, function(reason, code)
      coordinator.addChatMessage("Disconnected. Reason: "..tostring(reason)..", Code: "..tostring(code))
    end)
end