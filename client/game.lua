local logger = require("util.logger")
local network = require("network.client")

local scene = { }

scene.load = function(name, address)
  network.connect(address, { name = name })
end

scene.threaderror = function(...)
  if network.threaderror(...) then
    return
  end
  logger.error("Unknown thread error!", ...)
end

return scene