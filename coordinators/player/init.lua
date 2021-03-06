local args = require("util.args")

local playerCoordinator = { 
    speed = 100,
  }

if args["-server"] then
  require("coordinators.player.server")(playerCoordinator)
else
  require("coordinators.player.client")(playerCoordinator)
end

return playerCoordinator