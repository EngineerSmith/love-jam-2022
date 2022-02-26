local args = require("util.args")

local chatCoordinator = {
    chat = { },
    chatLimit = 100,
  }

chatCoordinator.chat.insert = function(message)
  if #chatCoordinator.chat == chatCoordinator.chatLimit then
    table.remove(chatCoordinator.chat, 100)
  end
  table.insert(chatCoordinator.chat, 1, message)
end

if args["-server"] then
  require("coordinators.chat.server")(chatCoordinator)
else
  require("coordinators.chat.client")(chatCoordinator)
end

return chatCoordinator