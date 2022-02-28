local assets = require("util.assets")
local characterState = require("client.src.characterState")

local state = characterState.new()

state:addImage("standing.FR", assets["characters.duck1.standing1"])
state:addImage("standing.BR", assets["characters.duck1.standing1"])
state:addImage("walking.FR", assets["characters.duck1.walking1"])
state:addImage("walking.BR", assets["characters.duck1.walking1"])

return state