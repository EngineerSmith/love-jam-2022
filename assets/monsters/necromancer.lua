local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("necromancer") -- must match file name

state:addImage("standing.FR", assets["monster.necromancer.standing"])
state:addImage("standing.BR", assets["monster.necromancer.standing"])
state:addImage("walking.FR", assets["monster.necromancer.standing"])
state:addImage("walking.BR", assets["monster.necromancer.standing"])

return state