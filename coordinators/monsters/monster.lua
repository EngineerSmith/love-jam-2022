local monster = {}
monster.__index = monster

monster.new = function(characterState)
  return setmetatable({
    characterState = characterState,
    }, monster)
end

return monster