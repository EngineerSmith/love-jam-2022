local settings = require("util.settings")
local assets = require("util.assets")
local suit = require("libs.suit").new()
local logger = require("util.logger")

local lg = love.graphics

local scene = { }
local disconnect
local dontConnect = 0

assets["audio.music.1"]:play()

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
  "DuckLover",
  "LittleJohn",
  "Richard",
  "AppleTea",
  "JellyBabies",
  "DigestiveB",
  "LostPanda",
  "LostWolf",
  "Glove",
  "Bot10101",
  "Israphel",
  "Dwarf",
  "Spaceman",
  "Yellow",
  "Steve",
  "Lilly",
  "Tata",
  "BlueTree",
  "DumbOne",
  "Missing",
  "Lewis",
  "Jaffa",
  "Dappy",
  "Drippy",
  "FastOne",
  "Mouse",
  "Socks",
  "BigToes",
  "Friend",
  "Peppa",
  "Jasmine",
  "GreenTea",
  "Purple",
  "Jigoku",
  "Flowers",
  "Bon",
  "Ben",
  "Johnny",
  "5Alive",
  "Batteries",
  "Oppa",
  "Chan",
}

local lowGraphics = { text = "Low Graphics", checked = settings.client.lowGraphics }
local fullscreen = { text = "Fullscreen", checked = settings.client.windowfullscreen }
local disableShaking = { text = "Disable Shaking", checked = settings.client.disableShaking}
local playerName = { text = names[love.math.random(1,#names)] }
local serverAddress = { text = "localhost:20202" }
local audio = { value=settings.client.volume, min=0, max=100, step=1 }

assets["audio.music.1"]:setVolume(audio.value/100)

scene.load = function(disconnectReason)
  disconnect = disconnectReason
  if disconnect then
    if disconnect == "normal" then
      dontConnect = 2
      disconnect = nil
    end
  end
end

local showSettings = false
local showGameMenu = false

-- for scene.draw
local time = 0
local below60, bonus = false, 0
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
        if dontConnect == 0 then
          --dontConnect = false
          if #playerName.text <= 12 then
            require("util.sceneManager").changeScene("client.game", playerName.text, serverAddress.text)
          end
        else
          dontConnect = dontConnect - 1
        end
      end
      if #playerName.text > 12 then
        suit:Input(playerName, {color={normal={fg={1,0,0}, bg={ .0000, .1568, .3490}}}}, suit.layout:up())
      else
        suit:Input(playerName, suit.layout:up())
      end
      if suit:Button("Regen name", suit.layout:left(125,30)).hit then
        playerName.text = names[love.math.random(1,#names)]
      end
      suit.layout:right(175,30)
      lg.setFont(assets["fonts.futile.24"])
      suit:Label("Player name", {align = "center"}, suit.layout:up())
      lg.setFont(assets["fonts.futile.18"])
      suit:Input(serverAddress, suit.layout:up())
      lg.setFont(assets["fonts.futile.24"])
      if suit:Button(#serverAddress.text == 0 and "Paste" or "Clear", suit.layout:left(125,30)).hit then
        if #serverAddress.text == 0 then
          serverAddress.text = love.system.getClipboardText()
        else
          serverAddress.text = ""
        end
      end
      suit.layout:right(175,30)
      suit:Label("Server IP", {align = "center"}, suit.layout:up())
      lg.setFont(assets["fonts.futile.18"])
    end
    if showSettings and not showGameMenu then
      if suit:Checkbox(lowGraphics, {align='right'}, suit.layout:up()).hit then
        settings.client.lowGraphics = lowGraphics.checked
      end
      if suit:Checkbox(fullscreen, {align="right"}, suit.layout:up()).hit then
        settings.client.windowfullscreen = fullscreen.checked
        love.window.setFullscreen(settings.client.windowfullscreen)
      end
      if suit:Checkbox(disableShaking, {align="right"}, suit.layout:up()).hit then
        settings.client.disableShaking = disableShaking.checked
      end
      if suit:Slider(audio, suit.layout:up()).changed then
        assets["audio.music.1"]:setVolume(audio.value/100)
        settings.client.volume = audio.value
      end
      suit:Label("Volume", {align="center"}, suit.layout:up())
    end
    suit.layout:reset(30, h-20)
    suit.layout:up(310,185)
    local str = " Controls\n  - WASD Movement\n  - Hold Right mouse for build wheel\n  - click to confirm placement\n  - Space bar to ready for wave\n  - Type \"disconnect\" to disconnect \tfrom server"
    suit:Label(str, {align="left"}, suit.layout:up())
    local str = " Make sure the program has access through your firewall for multiplayer"
    suit.layout:reset(w-lg.getFont():getWidth(str)-15, -5)
    suit:Label(str, {align="left"}, suit.layout:down(lg.getFont():getWidth(str)+10,30))
    if love.timer.getFPS() < 60 then
      below60 = true
      bonus = 0
    elseif below60 then
      bonus = bonus + 1
      below60 = not (bonus > 15)
    end
    if below60 then
      local str = " WARNING: Running below 60fps, use low graphics in settings for better performance"
      suit.layout:reset(w-lg.getFont():getWidth(str)-15, 40)
      suit:Label(str, {align="left"}, suit.layout:down(lg.getFont():getWidth(str)+10 ,30))
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
  lg.push()
  local w, h = assets["ui.logo"]:getDimensions()
  lg.translate(lg.getWidth()/2-w/2, lg.getHeight()/2-h*0.9)
  lg.draw(assets["ui.logo"])
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