local sceneManager = {
  currentScene = nil,
  nilFunc = function() end,
  sceneHandlers = {
    -- GAME LOOP
    "load",
    "unload",
    "update",
    "updateNetwork",
    "draw",
    "quit",
    -- WINDOW
    "focus",
    "resize",
    "visable",
    "displayrotated",
    "filedropped",
    "directorydropped",
    -- TOUCH INPUT
    "touchpressed",
    "touchmoved",
    "touchreleased",
    -- MOUSE INPUT
    "mousepressed",
    "mousemoved",
    "mousereleased",
    "mousefocus",
    "wheelmoved",
    -- KEY INPUT,
    "keypressed",
    "keyreleased",
    "textinput",
    "textedited",
    -- JOYSTICK/GAMEPAD INPUT
    "joystickhat",
    "joystickaxis",
    "joystickpressed",
    "joystickreleased",
    "joystickadded",
    "joystickremoved",
    "gamepadpressed",
    "gamepadreleased",
    "gamepadaxis",
    -- ERROR
    "threaderror",
    "lowmemory",
  },
}

sceneManager.changeScene = function(scene, ...)
  scene = require(scene)
  if sceneManager.currentScene then
    love.unload()
  end
  for _, v in ipairs(sceneManager.sceneHandlers) do
    love[v] = scene[v] or sceneManager.nilFunc
  end
  sceneManager.currentScene = scene
  collectgarbage("collect")
  collectgarbage("collect")
  love.load(...)
end

return sceneManager