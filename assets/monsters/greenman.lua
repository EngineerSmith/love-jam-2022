local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("greenman") -- must match file name

state:addImage("standing.FR", assets["monster.greenman.standing"])
state:addImage("standing.BR", assets["monster.greenman.standing"])
state:addImage("walking.FR", assets["monster.greenman.standing"])
state:addImage("walking.BR", assets["monster.greenman.standing"])

return state