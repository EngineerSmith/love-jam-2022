local character = {}
character.__index = character

local lg = love.graphics

local cdepthShader = lg.newShader("assets/shaders/characterDepth.glsl")

character.new = function(characterState)
  return setmetatable({
      characterState = characterState,
      facing = "FR",
      state = "standing",
    }, character)
end

character.getDimensions = function(self)
  return self.characterState:getDimensions(self.state.."."..self.facing)
end

local directions = {
  ["FL"] = true, ["FR"] = true,
  ["BL"] = true, ["BR"] = true,
}

character.setDirection = function(self, direction)
  self.facing = directions[direction] and direction or error(tostring(direction).." is an invalid direction")
end

local states = {
    ["standing"] = true,
    ["walking"]  = true,
  }

character.setState = function(self, state)
  self.state = states[state] and state or error(tostring(state).." is an invalid state")
end

character.draw = function(self, z)
  lg.push("all")
  lg.setDepthMode("lequal", true)
  lg.setShader(cdepthShader)
  cdepthShader:send("z", z)
  self.characterState:draw(self.state.."."..self.facing)
  lg.setShader()
  lg.pop()
end

return character