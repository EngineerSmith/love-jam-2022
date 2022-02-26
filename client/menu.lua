local scene = { }

local lg = love.graphics

scene.load = function()
  require("util.sceneManager").changeScene("client.game", "Chole", "localhost:20202")
end

scene.draw = function()
  lg.clear(.1,.1,.1)
  lg.print("TODO")
end

return scene