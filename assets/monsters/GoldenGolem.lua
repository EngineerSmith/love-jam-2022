local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("GoldenGolem") -- must match file name

state:addImage("standing.FR", assets["monster.goldengolem.standing"])
state:addImage("standing.BR", assets["monster.goldengolem.standing"])
state:addImage("walking.FR", assets["monster.goldengolem.standing"])
state:addImage("walking.BR", assets["monster.goldengolem.standing"])

return state