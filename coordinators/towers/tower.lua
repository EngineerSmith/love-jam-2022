local tower = {}
tower.__index = tower

tower.new = function(wheelGraphic, price, health, canAttack, attackSpeed, damage)
  return setmetatable({
      wheel = wheelGraphic,
      price = price,
      health = health,
      canAttack = canAttack or false,
      attackSpeed = attackSpeed,
      damage = damage,
    }, tower)
end

tower.states = {
    none          =  0,
    up            =  1,
    right         =  2,
    upright       =  3,
    down          =  4,
    updown        =  5,
    rightdown     =  6,
    uprightdown   =  7,
    left          =  8,
    upleft        =  9,
    rightleft     = 10,
    uprightleft   = 11,
    downleft      = 12,
    updownleft    = 13,
    rightdownleft = 14,
    all           = 15,
  }

tower.setStateTexture = function(self, state, texture)
  if not self.textures then
    self.textures = {}
  end
  self.textures[state] = texture
end

local sortDamage = function(a, b)
  return a.state > b.state
end

tower.setDamageStateTexture = function(self, state, texture)
  if not self.damageStates then
    self.damageStates = {}
  end
  table.insert(self.damageStates, {texture = texture, state = state})
  table.sort(self.damageStates, sortDamage)
end

tower.hasState = function(self)
  return self.textures ~= nil
end

tower.getTexture = function(self, state, damagePercentage)
  if not state or not self.textures then
    return self.wheel
  end
  if state < 0 or state > 15 then
    error("Incorrect state for tower: "..state)
  end
  
  if self.damageStates and damagePercentage then
    for _, state in ipairs(self.damageStates) do
      if state.state > damagePercentage then
        return state.texture
      end
    end
  end
  
  return self.textures[state] or self.textures[tower.states.rightleft] or self.wheel
  
  
end

return tower