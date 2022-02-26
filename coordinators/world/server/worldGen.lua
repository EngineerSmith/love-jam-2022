local noise = love.math.noise

local worldGen = function(width, height, seed)
  local world = {}
  for x=1, width do
    world[x] = {}
  for y=1, height do
    local nx = x / width - .5
    local ny = y / height - .5
    local d = math.sqrt(nx*nx+ny*ny)
    world[x][y] = { 
        height = (1+(noise(x*0.001, y*0.001, seed) * (noise(y, x)*0.01))-d)/2,
      }
  end
  end
  return world
end

return worldGen