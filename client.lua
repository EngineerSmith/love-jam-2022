local logger = require("util.logger")
local loader = require("util.lilyloader")

local lg = love.graphics
local floor = math.floor

local logo = lg.newImage("assets/UI/logoES.png")
logo:setFilter("nearest", "nearest")

local assets = require("util.assets")
assets["fonts.futile.24"] = lg.newFont("assets/fonts/FutilePro.ttf", 24)
assets["fonts.futile.24"]:getFilter("nearest", "nearest")
assets["fonts.futile.21"] = lg.newFont("assets/fonts/FutilePro.ttf", 21)
assets["fonts.futile.21"]:getFilter("nearest", "nearest")
assets["fonts.futile.18"] = lg.newFont("assets/fonts/FutilePro.ttf", 18)
assets["fonts.futile.18"]:getFilter("nearest", "nearest")
assets["fonts.futile.12"] = lg.newFont("assets/fonts/FutilePro.ttf", 12)
assets["fonts.futile.12"]:getFilter("nearest", "nearest")
lg.setFont(assets["fonts.futile.18"])

local scene = { }
local lily
scene.load = function()
  lily = loader()
  logger.info("Loading", lily:getCount(), "assets")
end

local percentage = 0
local timer = nil
scene.update = function(dt)
  percentage = lily:getLoadedCount() / lily:getCount()
  if lily:isComplete() then
    if timer == nil then
      timer = 0
    end
    timer = timer + dt
    if timer >= 1 then
      logger.info("Finished loading, moving to menu")
      require("util.sceneManager").changeScene("client.menu")
    end
  end
end
local w, h = love.graphics.getDimensions()
w, h = floor(w/2), floor(h/2)
scene.resize = function(w_, h_)
  w, h = floor(w_/2), floor(h_/2)
end

local barW, barH = 400, 20
local lineWidth = 2
local lineWidth2, lineWidth4 = lineWidth*2, lineWidth*4
scene.draw = function()
  lg.clear(.1,.1,.1)
  lg.push("all")
  lg.translate(w, h)
  local scale = 8
  lg.draw(logo, 0,0, 0, scale,scale, logo:getWidth()/2, logo:getHeight()/2)
  lg.translate(0, logo:getHeight()*(scale)/1.5)
  lg.translate(-floor(barW/2), -floor(barH/2))
  lg.stencil(function()
      lg.rectangle("fill", lineWidth, lineWidth, barW-lineWidth2, barH-lineWidth2)
    end, "replace", 1)
  lg.setColor(.9,.9,.9)
  lg.setStencilTest("equal", 0)
  lg.rectangle("fill", 0, 0, barW, barH)
  lg.setStencilTest()
  lg.rectangle("fill", lineWidth2, lineWidth2, (barW-lineWidth4)*percentage, barH-lineWidth4)
  local str = lily:getLoadedCount().."/"..lily:getCount()
  lg.pop()
  lg.push()
  lg.translate(w, h)
  lg.print(str, -lg.getFont():getWidth(str)/2, lg.getFont():getHeight()+logo:getHeight()*(scale)/1.5)
  lg.pop()
end

return scene