local logger = require("util.logger")
local loader = require("util.lilyLoader")

local floor = math.floor

local scene = {}
local lily
scene.load = function()
  love.graphics.setBackgroundColor(.1,.1,.1)
  lily = loader()
end

local percentage = 0
scene.update = function(dt)
  percentage = lily:getLoadedCount() / lily:getCount()
  if lily:isComplete() then
    --require("util.sceneManager").changeScene("client.menu")
  end
end
local w, h = love.graphics.getDimensions()
w, h = floor(w/2), floor(h/2)
scene.resize = function(w_, h_)
  w, h = floor(w_/2), floor(h_/2)
end

local lg = love.graphics
local barW, barH = 400, 20
local lineWidth = 2
local lineWidth2, lineWidth4 = lineWidth*2, lineWidth*4
scene.draw = function()
  lg.push("all")
  local x, y = w-floor(barW/2), h-floor(barH/2)
  lg.translate(x, y)
  lg.stencil(function()
      lg.rectangle("fill", lineWidth, lineWidth, barW-lineWidth2, barH-lineWidth2)
    end, "replace", 1)
  lg.setStencilTest("equal", 0)
  lg.rectangle("fill", 0, 0, barW, barH)
  lg.setStencilTest()
  lg.rectangle("fill", lineWidth2, lineWidth2, (barW-lineWidth4)*percentage, barH-lineWidth4)
  lg.pop()
end

return scene