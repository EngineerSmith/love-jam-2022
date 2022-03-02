local args = require("util.args")

local monstersCoordinator = {}

if args["-server"] then
  require("coordinators.monsters.server")(monstersCoordinator)
else
  require("coordinators.monsters.client")(monstersCoordinator)
end

return monstersCoordinator