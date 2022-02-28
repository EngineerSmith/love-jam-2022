local settings = require("util.settings")
local assets = require("util.assets")
local suit = require("libs.suit").new()

local lg = love.graphics
lg.setNewFont(15)

local scene = { }

scene.load = function()
  
end

local showSettings = false
local showGameMenu = false

local lowGraphics = { text = "Low Graphics", checked = settings.client.lowGraphics }

-- for scene.draw
local time = 0
scene.update = function(dt)
  time = time + dt
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

local tile = assets["tiles.water2"]
local tileW, tileH = 32, 16
local scale = 2
local getTile = function(x, y)
  local a = x/tileW
  local b = y/tileH
  local i = math.floor(a + b)
  local j = math.floor(a - b)
  return i, j
end
scene.draw = function()
  lg.clear(.1,.1,.1)
  lg.setColor(1,1,1)
  lg.push()
  lg.scale(scale)
  local shift = true
  for y = -tileH, math.ceil(lg.getHeight()/scale)*2, tileH/2 do
    shift = not shift
  for x = -tileW, math.ceil(lg.getWidth()/scale), tileW do
    tile:draw(tile.image, x + (shift and tileW/2 or 0), y+(math.sin(x+y+time)*4.5))
  end
  end
  lg.pop()
  suit:draw()
end

return scene