local settings = require("util.settings")
local assets = require("util.assets")
local suit = require("libs.suit").new()

local lg = love.graphics
assets["fonts.futile.24"] = lg.newFont("assets/fonts/FutilePro.ttf", 24)
assets["fonts.futile.24"]:getFilter("nearest", "nearest")
assets["fonts.futile.18"] = lg.newFont("assets/fonts/FutilePro.ttf", 18)
assets["fonts.futile.18"]:getFilter("nearest", "nearest")
assets["fonts.futile.12"] = lg.newFont("assets/fonts/FutilePro.ttf", 12)
assets["fonts.futile.12"]:getFilter("nearest", "nearest")
lg.setFont(assets["fonts.futile.18"])

local scene = { }
local disconnect

scene.load = function(disconnectReason)
  disconnect = disconnectReason
end

local showSettings = false
local showGameMenu = false

local names = {
  "James",
  "Paul",
  "Chole",
  "Amy",
  "David",
  "Tommy",
  "Marty",
  "Mark",
  "Jamie",
  "Santa",
  "Batperson",
  "DuckLover999",
  "LittleJohn",
  "Richard",
  "AppleTea",
  "Celerations",
}

local lowGraphics = { text = "Low Graphics", checked = settings.client.lowGraphics }
local playerName = { text = names[love.math.random(1,#names)] }
local serverAddress = { text = "localhost:20202" }
-- for scene.draw
local time = 0
scene.update = function(dt)
  time = time + dt
  local w, h = lg.getDimensions()
  if not disconnect then
    suit.layout:reset(w-225, h-30)
    suit.layout:up(175,30)
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
        if #playerName.text <= 12 then
          require("util.sceneManager").changeScene("client.game", playerName.text, serverAddress.text)
        end
      end
      if #playerName.text > 12 then
        suit:Input(playerName, {color={normal={fg={1,0,0}, bg={ .0000, .1568, .3490}}}}, suit.layout:up())
      else
        suit:Input(playerName, suit.layout:up())
      end
      lg.setFont(assets["fonts.futile.24"])
      suit:Label("Player name", {align = "center"}, suit.layout:up())
      lg.setFont(assets["fonts.futile.18"])
      suit:Input(serverAddress, suit.layout:up())
      lg.setFont(assets["fonts.futile.24"])
      suit:Label("Server IP", {align = "center"}, suit.layout:up())
      lg.setFont(assets["fonts.futile.18"])
    end
    if showSettings and not showGameMenu then
      if suit:Checkbox(lowGraphics, {align='right'}, suit.layout:up()).hit then
        settings.client.lowGraphics = lowGraphics.checked
      end
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
  local w, h = assets["ui.main.duck"]:getDimensions()
  local x, y = (lg.getWidth()/scale/2), (lg.getHeight()/scale/1.5+h/2)
  local height = math.sin(x+y+time)*4.5
  local r = math.cos(x+y+time)*0.2
  lg.translate(x, y + height)
  lg.draw(assets["ui.main.duck"], 0, 0, r, 1,1, w/2, h)
  lg.pop()
  suit:draw()
end

scene.textedited = function(...)
  suit:textedited(...)
end

scene.textinput = function(...)
  suit:textinput(...)
end

scene.keypressed = function(...)
  suit:keypressed(...)
end

return scene