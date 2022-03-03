local args = require("util.args")
local assets = require("util.assets")

local monstersCoordinator = {}

local character = require("client.src.character")

monstersCoordinator.monsters = {
    ["shadow"] = { character=character.new(require("assets.monsters.shadow")), health = 20 },
  }

monstersCoordinator.monsterTypes = {
  "shadow",
}

if args["-server"] then
  require("coordinators.monsters.server")(monstersCoordinator)
else
  require("coordinators.monsters.client")(monstersCoordinator)
end

return monstersCoordinator