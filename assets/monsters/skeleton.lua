local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("skeleton") -- must match file name

state:addImage("standing.FR", assets["monster.skeleton.standing"])
state:addImage("standing.BR", assets["monster.skeleton.standing"])
state:addImage("walking.FR", assets["monster.skeleton.standing"])
state:addImage("walking.BR", assets["monster.skeleton.standing"])

return state