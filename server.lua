local scene = { }

scene.load = function(port)
  require("util.sceneManager").changeScene("server.main")
end

return scene