local args = require("util.args")

local towerCoordinator = {
  }

if args["-server"] then
  require("coordinators.towers.server")(towerCoordinator)
else
  require("coordinators.towers.client")(towerCoordinator)
end

return towerCoordinator