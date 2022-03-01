local args = require("util.args")

local assets = require("util.assets")

local towerCoordinator = {
    towers = {
      ["NE"] = { texture = assets["objects.towers.green"]  , price = 100, health = 25 },
      ["NW"] = { texture = assets["objects.towers.purple"] , price = 100, health = 25 },
      ["SE"] = { texture = assets["objects.towers.red"]    , price = 100, health = 25 },
      ["SW"] = { texture = assets["tiles.walls.horizontal"], price =  50, health = 60 },
    }
  }

if args["-server"] then
  require("coordinators.towers.server")(towerCoordinator)
else
  require("coordinators.towers.client")(towerCoordinator)
end

return towerCoordinator