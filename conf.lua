local identity = "love-jam-2022-ES"
love.filesystem.setIdentity(identity, true)

local args = require("util.args")
local settings = require("util.settings")

local baseConf = function(t)
  t.identity = identity
  t.appendidentity = true
  t.version = "11.4"
  t.console = true
  t.accelerometerjoystick = false
  
  t.modules.sound = false
  t.modules.touch = false
  t.modules.video = false
  t.modules.physics = false
end

if args["-server"] then
  love.conf = function(t)
    baseConf(t)
    t.window.title = "Server"
    
    t.modules.data = true
    t.modules.event = true
    t.modules.math = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    
    t.modules.audio = false
    t.modules.font = false
    t.modules.graphics = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.mouse = false
    t.modules.window = false
  end
else
  love.conf = function(t)
    baseConf(t)
    t.gammacorrect = true
    
    t.window.title = "Battle for Egg Island"
    t.window.icon = nil
    t.window.resizable = true
    t.window.display = 1
    t.window.highdpi = true
    t.window.depth = 24
    t.window.width = settings.client.windowsize.width
    t.window.height = settings.client.windowsize.height
    t.window.minwidth = settings._default.client.windowsize.width
    t.window.minheight = settings._default.client.windowsize.height
    t.window.fullscreen = settings.client.windowfullscreen
    
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.window = true
  end
end