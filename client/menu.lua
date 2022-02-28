local settings = require("util.settings")
local suit = require("libs.suit").new()

local lg = love.graphics
lg.setNewFont(15)

local scene = { }

scene.load = function()
  
end

local showSettings = false
local showGameMenu = false

local lowGraphics = { text = "Low Graphics", checked = settings.client.lowGraphics }

scene.update = function()
  local w, h = lg.getDimensions()
  suit.layout:reset(w-200, h-30)
  suit.layout:up(150,30)
  suit.layout:padding(10,10)
  if not showSettings and not showGameMenu then
    if suit:Button("Quit", suit.layout:up()).hit then
      love.event.quit()
    end
    showSettings = suit:Button("Settings", suit.layout:up()).hit
    showGameMenu = suit:Button("Start", suit.layout:up()).hit
  end
  if showGameMenu or showSettings then
    if suit:Button("Back", suit.layout:up()).hit then
      showGameMenu = false
      showSettings = false
    end
  end
  if showGameMenu and not showSettings then
    if suit:Button("Connect", suit.layout:up()).hit then
      require("util.sceneManager").changeScene("client.game", "James", "localhost:20202")
    end
  end
  if showSettings and not showGameMenu then
    if suit:Checkbox(lowGraphics, {align='right'}, suit.layout:up()).hit then
      settings.client.lowGraphics = lowGraphics.checked
    end
  end
end

scene.draw = function()
  lg.clear(.1,.1,.1)
  lg.setColor(1,0,1)
  lg.rectangle("fill", 0,0, lg.getDimensions())
  lg.setColor(1,1,1)
  suit:draw()
end

return scene