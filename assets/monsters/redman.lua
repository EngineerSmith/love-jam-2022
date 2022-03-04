local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("redman") -- must match file name

state:addImage("standing.FR", assets["monster.redman.standing"])
state:addImage("standing.BR", assets["monster.redman.standing"])
state:addImage("walking.FR", assets["monster.redman.standing"])
state:addImage("walking.BR", assets["monster.redman.standing"])

return state