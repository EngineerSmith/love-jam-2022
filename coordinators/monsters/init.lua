local args = require("util.args")
local assets = require("util.assets")

local monstersCoordinator = {}

local character = require("client.src.character")

monstersCoordinator.monsters = {
    ["shadow"] = { character=character.new(require("assets.monsters.shadow")), health = 20, speedMul = 1, damage = 9, attackspeed = 1 },
    ["goldengolem"] = { character=character.new(require("assets.monsters.goldengolem")), health = 40, speedMul = .6, damage = 15, attackspeed = 1.2 },
  }

monstersCoordinator.monsterTypes = {
  "shadow",
  "goldengolem",
}

if args["-server"] then
  require("coordinators.monsters.server")(monstersCoordinator)
else
  require("coordinators.monsters.client")(monstersCoordinator)
end

return monstersCoordinator