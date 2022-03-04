local args = require("util.args")
local assets = require("util.assets")

local monstersCoordinator = {}

local character = require("client.src.character")

monstersCoordinator.monsters = {
    ["shadow"] = { character=character.new(require("assets.monsters.shadow")), health = 20, speedMul = 1, damage = 9, attackspeed = 1 },
    ["goldengolem"] = { character=character.new(require("assets.monsters.GoldenGolem")), health = 40, speedMul = 1.4, damage = 15, attackspeed = 1.2 },
    ["necromancer"] = { character=character.new(require("assets.monsters.necromancer")), health = 20, speedMul = .6, damage = 15, attackspeed = .8 },
    ["redman"] = { character=character.new(require("assets.monsters.redman")), health = 20, speedMul = .9, damage = 10, attackspeed = .9 },
    ["greenman"] = { character=character.new(require("assets.monsters.greenman")), health = 20, speedMul = .9, damage = 10, attackspeed = .9 },
    ["skeleton"] = { character=character.new(require("assets.monsters.greenman")), health = 40, speedMul = 1.2, damage = 20, attackspeed = 1.5 },
  }

monstersCoordinator.monsterTypes = {
  "shadow",
  "goldengolem",
  "necromancer",
  "redman",
  "greenman",
  "skeleton",
}

if args["-server"] then
  require("coordinators.monsters.server")(monstersCoordinator)
else
  require("coordinators.monsters.client")(monstersCoordinator)
end

return monstersCoordinator