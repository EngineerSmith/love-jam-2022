local args = require("util.args")

local assets = require("util.assets")

local tower = require("coordinators.towers.tower")

local wall = tower.new(assets["ui.wheel.wall"],  50, 60)
wall:setStateTexture(tower.states.updown, assets["tiles.walls.vertical"])
wall:setStateTexture(tower.states.rightleft, assets["tiles.walls.horizontal"])
wall:setStateTexture(tower.states.upright, assets["tiles.walls.rd"])
wall:setStateTexture(tower.states.rightdown, assets["tiles.walls.ru"])
wall:setStateTexture(tower.states.downleft, assets["tiles.walls.lu"])
wall:setStateTexture(tower.states.upleft, assets["tiles.walls.ld"])

local towerCoordinator = {
    towers = {                                        -- price, health
      ["NE"] = tower.new(assets["objects.towers.green"] , 100, 25),
      ["NW"] = tower.new(assets["objects.towers.purple"], 100, 25),
      ["SE"] = tower.new(assets["objects.towers.red"]   , 100, 25),
      ["SW"] = wall,
    }
  }


if args["-server"] then
  require("coordinators.towers.server")(towerCoordinator)
else
  require("coordinators.towers.client")(towerCoordinator)
end

return towerCoordinator