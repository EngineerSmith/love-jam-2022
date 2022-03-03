local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("shadow") -- must match file name

state:addImage("standing.FR", assets["monster.shadow.standing"])
state:addImage("standing.BR", assets["monster.shadow.standing"])
state:addImage("walking.FR", assets["monster.shadow.standing"])
state:addImage("walking.BR", assets["monster.shadow.standing"])

return state