local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new("duck1") -- must match file name

state:addImage("standing.FR", assets["characters.duck1.standing1"])
state:addImage("standing.BR", assets["characters.duck1.standing2"])
state:addImage("walking.FR", assets["characters.duck1.walking1"])
state:addImage("walking.BR", assets["characters.duck1.walking2"])

return state