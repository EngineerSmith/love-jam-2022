local args = require("util.args")

local assets = require("util.assets")

local towerCoordinator = {
    towers = {
      ["NE"] = { texture = assets["objects.towers.green"] , price = 50  },
      ["NW"] = { texture = assets["objects.towers.purple"], price = 50  },
      ["SE"] = { texture = assets["objects.towers.red"]   , price = 50  },
      ["SW"] = { texture = assets["objects.towers.test"]  , price = 50  },
    }
  }

if args["-server"] then
  require("coordinators.towers.server")(towerCoordinator)
else
  require("coordinators.towers.client")(towerCoordinator)
end

return towerCoordinator