local noise = love.math.noise

local buffer = require("string.buffer")

local worldGen = function()
  local file = love.filesystem.newFileData("coordinators/world/server/world.base64")
  local encodedMap = love.data.decode("string", "base64", file)
  return buffer.decode(encodedMap)
end

return worldGen