local args = require("util.args")

local chatCoordinator = {
    chatLimit = 10,
  }

local insert = function(message)
  if #chatCoordinator.chat == chatCoordinator.chatLimit then
    table.remove(chatCoordinator.chat, 1)
  end
  table.insert(chatCoordinator.chat, message)
end

local clear
clear = function()
  chatCoordinator.chat = {}
  chatCoordinator.chat.insert = insert
  chatCoordinator.chat.clear = clear
end

clear()

if args["-server"] then
  require("coordinators.chat.server")(chatCoordinator)
else
  require("coordinators.chat.client")(chatCoordinator)
end

return chatCoordinator