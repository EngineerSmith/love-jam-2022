local logger = require("util.logger")

local scene = { }

local loader = require("util.serverLoader")

scene.load = function(port)
  logger.info("Server loading assets")
  loader()
  logger.info("Switching to main loop")
  require("util.sceneManager").changeScene("server.main")
end

return scene