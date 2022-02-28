local args = require("util.args")
local sceneManager = require("util.sceneManager")
local logger = require("util.logger")
local settings = require("util.settings")

local flux = require("libs.flux")

local utf8 = require("utf8")
-- add utf8 len lib from lua lib
require("libs.utf8").len = utf8.len

local love = love
local le, lg, lt = love.event, love.graphics, love.timer

local processEvents = function()
  le.pump()
  for name, a,b,c,d,e,f,g,h,i,j,k in le.poll() do
    if name == "quit" then
      if not love.quit or not love.quit() then
        return a or 0
      end
    end
    love.handlers[name](a,b,c,d,e,f,g,h,i,j,k)
  end
end

local min, max = math.min, math.max
local clamp = function(target, minimum, maximum)
  return min(max(target, minimum), maximum)
end

-- https://gist.github.com/1bardesign/3ed0fabfdcd2661d3308b4da7fa3076d
local manualGC = function(timeBudget, safetyNetMB)
  local limit, steps = 1000, 0
  local start = lt.getTime()
  while lt.getTime() - start < timeBudget and steps < limit do
    collectgarbage("step", 1)
    steps = steps + 1
  end
  if collectgarbage("count") / 1024 > safetyNetMB then
    collectgarbage("collect")
  end
end

love.run = function()
  if args["-server"] then
    logger.info("Creating server gameloop")
    local port = args["-port"] or settings.server.port or settings._default.server.port
    sceneManager.changeScene("server", port)
    local networkDelt = 0
    lt.step()
    return function()
      local quit = processEvents()
      if quit then return quit end
      love.update()
      networkDelt = networkDelt + lt.step()
      if networkDelt > 1/10 then
        love.updateNetwork()
        networkDelt = 0
      end
      manualGC(1e-3, 128)
      lt.sleep(1e-5)
    end
  else -- love.run taken from feris 
    logger.info("Creating client gameloop")
    sceneManager.changeScene("client")
    local frameTime, fuzzyTime = 1/60, {1/2,1,2}
    local networkTick = 1/10
    local updateDelta, networkDelta = 0, 0
    local updatableAssets = require("util.assets").updateTable
    lt.step()
    return function()
      local quit = processEvents()
      if quit then return quit end
      
      local dt = love.timer.step()
      -- fuzzy timing snapping
      for _, v in ipairs(fuzzyTime) do
        v = frameTime * v
        if math.abs(dt - v) < 0.002 then
          dt = v
        end
      end
      -- dt clamping
      dt = clamp(dt, 0, 2*frameTime)
      updateDelta = updateDelta + dt
      networkDelta = networkDelta + dt
      -- frameTimer clamping
      updateDelta = clamp(updateDelta, 0, 8*frameTime)
      networkDelta = clamp(networkDelta, 0, 8*frameTime)
      
      local ticked = false
      while updateDelta > frameTime do
        updateDelta = updateDelta - frameTime
        -- libraries
        flux.update(frameTime)
        for _, tbl in ipairs(updatableAssets) do
          tbl:update(frameTime)
        end
        
        love.update(frameTime) -- constant

        ticked = true
      end
      
      if networkDelta > networkTick then
        networkDelta = 0
        love.updateNetwork()
      end
      
      if ticked then
        love.draw()
        lg.present()
      end
      -- Clean up garbage 
      manualGC(1e-3, 128)
      lt.sleep(1e-3)
    end
  end
end

-- ERROR HANDLER
-- Changed to output errors to log

local function error_printer(message, layer)
	return debug.traceback(tostring(message), 1+(layer or 1)):gsub("\n[^\n]+$", "")
end

function love.errorhandler(msg)
	msg = tostring(msg)
  -- [[ EDIT ]]
  logger.fatal(nil, error_printer(msg, 2))
  -- [[/EDIT ]]
	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end

