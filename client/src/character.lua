local character = {}
character.__index = character

local lg = love.graphics

local cdepthShader = lg.newShader("assets/shaders/characterDepth.glsl")

character.new = function(image)
  return setmetatable({
      image = image, -- TODO change to image set
    }, character)
end

character.getDimensions = function(self)
  return self.image:getDimensions()
end

character.draw = function(self, z)
  lg.push("all")
  lg.setDepthMode("lequal", true)
  lg.setShader(cdepthShader)
  cdepthShader:send("z", z)
  lg.draw(self.image)
  lg.setShader()
  lg.pop()
end

return character