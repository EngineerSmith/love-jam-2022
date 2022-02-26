local scene = { }

scene.load = function()
  require("util.sceneManager").changeScene("client.game", "Chole", "localhost:20202")
end

scene.draw = function()
  love.graphics.clear(.1,.1,.1)
  love.graphics.print("TODO")
end

return scene