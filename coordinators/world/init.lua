local args = require("util.args")

local worldCoordinator = { }

if args["-server"] then
  require("coordinators.world.server")(worldCoordinator)
else
  require("coordinators.world.client")(worldCoordinator)
end

return worldCoordinator