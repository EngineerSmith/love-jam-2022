local network = require("network.server")

local scene = { }

scene.load = function(port)
  network.start(port)
end

return scene