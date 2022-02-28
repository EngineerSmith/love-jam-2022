local characterState = {}
characterState.__index = characterState

local lg = love.graphics
local insert = table.insert

--[[
  - FL; Front left
  - FR; Front right
  - BL; Back left
  - BR; Back right
]]
local states = {
    ["standing.FL"] = true,
    ["standing.FR"] = true,
    ["standing.BL"] = true,
    ["standing.BR"] = true,
    ["walking.FL"]  = true,
    ["walking.FR"]  = true,
    ["walking.BL"]  = true,
    ["walking.BR"]  = true,
  }
  
local getOppositeState = function(state)
  if type(state) == "string" and states[state] then
    local char = state:sub(#state, #state)
    if char == "L" then
      char = "R"
    elseif char == "R" then
      char = "L"
    end
    return state:sub(1,#state-1)..char
  end
  return nil
end

characterState.new = function(id)
  local self = setmetatable({ id = id }, characterState)
  for state, _ in pairs(states) do
    self[state] = {}
  end
  return self
end

-- Currently only supports first image given to a state
characterState.addImage = function(self, state, image)
  if not states[state] then
    error(tostring(state).." is an invalid state")
  end
  insert(self[state], image)
end

characterState.getImage = function(self, state)
  if not states[state] then
    error(tostring(state).." is an invalid state")
  end
  if #self[state] > 0 then
    return true, self[state][1]
  else
    local oppState = getOppositeState(state)
    if #self[oppState] > 0 then
      return false, self[oppState][1]
    end
  end
  return false, nil
end

characterState.getDimensions = function(self, state)
  local _, image = self:getImage(state)
  if image then
    return image:getDimensions()
  end
  return 0,0
end

characterState.draw = function(self, state)
  local success, image = self:getImage(state)
  if success then
    if type(image) == "table" then
      image:draw(image.image)
    else
      lg.draw(image)
    end
  elseif not success and image then
    local w,h = image:getDimensions()
    if type(image) == "table" then
      image:draw(image.image, 0,0, 0, -1,1, w,0)
    else
      lg.draw(image, 0,0, 0, -1,1, w,0)
    end
  end
end

return characterState