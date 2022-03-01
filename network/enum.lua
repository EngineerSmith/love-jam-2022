local enum = {
    disconnect = {
        normal      = 0,
        badconnect  = 1,
        badserver   = 2,
        badusername = 3,
        badlogin    = 4,
      },
    packetType = { -- must be 1 char in size
        receive           = 'r',
        disconnect        = 'd',
        confirmConnection = 'c',
        -- custom
        chatMessage       = 'm',
        -- world data
        playerPosition    = 'p',
        worldData         = 'w',
        foreignPlayers    = 'f',
        foreignDisconnect = 'g',
        placeTower        = 't',
        tileUpdate        = 'u',
      },
  }
  
enum.convert = function(value, enumType)
  local enums = enum[enumType]
  if not enums then return nil end
  for k, v in pairs(enums) do
    if v == value then
      return k
    end
  end
  return nil
end

return enum